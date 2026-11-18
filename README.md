# nvim-windows-config

Windows Terminalで利用する、Windows向けの個人用Neovim設定

Vimのキーボード操作を維持しつつ、VS Codeに近いファイル操作・Git・検索機能、AI CLI連携、Google Drive上のMarkdownノート管理を統合

## 主な機能

| 分野         | 主な機能                                                                  |
| ------------ | ------------------------------------------------------------------------- |
| UI           | Molokai、lightline、nvim-tree、bufferline、which-key                      |
| ファイル検索 | Telescopeによるファイル検索・全文検索、grug-farによる横断置換             |
| Git          | vim-fugitive、gitsigns、LazyGit、Diffview                                 |
| 開発支援     | Python・TypeScript・JavaScript・Lua・TOML・YAMLのLSP、補完、Lint、Format  |
| AI           | SidekickからAntigravity CLI、Claude Code、Codexを操作                     |
| ノート       | obsidian.nvimによるWikiリンク、バックリンク、タグ、日次ノート、検索       |
| 日本語       | UTF-8を基本にCP932での再読み込みに対応。Google日本語入力・CorvusSKKを想定 |

## リポジトリ構成

```text
nvim-windows-config/
├── init.lua       # Neovim本体の設定
├── README.md      # このファイル
└── .gitignore     # 一時ファイルの除外
```

Neovimの設定は、Windowsでは通常 `%LOCALAPPDATA%\nvim\init.lua` に置く

## 動作環境

- Windows / Windows Terminal
- Neovim 0.11.3以降
- Git
- PowerShell 7またはWindows PowerShell

以下は、該当する機能を利用する場合に必要な外部ツール

- rg（ripgrep）：プロジェクト全文検索
- lazygit：Neovim内のGit UI
- agy / claude / codex：各AI CLI本体とその認証
- Google Drive for desktop：ノートフォルダーの同期
- 開発言語ごとのLint・Format用コマンド：利用する言語・機能に応じて必要

プラグイン管理にはlazy.nvimを、LSPや一部の開発用ツールの管理にはMasonを使用  
実際に動作する機能は、各外部コマンドの導入状況に依存

## 利用開始

### 新しいWindows環境に配置する

**Neovimの設定フォルダーがまだない場合**は、空の設定フォルダーにリポジトリをクローンする

```powershell
git clone <REPOSITORY_URL> (Join-Path $env:LOCALAPPDATA 'nvim')
```

`<REPOSITORY_URL>` はリポジトリのHTTPS/SSH URLに置き換える  
既存のnvimフォルダーがある場合は、その中身を確認・バックアップしてから移行する

起動後、Neovimから`:Lazy sync` を実行してプラグインを同期する

## よく使うキー

Leaderキーは `,`（カンマ）  
たとえば`,ac`はNORMALモードで`,`、`a`、`c`を順に押す

| キー            | 操作                                                    |
| --------------- | ------------------------------------------------------- |
| ,w / ,q         | 保存 / 終了                                             |
| jj              | INSERTモードを終了（IMEが英数字を直接入力しているとき） |
| Ctrl+P          | ファイル検索                                            |
| ,e / ,ef        | ファイルツリーの開閉 / 現在ファイルをツリーで選択       |
| ,sg / ,sr       | プロジェクト全文検索 / 検索・置換                       |
| ,gg             | LazyGitを開く                                           |
| ,gd / ,gh       | Git差分一覧 / 現在ファイルの履歴                        |
| ,f              | 手動フォーマット                                        |
| ,tt             | 統合ターミナルの開閉                                    |
| ,ag / ,ac / ,ao | Antigravity / Claude Code / Codexを開く                 |
| ,aa / ,as       | AI画面を開閉 / エージェントを選択                       |
| ,af / ,av       | 現在ファイル / 選択範囲をAIへ送る                       |
| ,no / ,nn / ,nd | ホームノート / 新規ノート / 日次ノート                  |
| ,nf / ,ns / ,nb | ノート名検索 / 全文検索 / バックリンク                  |

詳細な操作は `:map`、`:Telescope keymaps`、またはLeader入力後のwhich-key表示でも確認できる

## AI CLI連携

AI機能にはsidekick.nvimを使用し、各CLIをNeovim内のペインで操作する  
使用前に、それぞれのCLI本体をインストール・認証しておく

```vim
:AiCliStatus
:checkhealth sidekick
```

## Google DriveでMarkdownノートを管理する

ノート本体はGoogle Drive for desktopの同期フォルダーに置く想定  
NVIM_NOTES_DIRにそのフォルダーの絶対パスを指定する

```powershell
$notesDir = 'G:\マイドライブ\NotesVault' # 自分の同期先パスに変更
[Environment]::SetEnvironmentVariable('NVIM_NOTES_DIR', $notesDir, 'User')
```

Windows Terminalを開き直し、次のコマンドで状態を確認できる

```vim
:NotesStatus
:NotesOpen
```

ノートフォルダーがNeovim起動時に存在する場合、obsidian.nvimが有効になる  
ノートは通常の`.md`ファイルで、Wikiリンク（`[[ノート名]]`）、タグ、日次ノートなどを使える
