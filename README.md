# Supercine App

App **Flutter** de filmes e séries com layout premium inspirado no **HBO Max** (dark theme + roxo `#7B2BF9`).

O usuário fornece a **URL base da API** (proxy Supercine) na tela de configurações. O app consome a [Output API v1.4.0](https://github.com/deivid22srk/supercine-proxy/blob/main/docs/OUTPUT_API.md) do `supercine-proxy`.

## Funcionalidades

- **Início** — banner rotativo com destaques + 4 linhas horizontais (🔥 Lançamentos, ⭐ Destaques, 🆕 Recentes, 💡 Sugeridos) usando o novo endpoint `/v1/catalog/home` da v1.4.0. Fallback automático para `/v1/catalog/popular` se a home falhar.
- **Filmes** — grid de filmes disponíveis, com separação entre disponíveis / indisponíveis.
- **Séries** — grid de séries populares.
- **Buscar** — busca por texto livre com sugestões rápidas.
- **Favoritos** — lista de títulos salvos localmente (`SharedPreferences`).
- **Detalhes** — backdrop, elenco, ano, **nota IMDB**, **duração**, **categorias** (campos extras do `/home`), provedor; para séries, lista temporadas + episódios.
- **Player** — player em tela cheia (`video_player` + `chewie`) com fallback de servidor, suporte a HLS/m3u8 e **toggle de proxy `/v1/stream`** para contornar bloqueio de `Origin` dos CDNs.
- **Configurações** — URL da API + teste de conexão + status do proxy e provedores + toggle de proxy de stream.
- UI 100% em **português**

## Estilo visual

| Elemento | Cor |
|---|---|
| Background | `#0B0B14` |
| Surface | `#15151F` |
| Brand (roxo) | `#7B2BF9` |
| Texto primário | `#F7F4FF` |
| Texto secundário | `#B6B0CC` |

Tipografia: **Poppins** (títulos) + **Inter** (corpo).

## Estrutura

```
lib/
├── main.dart                  # App + MainShell (bottom nav 5 abas)
├── config/
│   ├── api_config.dart        # Monta URLs e timeouts por endpoint
│   └── api_exception.dart     # Erros com sentinelas "title not available" etc.
├── models/                    # MovieMeta, ResolveResult, SeasonsResponse, HomeResponse, ...
├── services/
│   ├── api_service.dart       # Cliente da Output API v1.4.0 (catálogo + resolve + stream + home)
│   ├── app_store.dart         # ChangeNotifierProvider central
│   ├── favorites_service.dart # Favoritos (SharedPreferences)
│   └── settings_service.dart  # URL base + toggle useStreamProxy persistidos
├── theme/app_theme.dart       # Tema HBO Max-like
├── widgets/                   # HeroBanner, MovieCard, SectionHeader, states...
└── screens/                   # home, movies, series, search, favorites, settings, detail, player
```

## Endpoints consumidos

| Endpoint | Uso no app |
|---|---|
| `GET /v1/catalog/home?type=movies\|tvshows` | **(v1.4.0)** Home com 4 linhas (Lançamentos, Destaques, Recentes, Sugeridos) |
| `GET /v1/catalog/popular?type=...` | Fallback da Home + grids de Filmes/Séries |
| `GET /v1/catalog/search?q=...` | Busca por texto |
| `GET /v1/resolve?imdb=...&type=...` | URL direta do filme |
| `GET /v1/resolveEpisode?imdb=...&season=...&episode=...` | URL direta do episódio |
| `GET /v1/seasons?imdb=...` | Temporadas + episódios |
| `GET /v1/stream?url=...` | **(v1.4.0)** Proxy de reprodução (opcional, contorna CORS/Origin dos CDNs) |
| `GET /v1/health` | Status do proxy |
| `GET /v1/providers` | Lista de provedores |

## Proxy de stream `/v1/stream` (v1.4.0)

Os CDNs dos hosters (MixDrop, StreamWish, VidHide) rejeitam `Origin` estrangeiro com 403. Clientes **navegador/WebView** precisam passar a URL por `/v1/stream?url=...`.

Como o Flutter usa `video_player` (ExoPlayer/Media3 nativo), o app vem com o proxy **desligado por padrão** (URL direta). Ative em Configurações → Reprodução → "Usar proxy de stream" se:

- Aparecer erro 403 do CDN ao reproduzir
- Você estiver usando uma WebView dentro do Flutter
- Quiser debugar via proxy

## Build local

```bash
flutter pub get
flutter run                # debug
flutter build apk --debug  # APK
```

## CI

O workflow `.github/workflows/build.yml` é disparado em todo `push` para `main`/`master`, em pull requests e manualmente via `workflow_dispatch`. Ele:

1. Instala Flutter `stable` + Java 17
2. Roda `flutter pub get`, `flutter analyze`, `flutter test`
3. Compila o **APK debug** com `flutter build apk --debug`
4. Publica o APK como artifact do GitHub Actions

Para baixar o APK compilado, vá em **Actions → build → Run mais recente → Artifacts**.

## Configuração inicial no app

1. Abra o app.
2. Toque no ícone de engrenagem no topo da Home.
3. Informe a URL base do proxy (ex: `https://supercine-proxy.onrender.com`).
4. Toque em **Testar conexão** — se aparecer ✓ Online, está tudo certo.
5. Toque em **Salvar**.

## Documentação da API

Veja [`docs/OUTPUT_API.md`](https://github.com/deivid22srk/supercine-proxy/blob/main/docs/OUTPUT_API.md) para o contrato completo (v1.4.0).

---

## Changelog

### v1.1.0 — Suporte à Output API v1.4.0

- ⭐ **Novo endpoint `/v1/catalog/home`**: a Home agora mostra 4 linhas de destaque (🔥 Lançamentos, ⭐ Destaques, 🆕 Recentes, 💡 Sugeridos) com 12 itens cada, espelhando a home do app original. Fallback automático para `/popular` se a home falhar.
- ⭐ **Novo endpoint `/v1/stream`**: toggle em Configurações → Reprodução para repassar URLs de vídeo pelo proxy e contornar o bloqueio de `Origin` dos CDNs. Badge "PROXY" no player quando ativo.
- ✨ `MovieMeta` estendido com `imdb_rating`, `runtime`, `categories`, `post_id` (campos extras retornados pelo `/home`).
- ✨ Hero banner e cards de pôster agora mostram ★ nota IMDB e duração quando disponíveis.
- ✨ Tela de Detalhes exibe nota IMDB, duração e categorias nos chips e na tabela de informações.
- 🔧 Fallback automático Home → Popular quando o proxy não implementa `/home` ou retorna erro.
- 📚 README atualizado com changelog e exemplos.

### v1.0.0 — Versão inicial

- App Flutter com layout HBO Max-like, 5 abas (Início, Filmes, Séries, Busca, Favoritos), player `video_player`+`chewie`, favoritos em `SharedPreferences`, integração com Output API v1.3.0.

---

Desenvolvido por [@deivid22srk](https://github.com/deivid22srk).
