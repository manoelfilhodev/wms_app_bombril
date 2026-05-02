import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../../core/app_theme.dart';
import '../../core/widgets/systex_glass_card.dart';
import '../../core/widgets/systex_scaffold.dart';
import '../../repositories/kits_repository.dart';
import '../../utils/notifier.dart';

class ApontamentoKitsPage extends StatefulWidget {
  const ApontamentoKitsPage({super.key});

  @override
  State<ApontamentoKitsPage> createState() => _ApontamentoKitsPageState();
}

class _ApontamentoKitsPageState extends State<ApontamentoKitsPage> {
  final _paleteUidController = TextEditingController();
  final _paleteUidFocus = FocusNode();
  final _kitsRepository = KitsRepository();

  bool _isApontando = false;
  String? _feedbackMessage;
  Color? _feedbackColor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _paleteUidFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _paleteUidController.dispose();
    _paleteUidFocus.dispose();
    super.dispose();
  }

  Future<void> _apontar() async {
    final paleteUid = _paleteUidController.text.trim();
    if (paleteUid.isEmpty) {
      _feedbackError();
      _toast('Digite o código do palete');
      return;
    }

    setState(() => _isApontando = true);

    try {
      await _kitsRepository.apontar(paleteUid: paleteUid);
      _paleteUidController.clear();
      _feedbackSuccess();
      _showSuccessAuto('Palete apontado com sucesso');
    } catch (e) {
      _feedbackError();
      _toast(_extractErrorMessage(e));
    } finally {
      setState(() => _isApontando = false);
      _paleteUidFocus.requestFocus();
    }
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

  void _feedbackSuccess() {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
  }

  void _feedbackError() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
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

  String _extractErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return SystexScaffold(
      title: 'APONTAMENTO DE KITS',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_feedbackMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _feedbackColor?.withOpacity(0.14),
                border: Border.all(color: _feedbackColor ?? SystexColors.textSecondary),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    _feedbackColor == SystexColors.success ? Icons.check_circle : Icons.error_outline,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                  'Foco automático. Leitura processada ao enviar.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SystexColors.textSecondary,
                        fontSize: 14,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _paleteUidController,
                  focusNode: _paleteUidFocus,
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
                      RegExp(r'[A-Z0-9\-_\.]'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _isApontando ? null : _apontar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SystexColors.brandRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isApontando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'APONTAR',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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