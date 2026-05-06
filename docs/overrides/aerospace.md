# AeroSpace の上書き

## デフォルト設定

- ベース設定: `files/aerospace/aerospace.toml`
- workspace 追加/上書き用オプション: `core.apps.aerospace.workspaces`
- floating 追加用オプション: `core.apps.aerospace.floatingAppIds`

## 上書き方法

`core.apps.aerospace.workspaces` は workspace 名をキーとして、生成有無、monitor 割当、app-id 割当を指定できます。
設定した workspace は既定で有効になり、AeroSpace 設定の `persistent-workspaces`、`alt-<key>`、
`alt-shift-<key>`、`workspace-to-monitor-force-assignment` に反映されます。
無効化したい場合だけ `enable = false` を指定します。
`monitor` の既定値は `main` です。
`appIds` に指定したアプリは、その workspace への `on-window-detected` rule として反映されます。
`core.apps.aerospace.floatingAppIds` に指定したアプリは `layout floating` rule として反映されます。

## 例

```nix
{
  core.apps.aerospace.workspaces.S = {
    monitor = "secondary";
    appIds = [
      "com.tinyspeck.slackmacgap"
    ];
  };

  core.apps.aerospace.workspaces.B.appIds = [
    "company.thebrowser.dia"
  ];

  core.apps.aerospace.floatingAppIds = [
    "com.apple.Preview"
  ];
}
```

この例は内部的に次の run へ変換されます。

- `workspaces.S.appIds = [ "com.tinyspeck.slackmacgap" ]` -> `move-node-to-workspace S`
- `workspaces.B.appIds = [ "company.thebrowser.dia" ]` -> `move-node-to-workspace B`
- `floatingAppIds = [ "com.apple.Preview" ]` -> `layout floating`

## 注意点

- `workspaces.<name>` を設定すると既定で workspace は生成されます。生成しない場合は `enable = false` を指定してください。
- `appIds` は有効な workspace だけ `on-window-detected` rule として出力されます。
- `floatingAppIds` は core の既定値に追加されます。
- core のデフォルトでは `S` workspace は定義していません。必要な環境だけ `workspaces.S` と `appIds` を追加してください。
