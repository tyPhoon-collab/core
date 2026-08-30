{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.core.shell.nushell;
  worktrunkNushellConfig = pkgs.runCommand "worktrunk-nushell-config.nu" { } ''
    ${lib.getExe pkgs.worktrunk} config shell init nu > $out
  '';
  defaultAliases = {
    b = "bat";
    bru = "brew update";
    brg = "brew upgrade";
    lg = "lazygit";
    j = "just";
    la = "eza -a";
    ll = "eza -lah";
    lt = "eza --tree";
    m = "mise";
    nhd = "nh darwin switch .";
    nhh = "nh home switch .";
    nho = "nh os switch .";
    zw = "zellij -l welcome";
  };
in
{
  home.packages = [ pkgs.worktrunk ];

  programs.direnv = {
    enable = true;
    enableNushellIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = fromTOML (builtins.readFile ./starship.toml);
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.mise = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.bat.enable = true;

  programs.zellij = {
    enable = true;
    # The shared config file is distributed from modules/programs/zellij.nix.
  };

  programs.nushell = {
    enable = true;
    shellAliases = defaultAliases // cfg.shellAliases;
    extraConfig = ''
      $env.config.buffer_editor = "nvim"
      $env.config.edit_mode = "vi"
      $env.config.show_banner = false
      $env.config.history.file_format = "sqlite"
      $env.config.history.isolation = true

      source ${pkgs.nu_scripts}/share/nu_scripts/aliases/git/git-aliases.nu
      source ${../../files/nushell/completions/zmx.nu}
      source ${worktrunkNushellConfig}

      # zellij auto-start was convenient, but too aggressive as a shared default.
      # Re-enable if you want terminal-specific opt-in again.
      # if $nu.is-interactive and "ZELLIJ" not-in $env and "SSH_CLIENT" not-in $env and "WSL_DISTRO_NAME" not-in $env {
      #     let allow_terminals = ["ghostty"]
      #     if ($env.TERM_PROGRAM? in $allow_terminals) {
      #         exec zellij a -c main
      #     }
      # }
    '';

    extraEnv = ''
      $env.CARAPACE_BRIDGES = 'zsh,bash'
      $env.EDITOR = "nvim"
      $env.VISUAL = "nvim"
      $env.SUDO_EDITOR = "nvim"
    '';
  };
}
