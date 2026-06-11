# core

Determine Systems を使うマシン向けの、再利用前提の共通設定です。

このリポジトリ自体は flake ではありません。consumer 側の flake から `flake = false` の source input として読み込み、依存関係の固定と `flake.lock` の管理は consumer 側で行います。

## このリポジトリの役割

- 複数環境で再利用しやすい Home Manager / nix-darwin 向け設定をまとめる
- 秘密情報やホスト固有の値は持たず、consumer 側から `coreConfig` で受け取る
- 実装の詳細よりも、再利用可能な既定値と統合ポイントを提供する

主要な consumer は `/Users/hiroaki/.config/dotfiles` です。ただし、このリポジトリは consumer に依存しない共通部品として扱います。

## 提供するもの

- 基本環境: Nushell と補完・prompt・移動補助、Zellij と用途別 layout、`nh`、Nix 補助、検索・ファイル操作・システム確認系の共通 CLI 環境
- 開発ツール: Git、GitHub CLI、Lazygit、Jujutsu、Nixvim、Yazi などの開発向け設定。Nixvim は Treesitter ベースの構文表示と現在位置の文脈表示を含む
- デスクトップ連携: AeroSpace、Espanso、Ghostty、Karabiner などの GUI アプリ設定
- Codex 連携: macOS 向けの静的 hook 設定配布
- システム統合: Darwin / Linux / WSL の分岐、nix-darwin 向け defaults と open files limit の補助 module
- consumer 向け公開面: `core.*` option と `config.core.brew.resolved` を通じた上書き・統合ポイント

個別ツールの詳細や現在の option 一覧は `llms.md` を参照してください。

## ドキュメントの分担

- `README.md`: リポジトリの目的、公開される使い方、統合の入口
- `llms.md`: 実装寄りの詳細、現在の公開面、運用上の注意
- コード: 最終的な source of truth

ドキュメントはコードの要点を説明するためのものです。静的設定や細かい既定値を丸写しせず、変更に追従しやすい粒度に保ちます。

## 何が入っているか

- `home.nix`: Home Manager 向け entrypoint
- `modules/core.nix`: `core.*` option の定義と正規化
- `modules/programs/`: Git, Jujutsu, AeroSpace, Espanso, Ghostty, Karabiner, Yazi, Nixvim など
- `modules/programs/codex.nix`: Darwin 向けに Codex の hook 設定を配布
- `modules/platform/`: Darwin, Linux, WSL 向けの分岐
- `modules/system/`: 必要に応じて consumer から追加 import する nix-darwin 補助 module
- `files/`: 配布する静的設定ファイル
- `lib/home-manager.nix`: Home Manager 統合時の既定値

## 使い方

1. 親 flake の `inputs` に `core` を追加する
2. `extraSpecialArgs` で `coreConfig` と必要な引数を渡す
3. Home Manager module に `(core + /home.nix)` を import する

```nix
{
  inputs.core = {
    url = "path:/path/to/core";
    flake = false;
  };
}
```

```nix
extraSpecialArgs = {
  inherit username homeDirectory core;
  coreConfig = {
    system = {
      desktop = true;
      fonts = true;
      extended = true;
      devLevel = 2;
    };
  };
  nixvim = inputs.nixvim;
  yaziPlugins = inputs.yazi-plugins;
};
```

```nix
{
  core,
  ...
}:
{
  imports = [
    (core + /home.nix)
  ];
}
```

`home.nix` が前提にしている主な引数は `username`、`homeDirectory`、`coreConfig`、`nixvim`、`yaziPlugins` です。

## 設定の考え方

consumer 側は `coreConfig` を渡し、core 内部では `config.core` に正規化された値を module から参照します。

- 再利用可能な既定値は core 側に置く
- 個人識別情報は `coreConfig.identity` など consumer 側に置く
- ホスト固有のポリシーや最終的な有効化判断は consumer 側に置く

例:

```nix
{
  coreConfig = {
    identity = {
      name = "Your Name";
      email = "you@example.com";
    };

    apps.aerospace.workspaces.S = {
      monitor = "secondary";
      appIds = [ "com.tinyspeck.slackmacgap" ];
    };

    apps.espanso.extraMatches = [
      {
        trigger = ";mail";
        replace = "you@example.com";
      }
    ];

    shell.nushell.shellAliases.k = "kubectl";
    brew.extraBrews = [ "mole" ];
  };
}
```

## Darwin 統合

consumer 側で `modules/core.nix` を import すると、`config.core.brew.resolved` を `homebrew.*` に流せます。`modules/system/darwin-defaults.nix` と `modules/system/darwin-limits.nix` は必要な場合だけ追加 import します。

## サポート範囲

- 公開面として扱うのは、`home.nix`、`modules/core.nix` が定義する `core.*` option、必要に応じた `modules/system/*` の統合方法です
- Codex については `~/.codex/hooks.json` のような静的設定だけを扱い、Codex 本体のインストールやバージョン固定はこの repo では管理しません。更新が速いツールなので、`mise` など外部の tool manager 側に委ねます
- Zellij は core 管理の `config.kdl` と用途別 layout を配布しますが、現時点では consumer 向けの追加 `core.*` option は公開しません。ペイン管理の主担当は Zellij とし、Alt 系はペイン移動に限定します。リサイズは Zellij の resize mode 経由で扱います
- `files/` 配下の具体的な中身や、module 内部の細かい既定値は実装詳細であり、必要な要点だけを `llms.md` に記録します
- 常用の端末・pane・editor 体験は gruvbox dark 系に寄せ、透明・blur よりも文字の読みやすさを優先します

実装寄りの詳細や現在の option 一覧は `llms.md` を参照してください。
