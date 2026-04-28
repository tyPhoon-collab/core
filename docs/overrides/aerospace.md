# AeroSpace の上書き

## デフォルト設定

- ベース設定: `files/aerospace/aerospace.toml`
- 追加用オプション: `core.apps.aerospace.extraRules`

## 上書き方法

`core.apps.aerospace.extraRules` は app-id をキーとして、
`workspace` / `floating` を意図ベースで指定できます。

## 例

```nix
{
  core.apps.aerospace.extraRules = {
    "company.thebrowser.dia" = {
      workspace = "B";
    };

    "com.apple.Preview" = {
      floating = true;
    };
  };
}
```

この例は内部的に次の run へ変換されます。

- `workspace = "B"` -> `move-node-to-workspace B`
- `floating = true` -> `layout floating`

## 注意点

- `extraRules` は app-id ごとに `workspace` か `floating` の少なくとも一方が必要です。
- `extraRules` では `workspace` が `floating` より優先されます。
