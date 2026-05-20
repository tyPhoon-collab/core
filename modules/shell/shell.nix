{
  pkgs,
  config,
  ...
}:
let
  cfg = config.core.shell.nushell;
  defaultAliases = {
    j = "just";
    m = "mise";
    nhd = "nh darwin switch .";
    nhh = "nh home switch .";
    nho = "nh os switch .";
  };
in
{
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
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.mise = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.zellij = {
    enable = true;
  };

  programs.nushell = {
    enable = true;
    shellAliases = defaultAliases // cfg.shellAliases;
    extraConfig = ''
      $env.config.buffer_editor = "nvim"
      $env.config.show_banner = false

      source ${pkgs.nu_scripts}/share/nu_scripts/aliases/git/git-aliases.nu

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
      $env.SUDO_EDITOR = "${config.programs.nixvim.package}/bin/nvim"
    '';
  };
}
