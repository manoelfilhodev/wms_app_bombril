# Architecture

Responsável: PROMETEU.

## Arquitetura Geral

O projeto é um aplicativo Flutter organizado por camadas funcionais. A arquitetura atual combina módulos por domínio, services para integração, camada local SQLite e serviço de sincronização.

## Camadas do App

- `main.dart`: inicialização, rotas principais e banner global de sincronização.
- `core`: configuração, bootstrap, tema, widgets base e client HTTP.
- `modules`: telas e services por domínio operacional.
- `services`: serviços compartilhados de API, autenticação offline, conectividade e token.
- `repositories`: coordenação entre banco local, conectividade e sync.
- `database`: SQLite local.
- `sync`: fila, status e sincronização automática.
- `models`: entidades e DTOs locais.
- `ui`: telas e widgets auxiliares do offline-first.

## Fluxo de Dados

Fluxo online típico:

1. Tela coleta dados do usuário.
2. Service ou repository monta payload.
3. Client HTTP envia para API Laravel.
4. Resposta atualiza UI e, quando aplicável, armazenamento local.

Fluxo offline típico:

1. Tela ou repository salva entidade no SQLite.
2. Registro é marcado como `pending`.
3. Payload é gravado em `sync_queue`.
4. `SyncService` envia pendências ao retornar conexão.
5. Entidade é marcada como `synced` ou `error`.

## API Laravel

A API Laravel é o backend operacional. O projeto usa base URL centralizada em `AppConfig.apiBaseUrl`, com fallback de produção para evitar quebra imediata.

Pendente: consolidar todos os endpoints em services de domínio e documentar contratos de request/response.

## Client HTTP

Existem dois padrões em uso:

- Dio em `ApiClient` e `ApiService`.
- `package:http` em módulos legados.

Pendente: padronizar a comunicação HTTP em Dio, com interceptors, token, timeout e tratamento uniforme de erro.

## Storage Local

- `flutter_secure_storage`: token de autenticação.
- `shared_preferences`: dados simples de sessão e usuário.
- SQLite com `sqflite`: entidades offline, fila de sync, conflitos e cache de EAN.

## Sincronização

`SyncService` monitora conectividade e executa envio de pendências. Atualmente trata funcionários, contagem livre e apontamentos de kits de forma explícita.

Pendente: expandir estratégia offline por módulo e definir política única para erros e conflitos.

## Navegação

O app usa `MaterialApp.routes` para rotas principais e `Navigator.push` para navegação modular a partir do dashboard. Há um layout legado com rotas que precisam ser validadas antes de uso amplo.

## Padrões Técnicos

- Configurações sensíveis devem ser centralizadas.
- Telas não devem conter detalhes de endpoint quando houver service disponível.
- Alterações em banco devem ser aditivas e migradas com segurança.
- Fluxos offline devem registrar fila e status.
- Tokens e credenciais não devem ser hardcoded.
