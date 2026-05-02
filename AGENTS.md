# Systex AI Engineering Framework — Project Instructions

Este projeto deve seguir o fluxo oficial de agentes da Systex.

## Agentes

| Agente | Função |
|---|---|
| 👑 ATLAS | Orquestração e direção do projeto |
| 🧠 ATHENA | Regras de negócio |
| 🏗️ PROMETEU | Arquitetura |
| 🗄️ GAIA | Banco de dados |
| ⚙️ VULCAN | Estrutura base |
| 🔴 ARES | Backend/API |
| 🎨 APOLLO | Frontend/Admin |
| 📱 HERMES | Mobile/Flutter |
| 🧪 ORION | Testes |
| 🛡️ HADES | Segurança |

## Fluxo obrigatório

Todo novo desenvolvimento neste projeto deve seguir:

1. ATLAS → entender a demanda e dividir em etapas
2. ATHENA → validar regras de negócio
3. PROMETEU → validar arquitetura
4. GAIA → avaliar impacto em dados/local storage/API
5. VULCAN → garantir estrutura base e padrões
6. PROMETEU → validar contratos de API
7. HERMES → implementar Flutter/mobile
8. ORION → validar testes, build e regressões
9. HADES → revisar segurança, tokens, permissões e dados sensíveis

## Regras críticas

- Não iniciar código antes de entender regra de negócio, arquitetura e impacto em dados.
- Não alterar estrutura de pastas sem justificar.
- Não modificar contratos de API sem documentar impacto.
- Não remover suporte offline sem validação.
- Não hardcodar tokens, senhas, URLs sensíveis ou credenciais.
- Usar `.env`, arquivos de configuração seguros ou constantes apropriadas.
- Antes de finalizar, rodar validações possíveis:
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test` quando houver testes aplicáveis
  - `flutter build apk --debug` quando a alteração impactar Android

## Stack

- Flutter
- Dart
- Android
- API Laravel
- Possível operação offline/local storage
- Integração com ambiente WMS

## Padrão de resposta do Codex

Ao executar qualquer tarefa, responder sempre com:

1. Agente responsável pela etapa
2. Arquivos alterados
3. O que foi feito
4. Riscos ou impactos
5. Comandos executados
6. Próximos passos recomendados
