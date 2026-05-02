import 'package:flutter/material.dart';

import 'inventario_ciclico_itens_page.dart';
import 'inventario_ciclico_service.dart';
import 'models/inventario_ciclico_requisicao.dart';

class InventarioCiclicoRequisicoesPage extends StatefulWidget {
  const InventarioCiclicoRequisicoesPage({super.key});

  @override
  State<InventarioCiclicoRequisicoesPage> createState() =>
      _InventarioCiclicoRequisicoesPageState();
}

class _InventarioCiclicoRequisicoesPageState
    extends State<InventarioCiclicoRequisicoesPage> {
  final InventarioCiclicoService _service = InventarioCiclicoService();
  late Future<List<InventarioCiclicoRequisicao>> _futureRequisicoes;

  @override
  void initState() {
    super.initState();
    _futureRequisicoes = _service.getRequisicoes();
  }

  void _reload() {
    setState(() {
      _futureRequisicoes = _service.getRequisicoes();
    });
  }

  Future<void> _refresh() async {
    _reload();
    await _futureRequisicoes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Inventário Cíclico'),
        centerTitle: false,
      ),
      body: FutureBuilder<List<InventarioCiclicoRequisicao>>(
        future: _futureRequisicoes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: 'Erro ao carregar requisições.',
              onRetry: _reload,
            );
          }

          final requisicoes = snapshot.data ?? const [];
          if (requisicoes.isEmpty) {
            return _EmptyState(onRefresh: _reload);
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: requisicoes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final requisicao = requisicoes[index];
                final progresso = _resolveProgress(
                  requisicao.progresso,
                  requisicao.contados,
                  requisicao.totalItens,
                );

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InventarioCiclicoItensPage(
                          idInventario: requisicao.id,
                        ),
                      ),
                    );

                    if (mounted) _reload();
                  },
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            requisicao.codRequisicao ?? 'Sem código',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Data: ${_formatDate(requisicao.dataRequisicao)}',
                          ),
                          const SizedBox(height: 4),
                          Text('Status: ${requisicao.status ?? '-'}'),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: progresso / 100,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${requisicao.contados} / ${requisicao.totalItens} itens',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  int _resolveProgress(int progresso, int contados, int totalItens) {
    if (progresso > 0) {
      return progresso.clamp(0, 100);
    }
    if (totalItens <= 0) return 0;
    return ((contados / totalItens) * 100).round().clamp(0, 100);
  }

  String _formatDate(String? date) {
    if (date == null || date.trim().isEmpty) return '-';

    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;

    final dia = parsed.day.toString().padLeft(2, '0');
    final mes = parsed.month.toString().padLeft(2, '0');
    final ano = parsed.year.toString();
    final hora = parsed.hour.toString().padLeft(2, '0');
    final minuto = parsed.minute.toString().padLeft(2, '0');

    return '$dia/$mes/$ano $hora:$minuto';
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.assignment_outlined, size: 44),
            const SizedBox(height: 12),
            const Text('Nenhuma requisição disponível.'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Atualizar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44, color: Colors.red),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
