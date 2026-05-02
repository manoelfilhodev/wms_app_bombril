import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_config.dart';
import '../../database/local_database_service.dart';
import '../../services/connectivity_service.dart';
import '../../sync/sync_service.dart';
import '../../core/app_theme.dart';

class ContagemLivrePage extends StatefulWidget {
  const ContagemLivrePage({super.key});

  @override
  State<ContagemLivrePage> createState() => _ContagemLivrePageState();
}

class _ContagemLivrePageState extends State<ContagemLivrePage> {
  static const String _webPendingKey = 'contagem_livre_web_pending';

  final TextEditingController posicaoController = TextEditingController();
  final TextEditingController eanController = TextEditingController();
  final TextEditingController quantidadeController = TextEditingController();

  final FocusNode posicaoFocus = FocusNode();
  final FocusNode eanFocus = FocusNode();
  final FocusNode quantidadeFocus = FocusNode();

  String infoProduto = '';
  String? sku;
  bool infoIsWarning = false;
  bool carregando = false;
  int pendentesSync = 0;
  int? usuarioId;
  String? _feedbackMessage;
  Color? _feedbackColor;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
    _refreshPendingCount();
    _syncWebPendingIfOnline();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(posicaoFocus);
      }
    });
  }

  Future<void> _carregarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      usuarioId = prefs.getInt('usuario_id');
    });
  }

  Future<void> _refreshPendingCount() async {
    int total = 0;
    if (kIsWeb) {
      total = (await _loadWebPending()).length;
    } else {
      total = await LocalDatabaseService.instance.getPendingSyncCount(
        entityType: 'contagem_livre',
      );
    }
    if (!mounted) return;
    setState(() => pendentesSync = total);
  }

  Future<void> buscarDescricao(String ean) async {
    final normalized = ean.trim();
    if (normalized.isEmpty) return;

    if (!ConnectivityService.instance.isOnline) {
      await _tryLoadFromCache(
        normalized,
        defaultMessage: 'Modo offline: produto sera validado na sincronizacao.',
        warning: true,
      );
      return;
    }

    try {
      final uri = AppConfig.apiUri(
        '/contagem-livre/buscarDescricaoApi',
        queryParameters: {'ean': normalized},
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final produto = data['data'];
          final foundSku = produto['sku']?.toString();
          final descricao = produto['descricao']?.toString() ?? '';

          if (foundSku != null && foundSku.isNotEmpty) {
            setState(() {
              sku = foundSku;
              infoProduto = '$foundSku - $descricao';
              infoIsWarning = false;
            });

            if (!kIsWeb) {
              await LocalDatabaseService.instance.cacheEan(
                ean: normalized,
                sku: foundSku,
                descricao: descricao,
              );
            }
            return;
          }
        }
      }

      await _tryLoadFromCache(
        normalized,
        defaultMessage: 'Produto nao encontrado.',
        warning: true,
      );
    } catch (_) {
      await _tryLoadFromCache(
        normalized,
        defaultMessage: 'Modo offline: produto sera validado na sincronizacao.',
        warning: true,
      );
    }
  }

  Future<void> _tryLoadFromCache(
    String ean, {
    required String defaultMessage,
    bool warning = false,
  }) async {
    if (kIsWeb) {
      _resetProduto(defaultMessage, warning: warning);
      return;
    }

    final cached = await LocalDatabaseService.instance.findCachedEan(ean);
    if (cached != null) {
      final cachedSku = cached['sku']?.toString() ?? '';
      final descricao = cached['descricao']?.toString() ?? '';

      if (!mounted) return;
      setState(() {
        sku = cachedSku;
        infoProduto = '$cachedSku - $descricao (cache offline)';
        infoIsWarning = false;
      });
      return;
    }

    _resetProduto(defaultMessage, warning: warning);
  }

  Future<void> salvarContagem() async {
    final posicao = posicaoController.text.trim();
    final ean = eanController.text.trim();
    final quantidade = quantidadeController.text.trim();

    if (posicao.isEmpty || ean.isEmpty || quantidade.isEmpty) {
      _feedbackError();
      _toast('Preencha todos os campos.');
      return;
    }

    final qtd = int.tryParse(quantidade) ?? 0;
    if (qtd <= 0) {
      _feedbackError();
      _toast('Quantidade invalida.');
      return;
    }

    if (usuarioId == null) {
      _feedbackError();
      _toast('Usuario nao identificado.');
      return;
    }

    if (sku == null || sku!.isEmpty) {
      await buscarDescricao(ean);
      if (sku == null || sku!.isEmpty) {
        await _saveOfflinePending(
          contadoPor: usuarioId!,
          sku: null,
          ean: ean,
          ficha: posicao,
          quantidade: qtd,
          dataHoraIso: DateTime.now().toIso8601String(),
        );
        return;
      }
    }

    setState(() => carregando = true);

    final dataHora = DateTime.now().toIso8601String();
    final payload = {
      'contado_por': usuarioId,
      'sku': sku,
      'ficha': posicao,
      'quantidade': qtd,
      'data_hora': dataHora,
    };

    try {
      final uri = AppConfig.apiUri('/contagem-livre/store');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        _feedbackSuccess();
        _showSuccessAuto('Contagem salva.');
        _resetCampos(keepPosicao: false);
        await _syncWebPendingIfOnline();
        await _refreshPendingCount();
      } else {
        await _saveOfflinePending(
          contadoPor: usuarioId!,
          sku: sku,
          ean: ean,
          ficha: posicao,
          quantidade: qtd,
          dataHoraIso: dataHora,
        );
      }
    } catch (_) {
      await _saveOfflinePending(
        contadoPor: usuarioId!,
        sku: sku,
        ean: ean,
        ficha: posicao,
        quantidade: qtd,
        dataHoraIso: dataHora,
      );
    }

    if (mounted) {
      setState(() => carregando = false);
    }
  }

  Future<void> _saveOfflinePending({
    required int contadoPor,
    required String? sku,
    required String ean,
    required String ficha,
    required int quantidade,
    required String dataHoraIso,
  }) async {
    if (kIsWeb) {
      await _saveWebPending({
        'contado_por': contadoPor,
        'sku': (sku != null && sku.trim().isNotEmpty)
            ? sku.trim()
            : '__EAN_PENDING__:$ean',
        'ean': ean,
        'ficha': ficha,
        'quantidade': quantidade,
        'data_hora': dataHoraIso,
      });

      await _refreshPendingCount();
      _feedbackSuccess();
      _showSuccessAuto(
        'Sem conexao. Contagem salva localmente e sera sincronizada.',
      );
      _resetCampos(keepPosicao: false);
      return;
    }

    await LocalDatabaseService.instance.saveContagemLivrePending(
      contadoPor: contadoPor,
      sku: sku,
      ean: ean,
      ficha: ficha,
      quantidade: quantidade,
      dataHoraIso: dataHoraIso,
    );

    await _refreshPendingCount();

    _feedbackSuccess();
    _showSuccessAuto(
      sku == null || sku.trim().isEmpty
          ? 'Sem conexao. Contagem salva pendente de validacao de EAN.'
          : 'Sem conexao. Contagem salva localmente e sera sincronizada.',
    );
    _resetCampos(keepPosicao: false);

    if (ConnectivityService.instance.isOnline) {
      await SyncService.instance.runAutoSync();
    }
  }

  Future<List<Map<String, dynamic>>> _loadWebPending() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_webPendingKey) ?? const [];
    return raw
        .map((e) => jsonDecode(e))
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> _saveWebPending(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_webPendingKey) ?? <String>[];
    current.add(jsonEncode(payload));
    await prefs.setStringList(_webPendingKey, current);
  }

  Future<void> _syncWebPendingIfOnline() async {
    if (!kIsWeb || !ConnectivityService.instance.isOnline) return;

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_webPendingKey) ?? <String>[];
    if (current.isEmpty) return;

    final remaining = <String>[];

    for (final item in current) {
      try {
        final payload = Map<String, dynamic>.from(jsonDecode(item) as Map);
        final uri = AppConfig.apiUri('/contagem-livre/store');
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode != 200) {
          remaining.add(item);
        }
      } catch (_) {
        remaining.add(item);
      }
    }

    await prefs.setStringList(_webPendingKey, remaining);
    await _refreshPendingCount();
  }

  void _resetProduto(String mensagem, {bool warning = false}) {
    if (!mounted) return;
    setState(() {
      sku = null;
      infoProduto = mensagem;
      infoIsWarning = warning;
    });
  }

  void _resetCampos({bool keepPosicao = true}) {
    if (!keepPosicao) {
      posicaoController.clear();
    }

    eanController.clear();
    quantidadeController.clear();

    setState(() {
      infoProduto = '';
      sku = null;
      infoIsWarning = false;
      _feedbackMessage = null;
      _feedbackColor = null;
    });

    posicaoFocus.requestFocus();
  }

  void _feedbackSuccess() {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
  }

  void _feedbackError() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
  }

  void _showFeedback(String message, {required bool isSuccess}) {
    if (!mounted) return;
    setState(() {
      _feedbackMessage = message;
      _feedbackColor =
          isSuccess ? SystexColors.success : SystexColors.brandRed;
    });
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1100),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showSuccessAuto(String message) {
    if (!mounted) return;

    _showFeedback(message, isSuccess: true);

    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'Sucesso',
      desc: message,
      autoHide: const Duration(milliseconds: 1100),
      dismissOnTouchOutside: true,
      dismissOnBackKeyPress: true,
      showCloseIcon: false,
    ).show();
  }

  @override
  void dispose() {
    posicaoController.dispose();
    eanController.dispose();
    quantidadeController.dispose();
    posicaoFocus.dispose();
    eanFocus.dispose();
    quantidadeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Contagem Livre'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF404954),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                offset: const Offset(0, 6),
                blurRadius: 16,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Dados da Contagem',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF9FA8DA),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!kIsWeb) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Pendentes de sincronizacao: $pendentesSync',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: pendentesSync > 0
                          ? Colors.amber.shade300
                          : theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                TextField(
                  controller: posicaoController,
                  focusNode: posicaoFocus,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Posicao',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  onSubmitted: (_) => eanFocus.requestFocus(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: eanController,
                  focusNode: eanFocus,
                  decoration: const InputDecoration(
                    labelText: 'EAN',
                    prefixIcon: Icon(Icons.qr_code_2_outlined),
                  ),
                  onSubmitted: (value) async {
                    await buscarDescricao(value);
                    quantidadeFocus.requestFocus();
                  },
                ),
                const SizedBox(height: 8),
                if (infoProduto.isNotEmpty)
                  Text(
                    infoProduto,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: infoIsWarning
                          ? Colors.amber.shade300
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantidadeController,
                  focusNode: quantidadeFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade',
                    prefixIcon: Icon(Icons.numbers_rounded),
                  ),
                  onSubmitted: (_) => salvarContagem(),
                  onEditingComplete: salvarContagem,
                ),
                const SizedBox(height: 24),
                carregando
                    ? const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : ElevatedButton.icon(
                        onPressed: salvarContagem,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Salvar Contagem'),
                      ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  label: const Text('Voltar'),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'Powered by Laravel API - Systex Infra Azure',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.7,
                      ),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
