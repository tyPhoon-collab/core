# core

Determine Systems を使うマシン向けの、再利用前提の共通設定です。

このリポジトリは flake ではありません。consumer 側の flake から `flake = false` の source input として読み込み、依存関係の固定と `flake.lock` の管理は consumer 側で行います。

## 何が入っているか

- `home.nix`: Home Manager 向けの entrypoint
- `modules/`: `core.*` option と各種 module
- `files/`: 配布する静的設定ファイル
- `lib/home-manager.nix`: Home Manager 統合時の共通既定値

扱うのは複数環境で再利用しやすい設定だけです。秘密情報やホスト固有の値は持ちません。

## 使い方

### AIエージェント向け

`llms.md` を参照すること

### 人間向け

1. 親 flake の `inputs` に `core` を追加する
2. `extraSpecialArgs` と必要なら `specialArgs` で `coreConfig` を渡す
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

consumer 側からは `coreConfig` を渡します。core 内部ではこれをもとに `config.core` が正規化され、各 module は `config.core` を参照します。

- 再利用できる既定値は core 側に置く
- 個人識別情報は `coreConfig.identity` など consumer 側に置く
- ホスト固有のポリシーは consumer 側に置く

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

