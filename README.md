# artcraft-nix

Nix packages, an overlay and a NixOS module for the [ArtCraft](https://github.com/storytold)
Crafting Apps:

| Package | Like | | Package | Like |
|---|---|---|---|---|
| `photocraft` | Photoshop | | `wordcraft` | Word |
| `lightcraft` | Lightroom | | `gridcraft` | Excel |
| `filmcraft` | Premiere Pro | | `deckcraft` | PowerPoint |
| `effectcraft` | After Effects | | `pdfcraft` | Acrobat |
| `vectorcraft` | Illustrator | | `cadcraft` | AutoCAD |
| `designcraft` | — | | `soundcraft` | Pro Tools |

Every app comes in two flavours:

- **`<app>`**: the official prebuilt release tarball, patched for NixOS (fast to install).
- **`<app>-src`**: built from source with `rustPlatform`, following upstream's
  `packaging/linux/package.sh` (slow; nothing prebuilt).

`all` (the default package) bundles every prebuilt app. Supported on `x86_64-linux` and
`aarch64-linux`.

## Try one

```sh
nix run github:ejb1123/artcraft-nix#photocraft
nix run github:ejb1123/artcraft-nix#photocraft-src   # from source
```

## NixOS

```nix
# flake.nix
{
  inputs.artcraft.url = "github:ejb1123/artcraft-nix";
  inputs.artcraft.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { nixpkgs, artcraft, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        artcraft.nixosModules.default
        {
          programs.artcraft = {
            enable = true;
            apps = [ "photocraft" "vectorcraft" "filmcraft" ]; # default: all of them
            # fromSource = true;                               # build everything from source
          };
        }
      ];
    };
  };
}
```

The module also turns on `hardware.graphics` (the apps render with wgpu over Vulkan/GL).

## Home Manager / overlay

```nix
nixpkgs.overlays = [ artcraft.overlays.default ];
home.packages = with pkgs.artcraft; [ photocraft wordcraft-src ];
```

## Updating

Versions and hashes live in `sources.json`. To bump to the latest GitHub releases:

```sh
nix run .#update                 # all apps (binary + source + cargo hashes)
nix run .#update -- photocraft   # just one
nix run .#update -- --no-src     # binary hashes only (seconds)
```

Binary hashes come from each release's `SHA256SUMS.txt`. Set `GITHUB_TOKEN` to avoid API rate
limits. Hand-maintained per-app metadata (descriptions, cargo features, whether it needs ALSA) is
in `nix/apps.nix`.

## Layout

```
flake.nix            packages, overlay, nixosModules, update app
sources.json         versions + hashes (written by the updater)
nix/apps.nix         per-app metadata
nix/bin.nix          prebuilt-tarball builder (autoPatchelfHook)
nix/src.nix          from-source builder (rustPlatform)
nix/runtime-libs.nix libraries the apps dlopen (Vulkan, EGL, Wayland, X11, xkbcommon, dbus)
nix/module.nix       NixOS module
scripts/update.sh    updater
```

Not packaged: the `artcraft` engine and `artcraftx`, which publish no Linux release builds.
