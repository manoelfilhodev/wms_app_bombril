import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_theme.dart';
import '../../../core/widgets/systex_glass_card.dart';
import '../../../core/widgets/systex_scaffold.dart';

class ConferenciaPage extends StatefulWidget {
  const ConferenciaPage({super.key});

  @override
  State<ConferenciaPage> createState() => _ConferenciaPageState();
}

class _ConferenciaPageState extends State<ConferenciaPage> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _skuController = TextEditingController();
  final _qtdController = TextEditingController();
  final _idFocus = FocusNode();
  final _skuFocus = FocusNode();
  final _qtdFocus = FocusNode();

  bool _isSaving = false;
  String? _feedbackMessage;
  Color? _feedbackColor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _idFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _skuController.dispose();
    _qtdController.dispose();
    _idFocus.dispose();
    _skuFocus.dispose();
    _qtdFocus.dispose();
    super.dispose();
  }

  Future<void> _salvarConferencia() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _feedbackMessage = null;
    });

    try {
      // TODO: integrar service real
      await Future.delayed(const Duration(seconds: 1)); // Simulação

      _idController.clear();
      _skuController.clear();
      _qtdController.clear();
      _showFeedback('Conferência salva com sucesso', isSuccess: true);
      _idFocus.requestFocus();
    } catch (e) {
      _showFeedback('Erro ao salvar conferência', isSuccess: false);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showFeedback(String message, {required bool isSuccess}) {
    setState(() {
      _feedbackMessage = message;
      _feedbackColor = isSuccess ? SystexColors.success : SystexColors.brandRed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SystexScaffold(
      title: 'CONFERÊNCIA DE RECEBIMENTO',
      actions: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: SystexColors.brandRed),
          tooltip: 'Voltar',
        ),
      ],
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Dados da conferência',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escaneie os códigos sequencialmente',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SystexColors.textSecondary,
                          fontSize: 14,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _idController,
                    focusNode: _idFocus,
                    autofocus: true,
                    style: const TextStyle(fontSize: 20, letterSpacing: 1.1),
                    decoration: const InputDecoration(
                      labelText: 'Recebimento / NF',
                      hintText: 'Escaneie o ID',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _skuFocus.requestFocus(),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Digite o ID do recebimento' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _skuController,
                    focusNode: _skuFocus,
                    style: const TextStyle(fontSize: 20, letterSpacing: 1.1),
                    decoration: const InputDecoration(
                      labelText: 'SKU / EAN',
                      hintText: 'Escaneie o produto',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _qtdFocus.requestFocus(),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Digite o código do produto' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _qtdController,
                    focusNode: _qtdFocus,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 20, letterSpacing: 1.1),
                    decoration: const InputDecoration(
                      labelText: 'Quantidade',
                      hintText: 'Digite a quantidade',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.go,
                    onFieldSubmitted: (_) => _salvarConferencia(),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Digite a quantidade' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _salvarConferencia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SystexColors.brandRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'SALVAR CONFERÊNCIA',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Powered by Laravel API • Systex Infra Azure',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SystexColors.textSecondary,
                    fontSize: 12,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
