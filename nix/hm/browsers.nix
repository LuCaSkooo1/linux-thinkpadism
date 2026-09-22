# Browsers, forced dark.
#
# A Firefox-family browser decides its own colours three times over, and
# getting a dark desktop out of it means answering all three:
#
#   * The chrome (tabs, toolbar) follows browser.theme.toolbar-theme.
#   * Page content follows layout.css.prefers-color-scheme.content-override,
#     which otherwise asks the XDG appearance portal -- correct, but only
#     once the portal has answered, which is after the first paint.
#   * The window Firefox paints *before* any of that resolves is
#     browser.display.background_color. Leaving it at its default white is
#     exactly the white flash on startup.
self: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.thinkpadism;
  inherit (lib) mkIf mkMerge;

  isDark = cfg.theme == "thinkpad-dark" || lib.hasSuffix "-dark" cfg.theme;

  # Shared prefs. Everything here is about appearance or about not
  # phoning home; nothing changes LibreWolf's privacy defaults.
  darkPrefs = {
    # 0 = dark, 1 = light, 2 = follow the system. Pinning it means the
    # first paint is already right.
    "layout.css.prefers-color-scheme.content-override" =
      if isDark
      then 0
      else 1;
    "ui.systemUsesDarkTheme" =
      if isDark
      then 1
      else 0;

    # 0 = dark, 1 = light, 2 = system.
    "browser.theme.toolbar-theme" =
      if isDark
      then 0
      else 1;
    "browser.theme.content-theme" =
      if isDark
      then 0
      else 1;

    # The colour of the window before the first page paints. This is the
    # white flash.
    "browser.display.background_color" = "#141414";
    "browser.display.background_color.dark" = "#141414";

    # Match the rest of the rice: no animation.
    "toolkit.cosmeticAnimations.enabled" = false;
    "ui.prefersReducedMotion" = 1;

    # Wayland, properly.
    "widget.use-xdg-desktop-portal.file-picker" = 1;
    "widget.use-xdg-desktop-portal.mime-handler" = 1;

    # A T420 has no video decode block that Firefox will use and two
    # cores to spare, so keep the content process count modest rather
    # than letting it scale to 8 and swap.
    "dom.ipc.processCount" = 4;

    # No first-run tab, no sponsored tiles on the new tab page.
    "browser.aboutwelcome.enabled" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
  };

  # Dark scrollbars and a red accent in the chrome, which prefs alone
  # cannot reach.
  userChrome = ''
    /* Thinkpadism */
    :root {
      --toolbar-bgcolor: #1b1b1b !important;
      --toolbar-color: #e6e4e1 !important;
      --tab-selected-bgcolor: #232323 !important;
      --lwt-accent-color: #141414 !important;
    }

    /* The active tab gets the accent as a top rule, the way the window
       borders do. */
    .tabbrowser-tab[selected] .tab-background {
      border-top: 2px solid #b3121d !important;
      border-radius: 0 !important;
    }

    /* Square everything, to match the compositor. */
    .tab-background,
    #urlbar,
    #urlbar-background,
    #searchbar {
      border-radius: 0 !important;
    }
  '';

  userContent = ''
    /* Paint about:blank and friends dark so tab switching doesn't
       strobe. */
    @-moz-document url("about:blank"), url("about:newtab"), url("about:home") {
      :root, body { background: #141414 !important; }
    }
  '';

  profile = {
    id = 0;
    isDefault = true;
    settings = darkPrefs;
    inherit userChrome userContent;
  };
in {
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.browsers.librewolf {
      programs.librewolf = {
        enable = true;
        profiles.default = profile // {name = "default";};

        # LibreWolf's own overrides file. Re-enabling these is a
        # deliberate trade: without them every session starts logged out
        # of everything, which in practice gets people to turn LibreWolf
        # off entirely.
        settings = {
          # Keep cookies and history between sessions.
          "privacy.clearOnShutdown.history" = false;
          "privacy.clearOnShutdown.cookies" = false;
          "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
          "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = false;
          "network.cookie.lifetimePolicy" = 0;

          # resistFingerprinting forces a light colour scheme on every
          # page and a fixed window size. Turning it off is what makes
          # dark mode actually apply; letterboxing and RFP can go back on
          # if you would rather have the anti-fingerprinting.
          "privacy.resistFingerprinting" = false;
          "privacy.fingerprintingProtection" = true;

          # WebGL off breaks enough sites to be worth re-enabling.
          "webgl.disabled" = false;
        };
      };
    })

    (mkIf cfg.browsers.firefox {
      programs.firefox = {
        enable = true;
        profiles.default = profile // {name = "default";};
      };
    })
  ]);
}
