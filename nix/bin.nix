# Package an app from its official prebuilt Linux release tarball.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  alsa-lib,
  callPackage,

  pname,
  app,
  source,
}:
let
  system = stdenv.hostPlatform.system;
  arch =
    {
      x86_64-linux = "x86_64";
      aarch64-linux = "aarch64";
    }
    .${system} or (throw "${pname}: unsupported system ${system}");
  runtimeLibs = callPackage ./runtime-libs.nix { };
in
stdenv.mkDerivation {
  inherit pname;
  inherit (source) version;

  src = fetchurl {
    url = "https://github.com/storytold/${pname}/releases/download/${source.tag}/${pname}-${source.version}-linux-${arch}.tar.gz";
    hash = source.bin.${system};
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ] ++ lib.optional (app.audio or false) alsa-lib;
  runtimeDependencies = runtimeLibs;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r bin share $out/
    runHook postInstall
  '';

  meta = {
    inherit (app) description;
    homepage = "https://github.com/storytold/${pname}";
    changelog = "https://github.com/storytold/${pname}/releases/tag/${source.tag}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = pname;
  };
}
