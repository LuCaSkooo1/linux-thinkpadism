{
  lib,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "thinkpadism-gtk-theme";
  version = "0.2";

  src = ../gtk_theme/ClassicPlatinumStreamlined;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/themes/ClassicPlatinumStreamlined
    cp -r . $out/share/themes/ClassicPlatinumStreamlined/

    runHook postInstall
  '';

  meta = {
    description = "Classic Platinum GTK theme, as shipped with Thinkpadism";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
