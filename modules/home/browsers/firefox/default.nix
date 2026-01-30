{ pkgs, ... }:
let
  csshacks = pkgs.fetchFromGitHub {
    owner = "MrOtherGuy";
    repo = "firefox-csshacks";
    rev = "bedf5da5134360f5031dbd5ea78f0ccb2937c99b";
    sha256 = "sha256-XmBzgKFCHz3uE45NhUpbAYi4OP939wE8biufgudDzrc=";
  };
in
{
  programs.firefox = {
    enable = true;
    profiles.default = {
      name = "Default";

      settings = {
        "browser.urlbar.suggest.searches" = true; # Need this for basic search suggestions
        "browser.urlbar.shortcuts.bookmarks" = false;
        "browser.urlbar.shortcuts.history" = false;
        "browser.urlbar.shortcuts.tabs" = false;

        "browser.tabs.tabMinWidth" = 75; # Make tabs able to be smaller to prevent scrolling

        "browser.urlbar.placeholderName" = "DuckDuckGo";
        "browser.urlbar.placeholderName.private" = "DuckDuckGo";

        "browser.aboutConfig.showWarning" = false; # No warning when going to config
        "browser.warnOnQuitShortcut" = false;

        "browser.tabs.loadInBackground" = true; # Load tabs automatically
        "media.ffmpeg.vaapi.enabled" = true; # Enable hardware acceleration

        "browser.in-content.dark-mode" = true; # Use dark mode
        "ui.systemUsesDarkTheme" = true;

        "extensions.autoDisableScopes" = 0; # Automatically enable extensions
        "extensions.update.enabled" = false;

        "widget.use-xdg-desktop-portal.file-picker" = 0; # Use new gtk file picker instead of legacy one

        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "layers.acceleration.force-enabled" = true;
        "gfx.webrender.all" = true;
        "gfx.webrender.enabled" = true;
        "layout.css.backdrop-filter.enabled" = true;
        "svg.context-properties.content.enabled" = true;
      };

      userChrome = ''
        @import url(${csshacks}/chrome/hide_tabs_toolbar_v2.css)
      '';

      search = {
        force = true;
        default = "ddg";
        order = [
          "ddg"
          "NixOS Options"
          "Nix Packages"
          "GitHub"
          "HackerNews"
        ];
        engines = {
          "Nix Packages" = {
            icon = "https://nixos.org/_astro/flake-blue.Bf2X2kC4_Z1yqDoT.svg";
            definedAliases = [ "@np" ];
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                  {
                    name = "channel";
                    value = "unstable";
                  }
                ];
              }
            ];
            metaData.hideOneOffButton = true;
          };

          "NixOS Options" = {
            icon = "https://nixos.org/_astro/flake-blue.Bf2X2kC4_Z1yqDoT.svg";
            definedAliases = [ "@no" ];
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            metaData.hideOneOffButton = true;
          };

          "GitHub" = {
            icon = "https://github.com/favicon.ico";
            definedAliases = [ "@gh" ];

            urls = [
              {
                template = "https://github.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            metaData.hideOneOffButton = true;
          };

          "Home Manager" = {
            icon = "https://home-manager-options.extranix.com/images/home-manager-option-search2.png";
            definedAliases = [ "@hm" ];

            urls = [
              {
                template = "https://home-manager-options.extranix.com/?&release=master";
                params = [
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            metaData.hideOneOffButton = true;
          };
        };
      };
    };
  };
}
