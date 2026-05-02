import 'package:flutter/material.dart';
import 'conferencia_page.dart';

class RecebimentoPage extends StatelessWidget {
  const RecebimentoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Recebimento"),
        centerTitle: false,
        elevation: 1.5, // leve sombra (igual Inventário)
        backgroundColor: theme.cardTheme.color, // topo levemente destacado
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuCard(
              context,
              icon: Icons.assignment_turned_in_outlined,
              emoji: "📋",
              title: "Conferência",
              subtitle: "Registrar itens recebidos",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConferenciaPage(),
                  ),
                );
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.library_books_outlined,
              emoji: "🧾",
              title: "Notas Recebidas",
              subtitle: "Consultar histórico de notas",
              onTap: () {
                // TODO: implementar tela de consulta
              },
            ),
            _buildMenuCard(
              context,
              icon: Icons.qr_code_scanner_outlined,
              emoji: "📦",
              title: "Etiquetagem",
              subtitle: "Gerar etiquetas de recebimento",
              onTap: () {
                // TODO: implementar tela
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: EdgeInsets.zero,
        color: theme.cardTheme.color?.withOpacity(0.95),
        elevation: theme.cardTheme.elevation ?? 3,
        shape: theme.cardTheme.shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 26),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
