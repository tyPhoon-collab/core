# core

個人用端末群の環境構築に使う、再利用用の core 設定です。

このリポジトリは flake ではなく、親の flake から `flake = false` の source input として読み込む前提です。依存関係の固定や `flake.lock` の管理は親リポジトリ側で行います。

## クイックスタート

1. 親 flake の `inputs` に `core` を追加
2. `extraSpecialArgs` と必要なら `specialArgs` で `coreConfig` を渡す
3. Home Manager モジュールに `(core + /home.nix)` を import

入力例:

```nix
{
  inputs.core = {
    url = "path:/path/to/core";
    flake = false;
  };
}
```

引数の受け渡し例:

```nix
extraSpecialArgs = {
  inherit username homeDirectory core;
  coreConfig = {
    system = {
      desktop = true;
      extended = true;
      fonts = true;
      devLevel = 2;
    };
  };
  nixvim = inputs.nixvim;
  yaziPlugins = inputs.yazi-plugins;
};
```

import 例:

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

## このリポジトリが持つもの

- `home.nix`: core エントリーポイント
- `modules/`: Home Manager / platform 向けモジュール
- `lib/`: 取り込み側で使う helper
- `files/`: 各種設定ファイル
- `docs/`: 取り込み側での上書きガイド

扱うのは、複数環境で使い回せる環境構築のコアだけです。秘密情報やホスト固有の値は含めません。

## ディレクトリ構成

```text
.
├── home.nix
├── lib/
│   └── home-manager.nix
├── files/
│   ├── aerospace/
│   ├── espanso/
│   ├── karabiner/
│   ├── nushell/
│   └── wezterm/
├── modules/
│   ├── platform/
│   ├── programs/
│   ├── shell/
│   └── system/
└── docs/
    └── overrides/
```

## 必要な引数

`home.nix` は少なくとも次を受け取ります。

- `username`
- `homeDirectory`
- `coreConfig`
- `nixvim`
- `yaziPlugins`

加えて、Home Manager が通常渡す `pkgs` や `lib` を利用します。

## Home Manager のシステム統合

NixOS / nix-darwin に Home Manager を組み込む場合は、共通の既定値として
`lib/home-manager.nix` の `default` を利用できます。

```nix
let
  coreHomeManager = import (core + /lib/home-manager.nix);
in
{
  home-manager = coreHomeManager.default // {
    users.${username} = import ./home.nix;
    extraSpecialArgs = {
      inherit username homeDirectory core coreConfig;
      nixvim = inputs.nixvim;
      yaziPlugins = inputs.yazi-plugins;
    };
  };
}
```

取り込み側で同じ属性を書いた場合は、取り込み側の値が優先されます。

## Core Config Tree

`core` は、取り込み側からひとつの設定木を流し込めるように、`core.*` の
public schema を持ちます。まずは次の軸から始めています。

- `core.system.*`
- `core.identity.*`
- `core.apps.aerospace.*`
- `core.apps.espanso.*`
- `core.apps.wezterm.*`
- `core.apps.karabiner.*`
- `core.brew.*`

取り込み側では、この設定木を `coreConfig` として 1 つ渡す想定です。

```nix
let
  coreConfig = {
    system = {
      desktop = true;
      fonts = true;
      extended = true;
      devLevel = 2;
    };

    identity = {
      name = "Your Name";
      email = "you@example.com";
    };

    apps.aerospace.extraRules = {
      "company.thebrowser.dia".workspace = "B";
    };

    apps.espanso.extraMatches = [
      {
        trigger = ";mail";
        replace = "you@example.com";
      }
    ];

    brew.extraBrews = [ "mole" ];
  };
in
{
  specialArgs = {
    inherit coreConfig;
  };

  home-manager.extraSpecialArgs = {
    inherit coreConfig;
  };
}
```

Home Manager や nix-darwin の module 側では、この `coreConfig` をもとに
`core.*` option の既定値が決まります。必要なら module 側で
`core.apps.aerospace.enable = false;` のようにさらに上書きできます。

```nix
{
  core = {
    system = {
      desktop = true;
      fonts = true;
      extended = true;
      devLevel = 2;
    };

    identity = {
      name = "Your Name";
      email = "you@example.com";
    };

    apps.aerospace.extraRules = {
      "company.thebrowser.dia".workspace = "B";
    };

    apps.espanso.extraMatches = [
      {
        trigger = ";mail";
        replace = "you@example.com";
      }
    ];

    brew.extraBrews = [ "mole" ];
  };
}
```

`core.brew.resolved` には、core 側の標準リストと `extra*` をマージした結果が入ります。
Darwin 側ではこの値を `homebrew.*` に流し込む使い方を想定しています。

`coreConfig` は外から渡す生の入力です。module 評価後の正規化済み状態は
`config.core` に集約されます。通常、consumer 側が触るのは `coreConfig`、
core 内部 module が参照するのは `config.core` です。

## 役割の境界

| core 側に置く                          | 親リポジトリ側に置く             |
| -------------------------------------- | -------------------------------- |
| 再利用できる shell / editor / CLI 設定 | ユーザー名やホスト固有の識別情報 |
| 公開して問題ない静的ファイル           | マシンごとに変わるポリシー       |
| 汎用的な macOS / Linux 向け設定        | 秘密情報                         |

## 設定の上書き

取り込み側で差分を重ねるためのガイドをモジュール別に分離しています。

- [AeroSpace の上書き](docs/overrides/aerospace.md)
- [Git の上書き](docs/overrides/git.md)
- [Jujutsu の上書き](docs/overrides/jujutsu.md)

共通ルール:

- core 側は再利用できる既定値のみを持つ
- 個人識別情報（ユーザー名やメールアドレス）は `coreConfig.identity` など取り込み側で設定する
- ホスト固有・環境固有のポリシーは取り込み側で設定する

`git` と `jujutsu` の個人識別情報は、通常は `coreConfig.identity` でまとめて渡します。

```nix
{
  coreConfig.identity = {
    name = "Your Name";
    email = "you@example.com";
  };
}
```

## 補足

`modules/system/darwin-defaults.nix` は、必要なら親リポジトリ側で直接 import して使えます。

Darwin 向けの標準 Homebrew リストは `modules/core.nix` の既定値として持ち、
親リポジトリ側では `config.core.brew.resolved` を `homebrew.*` に流し込む想定です。

例:

```nix
{
  username,
  homeDirectory,
  inputs,
  coreConfig,
  config,
  ...
}:
{
  imports = [
    (inputs.core + /modules/core.nix)
    (inputs.core + /modules/system/darwin-defaults.nix)
  ];

  system.primaryUser = username;

  homebrew = {
    enable = true;
    taps = config.core.brew.resolved.taps;
    brews = config.core.brew.resolved.brews;
    casks = config.core.brew.resolved.casks;
    masApps = config.core.brew.resolved.masApps;
  };

  users.users.${username} = {
    name = username;
    home = homeDirectory;
  };
}
```

`darwin-defaults.nix` を取り込んで `system.defaults` を適用する場合、`darwin-rebuild` を実行するターミナルや Nix 関連プロセスに Full Disk Access が必要になることがあります。

## Standalone Home Manager の最小例

親 flake から `core` を読み込んで、standalone Home Manager に組み込む最小構成です。

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    core = {
      url = "path:/path/to/core";
      flake = false;
    };
    nixvim.url = "github:nix-community/nixvim";
    yazi-plugins = {
      url = "github:yazi-rs/plugins";
      flake = false;
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, core, ... }:
    let
      system = "x86_64-linux";
      username = "user";
      homeDirectory = "/home/user";
      pkgs = import nixpkgs { inherit system; };
      coreConfig.system.devLevel = 2;
    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit username homeDirectory core coreConfig;
          nixvim = inputs.nixvim;
          yaziPlugins = inputs.yazi-plugins;
        };
        modules = [
          ({ core, ... }: {
            imports = [ (core + /home.nix) ];
          })
        ];
      };
    };
}
```

## NixOS / nix-darwin 統合の最小例

NixOS / nix-darwin の module として Home Manager を組み込む場合は、
`lib/home-manager.nix` の `default` を `home-manager` 設定に重ねます。

```nix
let
  coreHomeManager = import (core + /lib/home-manager.nix);
in
{
  modules = [
    home-manager.nixosModules.home-manager
    {
      home-manager = coreHomeManager.default // {
        users.${username} = import ./home.nix;
        extraSpecialArgs = {
          inherit username homeDirectory core coreConfig;
          nixvim = inputs.nixvim;
          yaziPlugins = inputs.yazi-plugins;
        };
      };
    }
  ];
}
```
