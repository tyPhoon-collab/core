{
  lib,
  pkgs,
  username,
  features,
  ...
}:
lib.mkIf (pkgs.stdenv.isLinux && features.wsl) {
  # Activation Script for WSL config files
  home.activation.syncWslConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Runtime check: Ensure we are actually running on WSL
    if ! grep -qi microsoft /proc/version; then
      exit 0
    fi

    # Sync .wslconfig to Windows User Profile
    WIN_HOME="/mnt/c/Users/${username}"
    SRC_WSLCONFIG="$HOME/.config/wsl/.wslconfig"

    if [ -d "$WIN_HOME" ] && [ -f "$SRC_WSLCONFIG" ]; then
      if ! cmp -s "$SRC_WSLCONFIG" "$WIN_HOME/.wslconfig"; then
        cp -f "$SRC_WSLCONFIG" "$WIN_HOME/.wslconfig"
        echo "Updated Windows .wslconfig. Run 'wsl --shutdown' to apply."
      fi
    fi

    # Sync wsl.conf to /etc/wsl.conf (Requires sudo)
    SRC_WSLCONF="$HOME/.config/wsl/wsl.conf"

    if [ -f "$SRC_WSLCONF" ]; then
      if ! cmp -s "$SRC_WSLCONF" "/etc/wsl.conf"; then
        echo "WSL config changed. Run: sudo cp $SRC_WSLCONF /etc/wsl.conf"
      fi
    fi
  '';

  home.file.".config/wsl/wsl.conf".text = ''
    [boot]
    systemd=true

    [interop]
    appendWindowsPath = false

    [automount]
    options = "metadata"
  '';

  home.file.".config/wsl/.wslconfig".text = ''
    [wsl2]
    networkingMode=mirrored

    [experimental]
    sparseVhd=true
    hostAddressLoopback=true
  '';

  programs.nushell = {
    shellAliases = {
      # Windows Tools (Explicit paths because appendWindowsPath=false)
      "wsl" = "/mnt/c/Windows/System32/wsl.exe";
      "pwsh" = "^'/mnt/c/Program Files/PowerShell/7/pwsh.exe'";
      "explorer" = "/mnt/c/Windows/explorer.exe";
      "winget" = "/mnt/c/Users/${username}/AppData/Local/Microsoft/WindowsApps/winget.exe";
    };
  };
}