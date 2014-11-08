{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config = {
    allowUnfree = true;

    firefox = {
      enableAdobeFlash = true;
      enableGoogleTalkPlugin = true;
    };

    chromium = {
      enablePepperFlash = true;
      enablePepperPDF = true;
    };
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "suse-lenovo-x200"; # Define your hostname.
  networking.firewall.enable = true;
  networking.wireless = {
    enable = true;
    interfaces = [ "wlp3s0" ];
    userControlled.enable = true;
    userControlled.group = "wheel";
  };
  # networking.networkmanager.enable = true;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_US.UTF-8";
  };

  # List packages installed in system profile. To search by name, run:
  # -env -qaP | grep wget
  environment = {
    #variables = {
    # EDITOR = "vim";
    #};

    systemPackages = with pkgs; [
      which
      wget
      vim
      tmux
      zip
      unzipNLS

      (pkgs.lib.overrideDerivation fish (attrs: {
        version = "2.1.1-1077-g9d7fbd2";
        name = "fish-2.1.1-1077-g9d7fbd2";

        src = fetchurl {
          url = "https://build.opensuse.org/source/shells:fish:nightly:master/fish/fish_2.1.1-1077-g9d7fbd2.orig.tar.gz?rev=d11f870e805b9ccb7c1947f96162a5e9";
          sha256 = "e063338986076bea4ce0aaa2521be92cd5f12d8dc6769a6a1d143202b7a5ba9e";
        };
      }))

      curl
      mc
      mutt
      offlineimap
      msmtp
      git

      chromium
      firefoxWrapper
      thunderbird
      skype
      dropbox
      dropbox-cli
      inconsolata
      docker
      # networkmanagerapplet
      wpa_supplicant_gui
      (with haskellPackages; [
        ghc
        haskellPlatform
        xmonadContrib
        xmonadExtras
        xmonad
        xmobar
        encoding
        dmenu
      ])
    ];

    shellInit = ''
      export EDITOR=vim;
    '';
  };

  programs.ssh = {
    forwardX11 = true;
    startAgent = true;
  };


  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    autorun = true;
    synaptics.enable = true;
    synaptics.twoFingerScroll = true;
    layout = "us(dvp),ru";
    xkbOptions = "grp:caps_toggle";
    videoDrivers = [ "intel" ];

    # Enable the KDE Desktop Environment.
    displayManager.slim.enable = true;
    displayManager.desktopManagerHandlesLidAndPower = false;
    desktopManager.xfce.enable = true;
    windowManager.default = "xmonad";
    desktopManager.default = "xfce";
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
  };

  hardware.opengl.driSupport32Bit = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.gnzh = {
    name = "gnzh";
    group = "users";
    extraGroups = [ "wheel" ];
    uid = 1000;
    createHome = true;
    home = "/home/gnzh";
    shell = "/run/current-system/sw/bin/bash";
  };

}

# vim: ts=2:sts=2:sw=2:expandtab
