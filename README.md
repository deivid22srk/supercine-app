# Supercine App

App **Flutter** de filmes e séries com layout premium inspirado no **HBO Max** (dark theme + roxo `#7B2BF9`).

O usuário fornece a **URL base da API** (proxy Supercine) na tela de configurações. O app consome a [Output API v1.3.0](https://github.com/deivid22srk/supercine-proxy/blob/main/docs/OUTPUT_API.md) do `supercine-proxy`.

## Funcionalidades

- **Início** — banner rotativo com destaques + seções horizontais (filmes e séries populares).
- **Filmes** — grid de filmes disponíveis, com separação entre disponíveis / indisponíveis.
- **Séries** — grid de séries populares.
- **Buscar** — busca por texto livre com sugestões rápidas.
- **Favoritos** — lista de títulos salvos localmente (`SharedPreferences`).
- **Detalhes** — backdrop, elenco, ano, provedor; para séries, lista temporadas + episódios.
- **Player** — player em tela cheia (`video_player` + `chewie`) com fallback de servidor.
- **Configurações** — URL da API + teste de conexão + status do proxy e provedores.

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
├── models/                    # MovieMeta, ResolveResult, SeasonsResponse, ...
├── services/
│   ├── api_service.dart       # Cliente da Output API v1.3.0
│   ├── app_store.dart         # ChangeNotifierProvider central
│   ├── favorites_service.dart # Favoritos (SharedPreferences)
│   └── settings_service.dart  # URL base persistida
├── theme/app_theme.dart       # Tema HBO Max-like
├── widgets/                   # HeroBanner, MovieCard, SectionHeader, states...
└── screens/                   # home, movies, series, search, favorites, settings, detail, player
```

## Endpoints consumidos

| Endpoint | Uso no app |
|---|---|
| `GET /v1/catalog/popular?type=movies` | Lista de filmes populares (Home + Filmes) |
| `GET /v1/catalog/popular?type=tvshows` | Lista de séries populares (Home + Séries) |
| `GET /v1/catalog/search?q=...` | Busca por texto |
| `GET /v1/resolve?imdb=...&type=...` | URL direta do filme |
| `GET /v1/resolveEpisode?imdb=...&season=...&episode=...` | URL direta do episódio |
| `GET /v1/seasons?imdb=...` | Temporadas + episódios |
| `GET /v1/health` | Status do proxy |
| `GET /v1/providers` | Lista de provedores |

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
3. Informe a URL base do proxy (ex: `https://meu-proxy.com`).
4. Toque em **Testar conexão** — se aparecer ✓ Online, está tudo certo.
5. Toque em **Salvar**.

## Documentação da API

Veja [`docs/OUTPUT_API.md`](https://github.com/deivid22srk/supercine-proxy/blob/main/docs/OUTPUT_API.md) para o contrato completo.

---

Desenvolvido por [@deivid22srk](https://github.com/deivid22srk).
