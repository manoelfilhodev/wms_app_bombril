# Security

Responsável: HADES.

## Armazenamento de Token

O projeto usa `flutter_secure_storage` para token de autenticação. Esta deve ser a fonte oficial para token.

Diretriz aprovada:

- token deve existir somente em `flutter_secure_storage`;
- token não deve mais ser salvo no SQLite;
- coluna `users.token` não deve ser removida nesta fase, por compatibilidade;
- dados sensíveis não devem ser hardcoded.

Pendente: ajustar código para deixar de gravar token em `users.token`.

## Login Offline

O login offline permite autenticação local quando não há conexão, desde que o usuário já tenha feito login online antes.

Estado atual:

- valida `username` e `password_hash`;
- usa SHA-256 simples;
- não há expiração implementada no schema atual.

Diretriz aprovada:

- login offline deve expirar em 15 dias;
- manter compatibilidade temporária com hash legado;
- evoluir para hash versionado com salt;
- registrar metadados de expiração e último login online.

## Riscos

- SHA-256 simples é fraco para armazenamento de senha offline.
- Token no SQLite aumenta superfície de exposição.
- Mensagens e logs de erro podem expor detalhes técnicos se não forem tratados.
- `shared_preferences` não deve armazenar segredos.
- Módulos legados ainda usam HTTP client direto e precisam padronização.

## Boas Práticas

- Usar `flutter_secure_storage` para tokens.
- Usar `shared_preferences` apenas para dados não sensíveis.
- Evitar logs com token, senha, payload sensível ou dados pessoais.
- Centralizar base URL e configuração por ambiente.
- Tratar 401 com revalidação de sessão.
- Definir política de expiração offline e limpeza no logout.

## Dados Sensíveis

Potenciais dados sensíveis:

- token de autenticação;
- credenciais ou hash de senha;
- identificação de usuário;
- operações de estoque;
- payloads locais de recebimento, movimentação e inventário.

## Recomendações

- Implementar expiração offline de 15 dias.
- Introduzir salt e versão de hash.
- Parar gravação de token no SQLite.
- Revisar payloads locais e necessidade de criptografia adicional.
- Validar permissões Android e política de backup antes de release operacional.
