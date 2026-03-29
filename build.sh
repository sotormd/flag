#!/usr/bin/env bash

nix build .#nixosConfigurations.flag.config.pattern.release
nix run github:sotormd/pattern#sign-release -- ./result ./flag-gpg
mkdir -p /var/tmp/update
rm -rf /var/tmp/update/*
cp -r pattern-release/. /var/tmp/update/
chmod -R a+rX /var/tmp/update
rm -rf pattern-release
