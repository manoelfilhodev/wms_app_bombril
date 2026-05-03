import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_theme.dart';
import '../../core/widgets/systex_glass_card.dart';
import '../../core/widgets/systex_scaffold.dart';
import '../../services/api_service.dart';
import '../../services/device_identity_service.dart';

class ApontamentoPaletesPage extends StatefulWidget {
  const ApontamentoPaletesPage({super.key});

  @override
  State<ApontamentoPaletesPage> createState() => _ApontamentoPaletesPageState();
}

class _ApontamentoPaletesPageState extends State<ApontamentoPaletesPage> {
  static const _appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0+1',
  );

  final _paleteController = TextEditingController();
  final _paleteFocus = FocusNode();
  final _apiService = ApiService.instance;
  final _deviceIdentityService = DeviceIdentityService.instance;

  bool _isApontando = false;
  String? _feedbackMessage;
  Color? _feedbackColor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _paleteFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _paleteController.dispose();
    _paleteFocus.dispose();
    super.dispose();
  }

  Future<void> _apontar() async {
    final codigoPalete = _normalizarPalete(_paleteController.text);
    if (codigoPalete.isEmpty) {
      _feedbackError();
      _toast('Digite ou escaneie o palete');
      return;
    }

    setState(() => _isApontando = true);

    try {
      await _registrarApontamento(codigoPalete);
      _paleteController.clear();
      _feedbackSuccess();
      _showFeedback(
        'Palete apontado com sucesso.',
        isSuccess: true,
      );
      _showSuccessAuto('Palete apontado com sucesso.');
    } catch (e) {
      _feedbackError();
      _showErrorDialog(_extractErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => _isApontando = false);
        _paleteFocus.requestFocus();
      }
    }
  }

  Future<void> _registrarApontamento(String codigoPalete) async {
    if (codigoPalete.isEmpty) {
      throw Exception('Palete invalido');
    }

    final payload = {
      'palete_codigo': codigoPalete,
      'origem': 'APP',
      'device_id': await _getDeviceId(),
      'app_version': _appVersion,
      'client_uuid': _generateClientUuid(),
      'apontado_em_app': DateTime.now().toIso8601String(),
      'observacao': null,
    };

    final response = await _apiService.apontarPaleteStretch(payload);
    final success = response['success'] == true ||
        response['status'] == 'ok' ||
        response['status'] == 'success';

    if (success) return;

    final statusCode = _toInt(response['status_code']);
    if (statusCode == 401) {
      await _handleUnauthorized();
      throw Exception('Sessao expirada. Faca login novamente.');
    }
    if (statusCode == 409 || statusCode == 422) {
      throw Exception(
        _resolveDuplicateMessage(response['message']),
      );
    }
    if (statusCode == 404) {
      throw Exception('Endpoint de apontamento Stretch ainda nao publicado.');
    }

    throw Exception(
      response['message']?.toString().trim().isNotEmpty == true
          ? response['message'].toString()
          : 'Nao foi possivel apontar o palete.',
    );
  }

  String _normalizarPalete(String value) {
    return value.trim().toUpperCase();
  }

  Future<String> _getDeviceId() async {
    return _deviceIdentityService.getOrCreateDeviceId();
  }

  String _generateClientUuid() {
    final random = Random();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  Future<void> _handleUnauthorized() async {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  String _resolveDuplicateMessage(dynamic message) {
    final resolved = message?.toString().trim();
    if (resolved == null || resolved.isEmpty) {
      return 'Este palete ja possui apontamento de Stretch ativo.';
    }

    final normalized = resolved.toLowerCase();
    if (normalized.contains('ja') ||
        normalized.contains('já') ||
        normalized.contains('duplic') ||
        normalized.contains('existe') ||
        normalized.contains('apontado')) {
      return 'Este palete ja possui apontamento de Stretch ativo.';
    }

    return resolved;
  }

  void _showFeedback(String message, {required bool isSuccess}) {
    setState(() {
      _feedbackMessage = message;
      _feedbackColor = isSuccess ? SystexColors.success : SystexColors.brandRed;
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

  void _showErrorDialog(String message) {
    if (!mounted) return;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Atencao',
      desc: message,
      btnOkText: 'OK',
      btnOkOnPress: () {
        _paleteFocus.requestFocus();
      },
    ).show();
  }

  void _feedbackSuccess() {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
  }

  void _feedbackError() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
  }

  String _extractErrorMessage(Object error) {
    if (error is DioException && error.response?.statusCode == 401) {
      _handleUnauthorized();
      return 'Sessao expirada. Faca login novamente.';
    }

    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    }

    final message = error.toString();
    if (message.contains('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return SystexScaffold(
      title: 'APONTAR PALETE COM STRETCH',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_feedbackMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _feedbackColor?.withValues(alpha: 0.14),
                border: Border.all(
                  color: _feedbackColor ?? SystexColors.textSecondary,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    _feedbackColor == SystexColors.success
                        ? Icons.check_circle
                        : Icons.error_outline,
                    color: _feedbackColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _feedbackMessage!,
                      style: TextStyle(
                        color: _feedbackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SystexGlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Escaneie o palete',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Foco automatico. Leitura processada ao apontar.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SystexColors.textSecondary,
                        fontSize: 14,
                      ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _paleteController,
                  focusNode: _paleteFocus,
                  autofocus: true,
                  style: const TextStyle(fontSize: 20, letterSpacing: 1.1),
                  decoration: const InputDecoration(
                    labelText: 'Palete / QR Code',
                    hintText: 'Escaneie aqui',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => _apontar(),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[A-Za-z0-9\-_\.]'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 64,
                  child: ElevatedButton.icon(
                    onPressed: _isApontando ? null : _apontar,
                    icon: _isApontando
                        ? const SizedBox.shrink()
                        : const Icon(Icons.check_circle_outline),
                    label: _isApontando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'APONTAR',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SystexColors.brandRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
