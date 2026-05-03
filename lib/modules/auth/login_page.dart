import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wms_app/core/app_theme.dart';
import 'package:wms_app/core/exceptions/auth_exception.dart';
import 'package:wms_app/core/widgets/systex_glass_card.dart';
import 'package:wms_app/core/widgets/systex_scaffold.dart';
import 'package:wms_app/services/device_identity_service.dart';
import 'package:wms_app/services/microsoft_auth_service.dart';
import 'package:wms_app/services/microsoft_web_auth.dart';
import 'package:wms_app/utils/user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String appVersion = 'v1.0.0';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final MicrosoftAuthService _microsoftAuthService = MicrosoftAuthService();
  final DeviceIdentityService _deviceIdentityService =
      DeviceIdentityService.instance;

  bool _microsoftLoading = false;
  String? _feedbackMessage;
  Color? _feedbackColor;
  late final Future<String> _deviceIdFuture;

  @override
  void initState() {
    super.initState();
    _deviceIdFuture = _deviceIdentityService.getOrCreateDeviceId();

    if (hasMicrosoftWebRedirectResult()) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loginMicrosoft());
    }
  }

  Future<void> _loginMicrosoft() async {
    setState(() {
      _microsoftLoading = true;
      _feedbackMessage = null;
    });

    try {
      final result = await _microsoftAuthService.login();
      final user = result.user;

      await UserService.saveUser(
        token: result.token,
        id: _toInt(user['id_user'] ?? user['id']),
        nome: user['nome']?.toString() ?? user['name']?.toString() ?? '',
        nivel: user['nivel']?.toString() ?? '',
        tipo: user['tipo']?.toString() ?? '',
        unidade: _toInt(user['unidade']),
        permissions: result.permissions,
      );

      if (!mounted) return;

      _showFeedback(
        'Bem-vindo, ${user['nome'] ?? user['name'] ?? ''}!',
        isSuccess: true,
      );

      Navigator.pushReplacementNamed(context, '/dashboard');
    } on AuthException catch (e) {
      if (!mounted) return;
      _showFeedback(e.message, isSuccess: false);
    } catch (e) {
      if (!mounted) return;
      _showFeedback(
        'Nao foi possivel concluir o login Microsoft: $e',
        isSuccess: false,
      );
    } finally {
      if (mounted) {
        setState(() => _microsoftLoading = false);
      }
    }
  }

  void _showFeedback(String message, {required bool isSuccess}) {
    setState(() {
      _feedbackMessage = message;
      _feedbackColor = isSuccess ? SystexColors.success : SystexColors.brandRed;
    });
  }

  Future<void> _copyDeviceId(String deviceId) async {
    await Clipboard.setData(ClipboardData(text: deviceId));

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('ID do dispositivo copiado')),
      );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Widget _buildDeviceIdSection() {
    return FutureBuilder<String>(
      future: _deviceIdFuture,
      builder: (context, snapshot) {
        final deviceId = snapshot.data;
        final isReady = deviceId != null && deviceId.isNotEmpty;
        final visibleDeviceId = deviceId ?? '';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    size: 17,
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dispositivo seguro',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SystexColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Este identificador é usado apenas para validação de acesso. Copie somente se o administrador solicitar.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SystexColors.textSecondary,
                      fontSize: 11,
                    ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: isReady
                        ? SelectableText(
                            visibleDeviceId,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: SystexColors.textPrimary,
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                          )
                        : Text(
                            'Gerando identificador...',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: SystexColors.textSecondary,
                                    ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Copiar ID do dispositivo',
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    onPressed:
                        isReady ? () => _copyDeviceId(visibleDeviceId) : null,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSecurityInfo(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withValues(alpha: 0.08),
            border: Border.all(
              color: Colors.greenAccent.withValues(alpha: 0.35),
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.security_rounded,
                size: 16,
                color: Colors.greenAccent,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Ambiente protegido por Microsoft Azure AD',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Conexao segura • Identidade centralizada • Zero senha local',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SystexColors.textSecondary,
                fontSize: 11,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Autenticacao empresarial com controle de dispositivo',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SystexColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 10,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    return Text(
      'Versao do app ${LoginPage.appVersion} • © 2026 Plataforma Operacional',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: SystexColors.textSecondary.withValues(alpha: 0.75),
            fontSize: 10,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
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
                      maxLines: 3,
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
                          'Portal Operacional',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gestao Inteligente de Operações',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: SystexColors.textSecondary,
                                    fontSize: 14,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Divider(height: 32),
                        Text(
                          'Acesse com sua conta corporativa',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed:
                                _microsoftLoading ? null : _loginMicrosoft,
                            icon: _microsoftLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.window_rounded),
                            label: const Text('Entrar com Microsoft'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildDeviceIdSection(),
                        const SizedBox(height: 20),
                        _buildSecurityInfo(context),
                        const SizedBox(height: 12),
                        _buildVersionInfo(context),
                      ],
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
