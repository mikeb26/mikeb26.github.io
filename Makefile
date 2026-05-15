.PHONY: aptkey aptrepo addeb aptfp aptpubkeys

DEB ?= $(firstword $(filter %.deb,$(MAKECMDGOALS)))

APT_REPREPRO_BASE := ./.reprepro
APT_REPO_DIR := ./docs
APT_CODENAME ?= stable
APT_COMPONENT ?= main
APT_ARCHITECTURES ?= amd64 source
APT_SIGN_KEY ?= apt@octium.dev
APT_KEYRING ?= $(APT_REPO_DIR)/octium-archive-keyring.gpg
APT_KEY_ASC ?= $(APT_REPO_DIR)/octium-archive-keyring.asc
APT_REPREPRO := reprepro --basedir $(APT_REPREPRO_BASE) --outdir $(APT_REPO_DIR)

aptkey:
	printf '%s\n' 'Key-Type: RSA' 'Key-Length: 4096' 'Key-Usage: sign,cert' 'Name-Real: Octium Apt Repository' 'Name-Email: apt@octium.dev' 'Expire-Date: 0' '%no-protection' '%commit' | gpg --batch --generate-key

aptfp:
	@APT_SIGN_KEY='$(APT_SIGN_KEY)' bash bin/aptfp

aptpubkeys:
	install -d '$(APT_REPO_DIR)'
	key_fp=$$(APT_SIGN_KEY='$(APT_SIGN_KEY)' bash bin/aptfp); \
	gpg --batch --yes --export "$$key_fp" > '$(APT_KEYRING)'; \
	gpg --batch --yes --armor --export "$$key_fp" > '$(APT_KEY_ASC)'; \
	printf '%s\n' "Published apt repository signing keys:" "  $(APT_KEYRING)" "  $(APT_KEY_ASC)"

aptrepo: aptpubkeys
	install -d '$(APT_REPREPRO_BASE)/conf' '$(APT_REPO_DIR)'
	key_fp=$$(APT_SIGN_KEY='$(APT_SIGN_KEY)' bash bin/aptfp); \
	printf '%s\n' \
		'Codename: $(APT_CODENAME)' \
		'Origin: Octium' \
		'Label: Octium Apt Repository' \
		'Architectures: $(APT_ARCHITECTURES)' \
		'Components: $(APT_COMPONENT)' \
		'Description: Octium apt repository' \
		"SignWith: $$key_fp" \
		> '$(APT_REPREPRO_BASE)/conf/distributions'
	$(APT_REPREPRO) export '$(APT_CODENAME)'

addeb: aptrepo
	@test -n '$(DEB)' || { echo "Usage: make addeb DEB=/path/to/package.deb" >&2; echo "   or: make addeb /path/to/package.deb" >&2; exit 2; }
	@test -f '$(DEB)' || { echo "No such .deb: $(DEB)" >&2; exit 2; }
	$(APT_REPREPRO) --component '$(APT_COMPONENT)' includedeb '$(APT_CODENAME)' '$(DEB)'

%.deb:
	@:
