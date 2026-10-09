{
  description = "Nix packages and NixOS module for the ArtCraft Crafting Apps (storytold)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      apps = import ./nix/apps.nix;
      sources = lib.importJSON ./sources.json;

      mkPackages =
        pkgs:
        lib.concatMapAttrs (pname: app: {
          ${pname} = pkgs.callPackage ./nix/bin.nix {
            inherit pname app;
            source = sources.${pname};
          };
          "${pname}-src" = pkgs.callPackage ./nix/src.nix {
            inherit pname app;
            source = sources.${pname};
          };
        }) apps;
    in
    {
      packages = forAllSystems (
        pkgs:
        let
          appPkgs = mkPackages pkgs;
        in
        appPkgs
        // {
          all = pkgs.symlinkJoin {
            name = "artcraft-apps";
            paths = map (n: appPkgs.${n}) (lib.attrNames apps);
          };
          default = self.packages.${pkgs.stdenv.hostPlatform.system}.all;
          update = pkgs.writeShellApplication {
            name = "artcraft-update";
            runtimeInputs = with pkgs; [
              curl
              jq
              nix
              gnused
            ];
            text = builtins.readFile ./scripts/update.sh;
          };
        }
      );

      overlays.default = final: _prev: {
        artcraft = mkPackages final;
      };

      nixosModules.default = import ./nix/module.nix self;
      nixosModules.artcraft = self.nixosModules.default;

      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}
