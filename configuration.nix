# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./home.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Swap partition
  boot.initrd.systemd.enable = true; # for lz4
  boot.zswap = {
    enable = true;
    compressor = "lz4";
  };

  boot.resumeDevice = "/dev/mapper/luks-2b5fa35a-0135-4cbd-a5ac-cb81c4dcfac1";
  boot.initrd.luks.devices."luks-2b5fa35a-0135-4cbd-a5ac-cb81c4dcfac1" = {
    device = "/dev/disk/by-uuid/2b5fa35a-0135-4cbd-a5ac-cb81c4dcfac1";
    allowDiscards = true;
    #randomEncryption = true; # not compatible with hibernation
  };
  swapDevices = [
    {
      device = "/dev/mapper/luks-2b5fa35a-0135-4cbd-a5ac-cb81c4dcfac1";
      options = [ "discard" ]; # equivalent to swapon --discard
    }
  ];

  # use hibernate when closing laptop lid
  services.logind.settings.Login = {
    HandleLidSwitch = "hibernate";
    HandleLidSwitchExternalPower = "hibernate";
    HandleLidSwitchDocked = "ignore";
  };

  networking.hostName = "lilac"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # enable brtfs compression and the noatime mount option
  # writing access times is a huge performance hit for no good reason
  fileSystems = {
    "/".options = [
      "compress=zstd"
      "noatime"
    ];
    "/home".options = [
      "compress=zstd"
      "noatime"
    ];
    "/nix".options = [
      "compress=zstd"
      "noatime"
    ];
  };

  # Monitor file checksums for bitrot (defaults to monthly)
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Necessary in order to configure Sway through Home Manager
  security.polkit.enable = true;

  # Enable GNOME Keyring to store secrets for applications
  services.gnome.gnome-keyring.enable = true;

  # Install Sway
  programs.sway.enable = true;

  # Set up greeter
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };

  # Enable the X11 windowing system.
  #services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    options = "caps:escape";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."qtf0x" = {
    isNormalUser = true;
    description = "Aster Marias";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      neovim
      kitty
      thunderbird
      github-cli
      gnupg
      pinentry-all
      zotero
      discord
      tree
      rustup
      nodejs
      gimp
      # Neovim reqs
      git
      gnumake
      unzip
      gcc
      ripgrep
      fd
      xclip
    ];
  };

  fonts.fontDir.enable = true;

  programs.bash.enable = true;

  programs.steam = {
    enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wl-clipboard # Copy/Paste functionality
    mako # Notification utility
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Git configuration
  programs.git = {
    enable = true;
    config = {
      user = {
        name = "Aster Marias";
        email = "aster@slware.org";
        signingkey = "0BFFAD39C2D4FBD0";
      };

      gpg.program = "gpg";
      commit.gpgsign = true;
      tag.gpgsign = true;
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Add any missing dynamic libraries for unpackaged programs
      # here, NOT in environment.systemPackages
      rust-analyzer
    ];
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
