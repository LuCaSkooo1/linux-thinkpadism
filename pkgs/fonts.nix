# The rice's own fonts: Monaco (terminal, lock screen) and Charcoal (menu
# titles). The bar loads them straight from its QML tree, but everything
# else needs them installed like any other font.
{
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "thinkpadism-fonts";
  version = "0.3";

  src = ../configs/quickshell/fonts;

  installPhase = ''
    runHook preInstall
    install -Dm644 Monaco.ttf Charcoal.ttf -t $out/share/fonts/truetype/thinkpadism
    runHook postInstall
  '';

  meta = {
    description = "Monaco and Charcoal, as used by the Thinkpadism desktop";
    platforms = lib.platforms.all;
  };
}
