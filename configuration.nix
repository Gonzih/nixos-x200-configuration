{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./mopidy.nix
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
  networking.firewall.allowedTCPPorts = [ 8080 ];
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];
  # networking.wireless = {
  #   enable = true;
  #   interfaces = [ "wlp3s0" ];
  #   userControlled.enable = true;
  #   userControlled.group = "wheel";
  # };
  networking.networkmanager.enable = true;

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
    etc = {
      "X11/xorg.conf.d/10-evdev.conf".text = ''
        Section "InputClass"
                Identifier  "Marble Mouse"
                MatchProduct "Logitech USB Trackball"
                MatchIsPointer "on"
                MatchDevicePath "/dev/input/event*"
                Driver "evdev"
        #       Physical button #s:     A b D - - - - B C    b = A & D simultaneously;   - = no button
        #       Option "ButtonMapping" "1 8 3 4 5 6 7 2 2"
                Option "ButtonMapping" "1 2 3 4 5 6 7 2 8"   #  From my configuration
        #       Option "ButtonMapping" "1 8 3 4 5 6 7 2 2"   #  For right-hand placement
        #       Option "ButtonMapping" "3 8 1 4 5 6 7 2 2"   #  For left-hand placement
        #
        #       EmulateWheel refers to emulating a mouse wheel using Marble Mouse trackball.
                Option "GrabDevice" "true"
                Option "EmulateWheel" "true"
                Option "EmulateWheelButton" "8"              # Factory default; use "9" for left-side placement.
                Option "EmulateWheelInertia" "30"            # Factory default: 50
                Option "EmulateWheelTimeout" "1"
        #       Option "EmulateWheelButton" "9"
                Option "ZAxisMapping" "4 5"
        #       Option "XAxisMapping" "6 7"                  # Disable this for vertical-only scrolling.
        #       Emulate3Buttons refers to the act of pressing buttons A and D
        #       simultaneously to emulate a middle-click or wheel click.
                Option "Emulate3Buttons" "true"
        #       Option "Emulate3Buttons" "true"              # Factory default.
        EndSection
      '';

      "X11/xorg.conf.d/20-thinkpad.conf".text = ''
        Section "InputClass"
          Identifier  "Trackpoint Wheel Emulation"
          MatchProduct  "TPPS/2 IBM TrackPoint|DualPoint Stick|Synaptics Inc. Composite TouchPad / TrackPoint|ThinkPad USB Keyboard with TrackPoint|USB Trackpoint pointing device|Composite TouchPad / TrackPoint"
          MatchDevicePath "/dev/input/event*"
          Option    "EmulateWheel"    "true"
          Option    "EmulateWheelButton"  "2"
          Option    "Emulate3Buttons" "false"
          Option    "XAxisMapping"    "6 7"
          Option    "YAxisMapping"    "4 5"
        EndSection
      '';
    };

    #variables = {
    # EDITOR = "vim";
    #};

    systemPackages = with pkgs; [
      which
      wget
      vim
      tmux
      htop
      mc
      mosh
      zip
      unzipNLS

      (pkgs.lib.overrideDerivation fish (attrs: {
        version = "2.1.1-1077-g09bac97";
        name = "fish-2.1.1-1077-g09bac97";

        # Source https://build.opensuse.org/package/show/shells:fish:nightly:master/fish
        src = fetchurl {
          url = "https://build.opensuse.org/source/shells:fish:nightly:master/fish/fish_2.1.1-1079-g09bac97.orig.tar.gz?rev=939d598d253fa5ace19e59d348854983";
          sha256 = "9a0d70ad441746250e9b6a5860a8f84d24dc1e36b470dceb6fb78c209854187b";
        };
      }))

      curl
      mutt-with-sidebar
      offlineimap
      msmtp
      git

      st
      chromium
      firefoxWrapper
      thunderbird
      skype
      inconsolata
      docker
      networkmanagerapplet
      openvpn
      # wpa_supplicant_gui
      (with haskellPackages; [
        ghc
        # haskellPlatform
        xmonadContrib
        xmonadExtras
        xmonad
        xmobar
        encoding
        dmenu
      ])

      teamviewer9
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

  services.journald.extraConfig = ''
    SystemMaxUse=500M
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.gnzh = {
    name = "gnzh";
    group = "users";
    extraGroups = [ "wheel" "networkmanager" "dialout" "audio" ];
    uid = 1000;
    createHome = true;
    home = "/home/gnzh";
    shell = "/run/current-system/sw/bin/bash";
  };

}

# vim: ts=2:sts=2:sw=2:expandtab
