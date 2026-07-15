{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager = {
    useGlobalPkgs = true;
    users."qtf0x" = { pkgs, ... }: {
      wayland.windowManager.sway = {
        enable = true;
        wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps
        config = rec {
          modifier = "Mod4";
          # Use kitty as default terminal
          terminal = "kitty";

          input."*" = {
            xkb_layout = "us";
            xkb_options = "caps:escape";
          };
        };
      };

      fonts.fontconfig.enable = true;

      home = {
        packages = with pkgs; [
          mpv
          wget
          iosevka-bin
          obsidian
          zotero
          tmux
        ];

        sessionVariables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };

        # The state version is required and should stay at the version you
        # originally installed.
        stateVersion = "26.05";
      };

      programs = {
        home-manager.enable = true;

        kitty = {
          enable = true;
          font.name = "Iosevka Fixed";
        };

        bash = {
          enable = true;
          shellAliases = {
            nv = "nvim";
            ls = "ls -lah --color";
          };

          initExtra = ''
            # Include .profile if it exists
            [[ -f ~/.profile ]] && . ~/.profile
          '';
        };
      };
    };
  };
}
