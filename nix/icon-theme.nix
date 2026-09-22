{
  lib,
  stdenvNoCC,
  gtk3,
}:
stdenvNoCC.mkDerivation {
  pname = "thinkpadism-icons";
  version = "0.2";

  src = ../icon_theme/ThinkpadismIcons;

  nativeBuildInputs = [gtk3];

  # The theme is ~2000 symlink aliases over ~550 real PNGs; copy it wholesale
  # and let gtk-update-icon-cache build the index.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons/ThinkpadismIcons
    cp -r . $out/share/icons/ThinkpadismIcons/

    gtk-update-icon-cache --force --quiet $out/share/icons/ThinkpadismIcons || true

    runHook postInstall
  '';

  meta = {
    description = "Red-accented retro pixel icon theme";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
