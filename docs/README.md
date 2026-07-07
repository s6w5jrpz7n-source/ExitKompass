# docs/

Ablageort für die Projektdokumentation des ExitKompass **und** die
gebaute Web-Vorschau der App (GitHub-Pages-Quelle).

Hier liegt die Produktspezifikation
[`ExitKompass_Spezifikation_v1.md`](ExitKompass_Spezifikation_v1.md).

## Web-Vorschau (GitHub Pages)

Dieser Ordner enthält zusätzlich einen fertig gebauten Web-Build der App
(`index.html`, `main.dart.js`, `assets/`, `canvaskit/` …), erzeugt aus
`app/tool/preview_app.dart` (volle Oberfläche, In-Memory-Zustand statt
nativer Datenbank). Canvaskit ist lokal eingebettet (`--no-web-resources-cdn`),
die App lädt also nichts von externen CDNs. `.nojekyll` schaltet die
Jekyll-Verarbeitung ab, damit die Dateien unverändert ausgeliefert werden.

**Live ansehen (z. B. am iPhone-Safari):** Das eigene GitHub-Konto besitzt
Admin-Rechte nur auf eigenen Repos. Deshalb:

1. Dieses Repo ins **eigene** Konto **forken** (Name `ExitKompass` beibehalten –
   der `<base href="/ExitKompass/">` hängt daran).
2. Im Fork: **Settings → Pages → Build and deployment → Source:
   „Deploy from a branch" → Branch `main`, Ordner `/docs` → Save.**
3. Nach ~1 Minute live unter `https://<konto>.github.io/ExitKompass/`.

Neu bauen (Ordner aktualisieren):

```bash
cd app
flutter build web -t tool/preview_app.dart --release \
  --base-href "/ExitKompass/" --no-web-resources-cdn
# ungenutzte Renderer-Varianten & Debug-Symbole entfernen (nur canvaskit-Basis + chromium behalten):
cd build/web/canvaskit && find . -name '*.symbols' -delete && \
  rm -f skwasm* wimp* && rm -rf experimental_webparagraph && cd -
cp -r build/web/. ../docs/ && rm -f ../docs/.last_build_id && touch ../docs/.nojekyll
```

> **Historie:** Die Engine (M1–M4) wurde zunächst ohne die Spec auf
> Basis der offiziellen Rechtslage 2026 gebaut (Spec und CLAUDE.md
> wurden am 2026-07-05 nachgereicht). Der anschließende Abgleich von
> `packages/exit_engine/lib/params/params_2026.json` gegen Spec §5
> ergab 100 % Übereinstimmung; Details und alle Annahmen in
> [`ASSUMPTIONS.md`](../ASSUMPTIONS.md) (A0).
