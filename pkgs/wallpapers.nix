{
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "thinkpadism-wallpapers";
  version = "0.2";

  src = ../wallpapers;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/wallpapers/thinkpadism
    cp *.png *.jpg $out/share/wallpapers/thinkpadism/

    runHook postInstall
  '';

  meta = {
    description = "Wallpapers shipped with Thinkpadism";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
