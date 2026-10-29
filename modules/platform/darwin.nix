{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../programs/aerospace.nix
    ../programs/karabiner.nix
  ];

  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    home.packages = lib.optionals config.core.system.desktop [
      pkgs.macism
    ];

    targets.darwin.defaults."com.apple.symbolichotkeys".AppleSymbolicHotKeys =
      lib.mkIf config.core.system.desktop
        {
          "15".enabled = false; # ズーム機能
          "17".enabled = false; # ズームイン
          "19".enabled = false; # ズームアウト
          "21".enabled = false; # 画面の色を反転
          "23".enabled = false; # 画像のスムージング
          "25".enabled = false; # コントラストを上げる
          "26".enabled = false; # コントラストを下げる
          "52".enabled = false; # Dock の自動表示・非表示
          "60".enabled = false; # 前の入力ソース
          "61".enabled = false; # 次の入力ソース
          "64".enabled = false; # Spotlight 検索
          "65".enabled = false; # Finder の検索ウインドウ
          "98".enabled = false; # ヘルプメニューを表示
          "118".enabled = false; # デスクトップ 1
          "119".enabled = false; # デスクトップ 2
          "120".enabled = false; # デスクトップ 3
          "121".enabled = false; # デスクトップ 4
          "176".enabled = false; # Siri
          "179".enabled = false; # ズーム時のフォーカス追従
          "190".enabled = false; # クイックメモ
          "233".enabled = false; # ウインドウをしまう
        };

    # Nix Git ships a Darwin system config with osxkeychain enabled. Reset it
    # so consumers can choose their credential transport declaratively.
    programs.git.settings.credential.helper = [ "" ];
  };
}
