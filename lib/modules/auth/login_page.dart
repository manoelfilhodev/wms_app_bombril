import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wms_app/core/app_theme.dart';
import 'package:wms_app/core/exceptions/auth_exception.dart';
import 'package:wms_app/core/widgets/systex_glass_card.dart';
import 'package:wms_app/core/widgets/systex_scaffold.dart';
import 'package:wms_app/services/offline_auth_service.dart';
import 'package:wms_app/utils/notifier.dart';
import 'package:wms_app/utils/user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _userFocus = FocusNode();
  final _passFocus = FocusNode();
  final OfflineAuthService _authService = OfflineAuthService();

  bool _loading = false;
  bool _obscurePass = true;
  String? _feedbackMessage;
  Color? _feedbackColor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    _userFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _feedbackMessage = null;
    });

    try {
      final result = await _authService.login(
        username: _userController.text.trim(),
        password: _passController.text.trim(),
      );

      final user = result.user;

      await UserService.saveUser(
        token: result.token,
        id: _toInt(user['id_user'] ?? user['id']),
        nome: user['nome']?.toString() ?? '',
        nivel: user['nivel']?.toString() ?? '',
        tipo: user['tipo']?.toString() ?? '',
        unidade: _toInt(user['unidade']),
      );

      if (!mounted) return;
      if (result.isOffline) {
        _showFeedback('Login offline realizado', isSuccess: true);
      } else {
        _showFeedback('Bem-vindo, ${user['nome'] ?? ''}!', isSuccess: true);
      }
      Navigator.pushReplacementNamed(context, '/dashboard');
    } on AuthException catch (e) {
      if (!mounted) return;
      _showFeedback(e.message, isSuccess: false);
    } catch (e) {
      if (!mounted) return;
      _showFeedback('Verifique sua conexão e tente novamente', isSuccess: false);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showFeedback(String message, {required bool isSuccess}) {
    setState(() {
      _feedbackMessage = message;
      _feedbackColor = isSuccess ? SystexColors.success : SystexColors.brandRed;
    });
  }

  Future<void> _showAuthErrorDialog(String message) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Erro de autenticação'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return SystexScaffold(
      title: 'LOGIN DO SISTEMA',
      useSafeArea: false,
      padding: EdgeInsets.zero,
      child: Column(
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
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: 400,
                  child: SystexGlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warehouse_rounded,
                            size: 56,
                            color: SystexColors.brandRed,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Systex WMS',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gestão de Armazéns Inteligente',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: SystexColors.textSecondary,
                                  fontSize: 14,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Divider(height: 32),
                          Text(
                            'Digite suas credenciais',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _userController,
                            focusNode: _userFocus,
                            autofocus: true,
                            keyboardType: TextInputType.text,
                            style: const TextStyle(fontSize: 20, letterSpacing: 1.1),
                            decoration: const InputDecoration(
                              labelText: 'Login',
                              hintText: 'Digite seu login',
                              border: OutlineInputBorder(),
                            ),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _passFocus.requestFocus(),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Digite seu login' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passController,
                            focusNode: _passFocus,
                            keyboardType: TextInputType.number,
                            obscureText: _obscurePass,
                            style: const TextStyle(fontSize: 20, letterSpacing: 1.1),
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              hintText: 'Digite sua senha',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePass
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () =>
                                    setState(() => _obscurePass = !_obscurePass),
                              ),
                            ),
                            textInputAction: TextInputAction.go,
                            onFieldSubmitted: (_) => _login(),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Digite sua senha' : null,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SystexColors.brandRed,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _loading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'ENTRAR',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Conexão segura • Fallback offline-first',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: SystexColors.textSecondary,
                                  fontSize: 12,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '© 2026 Systex Sistemas Inteligentes',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: SystexColors.textSecondary,
                                  fontSize: 11,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
