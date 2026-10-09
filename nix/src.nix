# Build an app from source, mirroring each repo's packaging/linux/package.sh.
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
  callPackage,

  pname,
  app,
  source,
}:
let
  appId = "ai.storyteller.${pname}";
  runtimeLibs = callPackage ./runtime-libs.nix { };
  features = app.features or [ ];
in
rustPlatform.buildRustPackage {
  pname = "${pname}-src";
  inherit (source) version;

  src = fetchFromGitHub {
    owner = "storytold";
    repo = pname;
    rev = source.tag;
    hash = source.src.hash;
  };

  inherit (source.src) cargoHash;

  cargoBuildFlags = [
    "-p"
    pname
    "-p"
    "${pname}-cli"
  ];
  buildFeatures = features;

  # The test suites are large (corpora, GPU tests); upstream CI covers them.
  doCheck = false;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = lib.optional (app.audio or false) alsa-lib;

  postInstall = ''
    install -Dm644 packaging/linux/${appId}.desktop $out/share/applications/${appId}.desktop
    install -Dm644 packaging/linux/${appId}.mime.xml $out/share/mime/packages/${appId}.xml
    mkdir -p $out/share/metainfo
    sed -e "s/@VERSION@/${source.version}/g" -e "s/@DATE@/1970-01-01/g" \
      packaging/linux/${appId}.metainfo.xml.in > $out/share/metainfo/${appId}.metainfo.xml
    mkdir -p $out/share/icons
    cp -R assets/app-icon/hicolor $out/share/icons/
  '';

  postFixup = ''
    for f in $out/bin/*; do
      patchelf --add-rpath ${lib.makeLibraryPath runtimeLibs} "$f"
    done
  '';

  meta = {
    inherit (app) description;
    homepage = "https://github.com/storytold/${pname}";
    changelog = "https://github.com/storytold/${pname}/releases/tag/${source.tag}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    platforms = lib.platforms.linux;
    mainProgram = pname;
  };
}
