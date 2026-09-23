# The Thinkpadism GTK themes.
#
# Both variants are generated at build time from the upstream Platinum
# theme by scripts/make-gtk-themes.py, so the repository carries one copy
# of the widget geometry and the palette is derived rather than duplicated.
# Editing the source theme updates both variants on the next rebuild.
{
  lib,
  stdenvNoCC,
  python3,
}: let
  python = python3.withPackages (ps: [ps.pillow]);
in
  stdenvNoCC.mkDerivation {
    pname = "thinkpadism-gtk-theme";
    version = "0.3";

    srcs = [];
    dontUnpack = true;

    nativeBuildInputs = [python];

    buildPhase = ''
      runHook preBuild

      mkdir -p themes
      python3 ${../scripts/make-gtk-themes.py} \
        --source ${../gtk_theme/ClassicPlatinumStreamlined} \
        --out themes

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/themes
      cp -r themes/* $out/share/themes/

      # The upstream theme is kept alongside the generated pair, so the
      # original look is still selectable from nwg-look.
      cp -r ${../gtk_theme/ClassicPlatinumStreamlined} \
        $out/share/themes/ClassicPlatinumStreamlined

      runHook postInstall
    '';

    meta = {
      description = "Platinum-style GTK themes in ThinkPad red, light and dark";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  }
