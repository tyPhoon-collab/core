# core

Determine Systems を使うマシン向けの共通設定です。

このリポジトリ自体は flake ではありません。consumer 側の flake から `flake = false` の source input として読み込み、依存関係の固定と `flake.lock` の管理は consumer 側で行います。

## 役割

- Home Manager / nix-darwin 向けの再利用可能な既定値をまとめる
- 秘密情報やホスト固有値は持たず、consumer 側から `coreConfig` で受け取る
- Darwin / Linux / WSL の分岐と、必要な nix-darwin 補助 module を提供する
- Codex などの AI agent 拡張は扱わず、別 repo の `agent-plugins` で管理する
- 個別ツールの現在値はコードを source of truth とし、ドキュメントには公開契約と統合方法だけを書く

## 構成

- `home.nix`: Home Manager 向け entrypoint
- `modules/core.nix`: 基本の `core.*` option と `core.brew.resolved`
- `modules/programs/`: shell、editor、terminal、desktop app などの Home Manager module
- `modules/platform/`: Darwin / Linux / WSL 向け分岐
- `modules/system/`: consumer 側から必要に応じて import する nix-darwin 補助 module
- `files/`: module から配布する静的設定
- `lib/home-manager.nix`: Home Manager 統合時の共通既定値

静的設定のうち Karabiner は、英数/かなキーを起点にした操作レイヤーを配布します。細かな割り当ては `files/karabiner/karabiner.json` を source of truth とし、ドキュメントには列挙しません。

Karabiner-Elements の設定画面で保存すると、Home Manager が張った `karabiner.json` の symlink が通常ファイルに置き換わる場合があります。core 側の変更を反映するには、consumer 側を再適用してから Karabiner-Elements を起動してください。

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

consumer 側は `coreConfig` を渡し、core 内部では正規化された `config.core` を参照します。

```nix
{
  coreConfig = {
    identity = {
      name = "Your Name";
      email = "you@example.com";
    };

    system = {
      desktop = true;
      fonts = true;
      extended = true;
      devLevel = 2;
    };

    shell.nushell.shellAliases.k = "kubectl";
    brew.extraBrews = [ "mole" ];
    brew.extraCasks = [ "nikitabobko/tap/aerospace" ];
  };
}
```

公開される `core.*` option の一覧と実装上の注意は `llms.md` を参照してください。細かい tool 設定、keymap、font、alias、静的 config の現在値は `modules/` と `files/` が source of truth です。Codex hooks などの AI agent plugin はこの repo では配布せず、`agent-plugins` 側で管理します。

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

- `README.md`: repo の目的、統合方法、公開面の境界
- `llms.md`: AI 向けの公開 option、壊しやすい前提、更新判断
- コード: 現在値の source of truth

仕様や公開面を変えた場合だけ、README と llms をこの分担に沿って更新します。実装詳細だけの変更では、必要な注意点がある場合だけ llms に反映します。
