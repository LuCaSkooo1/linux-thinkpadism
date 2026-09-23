{
  lib,
  symlinkJoin,
  makeWrapper,
  quickshell,
  kdePackages,
  # Runtime tools the shell shells out to. Passed in so they can be
  # swapped without rebuilding the QML tree.
  coreutils,
  jq,
  # The QML tree. Overridable so you can point the wrapper at a checkout you
  # are editing instead of the one in the store.
  configPath ? ../configs/quickshell,
}: let
  qmlPath = lib.makeSearchPath "lib/qt-6/qml" [
    kdePackages.qtbase
    kdePackages.qtdeclarative
    kdePackages.qt5compat
  ];

  # `jq` for the launcher keybind and coreutils for the mkdir the settings
  # bootstrap does. `hyprctl` is deliberately left out: it is already on PATH
  # inside a Hyprland session, and depending on it here would drag the whole
  # compositor into this package's closure.
  runtimePath = lib.makeBinPath [
    coreutils
    jq
  ];
in
  symlinkJoin {
    pname = "thinkpadism";
    inherit (quickshell) version;

    paths = [quickshell];
    nativeBuildInputs = [makeWrapper];

    postBuild = ''
      makeWrapper $out/bin/quickshell $out/bin/thinkpadism \
        --set QML2_IMPORT_PATH "${qmlPath}" \
        --prefix PATH : "${runtimePath}" \
        --add-flags '-p ${configPath}'
    '';

    meta = {
      description = "Red-accented retro Quickshell desktop shell for Hyprland";
      homepage = "https://github.com/LuCaSkooo1/linux-thinkpadism";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
      mainProgram = "thinkpadism";
    };
  }
