import 'package:flutter/material.dart';

import '../../models/funcionario.dart';
import '../../models/sync_status.dart';
import '../../repositories/funcionario_repository.dart';
import '../../sync/sync_service.dart';

class FuncionarioOfflinePage extends StatefulWidget {
  const FuncionarioOfflinePage({super.key});

  @override
  State<FuncionarioOfflinePage> createState() => _FuncionarioOfflinePageState();
}

class _FuncionarioOfflinePageState extends State<FuncionarioOfflinePage> {
  final FuncionarioRepository _repository = FuncionarioRepository();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();
  bool _saving = false;
  List<Funcionario> _items = const [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final items = await _repository.listarAtivos();
    if (!mounted) return;
    setState(() => _items = items);
  }

  Future<void> _save() async {
    final nome = _nomeController.text.trim();
    final matricula = _matriculaController.text.trim();
    final cargo = _cargoController.text.trim();
    if (nome.isEmpty || matricula.isEmpty || cargo.isEmpty) return;

    setState(() => _saving = true);
    try {
      await _repository.criar(nome: nome, matricula: matricula, cargo: cargo);
      _nomeController.clear();
      _matriculaController.clear();
      _cargoController.clear();
      await _reload();
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _syncNow() async {
    await SyncService.instance.runAutoSync();
    await _reload();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _matriculaController.dispose();
    _cargoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funcionarios Offline-First'),
        actions: [
          IconButton(
            tooltip: 'Sincronizar agora',
            onPressed: _syncNow,
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _matriculaController,
              decoration: const InputDecoration(labelText: 'Matricula'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _cargoController,
              decoration: const InputDecoration(labelText: 'Cargo'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Salvando...' : 'Salvar Offline'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _reload,
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.nome),
                        subtitle: Text('${item.matricula} - ${item.cargo}'),
                        trailing: _buildSyncChip(theme, item.syncStatus),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncChip(ThemeData theme, SyncStatus status) {
    final color = switch (status) {
      SyncStatus.pending => Colors.orange,
      SyncStatus.synced => Colors.green,
      SyncStatus.error => Colors.red,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: color.withValues(alpha: 0.15),
      ),
      child: Text(
        status.value,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

