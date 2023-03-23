{ lib, stdenvNoCC, fetchFromGitHub, xmlstarlet, librsvg, xcursorgen }:

stdenvNoCC.mkDerivation rec {
  name = "mocu-xcursor";

  src = fetchFromGitHub {
    owner = "sevmeyer";
    repo = name;
    rev = "efdd71279b79bf1e2566c38becc5e7c4ab2d900c";
    sha256 = "sha256-DVHPUCq3y/f1cVHHKg/qXYr/pGGUcP98RhFuGzNhT/I=";
  };

  nativeBuildInputs = [ xmlstarlet librsvg xcursorgen ];

  dontPatchELF = true;
  dontRewriteSymlinks = true;

  postPatch = ''
    patchShebangs .
  '';

  buildPhase = ''
    ./make.sh
  '';

  installPhase = ''
    install -dm 0755 $out/share/icons
    cp -rv dist/. $out/share/icons/
  '';
}
