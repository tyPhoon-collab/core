# LSP

Neovim の LSP 設定は `modules/programs/nixvim/plugins.nix` が source of truth です。

この文書は、各 LSP の有効条件と実行時の依存関係を記録します。

## 有効条件

`core.system.devLevel` が `0` のとき、LSP は有効になりません。

`devLevel >= 1` では JSON、Lua、Nix、Markdown を有効にします。

`devLevel >= 2` では Bash、TypeScript、Python、YAML、Go、Kotlin、Java、Dart、Swift、C#、Rust を有効にします。

## LSP 一覧

`package` が `null` でない LSP は Nixvim の既定 package を Neovim の PATH に加えます。`null` の LSP は、表の起動コマンドを Consumer の PATH に用意します。

`追加 runtime` は、LSP server の起動バイナリ以外に必要なコマンドまたは SDK です。

`バイナリの提供元` が Nixvim でも、プロジェクトの toolchain、interpreter、依存関係を用意する意味ではありません。

| LSP | 言語 | 条件 | 起動コマンド | `package` | バイナリの提供元 | 追加 runtime |
| --- | --- | --- | --- | --- | --- | --- |
| `jsonls` | JSON | `devLevel >= 1` | `vscode-json-language-server --stdio` | 未指定 | Nixvim | なし |
| `lua_ls` | Lua | `devLevel >= 1` | `lua-language-server` | 未指定 | Nixvim | なし |
| `nixd` | Nix | `devLevel >= 1` | `nixd` | 未指定 | Nixvim | なし |
| `markdown_oxide` | Markdown | `devLevel >= 1` | `markdown-oxide` | 未指定 | Nixvim | なし |
| `bashls` | Bash | `devLevel >= 2` | `bash-language-server start` | 未指定 | Nixvim | なし |
| `ts_ls` | TypeScript、JavaScript | `devLevel >= 2` | `typescript-language-server --stdio` | 未指定 | Nixvim | `typescript` package |
| `pyright` | Python | `devLevel >= 2` | `pyright-langserver --stdio` | 未指定 | Nixvim | `python`（プロジェクト解析用） |
| `yamlls` | YAML | `devLevel >= 2` | `yaml-language-server --stdio` | 未指定 | Nixvim | なし |
| `gopls` | Go | `devLevel >= 2` | `gopls` | 未指定 | Nixvim | `go` |
| `kotlin_lsp` | Kotlin | `devLevel >= 2` | `kotlin-lsp --stdio` | `null` | Consumer の PATH | なし |
| `jdtls` | Java | `devLevel >= 2` | `jdtls` | 未指定、`packageFallback = true` | Nixvim。Consumer の PATH を優先 | `java`（JDK） |
| `dartls` | Dart | `devLevel >= 2` | `dart language-server --protocol=lsp` | `null` | Consumer の PATH | なし（Dart SDK の `dart`） |
| `sourcekit` | Swift、C、C++、Objective-C | `devLevel >= 2` | `sourcekit-lsp` | `null` | Consumer の PATH | `swift`、Xcode project は `xcode-build-server` |
| `roslyn_ls` | C# | `devLevel >= 2` | `Microsoft.CodeAnalysis.LanguageServer --stdio` または `roslyn-language-server --stdio` | `null` | Consumer の PATH | `dotnet`（dotnet tool または DLL 版） |
| `rust_analyzer` | Rust | `devLevel >= 2` | `rust-analyzer` | 未指定 | Nixvim | `cargo`、`rustc` |

`jdtls` は `packageFallback = true` のため、Nixvim の package を使えますが、Consumer の PATH にある `jdtls` を優先します。

`rust_analyzer` は `cargo` と `rustc` を Nixvim に追加しません。

TypeScript、Python、Go は、LSP server の手動導入は不要ですが、プロジェクトのセットアップは必要です。

TypeScript は `tsconfig.json` または `jsconfig.json` と project dependencies、Python は interpreter と virtual environment（依存関係を解析する場合）、Go は Go toolchain と `go.mod` または `go.work` を Consumer 側で用意します。

## プロジェクトごとの前提

LSP は、開いたファイルから親ディレクトリをたどり、**ルートマーカー**（プロジェクトルートを示すファイルまたはディレクトリ）を探してワークスペースのルートを決めます。

ルートを特定できない場合、LSP は buffer に接続しないことがあります。

`root_dir` は `:LspInfo` で確認できます。

以下のルートマーカーは、Consumer が固定する Nixvim と nvim-lspconfig の既定設定を基準にしています。

### リポジトリを基準にする LSP

| LSP | ルートマーカー | プロジェクトごとの追加条件 |
| --- | --- | --- |
| `jsonls`、`bashls`、`yamlls` | `.git` | なし |
| `markdown_oxide` | `.git`、`.obsidian`、`.moxide.toml` | Obsidian vault は `.obsidian` を含むディレクトリを開きます。 |
| `lua_ls` | `.emmyrc.json`、`.luarc.json`、`.luarc.jsonc`、`.luacheckrc`、`.stylua.toml`、`stylua.toml`、`selene.toml`、`selene.yml`、`.git` | Lua の解析設定を置く場合は、該当ファイルをプロジェクトルートに置きます。 |
| `nixd` | `flake.nix`、`.git` | flake を持つプロジェクトは `flake.nix` を含むディレクトリを開きます。 |

`jsonls`、`bashls`、`yamlls` は `.git` 以外のプロジェクトメタデータをルート判定に使いません。

### プロジェクトメタデータを必要とする LSP

| LSP | ルートマーカー | プロジェクトごとの追加条件 |
| --- | --- | --- |
| `ts_ls` | `package-lock.json`、`yarn.lock`、`pnpm-lock.yaml`、`bun.lockb`、`bun.lock`、`.git` | TypeScript は `tsconfig.json`、JavaScript は `jsconfig.json` をプロジェクトルートに置きます。`deno.json`、`deno.jsonc`、`deno.lock` を含む Deno プロジェクトは `ts_ls` の対象外です。 |
| `pyright` | `pyrightconfig.json`、`pyproject.toml`、`setup.py`、`setup.cfg`、`requirements.txt`、`Pipfile`、`.git` | Python の依存関係と解析設定は、検出されたルートに置きます。 |
| `gopls` | `go.work`、`go.mod`、`.git` | Go workspace は `go.work`、単一 module は `go.mod` をルートの目印にします。 |
| `kotlin_lsp` | `settings.gradle`、`settings.gradle.kts`、`pom.xml`、`build.gradle`、`build.gradle.kts`、`workspace.json` | Gradle、Maven、または `workspace.json` を使うプロジェクトを開きます。 |
| `jdtls` | `mvnw`、`gradlew`、`settings.gradle`、`settings.gradle.kts`、`.git`、`build.xml`、`pom.xml`、`build.gradle`、`build.gradle.kts` | 複数 module は wrapper または settings file をルートに置きます。Java の単一 module は build file をルートに置きます。 |
| `dartls` | `pubspec.yaml` | なし |
| `rust_analyzer` | `Cargo.toml`、`rust-project.json`、`.git` | Cargo workspace のルートは `cargo metadata` で決まります。 |

`ts_ls` は package manager の lock file を優先して root を決めます。

`package.json` だけでは、現在の root 判定のプロジェクトマーカーになりません。

### Swift と C 系

`sourcekit` のルート判定は、BSP の接続仕様、Xcode プロジェクト、`compile_commands.json` または `Package.swift`、`.git` の順です。

BSP の接続仕様は、プロジェクトルートの `buildServer.json` または `.bsp` に置きます。

#### SwiftPM

- ルートの目印：`Package.swift`
- 開き方：`Package.swift` を含むディレクトリをプロジェクトルートとして開きます。
- 追加設定：標準と異なる `swift build` 引数が必要な場合は、ルートの `.sourcekit-lsp/config.json` に記録します。

#### Xcode

- ルートの目印：`*.xcodeproj` または `*.xcworkspace`
- 必須条件：ビルド設定を提供する BSP
- 準備：通常は `xcode-build-server` でプロジェクトルートに `buildServer.json` を生成します。
- 開き方：Xcode プロジェクトまたは `buildServer.json` を含むプロジェクトルートを開きます。

#### C、C++、Objective-C

- ルートの目印：`compile_commands.json`
- 準備：CMake などの build system に compilation database を生成させます。
- 開き方：`compile_commands.json` を含むプロジェクトルートを開きます。

`.git` だけでもルートは決まりますが、ビルド構成が渡らないため、プロジェクト固有の正確な解析には `compile_commands.json` または BSP が必要です。

### .NET と Unity

`roslyn_ls` は、ソリューションを優先し、ソリューションがなければプロジェクトファイルを読み込みます。

#### .NET プロジェクト

- ルートの目印：`.sln`、`.slnx`、または `.csproj`
- 開き方：ソリューションを使う場合は `.sln` または `.slnx` を含むディレクトリを開きます。
- 代替：ソリューションがない場合は、`.csproj` を含むディレクトリを開きます。

#### Unity

- 準備：Unity の External Tools で `.sln` と必要な `.csproj` の生成を有効にします。
- 開き方：生成後、Unity のプロジェクトルートを開きます。
- 復旧：Unity がプロジェクトファイルを再生成した後に C# の解析が古い場合、`:LspRestart roslyn_ls` を実行します。

Razor は、現在の `roslyn_ls` 設定で filetype の対象になっていません。

## 操作

`gd` は definition に移動します。

`grr` は reference を表示します。

`gri` は implementation に移動します。

`grt` は type definition に移動します。

`<leader>ca` は code action を開きます。

接続状態は `:LspInfo` で確認します。
