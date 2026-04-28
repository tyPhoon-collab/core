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

個人識別情報は core 側で固定値として持たず、通常は取り込み側の `coreConfig.identity` で設定します。

## 例

```nix
{
  coreConfig.identity = {
    name = "Your Name";
    email = "you@example.com";
  };

  programs.git.settings = {
    # core 側の既定値を必要に応じて上書き
    pull.rebase = false;
  };
}
```

## 注意点

- core 側の既定値は `programs.git.settings` に入っているため、取り込み側で同じキーを設定すると上書きされます。
- チームやマシン固有の設定は取り込み側で持つと管理しやすいです。
