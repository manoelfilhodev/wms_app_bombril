import 'package:flutter/material.dart';

import 'inventario_ciclico_service.dart';
import 'models/inventario_ciclico_item.dart';

class InventarioCiclicoItensPage extends StatefulWidget {
  final int idInventario;

  const InventarioCiclicoItensPage({super.key, required this.idInventario});

  @override
  State<InventarioCiclicoItensPage> createState() =>
      _InventarioCiclicoItensPageState();
}

class _InventarioCiclicoItensPageState
    extends State<InventarioCiclicoItensPage> {
  final InventarioCiclicoService _service = InventarioCiclicoService();
  late Future<Map<String, dynamic>> _futureItens;

  @override
  void initState() {
    super.initState();
    _futureItens = _service.getItens(widget.idInventario);
  }

  void _reload() {
    setState(() {
      _futureItens = _service.getItens(widget.idInventario);
    });
  }

  Future<void> _refresh() async {
    _reload();
    await _futureItens;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Contagem Cíclica'), centerTitle: false),
      body: Padding(
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
            child: FutureBuilder<Map<String, dynamic>>(
              future: _futureItens,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }

                if (snapshot.hasError) {
                  return _FeedbackContent(
                    icon: Icons.error_outline,
                    message: 'Erro ao carregar os itens do inventário.',
                    actionLabel: 'Tentar novamente',
                    onTap: _reload,
                  );
                }

                final itens = _extractItens(snapshot.data ?? const {});
                if (itens.isEmpty) {
                  return _FeedbackContent(
                    icon: Icons.inventory_2_outlined,
                    message: 'Nenhum item encontrado para esta requisição.',
                    actionLabel: 'Atualizar',
                    onTap: _reload,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Dados da Contagem',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF9FA8DA),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: itens.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = itens[index];
                            final precisaAjuste = item.necessitaAjuste == 1;

                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white.withValues(alpha: 0.04),
                                border: Border.all(
                                  color: precisaAjuste
                                      ? Colors.red.shade400
                                      : Colors.white.withValues(alpha: 0.14),
                                  width: 1.2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _lineLabel(
                                      title: 'SKU',
                                      value: item.material ?? '-',
                                    ),
                                    const SizedBox(height: 6),
                                    _lineLabel(
                                      title: 'Descrição',
                                      value: item.descricao ?? '-',
                                    ),
                                    const SizedBox(height: 6),
                                    _lineLabel(
                                      title: 'Posição',
                                      value: item.posicao ?? '-',
                                    ),
                                    const SizedBox(height: 6),
                                    _lineLabel(
                                      title: 'Quantidade Sistema',
                                      value: _formatNumber(
                                        item.quantidadeSistema,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    _lineLabel(
                                      title: 'Quantidade Física',
                                      value: item.quantidadeFisica == null
                                          ? '-'
                                          : _formatNumber(
                                              item.quantidadeFisica!,
                                            ),
                                    ),
                                    if (precisaAjuste) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Item com necessidade de ajuste.',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: Colors.red.shade300,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                    if (item.quantidadeFisica == null) ...[
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton.icon(
                                          onPressed: () =>
                                              _abrirDialogContagem(item),
                                          icon: const Icon(
                                            Icons.edit_note_rounded,
                                          ),
                                          label: const Text('Contar'),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      label: const Text('Voltar'),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Powered by Laravel API • Systex Infra Azure',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _lineLabel({required String title, required String value}) {
    return Text(
      '$title: $value',
      style: const TextStyle(color: Colors.white, fontSize: 14),
    );
  }

  List<InventarioCiclicoItem> _extractItens(Map<String, dynamic> data) {
    final candidates = <dynamic>[data['itens'], data['items'], data['data']];

    for (final candidate in candidates) {
      final lista = _mapList(candidate);
      if (lista.isNotEmpty) {
        return lista.map(InventarioCiclicoItem.fromJson).toList();
      }
    }

    final fallback = _mapList(data);
    if (fallback.isNotEmpty) {
      return fallback.map(InventarioCiclicoItem.fromJson).toList();
    }

    return const [];
  }

  List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (value is Map) {
      final normalized = Map<String, dynamic>.from(value);
      final nested =
          normalized['data'] ?? normalized['itens'] ?? normalized['items'];
      if (nested != null) return _mapList(nested);

      if (normalized.containsKey('id_item') ||
          normalized.containsKey('item_id') ||
          normalized.containsKey('idItem')) {
        return [normalized];
      }
    }

    return const [];
  }

  String _formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }

    var text = value.toStringAsFixed(4);
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
    return text;
  }

  Future<void> _abrirDialogContagem(InventarioCiclicoItem item) async {
    final formKey = GlobalKey<FormState>();
    final quantidadeController = TextEditingController();
    final posicaoController = TextEditingController(text: item.posicao ?? '');
    bool salvando = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Contar item'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('SKU: ${item.material ?? '-'}'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: quantidadeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Quantidade Física',
                      ),
                      validator: (value) {
                        final raw = value?.trim() ?? '';
                        if (raw.isEmpty) return 'Informe a quantidade física.';

                        final numero = double.tryParse(
                          raw.replaceAll(',', '.'),
                        );
                        if (numero == null) return 'Informe um número válido.';
                        if (numero < 0) {
                          return 'A quantidade não pode ser negativa.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: posicaoController,
                      decoration: const InputDecoration(
                        labelText: 'Posição (opcional)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: salvando
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: salvando
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }

                          final quantidade = double.parse(
                            quantidadeController.text.trim().replaceAll(
                              ',',
                              '.',
                            ),
                          );

                          final messenger = ScaffoldMessenger.of(this.context);
                          setDialogState(() => salvando = true);

                          try {
                            await _service.contarItem(
                              idItem: item.idItem,
                              quantidadeFisica: quantidade,
                              posicao: posicaoController.text.trim().isEmpty
                                  ? null
                                  : posicaoController.text.trim(),
                            );

                            if (!mounted || !dialogContext.mounted) return;

                            Navigator.pop(dialogContext);
                            _reload();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Contagem salva com sucesso.'),
                              ),
                            );
                          } catch (_) {
                            if (!mounted) return;

                            setDialogState(() => salvando = false);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Não foi possível salvar a contagem.',
                                ),
                              ),
                            );
                          }
                        },
                  child: salvando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    quantidadeController.dispose();
    posicaoController.dispose();
  }
}

class _FeedbackContent extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onTap;

  const _FeedbackContent({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: Colors.white70),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.refresh),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
