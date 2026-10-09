# NixOS module: `programs.artcraft.enable = true;` installs the Crafting Apps system-wide.
self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.artcraft;
  apps = import ./apps.nix;
  flakePkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
  pkgFor = name: if cfg.fromSource then flakePkgs."${name}-src" else flakePkgs.${name};
in
{
  options.programs.artcraft = {
    enable = lib.mkEnableOption "the ArtCraft Crafting Apps";

    apps = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (lib.attrNames apps));
      default = lib.attrNames apps;
      defaultText = lib.literalExpression "all apps";
      example = [
        "photocraft"
        "vectorcraft"
      ];
      description = "Which Crafting Apps to install.";
    };

    fromSource = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Build the apps from source instead of using the official prebuilt release binaries.
        Much slower, but nothing prebuilt is installed.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = map pkgFor cfg.apps;
    # Vulkan/GL drivers for wgpu.
    hardware.graphics.enable = lib.mkDefault true;
  };
}
