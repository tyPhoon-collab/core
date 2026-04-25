# Jujutsu の上書き

## デフォルト設定

- `programs.jujutsu.enable = true`
- 共通設定:
  - aliases (`f`, `p`)
  - `revset-aliases`
  - `ui.default-command = "log"`

実装は `modules/programs/jujutsu.nix` にあります。

## 上書き方法

個人識別情報は取り込み側で設定します。

## 例

```nix
{
  programs.jujutsu.settings = {
    user.name = "Your Name";
    user.email = "you@example.com";
  };
}
```

```nix
{
  programs.jujutsu.settings = {
    git.push-bookmark-prefix = "hiroaki/";
    ui.paginate = "auto";
  };
}
```

## 注意点

- `programs.jujutsu.settings` は属性セットなので、同じキーは取り込み側の値が優先されます。
- 共有したい alias は shared 側、個人運用向け alias は取り込み側に分けると衝突を減らせます。
