# AGENTS.md

Guidance for agentic coding assistants working in this repository.

## Repository purpose

This repository publishes the Octium apt repository via GitHub Pages on the custom domain `https://repo.octium.dev`. The public web root is `docs/`.

The repository currently contains the `octium` Debian package for `amd64` under the `stable` codename and `main` component.

## Important paths

- `docs/` - GitHub Pages output and apt repository root.
- `docs/index.html` - Human-facing landing page for install instructions.
- `docs/dists/` - Generated apt metadata served to clients.
- `docs/pool/` - Published `.deb` package files.
- `docs/octium-archive-keyring.gpg` - Binary apt signing key for `signed-by=` usage.
- `docs/octium-archive-keyring.asc` - ASCII-armored copy of the apt signing key.
- `.reprepro/` - `reprepro` state and configuration used to generate repository metadata.
- `Makefile` - Automation for publishing keys, generating metadata, and adding `.deb` packages.
- `bin/aptfp` - Helper for resolving the configured apt signing-key fingerprint.

## Common tasks

- Add a package:
  - `make addeb DEB=/path/to/octium_VERSION_amd64.deb`
- Regenerate apt metadata and public keys:
  - `make aptrepo`
- Export public signing keys only:
  - `make aptpubkeys`
- Show the apt signing-key fingerprint:
  - `make aptfp`

Default publishing settings are defined in `Makefile`:

- `APT_REPO_DIR=./docs`
- `APT_CODENAME=stable`
- `APT_COMPONENT=main`
- `APT_ARCHITECTURES=amd64 source`
- `APT_SIGN_KEY=apt@octium.dev`

## Agent instructions

- Treat `docs/` as generated/public content for GitHub Pages, but keep `docs/index.html` human-readable and accurate for `https://repo.octium.dev`.
- Do not hand-edit generated apt metadata under `docs/dists/`; use the `Makefile`/`reprepro` workflow instead.
- Do not rewrite files under `docs/pool/` manually. Add or remove packages through `reprepro` so indexes and checksums remain consistent.
- Preserve the repository codename `stable`, component `main`, and custom domain `repo.octium.dev` unless explicitly asked to change them.
- Avoid committing private signing material. Only public key exports belong in `docs/`.
- After changing repository metadata or package contents, verify the work with `git status --short` and inspect relevant generated files before reporting completion.
