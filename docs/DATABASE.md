# Database

Responsável: GAIA.

## Banco Local

O projeto usa SQLite via `sqflite`. O banco identificado é:

- Nome: `wms_offline_first.db`
- Versão atual no código: `3`
- Serviço: `LocalDatabaseService`

O banco é inicializado apenas fora do Web. No Web, o app usa alternativas limitadas, como `shared_preferences` para algumas pendências.

## Tabelas Identificadas

### `users`

Armazena usuário local para login offline.

Campos relevantes: `id_local`, `id_server`, `username`, `nome`, `nivel`, `tipo`, `unidade`, `password_hash`, `token`, `token_needs_revalidation`, timestamps e `sync_status`.

Risco: a coluna `token` existe e o código atual ainda pode gravar token no SQLite. A diretriz aprovada é manter a coluna por compatibilidade, mas passar a usar token somente em `flutter_secure_storage`.

### `funcionarios`

Entidade de exemplo/uso offline para CRUD local e sincronização.

Campos relevantes: identificação local/servidor, nome, matrícula, cargo, timestamps, `sync_status` e `deleted_at`.

### `apontamentos_kits`

Registra apontamentos de kits/paletes.

Campos relevantes: palete, material, quantidade, status, usuário, timestamps e sincronização.

### `recebimentos`

Armazena payload JSON de recebimentos com status de sincronização.

### `estoque`

Armazena payload JSON de estoque com status de sincronização.

### `movimentacoes`

Armazena payload JSON de movimentações com status de sincronização.

### `contagem_livre`

Armazena contagens livres pendentes ou sincronizadas.

Campos relevantes: usuário contador, SKU, ficha/posição, quantidade, data/hora e `sync_status`.

### `ean_cache`

Cache local de EAN para SKU e descrição, usado em cenários offline.

### `sync_queue`

Fila de sincronização.

Campos relevantes: entidade, ID local, ação, payload JSON, status, erro e timestamps.

### `sync_conflicts`

Registro de conflitos entre payload local e payload do servidor.

## Riscos Atuais

- A versão 3 adiciona `error_message` por migration em algumas tabelas, mas o `onCreate` não cria essas colunas em instalações novas.
- A tabela `users` mantém coluna `token`; o plano de segurança exige parar de gravar token localmente no SQLite.
- O hash offline é legado e baseado em SHA-256 simples.
- Nem todos os módulos usam o mesmo padrão de persistência local.

## Plano de Evolução

- Criar versão 4 do banco com migration idempotente.
- Garantir que `onCreate` e `onUpgrade` produzam o mesmo schema final.
- Adicionar metadados para login offline seguro, como versão de hash, salt e expiração.
- Manter migrations aditivas, sem remoção de colunas nesta fase.
- Documentar cada entidade offline antes de expandir sincronização.

## Relação com API/Backend

O SQLite é cache operacional e fila local. A API Laravel permanece fonte de verdade para dados sincronizados. IDs locais (`id_local`) devem ser conciliados com IDs do servidor (`id_server`) após sincronização.
