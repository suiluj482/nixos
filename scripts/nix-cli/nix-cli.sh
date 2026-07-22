#!/usr/bin/env bash

if [[ -z "$1" ]]; then
  echo "Available shells:"
  ls "$TEMPLATES"
  exit 0
fi

if [[ -f "./flake.nix" ]]; then
  echo "flake.nix already exists, aborting"
  exit 1
fi

cp -r "$TEMPLATES/$1/." .
git add flake.nix .envrc 2>/dev/null
echo "Copied $1 shell. Run: nix develop (or direnv allow)"