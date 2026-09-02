{ config, lib, pkgs, ... }:
let
  lazygitTab = pkgs.writeShellApplication {
    name = "lazygit-tab";
    runtimeInputs = with pkgs; [
      coreutils
      git
      jq
      config.programs.lazygit.package
      zellij
    ];
    text = builtins.readFile ../../files/bin/lazygit-tab;
  };
in
{
  home.packages = [ lazygitTab ];

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user =
        lib.optionalAttrs (config.core.identity.name != null) {
          name = config.core.identity.name;
        }
        // lib.optionalAttrs (config.core.identity.email != null) {
          email = config.core.identity.email;
        };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      merge.conflictStyle = "zdiff3";
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      dark = true;
      syntax-theme = "gruvbox-dark";
      line-numbers = true;
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        diffRenderers = [
          {
            command = "${lib.getExe config.programs.delta.package} --no-gitconfig --dark --syntax-theme=gruvbox-dark --paging=never --hyperlinks --hyperlinks-file-link-format=\"lazygit-edit://{path}:{line}\"";
          }
        ];
      };
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
}
