#!/usr/bin/env bash

sudo nixos-rebuild switch -I nixos-config="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/configuration.nix"
