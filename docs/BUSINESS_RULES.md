# Business Rules

Responsável: ATHENA.

## Visão Geral

O WMS App apoia operações móveis de armazém integradas ao backend Laravel. As regras abaixo documentam o comportamento identificado no projeto atual e destacam pontos pendentes de validação humana.

## Login Online e Offline

- O login online autentica usuário e senha pela API Laravel.
- Em login online bem-sucedido, o token é salvo em `flutter_secure_storage`.
- O app mantém dados básicos do usuário em `shared_preferences`.
- Em plataformas não Web, o app salva credencial offline no SQLite por `username` e `password_hash`.
- O login offline é usado quando não há conexão ou em falhas recuperáveis de rede.
- Pendente: expiração oficial de login offline de 15 dias ainda precisa ser implementada no código.
- Pendente: hash legado com SHA-256 simples ainda precisa de plano de evolução seguro.

## Sincronização

- Entidades offline são registradas localmente com `sync_status`.
- A fila `sync_queue` registra entidade, ação e payload.
- Quando a conexão retorna, o `SyncService` tenta enviar pendências.
- Em sucesso, a entidade é marcada como sincronizada.
- Em erro, a fila pode ser marcada como `error` com mensagem.
- Pendente: nem todos os módulos usam a mesma estratégia offline.

## Recebimento

- Existem telas, models e services para recebimento e conferência.
- Há TODOs indicando integrações ainda pendentes.
- Pendente: validar contrato real da API, estados de conferência e regras de divergência.

## Armazenagem

- O módulo valida posição e busca descrição por SKU/EAN.
- O registro de armazenagem envia posição, SKU, quantidade, observações e usuário.
- Pendente: padronizar o acesso HTTP em Dio e validar autenticação em todos os endpoints.

## Separação

- O módulo está presente no dashboard.
- Pendente: validar regras de picking, reserva, divergência e baixa operacional.

## Expedição

- O módulo está presente no dashboard.
- Pendente: validar regras de expedição, conferência final, transporte e status de saída.

## Inventário

- Há telas para contagem livre, contagem dirigida e ajustes de estoque.
- A contagem livre possui cache de EAN e suporte offline em SQLite para plataformas não Web.
- No Web, pendências de contagem livre são mantidas em `shared_preferences`.
- Pendente: validar regras de contagem dirigida e ajustes com backend.

## Kits

- O módulo de kits registra apontamentos e possui integração com fila offline para `apontamentos_kits`.
- O sync tenta apontar kit na API e atualiza status local.
- Pendente: validar status oficiais, retorno da API e regras de reprocessamento.

## Conflitos Offline

- Conflitos podem ser gravados em `sync_conflicts`.
- Para funcionários, quando `updated_at` local é mais recente que o servidor, o conflito é registrado e uma atualização é enfileirada.
- Pendente: definir política institucional para resolução manual ou automática de conflitos por módulo.

## Premissas Operacionais

- O usuário deve autenticar online ao menos uma vez antes de usar login offline.
- Coletores podem operar em ambientes com conectividade instável.
- Dados sensíveis não devem ser hardcoded.
- Alterações em contratos de API devem ser documentadas antes da implementação.
