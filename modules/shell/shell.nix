{ pkgs, config, ... }:
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
    extraConfig = ''
      $env.config.buffer_editor = "nvim"
      $env.config.show_banner = false

      source ~/.config/nushell/aliases/git-aliases.nu
      source ~/.config/nushell/aliases/original-aliases.nu

      # zellij auto-start was convenient, but too aggressive as a shared default.
      # Re-enable if you want terminal-specific opt-in again.
      # if $nu.is-interactive and "ZELLIJ" not-in $env and "SSH_CLIENT" not-in $env and "WSL_DISTRO_NAME" not-in $env {
      #     let allow_terminals = ["ghostty", "WezTerm"]
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
