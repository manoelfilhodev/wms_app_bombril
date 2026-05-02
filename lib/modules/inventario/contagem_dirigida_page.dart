import 'package:flutter/material.dart';

import '../../core/widgets/systex_glass_card.dart';
import '../../core/widgets/systex_scaffold.dart';

class ContagemDirigidaPage extends StatelessWidget {
  const ContagemDirigidaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SystexScaffold(
      title: 'Contagem Dirigida',
      child: SingleChildScrollView(
        child: SystexGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Contagem Dirigida',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Esta tela permitirá realizar contagens guiadas baseadas em tarefas '
                'do sistema, onde cada operador receberá posições e SKUs pré-designados.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Icon(
                Icons.map_outlined,
                color: theme.colorScheme.primary.withValues(alpha: 0.85),
                size: 72,
              ),
              const SizedBox(height: 14),
              Text(
                'Função em desenvolvimento...',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                label: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
