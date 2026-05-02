import 'package:flutter/material.dart';

import '../../core/widgets/systex_glass_card.dart';
import '../../core/widgets/systex_scaffold.dart';
import '../inventario_ciclico/inventario_ciclico_requisicoes_page.dart';
import 'ajustes_estoque_page.dart';
import 'contagem_livre_page.dart';

class InventarioPage extends StatelessWidget {
  const InventarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SystexScaffold(
      title: 'Inventário',
      child: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildMenuCard(
            context,
            icon: Icons.inventory_2_outlined,
            title: 'Contagem Livre',
            subtitle: 'Realizar inventário livre no armazém',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContagemLivrePage(),
                ),
              );
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.autorenew_rounded,
            title: 'Inventário Cíclico',
            subtitle: 'Contagem cíclica com requisições do sistema',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InventarioCiclicoRequisicoesPage(),
                ),
              );
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.balance_rounded,
            title: 'Ajustes de Estoque',
            subtitle: 'Corrigir divergências detectadas',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AjustesEstoquePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return SystexGlassCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: theme.colorScheme.primary),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
