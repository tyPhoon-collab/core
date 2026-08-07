# core

Determine Systems を使うマシン向けの共通設定です。

このリポジトリ自体は flake ではありません。consumer 側の flake から `flake = false` の source input として読み込み、依存関係の固定と `flake.lock` の管理は consumer 側で行います。

## 役割

- Home Manager / nix-darwin 向けの再利用可能な既定値をまとめる
- 秘密情報やホスト固有値は持たず、consumer 側から `coreConfig` で受け取る
- Darwin / Linux / WSL の分岐と、必要な nix-darwin 補助 module を提供する

## 構成

- `home.nix`: Home Manager 向け entrypoint
- `modules/core.nix`: 基本の `core.*` option と `core.brew.resolved`
- `modules/programs/`: shell、editor、terminal、desktop app などの Home Manager module
- `modules/platform/`: Darwin / Linux / WSL 向け分岐
- `modules/system/`: consumer 側から必要に応じて import する nix-darwin 補助 module
- `files/`: module から配布する静的設定
- `lib/home-manager.nix`: Home Manager 統合時の共通既定値

## 使い方

親 flake の input に `core` を追加します。

```nix
{
  inputs.core = {
    url = "path:/path/to/core";
    flake = false;
  };
}
```

Home Manager の `extraSpecialArgs` で必要な値を渡します。

```nix
extraSpecialArgs = {
  inherit username homeDirectory core;
  coreConfig = {
    system.desktop = true;
  };
  nixvim = inputs.nixvim;
  yaziPlugins = inputs.yazi-plugins;
};
```

Home Manager module から import します。

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

`home.nix` が前提にする主な引数は `username`、`homeDirectory`、`coreConfig`、`nixvim`、`yaziPlugins` です。

## 設定

consumer 側は `coreConfig` を渡し、core 内部では正規化された `config.core` を参照します。ここでは最小例だけ示します。実運用の組み合わせは consumer 側の repo で管理してください。

```nix
{
  coreConfig = {
    identity.email = "you@example.com";
    system.desktop = true;
    apps.aerospace.workspaces."5".monitor = [ "3" "1" ];
  };
}
```

公開される `core.*` option の一覧、runtime contract、実装上の注意は `llms.md` を参照してください。細かい tool 設定、keymap、font、alias、package list、静的 config の現在値は `modules/` と `files/` が source of truth です。

## Darwin 統合

consumer 側で Homebrew まで統合する場合は、必要に応じて system module を追加 import します。

```nix
{
  imports = [
    (inputs.core + /modules/core.nix)
    (inputs.core + /modules/system/darwin-homebrew.nix)
    (inputs.core + /modules/system/darwin-defaults.nix)
    (inputs.core + /modules/system/darwin-limits.nix)
  ];
}
```

`darwin-homebrew.nix` は `config.core.brew.resolved` を `homebrew.*` に流し込みます。`darwin-defaults.nix` と `darwin-limits.nix` は必要なホストだけで import します。

## ドキュメント方針

README は repo の目的、統合方法、公開面の境界だけを書きます。公開 option と更新判断は `llms.md`、作業規約は `AGENTS.md` を参照してください。現在値の一覧は docs に写さず、コードを source of truth とします。
