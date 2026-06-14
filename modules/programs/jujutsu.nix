{
  pkgs,
  config,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    lazyjj
  ];

  programs.jujutsu = {
    enable = true;

    settings = {
      aliases = {
        f = [
          "git"
          "fetch"
        ];
        p = [
          "git"
          "push"
        ];
      };
      user =
        lib.optionalAttrs (config.core.identity.name != null) {
          name = config.core.identity.name;
        }
        // lib.optionalAttrs (config.core.identity.email != null) {
          email = config.core.identity.email;
        };
      revset-aliases = {
        "immutable_heads()" = "builtin_immutable_heads() | present(main) | present(main@origin)";
      };
      ui.default-command = "log";
    };
  };

}
