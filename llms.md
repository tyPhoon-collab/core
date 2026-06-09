# core implementation notes

このファイルは、人間と AI エージェント向けの実装リファレンスです。`README.md` は入口と公開契約、`llms.md` は実装に寄った詳細と運用ルールを扱います。最終的な source of truth はコードです。

## ドキュメント方針

- `README.md` には、repo の目的、統合方法、公開面として扱う範囲を書く
- `llms.md` には、現在の構成、公開 option、実装上の注意、consumer との整合条件を書く
- 静的設定ファイル、keymap、plugin の細かい値は、公開契約や運用上の注意でない限り複製しない
- 仕様を変えたら `README.md` と `llms.md` を役割分担に沿って更新する
- コードを読めば分かる現在値より、変更時に壊しやすい前提を優先して記録する

## Repository shape

- `home.nix`: Home Manager entrypoint。core option、shell/program/platform modules を import する
- `modules/core.nix`: `core.*` option を定義し、consumer の `coreConfig` を `config.core` に正規化する
- `modules/programs/*`: Git、Jujutsu、AeroSpace、Espanso、Ghostty、Karabiner、Yazi、Zellij、Nixvim、Codex などの module
- `modules/platform/*`: Darwin、Linux、WSL 向けの分岐
- `modules/system/*`: consumer 側から必要に応じて import する nix-darwin 補助 module
- `files/*`: module から配布する静的設定ファイル
- `lib/home-manager.nix`: Home Manager 統合時の共通既定値

## Runtime contract

`home.nix` が前提にしている主な引数:

- `username`
- `homeDirectory`
- `coreConfig`
- `nixvim`
- `yaziPlugins`

consumer は生の入力として `coreConfig` を渡します。この repo 内の module は、評価後に正規化された `config.core` を参照します。

## 公開 config surface

公開面として追跡すべき `core.*` option は次の通りです。

- Identity: `core.identity.name`, `core.identity.email`
- System: `core.system.desktop`, `core.system.fonts`, `core.system.extended`, `core.system.devLevel`, `core.system.wsl`, `core.system.openFiles.soft`, `core.system.openFiles.hard`
- Apps: `core.apps.aerospace.enable`, `core.apps.aerospace.workspaces`, `core.apps.aerospace.floatingAppIds`, `core.apps.espanso.enable`, `core.apps.espanso.extraMatches`, `core.apps.ghostty.enable`, `core.apps.karabiner.enable`
- Shell: `core.shell.nushell.shellAliases`
- Homebrew: `core.brew.enable`, `core.brew.extraTaps`, `core.brew.extraBrews`, `core.brew.extraCasks`, `core.brew.extraMasApps`, `core.brew.resolved`

補足:

- `core.apps.ghostty` と `core.apps.karabiner` は今のところ `enable` のみを公開する
- Zellij は設定ファイルを配布するが、consumer 向けの追加 `core.*` option はまだ持たない
- `core.shell.nushell` は今のところ `shellAliases` のみを公開する
- `core.brew.resolved` は read-only の派生値で、consumer が直接設定するものではない

## 振る舞いの要点

### Shell and base tools

Nushell を中心に、direnv、zoxide、starship、carapace、mise、Zellij を共通の shell 基盤として有効化します。

Nushell alias は core 既定値に `core.shell.nushell.shellAliases` を上書きマージします。Java や Maven のような project-local toolchain は固定 package ではなく、`mise` / `direnv` で供給する前提です。

Zellij は `files/zellij/config.kdl` と `files/zellij/layouts/*.kdl` を静的に配布します。pane 管理の主担当は Zellij とし、現時点では consumer 向けの option 化された override 面を持ちません。`work` layout は左に `nvim`、右に `codex` を置く開発用 layout です。

端末・pane・editor の通常テーマは gruvbox dark 系に寄せます。Ghostty は透明化や blur よりも文字のコントラストを優先し、gruvbox の淡い配色が眠くならない状態を既定にします。具体値は Ghostty module、Zellij 静的 config、Nixvim module をSSoTとし、ドキュメント側では方針だけを記録します。

常用 CLI として、`bat`、`eza`、`bottom`、`gdu`、`procs`、`fzf`、`ripgrep`、`fd`、`jq`、`file`、`p7zip`、`rsync` を有効化または配布します。Nix 周辺では `home-manager`、`nh`、`nix-output-monitor`、`nvd`、`nu_scripts` を含めます。

### Developer tools

Git、GitHub CLI、Lazygit、Jujutsu、Nixvim、Yazi を開発向けの既定ツールとして有効化します。`core.identity.*` が設定されている場合は、Git と Jujutsu の user 設定に反映します。

Nixvim は editor として常時有効です。大枠として、clipboard は system clipboard 寄り、Darwin 以外では OSC52 寄り、ファイル操作は Snacks explorer / Yazi 側、日常の pane 移動は Zellij 側に寄せます。

LSP や言語サポートは `core.system.devLevel` に応じて増えます。ただし Dart、Rust、Java、Maven などの project-local toolchain はこの repo では固定せず、project/devshell/tool manager 側を優先します。

Yazi は Nushell integration と wrapper を有効化し、`yaziPlugins` から plugin を受け取ります。preview 向け package は `core.system.extended` で増やします。

### Desktop apps and static config

AeroSpace、Espanso、Ghostty、Karabiner は `core.apps.*.enable` で配布を制御します。Darwin desktop 向けを主対象にしつつ、Espanso と Ghostty は Linux 側の条件分岐も持ちます。

AeroSpace は `core.apps.aerospace.workspaces` と `floatingAppIds` から設定を生成します。workspace は persistent workspace、key binding、monitor assignment、app move rule に反映されます。

Espanso は base config を配布し、`core.apps.espanso.extraMatches` がある場合だけ generated YAML を追加します。

Ghostty と Karabiner は現在、静的設定の配布有無だけを公開面にしています。細かい設定値は `files/` と module 実装をSSoTとします。

Codex は Darwin で `~/.codex/hooks.json` を静的設定として配布します。Codex 本体のインストールやバージョン固定は扱わず、`mise` など外部の tool manager に委ねます。

### Homebrew and Darwin modules

`modules/core.nix` は Darwin desktop 向けの built-in Homebrew base list を持ち、consumer の extra 設定とマージして `core.brew.resolved` を作ります。

consumer 側では、必要に応じて `modules/core.nix`、`modules/system/darwin-defaults.nix`、`modules/system/darwin-limits.nix` を import し、`config.core.brew.resolved` を `homebrew.*` に流します。

```nix
{
  imports = [
    (inputs.core + /modules/core.nix)
    (inputs.core + /modules/system/darwin-defaults.nix)
    (inputs.core + /modules/system/darwin-limits.nix)
  ];

  homebrew = {
    enable = true;
    taps = config.core.brew.resolved.taps;
    brews = config.core.brew.resolved.brews;
    casks = config.core.brew.resolved.casks;
    masApps = config.core.brew.resolved.masApps;
  };
}
```

## Integration examples

### Standalone Home Manager

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
      coreConfig = {
        system.devLevel = 2;
      };
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

### NixOS or nix-darwin with Home Manager

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

## Consumer alignment

主要 consumer である `/Users/hiroaki/.config/dotfiles` では、現在:

- `hosts/darwin/default.nix` から `modules/core.nix`、`modules/system/darwin-defaults.nix`、`modules/system/darwin-limits.nix` を import している
- `config.core.brew.resolved` を `homebrew.*` に流している
- `flake.nix` で `coreConfig` を構築し、`extraSpecialArgs` で渡している

この repo の docs は、この repo が standalone flake ではなく consumer から読み込まれる reusable source input である前提と整合させます。

## 変更時のチェックポイント

- 公開面を変えた場合は、`README.md` の説明と `llms.md` の公開 option を両方更新する
- 実装詳細だけを変えた場合は、必要な注意点だけを `llms.md` に反映する
- inactive なものを active に戻した場合、または active なものを外した場合は、公開面と repository shape の説明を更新する
- consumer 側の統合前提が変わった場合は、integration example と consumer alignment を更新する
- このマシンでの適用確認を行う場合は、consumer 側で `--override-input` を使って eval や build を検証する
