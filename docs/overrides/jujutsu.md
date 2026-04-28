# Jujutsu の上書き

## デフォルト設定

- `programs.jujutsu.enable = true`
- 共通設定:
  - aliases (`f`, `p`)
  - `revset-aliases`
  - `ui.default-command = "log"`

実装は `modules/programs/jujutsu.nix` にあります。

## 上書き方法

個人識別情報は core 側で固定値として持たず、通常は取り込み側の `coreConfig.identity` で設定します。

## 例

```nix
{
  coreConfig.identity = {
    name = "Your Name";
    email = "you@example.com";
  };
}
```

```nix
{
  programs.jujutsu.settings = {
    ui.paginate = "auto";
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
- 共有したい alias は core 側、個人運用向け alias は取り込み側に分けると衝突を減らせます。
