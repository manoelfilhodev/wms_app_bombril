# Offline-First Architecture (WMS)

## Camadas
- `lib/models`: entidades offline (`Funcionario`, `SyncQueueItem`, `SyncStatus`)
- `lib/database`: SQLite local (`LocalDatabaseService`)
- `lib/services`: API, token seguro, conectividade e login offline
- `lib/repositories`: regra de persistencia por entidade (`FuncionarioRepository`)
- `lib/sync`: sincronizacao automatica, fila e estado visual
- `lib/ui`: tela exemplo de funcionario e banner global de status

## Fluxo Offline
1. Sem internet: `FuncionarioRepository` grava em `funcionarios` e registra fila em `sync_queue` com `pending`.
2. Com internet: `SyncService` envia pendencias, atualiza `id_server` e marca `synced`.
3. Conflito: regra de `updated_at` mais recente prevalece, e conflito e salvo em `sync_conflicts`.

## Login Offline
1. Online: autentica na API e salva usuario local (`users`) + token em `flutter_secure_storage`.
2. Offline: valida `username + password_hash` no SQLite.
3. Token expirado (401): marca `token_needs_revalidation`.

## Teste Rapido
1. Login online uma vez.
2. Ir para `Funcionario Offline` no dashboard.
3. Desligar internet e cadastrar funcionario.
4. Ligar internet.
5. Ver banner mudar para `🔄 Sincronizando` e depois `🟢 Online`.

