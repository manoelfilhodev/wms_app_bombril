# Login Microsoft no app WMS

O app usa OAuth Authorization Code + PKCE via `flutter_appauth`. O app nao
valida tenant, dominio, `azure_id`, usuario ativo ou dispositivo autorizado.
Essas validacoes continuam no backend Laravel.

## Fluxo

1. Usuario toca em "Entrar com Microsoft".
2. O app abre o login Microsoft pelo fluxo seguro do sistema.
3. A Microsoft retorna `access_token` e `id_token` para o app.
4. O app recupera o `device_id` persistente.
5. O app envia os dados para o backend:

```json
{
  "access_token": "...",
  "id_token": "...",
  "device_id": "uuid-do-app",
  "platform": "android"
}
```

Endpoint:

```text
POST /api/auth/microsoft
```

O backend e responsavel por validar Azure, usuario, tenant, dominio e
dispositivo do tipo `app`.

## Configuracao

Configurar via `--dart-define`, sem hardcodar dados Azure:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:8000/api \
  --dart-define=AZURE_TENANT_ID=<tenant-id> \
  --dart-define=AZURE_CLIENT_ID=<client-id> \
  --dart-define=AZURE_REDIRECT_URI=com.example.wms_app:/oauthredirect
```

Escopos padrao:

```text
openid profile email offline_access User.Read
```

Para sobrescrever:

```bash
--dart-define="AZURE_SCOPES=openid profile email offline_access User.Read"
```

## Android

O redirect scheme configurado no Gradle e:

```text
com.example.wms_app
```

Cadastrar no Azure Entra ID o redirect URI:

```text
com.example.wms_app:/oauthredirect
```

## Offline

Apos login online, o app salva token, usuario, permissoes e validade offline de
12h. Primeiro login offline continua bloqueado porque depende de login anterior
com sucesso.

## Seguranca

- O app nao valida tokens Microsoft localmente.
- O app nao guarda segredo de cliente.
- O app nao usa IMEI/MAC.
- O backend deve negar `403` para dispositivo nao autorizado antes de emitir o
  token interno.
