import 'package:flutter/material.dart';

import '../../core/widgets/systex_glass_card.dart';
import '../../core/widgets/systex_scaffold.dart';

class ApontamentoPaletesPage extends StatelessWidget {
  const ApontamentoPaletesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SystexScaffold(
      title: 'Apontamento de Paletes',
      child: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildMenuCard(
            context,
            icon: Icons.add_box_outlined,
            title: 'Novo Apontamento',
            subtitle: 'Registrar novo apontamento de palete',
            onTap: () {
              // TODO: Navegar para página de novo apontamento
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.history_outlined,
            title: 'Histórico',
            subtitle: 'Visualizar apontamentos realizados',
            onTap: () {
              // TODO: Navegar para página de histórico
            },
          ),
          _buildMenuCard(
            context,
            icon: Icons.qr_code_scanner_outlined,
            title: 'Escanear Palete',
            subtitle: 'Usar câmera para escanear código do palete',
            onTap: () {
              // TODO: Navegar para página de escaneamento
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