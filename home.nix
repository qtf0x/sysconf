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
        checkConfig = false;
        config = {
          modifier = "Mod4";
          # Use kitty as default terminal
          terminal = "kitty";

          input."*" = {
            xkb_layout = "us";
            xkb_options = "caps:escape";
          };

          output."*" = {
            mode = "1920x1080@60hz";
            bg = "/home/qtf0x/Downloads/geese-rock-band.jpg fill";
          };

          window.titlebar = false;
          gaps = {
            #inner = 12;
            #outer = 5;
            smartBorders = "on";
            #smartGaps = "on";
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
          firefox

          # Sway extensions
          swaybg
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

          settings = {
            confirm_os_window_close = 0;
            dynamic_background_opacity = true;
            enable_audio_bell = false;
            mouse_hide_wait = "-1.0";
            window_padding_width = 10;
            background_opacity = "0.85";
            background_blur = 64;
          };
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
