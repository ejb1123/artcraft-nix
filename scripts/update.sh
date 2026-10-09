#!/usr/bin/env bash
# Bump sources.json to each app's latest GitHub release.
#
#   nix run .#update                    # every app
#   nix run .#update -- photocraft      # just these
#   nix run .#update -- --no-src ...    # skip source/cargo hashes (fast; binaries only)
#
# Binary hashes come straight from each release's SHA256SUMS.txt. Source hashes are prefetched,
# and cargoHash is found by building the vendored-deps derivation once with a fake hash.
# Set GITHUB_TOKEN to avoid API rate limits. Run from the repo root.
set -euo pipefail

SOURCES=sources.json
FAKE=sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
SYSTEM=$(nix eval --raw --impure --expr builtins.currentSystem)

[ -f "$SOURCES" ] || { echo "error: run from the repo root ($SOURCES not found)" >&2; exit 1; }

DO_SRC=1
APPS=()
for arg in "$@"; do
  case "$arg" in
    --no-src) DO_SRC=0 ;;
    -*) echo "unknown flag: $arg" >&2; exit 2 ;;
    *) APPS+=("$arg") ;;
  esac
done
if [ ${#APPS[@]} -eq 0 ]; then
  mapfile -t APPS < <(nix eval --json --file nix/apps.nix --apply builtins.attrNames | jq -r '.[]')
fi

gh_api() {
  curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} "https://api.github.com/$1"
}
to_sri() { nix hash convert --hash-algo sha256 --to sri "$1"; }
set_field() { # set_field <app> <jq path> <value>
  local tmp
  tmp=$(mktemp)
  jq --arg app "$1" --arg v "$3" "setpath([\$app] + $2; \$v)" "$SOURCES" >"$tmp" && mv "$tmp" "$SOURCES"
}

for app in "${APPS[@]}"; do
  tag=$(gh_api "repos/storytold/$app/releases/latest" | jq -r .tag_name)
  version=${tag#v}
  old=$(jq -r --arg a "$app" '.[$a].version // ""' "$SOURCES")
  cargo_hash=$(jq -r --arg a "$app" '.[$a].src.cargoHash // ""' "$SOURCES")
  if [ "$old" = "$version" ] && { [ "$DO_SRC" = 0 ] || { [ -n "$cargo_hash" ] && [ "$cargo_hash" != "$FAKE" ]; }; }; then
    echo "$app: up to date ($version)"
    continue
  fi
  echo "$app: ${old:-new} -> $version"

  sums=$(curl -fsSL "https://github.com/storytold/$app/releases/download/$tag/SHA256SUMS.txt")
  set_field "$app" '["version"]' "$version"
  set_field "$app" '["tag"]' "$tag"
  for pair in x86_64-linux:x86_64 aarch64-linux:aarch64; do
    sys=${pair%%:*} arch=${pair#*:}
    hex=$(awk -v f="$app-$version-linux-$arch.tar.gz" '$2 == f { print $1 }' <<<"$sums")
    [ -n "$hex" ] || { echo "error: no $arch tarball in $app $tag SHA256SUMS" >&2; exit 1; }
    set_field "$app" "[\"bin\",\"$sys\"]" "$(to_sri "$hex")"
  done

  if [ "$DO_SRC" = 1 ]; then
    set_field "$app" '["src","hash"]' "$(nix flake prefetch --json "github:storytold/$app/$tag" | jq -r .hash)"
    set_field "$app" '["src","cargoHash"]' "$FAKE"
    got=$(nix build --no-link ".#packages.$SYSTEM.$app-src.cargoDeps" 2>&1 | sed -n 's/^ *got: *//p' || true)
    [ -n "$got" ] || { echo "error: could not determine cargoHash for $app" >&2; exit 1; }
    set_field "$app" '["src","cargoHash"]' "$got"
  fi
done
