# core implementation notes

このファイルは、AI に渡すための実装リファレンスです。現在値の source of truth はコードです。ここには公開面、統合前提、変更時に壊しやすい注意点だけを置きます。

設定値を写経しないでください。keymap、font、alias、package list、plugin list、静的 config の具体値は `modules/` と `files/` を直接確認します。

## Documentation policy

- `README.md`: 人向けに repo の目的、統合方法、公開面の境界を書く
- `llms.md`: AI 向けに公開 option、runtime contract、統合前提、壊しやすい注意を書く
- `lsp.md`: LSP の有効条件、実行時依存、project ごとの前提を書く。設定の最終的な source of truth は `modules/programs/nixvim/plugins.nix`
- `AGENTS.md`: 作業する agent 向けに検証手順と docs 更新判断を書く
- 静的設定ファイル、keymap、plugin、font、alias、package list の現在値は docs に複製しない。公開面だけを docs に残す

## Repository shape

- `home.nix`: Home Manager entrypoint。core option、program、shell、platform module を import する
- `modules/core.nix`: 基本の `core.*` option と `core.brew.resolved` を定義する
- `modules/programs/*`: 各 tool / app の Home Manager module。追加の公開 option を持つ場合がある
- `modules/platform/*`: Darwin、Linux、WSL 向け分岐
- `modules/system/*`: nix-darwin 側から必要に応じて import する補助 module
- `files/*`: module から配布する静的設定。具体値はここを SoT とする
- `lib/home-manager.nix`: Home Manager 統合時の共通既定値
- `lsp.md`: Neovim LSP の有効条件と Consumer 側の runtime 前提

## Known pitfalls

Karabiner-Elements の UI で設定保存すると、Home Manager が作る `~/.config/karabiner/karabiner.json` symlink が通常ファイルへ置換されることがある。反映確認時は symlink か確認し、必要なら consumer 側を `--override-input core /Users/hiroaki/.config/core` 付きで再適用する。

## Runtime contract

`home.nix` が前提にしている主な引数:

- `username`
- `homeDirectory`
- `coreConfig`
- `nixvim`
- `yaziPlugins`
- `hunk`

consumer は生の入力として `coreConfig` を渡します。repo 内の module は、評価後に正規化された `config.core` を参照します。

## Public config surface

公開面として追跡する `core.*` option:

- Identity: `core.identity.name`, `core.identity.email`
- System: `core.system.desktop`, `core.system.fonts`, `core.system.extended`, `core.system.devLevel`, `core.system.wsl`, `core.system.openFiles.soft`, `core.system.openFiles.hard`
- Apps: `core.apps.aerospace.enable`, `core.apps.aerospace.workspaces`, `core.apps.aerospace.floatingAppIds`, `core.apps.espanso.enable`, `core.apps.espanso.extraMatches`, `core.apps.ghostty.enable`, `core.apps.karabiner.enable`
- Shell: `core.shell.nushell.shellAliases`
- Homebrew: `core.brew.enable`, `core.brew.extraTaps`, `core.brew.extraBrews`, `core.brew.extraCasks`, `core.brew.extraMasApps`, `core.brew.resolved`

注意:

- `core.brew.resolved` は read-only の派生値。consumer が直接設定するものではない
- `core.apps.aerospace.workspaces` は workspace 生成、key binding、monitor assignment、app rule に影響する
- `core.apps.aerospace.workspaces.<name>.monitor` は monitor pattern の文字列、または優先順リスト。リストは先頭から最初に一致した monitor を使う
- `core.apps.espanso.extraMatches` は generated YAML として追加される
- consumer option を持たない配布設定の具体値は `modules/` と `files/` を確認する

## Integration notes

Home Manager では `(core + /home.nix)` を import し、`extraSpecialArgs` で runtime contract の引数を渡します。

nix-darwin 側で Homebrew を使う場合は、`modules/core.nix` と `modules/system/darwin-homebrew.nix` を同じ評価に import します。`darwin-homebrew.nix` は `config.core.brew.resolved` を `homebrew.*` に流します。

`modules/system/darwin-defaults.nix` と `modules/system/darwin-limits.nix` は必須ではありません。必要な host だけが import します。

## Integration samples

Standalone Home Manager:

```nix
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = {
    inherit username homeDirectory core coreConfig;
    nixvim = inputs.nixvim;
    yaziPlugins = inputs.yazi-plugins;
    hunk = inputs.hunk;
  };
  modules = [
    ({ core, ... }: {
      imports = [ (core + /home.nix) ];
    })
  ];
}
```

AeroSpace workspace の monitor fallback は `monitor = [ "3" "1" ];` のように指定します。

nix-darwin or NixOS with Home Manager:

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
      hunk = inputs.hunk;
    };
  };
}
```

nix-darwin Homebrew integration:

```nix
{
  imports = [
    (inputs.core + /modules/core.nix)
    (inputs.core + /modules/system/darwin-homebrew.nix)
    (inputs.core + /modules/system/darwin-defaults.nix)
    # Optional per host:
    # (inputs.core + /modules/system/darwin-limits.nix)
  ];
}
```

## Change rules

- `core.*` option を追加、削除、型変更、意味変更したら README と llms を更新する
- `home.nix` の required args や import 前提を変えたら README と llms を更新する
- consumer 側の integration example が古くなる変更では README を更新する
- `files/` や module 内部の現在値だけを変えた場合、docs に値を写さない
- keymap、font、alias、package list、plugin list の具体値変更だけなら原則 docs 不要
- consumer 影響や運用上の注意が増えた場合だけ、その注意を `llms.md` に反映する
- inactive な module を active に戻す、または active な module を外す場合は repository shape と公開面を確認する

## Verification

この repo は consumer 側 flake から `flake = false` input として使われます。consumer 環境で適用前検証をする時は、consumer 側の flake に対して `--override-input core /Users/hiroaki/.config/core` を使い、`eval` や `build` で確認します。
