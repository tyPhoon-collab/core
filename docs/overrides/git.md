# Git の上書き

## デフォルト設定

- `programs.git.enable = true`
- 共通設定:
  - `init.defaultBranch = "main"`
  - `pull.rebase = true`
  - `push.autoSetupRemote = true`
- 関連ツール:
  - `programs.lazygit.enable = true`
  - `programs.gh.enable = true`

実装は `modules/programs/git.nix` にあります。

## 上書き方法

個人識別情報は shared 側で持たない前提です。取り込み側で設定します。

## 例

```nix
{
  programs.git.settings = {
    # shared 側の既定値を必要に応じて上書き
    pull.rebase = false;
    user.name = "Your Name";
    user.email = "you@example.com";
  };
}
```

```nix
{
  programs.git = {
    signing = {
      key = "YOUR_GPG_KEY";
      signByDefault = true;
    };
    aliases = {
      st = "status -sb";
      co = "checkout";
    };
  };
}
```

## 注意点

- shared 側の既定値は `programs.git.settings` に入っているため、取り込み側で同じキーを設定すると上書きされます。
- チームやマシン固有の設定は取り込み側で持つと管理しやすいです。
