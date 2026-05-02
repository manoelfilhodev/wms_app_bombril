# Mobile

Responsável: HERMES.

## Configuração Flutter

O projeto usa Flutter com Dart `>=3.0.0 <4.0.0`.

Comando inicial:

```bash
flutter pub get
```

Execução padrão:

```bash
flutter run
```

Execução com API por ambiente:

```bash
flutter run --dart-define=API_BASE_URL=https://host/api
```

## Android

Android é o alvo operacional principal identificado para coletores, tablets e smartphones.

Execução em Android:

```bash
flutter run -d android
```

Build debug:

```bash
flutter build apk --debug
```

## Dispositivo Físico

Checklist:

- habilitar modo desenvolvedor;
- habilitar depuração USB;
- conectar dispositivo;
- confirmar que `flutter devices` reconhece o aparelho;
- executar `flutter run -d android`.

## Permissões

As permissões devem ser revisadas antes de release operacional, especialmente para:

- acesso à rede;
- armazenamento local;
- comportamento de backup;
- recursos específicos de coletores, se forem adicionados.

## Build Release Futuro

Comandos previstos:

```bash
flutter build apk --release
flutter build appbundle --release
```

Pendente: validar assinatura, keystore, flavors, ambientes e distribuição autorizada.

## Observações Mobile

- O app possui suporte multi-plataforma gerado pelo Flutter, mas a validação operacional deve priorizar Android.
- O suporte offline completo não está uniforme em todos os módulos.
- A experiência em coletores físicos deve validar foco de campos, teclado, leitura de códigos e reconexão.
