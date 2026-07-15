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
      # Configure keymap again in case GNOME overwrites XKB options
      #dconf.settings = {
      #  "org/gnome/desktop/input-sources" = {
      #    xkb-options = [ "caps:escape" ];
      #  };
      #};

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

      home = {
        packages = with pkgs; [
          mpv
          wget
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
