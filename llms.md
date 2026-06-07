# core implementation notes

このファイルは、人間と AI エージェント向けの実装リファレンスです。`README.md` は入口と公開契約、`llms.md` は実装に寄った詳細と運用ルールを扱います。最終的な source of truth はコードです。

## ドキュメント方針

- `README.md` には「何のための repo か」「どう統合するか」「何を公開面とみなすか」を書く
- `llms.md` には「現在の構成」「公開 option の実態」「実装上の注意」「consumer との整合条件」を書く
- コードを読めば分かる静的設定の全文や細かい値は、必要がない限りドキュメントに複製しない
- 実装が変わったら、`README.md` と `llms.md` の両方を、役割分担に沿って更新する
- 「書いてあること」と「書いていないこと」の境界は意図的に管理する。公開契約でない内部詳細は、無理に README に出さない

## Repository shape

- `home.nix`
  Home Manager entrypoint。`modules/core.nix`、shell/program/platform modules を import する
- `modules/core.nix`
  `core.*` option を定義し、`coreConfig` から `config.core` を組み立てる
- `modules/programs/*`
  Git、Jujutsu、AeroSpace、Espanso、Ghostty、Karabiner、Yazi、Zellij、Nixvim などの module
- `modules/programs/codex.nix`
  Darwin 向けに `files/codex/hooks.json` を `~/.codex/hooks.json` として配布する
- `modules/platform/*`
  Darwin、Linux、WSL 向けの分岐
- `modules/system/darwin-defaults.nix`
  nix-darwin の `system.defaults` と `programs.zsh.enable`
- `modules/system/darwin-limits.nix`
  `core.system.openFiles.*` を `launchctl limit maxfiles` に反映
- `lib/home-manager.nix`
  Home Manager 統合時の共通既定値

補足:

- `modules/programs/wezterm.nix` と `files/wezterm/` は tree に残っているが、`home.nix` から import されていない
- したがって WezTerm は現時点では inactive であり、公開面には含めない

## Runtime contract

`home.nix` が前提にしている引数:

- `username`
- `homeDirectory`
- `nixvim`
- `yaziPlugins`
- `coreConfig`

`coreConfig` は consumer が渡す生の入力です。module 評価後、内部では正規化済みの `config.core` を参照します。

- consumer は基本的に `coreConfig` を書く
- この repo 内の module は `config.core` を読む

## 公開 config surface

現状、公開面として追跡すべき `core.*` は次の通りです。

- `core.identity.name`
- `core.identity.email`
- `core.system.desktop`
- `core.system.fonts`
- `core.system.extended`
- `core.system.devLevel`
- `core.system.wsl`
- `core.system.openFiles.soft`
- `core.system.openFiles.hard`
- `core.apps.aerospace.enable`
- `core.apps.aerospace.workspaces`
- `core.apps.aerospace.floatingAppIds`
- `core.apps.espanso.enable`
- `core.apps.espanso.extraMatches`
- `core.apps.ghostty.enable`
- `core.apps.karabiner.enable`
- `core.shell.nushell.shellAliases`
- `core.brew.enable`
- `core.brew.extraTaps`
- `core.brew.extraBrews`
- `core.brew.extraCasks`
- `core.brew.extraMasApps`
- `core.brew.resolved`

補足:

- `core.apps.ghostty` と `core.apps.karabiner` は今のところ `enable` のみを公開する
- Zellij は設定ファイルを配布するが、consumer 向けの追加 `core.*` option はまだ持たない
- `core.shell.nushell` は今のところ `shellAliases` のみを公開する
- `core.brew.resolved` は read-only の派生値で、consumer が直接設定するものではない

## 振る舞いの要点

### Shell and base tools

- `programs.nushell.enable = true`
- alias は `defaultAliases // cfg.shellAliases` でマージされる
- core 既定 alias は `b`, `j`, `m`, `nhd`, `nhh`, `nho`
- `direnv`、`zoxide`、`starship`、`carapace`、`mise`、`bat`、`zellij` を有効化する
- `modules/programs/zellij.nix` が `files/zellij/config.kdl` を `xdg.configFile."zellij/config.kdl"` として配布する
- `modules/programs/codex.nix` が Darwin で `files/codex/hooks.json` を `xdg.configFile."codex/hooks.json"` として配布する
- Zellij の keybind や theme は静的ファイル管理で、Nix option 化された公開 override 面はまだない
- 日常の pane 管理は Zellij 側を主担当とし、locked でも `Alt+矢印` / `Alt+h/j/k/l` で移動できる前提にする
- Java や Maven のような project-local toolchain は固定 package ではなく `mise` 前提

### Codex

- Darwin では `~/.codex/hooks.json` を core 側の静的ファイルとして配布する
- 現在の hook は `PermissionRequest` と `Stop` に対する通知音用 command hook を含む
- これは consumer 向けの公開 option ではなく、内部実装として管理する
- Codex 本体のインストールやバージョン固定はこの repo では扱わない
- Codex は更新速度が高いため、実行バイナリの管理は `mise` など外部の tool manager に委ねる前提にする

### Git

- `programs.git.enable = true`
- `programs.git.lfs.enable = true`
- 既定値は `init.defaultBranch = "main"`、`pull.rebase = true`、`push.autoSetupRemote = true`
- `config.core.identity.*` があれば `programs.git.settings.user.*` に流す
- `programs.lazygit.enable = true`
- `programs.gh.enable = true`
- Nixvim 側で Git keymap も追加する

Consumer override example:

```nix
{
  coreConfig.identity = {
    name = "Your Name";
    email = "you@example.com";
  };

  programs.git.settings.pull.rebase = false;
}
```

### Jujutsu

- `programs.jujutsu.enable = true`
- alias `f` と `p` を定義する
- `ui.default-command = "log"`
- `revset-aliases."immutable_heads()" = "builtin_immutable_heads() | present(main) | present(main@origin)"`
- `config.core.identity.*` があれば `programs.jujutsu.settings.user.*` に流す

Consumer override example:

```nix
{
  coreConfig.identity = {
    name = "Your Name";
    email = "you@example.com";
  };

  programs.jujutsu.settings = {
    git.push-bookmark-prefix = "hiroaki/";
    ui.paginate = "auto";
  };
}
```

### AeroSpace

- `core.apps.aerospace.enable` が true のとき `xdg.configFile."aerospace/aerospace.toml"` を生成する
- ベースファイルは `files/aerospace/aerospace.toml`
- `core.apps.aerospace.workspaces.<name>` で workspace を定義する
- workspace ごとに `enable`、`monitor`、`appIds` を持つ
- 有効な workspace は persistent workspace、`alt-<key>`、`alt-shift-<key>`、monitor assignment、`on-window-detected` に反映される
- `core.apps.aerospace.floatingAppIds` は floating window rule を追加する

Consumer override example:

```nix
{
  core.apps.aerospace.workspaces.S = {
    monitor = "secondary";
    appIds = [ "com.tinyspeck.slackmacgap" ];
  };

  core.apps.aerospace.workspaces.B.appIds = [
    "company.thebrowser.dia"
  ];

  core.apps.aerospace.floatingAppIds = [
    "com.apple.Preview"
  ];
}
```

Additional notes:

- `workspaces.<name>` の `enable` は既定で `true`
- `S` は `workspaceOrder` に含まれるが、built-in default workspace set には含まれない
- `appIds` は有効化された workspace に対してだけ rule になる

### Espanso

- `core.apps.espanso.enable` が true のとき Espanso 設定を配布する
- Darwin では `xdg.configFile` のみ
- Linux では `xdg.configFile` に加えて `services.espanso` も有効化する
- `core.apps.espanso.extraMatches` が非空なら追加の generated YAML を出力する

Consumer override example:

```nix
{
  core.apps.espanso.extraMatches = [
    {
      trigger = ";mail";
      replace = "you@example.com";
    }
  ];
}
```

### Ghostty and Karabiner

- `core.apps.ghostty.enable` は Ghostty config の配布を制御する
- Ghostty の既定値は `Catppuccin Mocha`、`background-opacity = 0.85`、`background-opacity-cells = true`、`background-blur = true`
- 半透明背景は見た目優先ではなく可読性とのバランス重視の既定値として扱う
- `core.apps.karabiner.enable` は Karabiner config の配布を制御する
- 追加の公開 option はまだ持たない

### Nixvim

- `programs.nixvim.enable = true`
- `defaultEditor = true`、`viAlias = true`、`vimAlias = true`
- provider は絞り、Node / Perl / Python / Ruby provider は Home Manager 側からは持たない
- clipboard は基本 `unnamedplus` を使い、Darwin 以外では global clipboard provider を `osc52` に寄せる
- `netrw` は完全に無効化し、ファイル操作は `Snacks.explorer` と `yazi.nvim` 側に寄せる
- colorscheme は `catppuccin` の `mocha`
- Catppuccin は `transparent_background = true` とし、通常バッファ、split terminal、float を含めて広めに端末側の半透明背景を見せる
- `number`、`expandtab`、`ignorecase + smartcase`、`signcolumn=yes`、`cursorline`、`scrolloff=8`、`splitbelow/splitright`、`undofile`、`breakindent`、`confirm` を基本既定値にする
- `completeopt = menuone,noselect,popup`、`pumborder = rounded`、`winborder = rounded`
- IME まわりは `macism` があれば `InsertLeave` / `TermLeave` / `CmdlineEnter` で英数入力へ戻す
- `FocusGained` / `TermClose` / `CursorHold` / `CursorHoldI` で `checktime` を走らせ、外部変更の自動追従を優先する
- LSP は `core.system.devLevel >= 1` で有効
- `jsonls`、`lua_ls`、`nixd`、`marksman` は `devLevel >= 1`
- `bashls`、`ts_ls`、`pyright`、`yamlls` は `devLevel >= 2`
- `jdtls` は `core.system.devLevel >= 2` で有効
- `dartls` も `devLevel >= 2` で有効だが package は固定しない
- `rust_analyzer` も `devLevel >= 2` で有効だが `rustc` / `cargo` はここで配らない
- insert mode では `tn` を `<Esc>`、terminal mode では `tn` を `<C-\><C-n>` に割り当てる
- terminal mode では `<A-Esc>` でも normal mode に戻せる
- `n` / `N` は検索結果へ移動した後に `zz` と `zv` を入れて、中央寄せと fold 展開を行う
- Normal mode の `J` は join lines のまま維持する
- `cutlass.nvim` を追加し、`c`/`d`/`x` 系は既定で black-hole register に流して unnamed / system clipboard を汚しにくくする
- ただし `flash.nvim` と衝突しないよう、`s` / `S` の cutlass 上書きは無効化する
- 専用の `cut` キーはまだ増やさず、必要なら consumer 側で追加判断する
- `smear-cursor.nvim` を有効にし、カーソル移動に控えめなアニメーションを付ける
- upstream README の紹介値に近い stiffness / damping を採用し、insert mode でもアニメーションを有効にする
- Visual mode の `J` / `K` で選択範囲を上下移動し、Normal / Insert mode の `<A-j>` / `<A-k>` で現在行を上下移動する
- `Snacks` は `explorer`、`picker`、`terminal`、`toggle`、`scope`、`notifier`、`quickfile` などを有効化し、dashboard も有効にする
- picker/explorer の主要導線は `<leader>e`、`<leader>ff`、`<leader>fg`、`<leader><leader>`、`<leader>,`、`<leader>fh`
- `Snacks.explorer` は watch と git status 表示を有効にする
- `Snacks.lazygit` の `configure = false` にして、`nvim-remote` 前提の fragile な既定値を避ける
- `cmp` は `nvim_lsp` / `path` / `buffer` source を使い、`<C-Space>` 補完開始、`<CR>` 確定、`<Tab>` / `<S-Tab>` で候補移動
- `treesitter` は highlight / indent を有効にする
- `flash.nvim` は `s` / `S` を normal / visual / operator-pending に割り当てる
- diagnostics は `]d` / `[d`、`<leader>cd`、`<leader>xx`、`<leader>xX` を使う
- LSP の主な導線は `K` hover、`gd` 定義、`grr` 参照、`gri` 実装、`grt` 型定義
- buffer 移動は `<S-h>` / `<S-l>`
- 日常の pane 移動ショートカットは Nixvim に持たせず、Neovim window は必要時に素の `Ctrl-w` 系操作で扱う
- `jdtls` 自体は Nixvim/Home Manager から供給するが、`packageFallback = true` なので project/devshell 由来の `jdtls` が `PATH` にあればそちらを使える
- Java と Maven はここで固定しない。`mise`/`direnv` が用意する環境を前提にする

### Yazi

- `programs.yazi.enable = true`
- Nushell integration と `shellWrapperName = "y"` を有効化する
- `smart-enter` plugin を `yaziPlugins` から読む
- `fzf`、`ripgrep`、`fd`、`jq` を一緒に有効化する
- `core.system.extended` が true のとき preview 向け package を追加する

### Homebrew

`modules/core.nix` は Darwin desktop 向けの built-in base list を持ち、次を `core.brew.resolved` に解決します。

- `taps`
- `brews`
- `casks`
- `masApps`

補足:

- `core.system.desktop = false` のとき、`core.brew.enable` の既定値も `false` になる
- その場合 `core.brew.resolved` は空になる

Consumer integration example:

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

この repo の docs はこの利用モデルと整合している必要があります。つまり、この repo は standalone flake ではなく、consumer から読み込まれる reusable source input として説明するのが前提です。

## 変更時のチェックポイント

- 公開面を変えたか。変えたなら `README.md` の説明と `llms.md` の option 一覧を両方更新する
- 実装詳細だけを変えたか。変えたなら `llms.md` の該当 section だけ更新する
- inactive なものを active に戻したか、逆に外したか。公開面の説明を更新する
- consumer 側の統合前提が変わったか。integration example と consumer alignment を更新する
