{ config, lib, ... }:
{
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
        pagers = [
          {
            pager = "${lib.getExe config.programs.delta.package} --no-gitconfig --dark --syntax-theme=gruvbox-dark --paging=never --hyperlinks --hyperlinks-file-link-format=\"lazygit-edit://{path}:{line}\"";
          }
        ];
      };
    };
  };

  programs.gh.enable = true;
}
