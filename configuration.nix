{ config, ... }:

#{ ... }: {
let
  #sources = import ../nix/sources.nix;
  #pkgs = import sources.nixpkgs { };
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;
  #config = pkgs.config;
in

{
  imports = [
    ./hardware-configuration.nix
    
    
  ];

  # More hardware configuration #
  boot.loader.grub = {
    efiSupport = true;
    #efiInstallAsRemovable = true;
    device = "nodev";
  };
  fileSystems."/boot" = { device = "/dev/disk/by-uuid/70D6-1701"; fsType = "vfat"; };
  boot.initrd.kernelModules = [ "nvme" ];
  boot.kernelModules = [ "kvm-intel" "wl" "nvme" ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  # file:///mnt2/old-root/etc/fstab , https://github.com/tudurom/dotfiles/blob/df86674e0b4cd33a889e6cd8182af605887b86f6/machines/anton/hardware.nix
  fileSystems."/" = { device = "/dev/disk/by-uuid/d04c775a-e47f-4008-b5d4-11ac81c343b3"; fsType = "btrfs"; options = [ "defaults" "compress=zstd" "subvol=@" "noatime" ]; };
  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/d04c775a-e47f-4008-b5d4-11ac81c343b3";
      fsType = "btrfs";
      options = [ "defaults" "subvol=@home" "noatime" ];
    };
  # https://discourse.nixos.org/t/wrong-swap-partition-detected-by-nixos-generate-config-on-fresh-install/5355
  swapDevices =
    [ {
      device = "/dev/disk/by-uuid/c4aa5d0f-fe56-4cae-90ce-563fcd3364d4"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
  # #


  #boot.cleanTmpDir = true;
  networking.hostName = "MacBookPro";
  #networking.firewall.allowPing = true;
  #services.openssh.enable = true;
  #users.users.root.openssh.authorizedKeys.keys = [
  #  "" 
  #];


  # Enable CUPS to print documents.
  services.printing.enable = true;
  
  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;


  nix = {
    trustedUsers = [ "root" "sebastian" ];
  };


  # Define a user account. Don't forget to set a password with `passwd`.
  users = {
    users.sebastian = {
      #shell = pkgs.bash;
      #useDefaultShell = false;
      isNormalUser = true;
      home = "/home/sebastian";
      description = "Sebastian";
      extraGroups = [ "wheel" "networkmanager" ]; # Enable `sudo` for the user.
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    emacs
    vim
    git
    wget
    curl
    xclip
    dmidecode
    pciutils usbutils
    wirelesstools
    networkmanager
 ];

  
  #boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "broadcom-sta"
      "facetimehd-firmware"
    ];
  boot.loader.systemd-boot.enable = false; #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;  

  # https://github.com/siraben/dotfiles/blob/master/nixos/configuration.nix #

  #time.timeZone = "America/Chicago";
  #networking.hostId = //TODO: unique ID?

  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.0.0.1" "1.1.1.1" ];

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    
    fonts = with pkgs; [
      emojione
      noto-fonts
      noto-fonts-cjk
      noto-fonts-extra
      inconsolata
      material-icons
      liberation_ttf
      dejavu_fonts
      terminus_font
      siji
      unifont
    ];
    fontconfig.defaultFonts = {
      monospace = [
        "Hack" #"DejaVu Sans Mono"
      ];
      sansSerif = [
        "DejaVu Sans"
        "Noto Sans"
      ];
      serif = [
        "DejaVu Serif"
        "Noto Serif"
      ];
    };
  };

  # Etc #

  environment.pathsToLink = [ "libexec" ];
  services.xserver = {
    enable = true;
    
    desktopManager = {
      xterm.enable = false;
    };
    
    displayManager = {
      defaultSession = "none+i3";
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
        i3blocks
      ];
    };
  };

  system.stateVersion = "20.09";
}
