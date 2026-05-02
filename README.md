# Systex WMS Mobility Platform

### Engenharia operacional para logística real

## Visão Geral Institucional

O Systex WMS Mobility Platform é o aplicativo mobile corporativo da Systex Sistemas Inteligentes para apoio às operações de armazém em ambientes WMS. O projeto foi construído em Flutter para uso em coletores, tablets e smartphones, com integração à API Laravel do ecossistema WMS.

A plataforma tem como foco levar processos operacionais para o ponto real de execução: docas, ruas de armazenagem, áreas de separação, inventário e expedição. O projeto está em evolução contínua e documenta de forma explícita os módulos consolidados, os módulos parciais e os pontos que ainda exigem validação de negócio, arquitetura e segurança.

## Objetivo Operacional

O objetivo do app é permitir que usuários operacionais registrem, consultem e sincronizem atividades de WMS diretamente em dispositivos móveis, reduzindo dependência de estações fixas e aumentando aderência ao fluxo físico da operação.

Diretrizes operacionais:

- apoiar operação móvel em ambiente logístico;
- integrar o app ao backend Laravel do WMS;
- preservar dados críticos durante instabilidade de rede;
- sincronizar registros locais quando a conexão retornar;
- evoluir módulos sem comprometer contratos de API, dados locais ou segurança.

## Stack Tecnológica

- Flutter
- Dart `>=3.0.0 <4.0.0`
- Android como alvo operacional principal
- API Laravel
- SQLite local com `sqflite`
- Sync Queue local
- Dio para comunicação HTTP principal
- `package:http` ainda presente em módulos legados em transição
- `flutter_secure_storage` para token
- `shared_preferences` para dados locais não sensíveis
- `connectivity_plus` para status de conexão
- Codemagic para pipeline de build

## Módulos Operacionais

### Autenticação

Login integrado à API Laravel, com fallback offline em plataformas não Web. O login offline está em evolução para reforço de segurança, expiração e política de hash.

### Dashboard

Tela de entrada operacional para navegação entre os módulos disponíveis no app.

### Recebimento

Estrutura de páginas, models e services presente. Integrações e regras completas de conferência ainda estão pendentes de validação.

### Armazenagem

Fluxo para validação de posição, consulta de SKU/EAN e registro de armazenagem. O módulo existe, mas sua comunicação HTTP ainda está em transição para padronização total em Dio.

### Separação

Módulo presente no app. Regras de picking, reserva, divergência e baixa operacional ainda precisam validação funcional.

### Expedição

Módulo presente no app. Regras de conferência final, transporte e status de saída ainda precisam validação funcional.

### Inventário

Inclui contagem livre, contagem dirigida e ajustes de estoque. A contagem livre possui suporte offline parcial, cache de EAN e sincronização para plataformas não Web.

### Inventário Cíclico

Módulo com requisições e itens integrados via API. Contratos e cenários operacionais devem continuar documentados conforme evolução.

### Kits

Fluxos de apontamento de kits/paletes com integração parcial à fila de sincronização. Status oficiais e regras de reprocessamento ainda exigem validação.

### Funcionário Offline

Fluxo de referência para CRUD offline-first, usando SQLite, `sync_queue`, status local e sincronização automática.

## Arquitetura Operacional

A arquitetura operacional do app considera conectividade variável como condição normal de campo. O aplicativo deve conseguir registrar dados localmente, manter status de sincronização e reenviar pendências quando a conexão estiver disponível.

Fluxo operacional base:

1. Usuário executa uma atividade no dispositivo.
2. O app valida dados mínimos da operação.
3. Quando online, o registro é enviado à API Laravel.
4. Quando offline, o registro é persistido localmente.
5. A fila de sincronização registra ação e payload.
6. Ao retornar a conexão, o app tenta sincronizar pendências.
7. Conflitos e erros devem ser registrados para análise e correção.

## Arquitetura Técnica

Estrutura principal:

```text
lib/
  core/           Configuração, bootstrap, tema, widgets base e API client
  database/       SQLite local e schema offline-first
  models/         Entidades e objetos de apoio
  modules/        Telas e services por domínio operacional
  repositories/   Coordenação entre dados locais, API e sync
  services/       API, autenticação, conectividade e token
  sync/           Sync Queue, status e sincronização automática
  ui/             Telas e widgets auxiliares offline-first
  utils/          Utilidades compartilhadas
```

Componentes técnicos relevantes:

- `AppConfig`: configuração central da API via `API_BASE_URL`, com fallback de produção.
- `ApiClient` e `ApiService`: base de comunicação HTTP com Dio.
- `LocalDatabaseService`: SQLite local.
- `SyncService`: envio de pendências e pull de dados sincronizáveis.
- `TokenStorageService`: armazenamento seguro de token.
- `OfflineAuthService`: autenticação online/offline.

## Estratégia Offline-First

Offline-first é requisito crítico para operação logística real, especialmente em ambientes com cobertura instável, coletores em movimento ou áreas com bloqueio de sinal.

Estado atual:

- SQLite local disponível em plataformas não Web.
- Fila `sync_queue` para pendências.
- Tabelas locais para usuários, funcionários, contagem livre, kits, recebimentos, estoque, movimentações, cache EAN e conflitos.
- Banner global de status de sincronização.
- Sincronização explícita para funcionários, contagem livre e apontamentos de kits.

Em evolução:

- política unificada de conflitos por módulo;
- padronização offline para todos os módulos operacionais;
- expiração do login offline em 15 dias;
- remoção do uso de token no SQLite, mantendo token somente em `flutter_secure_storage`;
- migrations SQLite idempotentes e compatíveis com produção.

## Instalação

Pré-requisitos:

- Flutter SDK compatível com Dart `>=3.0.0 <4.0.0`
- Git
- Android SDK
- Dispositivo físico ou emulador Android

Instalar dependências:

```bash
flutter pub get
```

## Execução

Execução padrão:

```bash
flutter run
```

Execução com API por ambiente:

```bash
flutter run --dart-define=API_BASE_URL=https://host/api
```

## Qualidade e Validação

Comandos de validação:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Critérios esperados:

- análise estática sem erros críticos;
- testes automatizados compatíveis com o comportamento real do app;
- build Android debug gerado com sucesso;
- alterações offline acompanhadas de validação de fila, status e sincronização;
- alterações de banco acompanhadas de plano de migration.

Observação: a suíte de testes ainda está em evolução e deve substituir testes template por validações reais de app, autenticação, sync e banco local.

## Engenharia e Governança com Agentes IA

Este projeto segue o Systex AI Engineering Framework definido em `AGENTS.md`.

Fluxo obrigatório de engenharia:

1. ATLAS: orquestração e direção do projeto.
2. ATHENA: validação de regras de negócio.
3. PROMETEU: validação de arquitetura.
4. GAIA: avaliação de dados, local storage e API.
5. VULCAN: estrutura base e padrões.
6. PROMETEU: contratos de API.
7. HERMES: implementação Flutter/mobile.
8. ORION: testes, build e regressões.
9. HADES: segurança, tokens, permissões e dados sensíveis.

Toda mudança funcional deve respeitar regra de negócio, arquitetura, dados, segurança e qualidade antes de ser considerada pronta.

## Licença

Este projeto é proprietário da Systex Sistemas Inteligentes. O uso é permitido apenas em contexto interno ou expressamente autorizado.

É proibida a cópia, redistribuição, venda, sublicenciamento ou uso não autorizado do código, documentação, assets e configurações associadas.

Consulte `LICENSE` para os termos proprietários completos.

## Assinatura Oficial Systex

Projeto: Systex WMS Mobility Platform  
Produto/Repositório: `wms_app`  
Empresa: Systex Sistemas Inteligentes  
Finalidade: mobilidade operacional para ambiente WMS  
Stack: Flutter, Dart, SQLite, Sync Queue e API Laravel  
Governança: Systex AI Engineering Framework  
Licença: proprietária Systex  
