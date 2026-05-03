# Device ID do app/coletor

O app WMS usa um `device_id` local para identificar cada instalacao em
coletores e celulares. Ele e o equivalente funcional do cookie
`systex_wms_device_id` usado no WMS Web, mas e salvo no armazenamento local do
app.

## Onde e gerado e salvo

- Servico: `lib/services/device_identity_service.dart`
- Chave local: `systex_wms_device_id`
- Armazenamento: `SharedPreferences`
- Formato novo: UUID v4

Ao abrir a tela de login, o app chama `getOrCreateDeviceId()`. Se o ID ja
existir, ele e reutilizado. Se nao existir, o app tenta migrar o identificador
legado `stretch_device_id`. Se tambem nao houver legado, gera um UUID v4 e
persiste localmente.

O ID nao depende de sessao, token ou cache temporario. Ele deve permanecer apos
fechar o app e apos logout. Ele so deve ser recriado se o app for desinstalado
ou se os dados locais forem apagados.

## Onde e exibido

- Tela: `lib/modules/auth/login_page.dart`
- Bloco: "ID deste dispositivo"

A tela permite selecionar/copiar o ID para que o usuario envie ao admin ou para
que o admin cadastre o dispositivo no painel Web `/dispositivos`.

## Onde e enviado

- Login atual: `POST /login`
- Metodo: `ApiService.login`
- Campo enviado: `device_id`

Payload:

```json
{
  "email": "usuario@empresa.com",
  "password": "...",
  "device_id": "uuid-ou-id-do-dispositivo"
}
```

O `ApiService` tambem possui o metodo `loginMicrosoft`, usado no endpoint
`POST /auth/microsoft`:

```json
{
  "access_token": "...",
  "id_token": "...",
  "device_id": "uuid-ou-id-do-dispositivo",
  "platform": "android"
}
```

## Segurança

O app nao usa IMEI, MAC address ou identificadores restritos do sistema
operacional. A interface exibe apenas o `device_id`, sem tokens, credenciais ou
dados sensiveis.
