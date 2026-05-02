import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/widgets/systex_glass_card.dart';
import '../../core/widgets/systex_scaffold.dart';
import '../../ui/pages/funcionario_offline_page.dart';
import '../armazenagem/armazenagem_page.dart';
import '../auth/login_page.dart' show LoginPage;
import '../expedicao/expedicao_page.dart';
import '../inventario/inventario_page.dart';
import '../kits/apontamento_kits_page.dart';
import '../recebimento/pages/recebimento_page.dart';
import '../separacao/separacao_page.dart';

class DashboardPage extends StatelessWidget {
  final String userName;

  const DashboardPage({super.key, this.userName = 'Usuario'});

  String get firstName {
    if (userName.trim().isEmpty) return 'Usuario';
    return userName.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossCount = screenWidth > 900
        ? 4
        : screenWidth > 600
            ? 3
            : 2;

    final modules = [
      {
        'title': 'Recebimento',
        'subtitle': 'Entrada e conferencia de mercadorias',
        'page': const RecebimentoPage(),
        'icon': Icons.inventory_2_outlined,
      },
      {
        'title': 'Armazenagem',
        'subtitle': 'Movimentacao e localizacao de produtos',
        'page': const ArmazenagemPage(),
        'icon': Icons.move_down_outlined,
      },
      {
        'title': 'Separacao',
        'subtitle': 'Picking e preparacao de pedidos',
        'page': const SeparacaoPage(),
        'icon': Icons.playlist_add_check_circle_outlined,
      },
      {
        'title': 'Expedicao',
        'subtitle': 'Saida e transporte de mercadorias',
        'page': const ExpedicaoPage(),
        'icon': Icons.local_shipping_outlined,
      },
      {
        'title': 'Inventario',
        'subtitle': 'Controle e contagem de estoque',
        'page': const InventarioPage(),
        'icon': Icons.analytics_outlined,
      },
      {
        'title': 'Kits',
        'subtitle': 'Apontamento e montagem de kits',
        'page': const ApontamentoKitsPage(),
        'icon': Icons.inventory_outlined,
      },
      if (!kIsWeb)
        {
          'title': 'Funcionario Offline',
          'subtitle': 'Cadastro local com sync automatico',
          'page': const FuncionarioOfflinePage(),
          'icon': Icons.badge_outlined,
        },
    ];

    return SystexScaffold(
      title: 'Painel de Controle',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            children: [
              Icon(
                Icons.account_circle_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Ola, $firstName',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: SystexColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Sair do sistema',
                icon: Icon(
                  Icons.logout_rounded,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                return SystexGlassCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => module['page'] as Widget,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        module['icon'] as IconData,
                        color: theme.colorScheme.primary,
                        size: 36,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        module['title'].toString(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        module['subtitle'].toString(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 40,
                        height: 3,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.85,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SystexGlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Text(
                  '© 2026 - Systex Sistemas Inteligentes',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SystexColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Infraestrutura em Azure - Backend Laravel - API SSL',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
