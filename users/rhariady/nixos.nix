{ pkgs, inputs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" ];

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  # Since we're using fish as our shell
  programs.fish.enable = true;

  users.users.rhariady = {
    isNormalUser = true;
    home = "/home/rhariady";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.fish;
    hashedPassword = "$6$FE/3ZnTrXPK2tVCN$3fMbvtJuDhft5lst04lz0uWXQnKr6Ebi9OsV5bbvvbdXA27kowlqf0WiRrKiTDcofyxc150zsiL3ndxFvnSr3/";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMbTbgKxquozGbbNUIuSUkU3vJVWXeqZHMbYa62nUHuc NB-DK-0330"
    ];
  };
}
