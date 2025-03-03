{ inputs, ... }:

{ config, lib, pkgs, ... }:

let
  # sources = import ../../nix/sources.nix;
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

in {
  home.stateVersion = "24.11";

  xdg.enable = true;
  xresources.extraConfig = builtins.readFile ./config/Xresources;

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  home.packages = [
    pkgs.glab
    pkgs.yq-go
    pkgs.watch
    (pkgs.google-cloud-sdk.withExtraComponents [
      pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])
    pkgs.kubectl
    pkgs.kubectx
    pkgs.k9s
    pkgs.yamllint
    pkgs.yamlfix
    pkgs.pre-commit
    pkgs.terraform
    pkgs.terraform-docs
    pkgs.terraform-ls
    pkgs.tfswitch
    pkgs.tflint
    pkgs.kubernetes-helm
    pkgs.helm-docs
    pkgs.pluto
  ];

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "emacs-client";
    PAGER = "less -FirSwX";
  };

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  # programs.gpg.enable = !isDarwin;

  programs.htop.enable = true;

  programs.jq.enable = true;

  programs.bash = {
    enable = true;
    shellOptions = [];
    historyControl = [ "ignoredups" "ignorespace" ];
    # initExtra = builtins.readFile ./bashrc;

    shellAliases = {
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gdiff = "git diff";
      gl = "git prettylog";
      gp = "git push";
      gs = "git status";
      gt = "git tag";
    };
  };

  programs.direnv= {
    enable = true;

    config = {
      whitelist = {
        exact = ["$HOME/.envrc"];
      };
    };
  };

  # programs.fish = {
  #   enable = true;
  #   interactiveShellInit = lib.strings.concatStrings (lib.strings.intersperse "\n" ([
  #     "source ${sources.theme-bobthefish}/functions/fish_prompt.fish"
  #     "source ${sources.theme-bobthefish}/functions/fish_right_prompt.fish"
  #     "source ${sources.theme-bobthefish}/functions/fish_title.fish"
  #     (builtins.readFile ./config.fish)
  #     "set -g SHELL ${pkgs.fish}/bin/fish"
  #   ]));

  #   shellAliases = {
  #     ga = "git add";
  #     gc = "git commit";
  #     gco = "git checkout";
  #     gcp = "git cherry-pick";
  #     gdiff = "git diff";
  #     gl = "git prettylog";
  #     gp = "git push";
  #     gs = "git status";
  #     gt = "git tag";

  #     jf = "jj git fetch";
  #     jn = "jj new";
  #     js = "jj st";
  #   } // (if isLinux then {
  #     # Two decades of using a Mac has made this such a strong memory
  #     # that I'm just going to keep it consistent.
  #     pbcopy = "xclip";
  #     pbpaste = "xclip -o";
  #   } else {});

  #   plugins = map (n: {
  #     name = n;
  #     src  = sources.${n};
  #   }) [
  #     "fish-fzf"
  #     "fish-foreign-env"
  #     "theme-bobthefish"
  #   ];
  # };

  programs.git = {
    enable = true;
    userName = "Ricky Hariady";
    userEmail = "ricky.hariady@tech.jago.com";
    aliases = {
      cleanup = "!git branch --merged | grep  -v '\\*\\|master\\|develop' | xargs -n 1 -r git branch -d";
      prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      root = "rev-parse --show-toplevel";
    };
    extraConfig = {
      branch.autosetuprebase = "always";
      color.ui = true;
      core.askPass = ""; # needs to be empty to use terminal for ask pass
      credential.helper = "store"; # want to make this more secure
      github.user = "orhan89";
      push.default = "tracking";
      init.defaultBranch = "main";
    };
  };

  programs.go = {
    enable = true;
    goPath = "Projects";
    goPrivate = [ "github.com/orhan89" ];
  };

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    shortcut = "l";
    secureSocket = false;
    mouse = true;

    extraConfig = ''
      set -ga terminal-overrides ",*256col*:Tc"

      set -g @dracula-show-battery false
      set -g @dracula-show-network false
      set -g @dracula-show-weather false

      bind -n C-k send-keys "clear"\; send-keys "Enter"
    '';
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.magit
      epkgs.org
      epkgs.zenburn-theme
      epkgs.web-mode
      epkgs.use-package
      epkgs.terraform-doc
      epkgs.terraform-mode
      epkgs.lsp-mode
      epkgs.lsp-ui
      epkgs.lsp-treemacs
      epkgs.kubernetes
      epkgs.kubernetes-helm
      epkgs.kubedoc
      epkgs.kubectx-mode
      epkgs.k8s-mode
      epkgs.json-mode
      epkgs.jedi
      epkgs.go-mode
      epkgs.flymake-go
      epkgs.flymake-easy
      epkgs.flycheck-yamllint
      epkgs.csv-mode
      epkgs.csv
      epkgs.company-terraform
      epkgs.company-quickhelp
      epkgs.async
      epkgs.ansible
      epkgs.nixos-options
      epkgs.company-nixos-options
      epkgs.helm-nixos-options
      epkgs.gptel
      epkgs.yasnippet
    ];
    extraConfig = builtins.readFile ./config/emacs;
  };

  programs.urxvt = {
    enable = true;
    fonts = [
      "xft:DejaVu Sans Mono"
    ];
  };

  programs.rofi = {
    enable = true;
    theme = "blue";
  };

  programs.xmobar = {
    enable = true;
    extraConfig = builtins.readFile ./config/xmobar;
  };

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      theme = "rose-pine";
      font-size = 20;
      font-family = "DeJaVu Sans Mono";
      window-decoration = false;
    };
  };

  # This will add secrets.yml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "/home/rhariady/.ssh/id_ed25519" ];
  # This is using an age key that is expected to already be in the filesystem
  sops.age.keyFile = "/home/rhariady/.config/sops/age/keys.txt";
  # This will generate a new key if the key specified above does not exist
  sops.age.generateKey = true;
  # This is the actual specification of the secrets.
  sops.secrets.openapi_key = {};
}
