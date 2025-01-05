{ config, pkgs, lib, ...}: {

  imports = [
    ./hardware/vm-aarch64.nix
  ];

  # Setup qemu so we can run x86_64 binaries
  # boot.binfmt.emulatedSystems = ["x86_64-linux"];

  # Disable the default module and import our override. We have
  # customizations to make this work on aarch64.
  # disabledModules = [ "virtualisation/vmware-guest.nix" ];

  # Lots of stuff that uses aarch64 that claims doesn't work, but actually works.
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  virtualisation.vmware.guest.enable = true;

  # Share our host filesystem
  fileSystems."/host" = {
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    device = ".host:/";
    options = [
      "umask=22"
      "uid=1000"
      "gid=1000"
      "allow_other"
      "auto_unmount"
      "defaults"
    ];
  };

  # boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # boot.loader.systemd-boot.consoleMode = "0";

  networking.hostName = "nixos-dev";

  time.timeZone = "Asia/Jakarta";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
    };
  };

  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "dvorak";
    dpi = 180;
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;
    windowManager.xmonad.extraPackages = hPkgs: [
      hPkgs.xmobar
      hPkgs.yeganesh
    ];
    windowManager.xmonad.config = builtins.readFile ../xmonad/xmonad.hs;

    displayManager.lightdm = {
      enable = true;
      greeters.mini = {
        enable = false;
      };
    };
  };

  console.keyMap = "dvorak";

  services.printing.enable = false;
  
  environment.systemPackages = with pkgs; [
    xclip
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  networking.firewall.enable = false;
  networking.networkmanager.enable = true;
  networking.interfaces.ens160.useDHCP = true;
  
  system.stateVersion = "24.11";

  # This will add secrets.yml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "/home/rhariady/.ssh/id_ed25519" ];
  # This is using an age key that is expected to already be in the filesystem
  sops.age.keyFile = "/home/rhariady/.config/sops/age/keys.txt";
  # This will generate a new key if the key specified above does not exist
  sops.age.generateKey = true;
  # This is the actual specification of the secrets.
  sops.secrets.openapi_key = {};
}
