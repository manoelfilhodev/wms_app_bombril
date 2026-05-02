# Roadmap

Responsável: ATLAS.

## Fase Atual

Documentação institucional e técnica base do projeto, alinhada ao Systex AI Engineering Framework.

## Fase 1: Estabilização Estrutural

Objetivos:

- remover URLs hardcoded;
- centralizar configuração de API;
- padronizar HTTP em Dio;
- revisar segurança do login offline;
- revisar SQLite/migrations sem quebrar produção.

Status: iniciada. A centralização de URL foi iniciada com `AppConfig`.

## Fase 2: Segurança e Offline

Objetivos:

- token somente em `flutter_secure_storage`;
- expiração de login offline em 15 dias;
- compatibilidade temporária com hash legado;
- evolução para hash com salt e versão;
- revisão de dados sensíveis locais;
- política de conflitos offline.

## Fase 3: Módulos Operacionais

Objetivos:

- validar recebimento e conferência;
- estabilizar armazenagem;
- validar separação;
- validar expedição;
- consolidar inventário;
- consolidar kits;
- documentar contratos de API por módulo.

## Fase 4: Testes e CI

Objetivos:

- substituir teste template por testes reais;
- criar testes de services, repositories e sync;
- adicionar testes de migration SQLite;
- endurecer CI removendo tolerância indevida a falhas;
- validar build Android debug por mudança relevante.

## Fase 5: Release Operacional

Objetivos:

- definir ambientes;
- configurar assinatura Android;
- validar dispositivos físicos;
- revisar licença, segurança e privacidade;
- gerar pacote operacional autorizado;
- documentar procedimento de suporte e rollback.
