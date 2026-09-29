{ ... }:
{
  xdg.configFile = {
    "leaf/config.toml" = {
      source = ../../files/leaf/config.toml;
      force = true;
    };
    "leaf/theme/gruvbox.toml" = {
      source = ../../files/leaf/theme/gruvbox.toml;
      force = true;
    };
  };
}
