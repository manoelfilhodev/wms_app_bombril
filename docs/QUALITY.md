# Quality

Responsável: ORION.

## Comandos de Validação

Instalação de dependências:

```bash
flutter pub get
```

Análise estática:

```bash
flutter analyze
```

Testes:

```bash
flutter test
```

Build Android debug:

```bash
flutter build apk --debug
```

## Critérios Mínimos de Aceite

- `flutter pub get` sem erro.
- `flutter analyze` sem erro crítico.
- `flutter test` executando testes relevantes.
- `flutter build apk --debug` gerando APK quando houver impacto mobile/Android.
- Nenhuma URL sensível, token ou senha hardcoded.
- Mudanças offline acompanhadas de validação de fila, status e sincronização.
- Mudanças de banco acompanhadas de migration segura.

## Riscos Conhecidos

- O teste atual parece derivado do template padrão de contador e deve ser substituído.
- O CI atual permite que analyze/test falhem sem quebrar build.
- Cobertura automatizada ainda é insuficiente para offline-first, autenticação e sync.
- Alguns módulos têm TODOs de integração.

## Recomendações

- Criar testes unitários para services e repositories.
- Criar smoke test real para inicialização/login/dashboard.
- Adicionar testes de migration SQLite antes da evolução do schema.
- Remover `|| true` de analyze/test no CI quando a base estiver estabilizada.
