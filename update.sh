#!/usr/bin/env bash

set -euo pipefail

nix build .#nixosConfigurations.flag.config.pattern.release --option allow-import-from-derivation true
nix run github:sotormd/pattern#sign-release -- ./result ./flag-gpg

tmpdir="$(mktemp -d /var/tmp/update.XXXXXX)"

cp -r pattern-release/. "$tmpdir/"

chmod -R a+rX "$tmpdir"

# atomic swap?
mv -T "$tmpdir" /var/tmp/update

rm -rf pattern-release
