{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  ruby,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "idef0-svg-gost";
  version = "unstable-2018-10-14";
  src = fetchFromGitHub {
    owner = "jimmyjazz";
    repo = "IDEF0-SVG";
    rev = "f689fe913260e0582905a9cb8ef7434c960112ea";
    hash = "sha256-sbKEfiASZT7s2CXIiENnglv0zPdiptaIEhyrOvVw0yw=";
  };
  patches = [
    ./patches/0001-layout-fixes.patch
    ./patches/0002-gost-styling.patch
  ];
  nativeBuildInputs = [makeWrapper];
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib $out/bin
    cp -r lib/idef0 $out/lib/
    for bin in bin/*; do
      name=$(basename "$bin")
      install -Dm755 "$bin" "$out/bin/$name"
      wrapProgram "$out/bin/$name" \
        --prefix PATH : ${lib.makeBinPath [ruby]}
    done
    runHook postInstall
  '';
  meta = {
    description = "IDEF0 diagram renderer patched for Cyrillic layout and GOST styling";
    homepage = "https://github.com/jimmyjazz/IDEF0-SVG";
    license = lib.licenses.mit;
    maintainers = [];
    mainProgram = "schematic";
    platforms = lib.platforms.unix;
  };
})
