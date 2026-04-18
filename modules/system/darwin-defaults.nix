{ ... }:
{
  security.pam.services.sudo_local.touchIdAuth = true;

  # https://github.com/nix-darwin/nix-darwin/tree/master/modules/system/defaults
  system.defaults = {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      ApplePressAndHoldEnabled = false;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.0;
      expose-group-apps = true;
      show-recents = false;
      mru-spaces = false;
    };
    trackpad = {
      Clicking = true;
    };
    spaces.spans-displays = false; # For Ice app.
    finder = {
      QuitMenuItem = true;
      FXEnableExtensionChangeWarning = false;
      _FXShowPosixPathInTitle = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXDefaultSearchScope = "SCcf";
      FXPreferredViewStyle = "Nlsv";
    };
    screencapture = {
      disable-shadow = true;
      location = "~/Downloads";
    };
    universalaccess = {
      mouseDriverCursorSize = 2.5;
      reduceMotion = true;
    };
  };

  # zsh を有効にしないと darwin-rebuild が正常に動作しない場合があります
  programs.zsh.enable = true;
}
