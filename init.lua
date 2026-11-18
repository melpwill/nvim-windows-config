-- Windows向けNeovim設定

-- 標準のnetrwを無効化し、ファイルツリーをnvim-treeに置き換える
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Leaderキーはプラグインやキーマッピングより先に設定する
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

-- Emmetの言語設定
vim.g.user_emmet_settings = { variables = { lang = "ja" } }

local opt = vim.opt

-- ファイルとバッファの設定
-- Neovim内部はUTF-8。既存ファイルはUTF-8を優先し、WindowsのCP932も読み込む
-- 文字コードの自動判定は完全ではないため、文字化け時は:EditCP932で明示的に再読込する
opt.fileformats = { "unix", "dos", "mac" }
opt.fileencodings = { "ucs-bom", "utf-8", "cp932", "latin1" }
opt.backup = false
opt.swapfile = false
opt.undofile = true
opt.autoread = true
opt.hidden = true
opt.history = 5000
opt.backspace = { "indent", "eol", "start" }

-- インデント設定
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = false
opt.autoindent = true
opt.smartindent = true

-- 空白文字の表示とスペルチェック
opt.list = true
opt.listchars = {
  tab = vim.fn.nr2char(0x00A6) .. "_",
  trail = "~",
  nbsp = "~",
}
-- 日本語の文章・コメントを英語のスペルチェックで誤検知しないよう初期状態はOFF
-- 英語の文書だけ確認したい場合は :setlocal spell を使用する
opt.spell = false

-- 検索設定
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.wrapscan = true
opt.hlsearch = true

-- 表示とカーソル移動
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.ruler = true
opt.showmatch = true
opt.showcmd = true
opt.showmode = false
opt.virtualedit = "onemore"
opt.laststatus = 2
opt.wildmenu = true
opt.wildmode = { "list:longest" }
opt.termguicolors = true
opt.signcolumn = "yes"
opt.splitright = true
opt.splitbelow = true

-- VSCodeに近い操作性を確保する（既存のVimキー操作は維持）
opt.mouse = "a"
opt.scrolloff = 5
opt.updatetime = 250
opt.timeoutlen = 700
opt.confirm = true -- 未保存の変更がある場合は終了前に確認する

-- 通常のヤンクと貼り付けでWindowsのクリップボードを使用する
opt.clipboard = "unnamedplus"

-- ステータスラインにGitブランチを表示する（既存のlightline + vim-fugitiveを使用）
vim.g.lightline = {
  active = {
    left = {
      { "mode", "paste" },
      { "gitbranch", "readonly", "filename", "modified" },
    },
  },
  component_function = {
    gitbranch = "FugitiveHead",
  },
}

-- キーマッピング
local map = vim.keymap.set
local silent = { silent = true }

-- jj はIMEが直接ASCII入力している場合のみ有効。日本語変換中はIMEにキーが渡る
-- Google日本語入力とCorvusSKKはOS側のIMEであり、ここでは強制的に切り替えない
map("i", "jj", "<Esc>", { desc = "挿入モードを終了（IME英数入力時）" })
map("i", "<C-t>", [[<Esc><Left>"zx"zpa]], { desc = "Move character to the right" })
map("n", "j", "gj", { desc = "Move one displayed line down" })
map("n", "k", "gk", { desc = "Move one displayed line up" })
map("n", "<C-o>", ":<C-u>call append(line('.'), '')<CR>j", silent)
map("n", "<Esc><Esc>", "<Cmd>nohlsearch<CR>", silent)

-- カーソル位置の単語を検索レジスタ（/）に登録して強調表示する
map("n", "<Space><Space>", function()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    return
  end
  vim.fn.setreg("/", [[\<]] .. vim.fn.escape(word, [[\/]]) .. [[\>]])
  opt.hlsearch = true
end, { desc = "Highlight current word" })

-- 置換用ショートカット
map("n", "#", "<Space><Space>:%s/<C-r>///g<Left><Left>", { remap = true })

-- ヤンク・貼り付け後のカーソル位置を操作対象の末尾に合わせる
map("x", "y", "y`]", silent)
map("x", "p", "p`]", silent)
map("n", "p", "p`]", silent)
map("x", "v", "$h")

-- 分割ウィンドウ間の移動とサイズ変更
map("n", "<C-h>", "<C-w>h", silent)
map("n", "<C-j>", "<C-w>j", silent)
map("n", "<C-k>", "<C-w>k", silent)
map("n", "<C-l>", "<C-w>l", silent)
map("n", "<S-Left>", "<C-w><", silent)
map("n", "<S-Right>", "<C-w>>", silent)
map("n", "<S-Up>", "<C-w>-", silent)
map("n", "<S-Down>", "<C-w>+", silent)

-- コマンドラインでEmacs風のキー操作を使用する
local command_line_maps = {
  ["<C-p>"] = "<Up>",
  ["<C-n>"] = "<Down>",
  ["<C-b>"] = "<Left>",
  ["<C-f>"] = "<Right>",
  ["<C-a>"] = "<Home>",
  ["<C-e>"] = "<End>",
  ["<C-d>"] = "<Del>",
}
for lhs, rhs in pairs(command_line_maps) do
  map("c", lhs, rhs)
end

-- Leaderキーマッピング
map("n", "<leader>w", "<Cmd>write<CR>", silent)
map("n", "<leader>q", "<Cmd>quit<CR>", silent)
map("n", "<leader>wq", "<Cmd>wq<CR>", silent)
map("n", "<leader>vs", "<Cmd>vsplit<CR>", silent)
map("n", "<leader>ss", "<Cmd>split<CR>", silent)
map("n", "<leader>h", "^")
map("n", "<leader>l", "$")
map("x", "<leader>y", '"+y')
map("x", "<leader>d", '"+d')
map({ "n", "x" }, "<leader>p", '"+p')
map({ "n", "x" }, "<leader>P", '"+P')

-- 独自のExコマンド
vim.api.nvim_create_user_command("Ss", "split", {})
vim.api.nvim_create_user_command("P", function()
  opt.paste = true
end, {})
vim.api.nvim_create_user_command("Np", function()
  opt.paste = false
end, {})
vim.api.nvim_create_user_command("I", function()
  opt.list = not opt.list:get()
end, {})

-- Windowsの日本語ファイルを文字コードを指定して安全に開き直す
-- 未保存の変更があれば再読込せず、変更の消失を防止する
local function reopen_with_encoding(encoding)
  if vim.bo.modified then
    vim.notify("未保存の変更があります。保存するか破棄してから実行してください。", vim.log.levels.WARN)
    return
  end
  if vim.api.nvim_buf_get_name(0) == "" then
    vim.notify("ファイルを開いてから実行してください。", vim.log.levels.WARN)
    return
  end
  vim.cmd("edit ++enc=" .. encoding)
end
vim.api.nvim_create_user_command("EditCP932", function()
  reopen_with_encoding("cp932")
end, { desc = "現在のファイルをCP932として再読込する" })
vim.api.nvim_create_user_command("EditUTF8", function()
  reopen_with_encoding("utf-8")
end, { desc = "現在のファイルをUTF-8として再読込する" })

-- ファイルを開いた際に前回のカーソル位置へ復帰する
local group = vim.api.nvim_create_augroup("UserInit", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function(event)
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local line = mark[1]
    if line > 0 and line <= vim.api.nvim_buf_line_count(event.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- 全角スペースを強調表示
local function set_custom_highlights()
  vim.api.nvim_set_hl(0, "FullWidthSpace", { bg = "#5f005f" })
end
vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = set_custom_highlights,
})
vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
  group = group,
  callback = function()
    if not vim.w.fullwidth_space_match_id then
      vim.w.fullwidth_space_match_id = vim.fn.matchadd("FullWidthSpace", vim.fn.nr2char(0x3000))
    end
  end,
})

-- lazy.nvimの初期導入処理、PATHからGitを実行できる必要がある
local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazy_path) then
  local repository = "https://github.com/folke/lazy.nvim.git"
  local output = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable", repository, lazy_path,
  })
  if vim.v.shell_error ~= 0 then
    error("Failed to install lazy.nvim:\n" .. output)
  end
end
opt.rtp:prepend(lazy_path)

-- Claude CodeはWindowsのWinGet版でclaude.exeとして提供される
-- NeovimのPATHが古い場合にも、WinGetのインストール先から実体を探す
-- ユーザー名やインストール先を固定せず、OSの環境変数から解決する
local function resolve_claude_executable()
  local is_windows = vim.fn.has("win32") == 1
  local command_names = is_windows and { "claude.exe", "claude" } or { "claude" }

  for _, command in ipairs(command_names) do
    local path = vim.fn.exepath(command)
    if path ~= "" and vim.fn.executable(path) == 1 then
      return path
    end
  end

  if is_windows and vim.env.LOCALAPPDATA and vim.env.LOCALAPPDATA ~= "" then
    local packages = vim.env.LOCALAPPDATA:gsub("\\", "/") .. "/Microsoft/WinGet/Packages"
    local pattern = packages .. "/Anthropic.ClaudeCode_*/claude.exe"
    for _, path in ipairs(vim.fn.glob(pattern, false, true)) do
      if vim.fn.executable(path) == 1 then
        return path
      end
    end
  end

  -- 未導入時には既存のチェック処理で警告を表示する
  return is_windows and "claude.exe" or "claude"
end

local claude_executable = resolve_claude_executable()

-- Windowsのnpm版Codexはcodex.cmd経由で起動できる。
-- Neovimのexecutable()は.cmdを直接認識しない環境があるため、cmd.exe経由で実行する。
-- npmの内部ディレクトリ構造には依存せず、実在するラッパーを探す。
local function resolve_codex_command()
  if vim.fn.has("win32") ~= 1 then
    return { "codex" }
  end

  -- ネイティブのcodex.exeがある場合はそちらを優先する。
  local native_executable = vim.fn.exepath("codex.exe")
  if native_executable ~= "" and vim.fn.executable(native_executable) == 1 then
    return { native_executable }
  end

  local command_shell = "cmd.exe"
  if vim.fn.executable(command_shell) ~= 1 then
    command_shell = vim.env.ComSpec or command_shell
  end
  if vim.fn.executable(command_shell) ~= 1 then
    return { "codex.cmd" }
  end

  local candidates = {}
  local seen = {}
  local function add_candidate(path)
    if type(path) ~= "string" or path == "" then
      return
    end
    local normalized = vim.fs.normalize(path)
    local key = normalized:lower()
    if not seen[key] then
      seen[key] = true
      candidates[#candidates + 1] = normalized
    end
  end

  -- PATH / nvm-windows / npmグローバルの順に確認する。
  add_candidate(vim.fn.exepath("codex.cmd"))
  if vim.env.NVM_SYMLINK and vim.env.NVM_SYMLINK ~= "" then
    add_candidate(vim.fs.joinpath(vim.env.NVM_SYMLINK, "codex.cmd"))
  end
  -- この端末でPowerShellから存在を確認済みのnvm-windowsリンク先。
  add_candidate("C:/nvm4w/nodejs/codex.cmd")
  if vim.env.APPDATA and vim.env.APPDATA ~= "" then
    add_candidate(vim.fs.joinpath(vim.env.APPDATA, "npm", "codex.cmd"))
  end
  for _, directory in ipairs(vim.split(vim.env.PATH or "", ";", { plain = true })) do
    if directory ~= "" then
      add_candidate(vim.fs.joinpath(directory, "codex.cmd"))
    end
  end

  for _, wrapper in ipairs(candidates) do
    if vim.fn.filereadable(wrapper) == 1 then
      -- cmd.exeにはWindows形式の区切り文字を渡す。
      local windows_wrapper = wrapper:gsub("/", "\\")
      -- Sidekickが.exeを直接起動できることを利用し、cmd.exeへ引数を渡す。
      return { command_shell, "/d", "/c", windows_wrapper }
    end
  end

  -- 実行ファイルがない場合は診断で未認識と表示し、成功を偽装しない。
  return { "codex.cmd" }
end

local codex_command = resolve_codex_command()

-- 各CLIが導入済みであることを確認してから、Sidekickのペインを開く
-- 誤って別のプログラムを起動しないよう、実行コマンドを固定する
local function open_ai_agent(name, executable)
  if vim.fn.executable(executable) ~= 1 then
    vim.notify(
      string.format("%s が見つかりません。Windows Terminal側で %s --version を確認してください。", name, executable),
      vim.log.levels.WARN
    )
    return
  end

  require("sidekick.cli").show({ name = name, focus = true })
end

-- 実際にSidekickへ渡しているCLIコマンドと実行可能判定を確認する。
-- :AiCliStatus を実行すると、PATHやnpm配置先の違いをその場で切り分けられる。
vim.api.nvim_create_user_command("AiCliStatus", function()
  local tools = require("sidekick.config").tools()
  for _, name in ipairs({ "antigravity", "claude", "codex" }) do
    local tool = tools[name]
    local cmd = tool and tool.cmd or {}
    local executable = cmd[1]
    local installed = executable and vim.fn.executable(executable) == 1 or false
    print(string.format("%s: executable=%s cmd=%s", name, tostring(installed), vim.inspect(cmd)))
    if name == "codex" and cmd[2] == "/d" and cmd[3] == "/c" then
      print(string.format("codex wrapper: readable=%s path=%s", tostring(vim.fn.filereadable(cmd[4]) == 1), cmd[4]))
    end
  end
end, { desc = "SidekickのAI CLI実行コマンドを診断する" })

-- Google Drive for desktopが同期するローカルのMarkdownフォルダーを使用する。
-- Windowsの実際の同期パスは端末ごとに異なるため、NVIM_NOTES_DIRで指定する。
-- 例: PowerShellで $env:NVIM_NOTES_DIR = 'G:\マイドライブ\NotesVault'
-- この機能はGoogle Drive APIを使用せず、ノートは通常のMarkdownファイルとして保存される。
local notes_directory = vim.env.NVIM_NOTES_DIR or ""
if notes_directory ~= "" then
  notes_directory = vim.fs.normalize(vim.fn.expand(notes_directory))
end
local notes_available = notes_directory ~= "" and vim.fn.isdirectory(notes_directory) == 1

local function get_notes_directory()
  if notes_directory == "" then
    vim.notify("NVIM_NOTES_DIRが未設定です。Google Driveのノートフォルダーを指定してください。", vim.log.levels.WARN)
    return nil
  end
  if vim.fn.isdirectory(notes_directory) ~= 1 then
    vim.notify("ノートフォルダーが見つかりません: " .. notes_directory, vim.log.levels.WARN)
    return nil
  end
  return notes_directory
end

-- プロジェクトの作業ディレクトリを変更せず、同期フォルダーのホームノートを開く。
vim.api.nvim_create_user_command("NotesOpen", function()
  local directory = get_notes_directory()
  if not directory then
    return
  end
  local home = vim.fs.joinpath(directory, "Home.md")
  vim.cmd("edit " .. vim.fn.fnameescape(home))
end, { desc = "Google Driveのホームノートを開く" })

vim.api.nvim_create_user_command("NotesStatus", function()
  print("NVIM_NOTES_DIR: " .. (notes_directory ~= "" and notes_directory or "(未設定)"))
  print("ノートフォルダー: " .. (vim.fn.isdirectory(notes_directory) == 1 and "利用可能" or "未検出"))
  print("ripgrep: " .. (vim.fn.executable("rg") == 1 and "利用可能" or "未検出"))
  print("obsidian.nvim: " .. (notes_available and "有効（起動時）" or "無効（ノートフォルダー未設定）"))
end, { desc = "Google Driveノートの設定と依存ツールを確認する" })

map("n", "<leader>no", "<Cmd>NotesOpen<CR>", { desc = "Google Driveのノートを開く" })

require("lazy").setup({
  { "tomasr/molokai", lazy = false, priority = 1000,
    config = function()
      vim.cmd.colorscheme("molokai")
    end,
  },
  { "itchyny/lightline.vim" },
  -- 常時表示のファイルツリー。開いているファイルやGit状態を追跡する
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 34,
          side = "left",
          preserve_window_proportions = true,
        },
        sync_root_with_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = false,
        },
        tab = {
          sync = { open = true, close = true },
        },
        actions = {
          open_file = { quit_on_open = false },
        },
        git = {
          enable = true,
          show_on_dirs = true,
        },
        filters = {
          git_ignored = true,
        },
        modified = { enable = true },
        renderer = {
          highlight_git = "name",
          highlight_opened_files = "name",
          highlight_modified = "name",
          icons = {
            -- Nerd FontがなくてもGit状態を判別できるように文字記号を使用する
            show = {
              file = false,
              folder = false,
              folder_arrow = false,
              git = true,
              modified = true,
            },
            glyphs = {
              modified = "*",
              git = {
                unstaged = "M",
                staged = "S",
                unmerged = "!",
                renamed = "R",
                untracked = "?",
                deleted = "D",
                ignored = "I",
              },
            },
          },
        },
      })
    end,
  },
  -- VSCodeの行単位のGit変更表示に相当する機能
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = require("gitsigns")
          local function git_map(lhs, rhs, desc)
            map("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
          end

          git_map("]c", function()
            if vim.wo.diff then
              vim.cmd.normal({ "]c", bang = true })
            else
              gs.nav_hunk("next")
            end
          end, "次のGit変更へ")

          git_map("[c", function()
            if vim.wo.diff then
              vim.cmd.normal({ "[c", bang = true })
            else
              gs.nav_hunk("prev")
            end
          end, "前のGit変更へ")

          git_map("<leader>gp", gs.preview_hunk, "変更箇所をプレビュー")
          git_map("<leader>gb", function()
            gs.blame_line({ full = true })
          end, "現在行のGit Blame")
          git_map("<leader>gB", gs.toggle_current_line_blame, "行単位のGit Blameを切り替える")
        end,
      })
    end,
  },
  { "tpope/vim-fugitive" },
  { "kylechui/nvim-surround", config = function()
      require("nvim-surround").setup()
    end,
  },
  { "mg979/vim-visual-multi" },
  { "andymass/vim-matchup" },
  { "mattn/emmet-vim" },

  -- VSCodeのクイックオープンとファイル横断検索に相当する機能
  {
    "nvim-telescope/telescope.nvim",
    version = vim.fn.has("nvim-0.11.7") == 1 and "0.2.*" or "0.1.9",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        path_display = { "truncate" },
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = { preview_width = 0.55 },
          width = 0.92,
          height = 0.84,
        },
        file_ignore_patterns = { "%.git/", "node_modules/", "%.venv/", "%.next/" },
      },
      pickers = {
        find_files = { hidden = true },
      },
    },
    keys = {
      { "<C-p>", function() require("telescope.builtin").find_files() end, desc = "ファイルをクイックオープン" },
      { "<leader>sf", function() require("telescope.builtin").find_files() end, desc = "ファイル名を検索" },
      { "<leader>sg", function() require("telescope.builtin").live_grep() end, desc = "プロジェクト全体を検索" },
      { "<leader>sc", function() require("telescope.builtin").current_buffer_fuzzy_find() end, desc = "現在のファイルを検索" },
      { "<leader>sw", function() require("telescope.builtin").grep_string() end, desc = "カーソル位置の単語を横断検索" },
      { "<leader>sb", function() require("telescope.builtin").buffers() end, desc = "開いているファイルを検索" },
      { "<leader>so", function() require("telescope.builtin").oldfiles() end, desc = "最近開いたファイルを検索" },
      { "<leader>sh", function() require("telescope.builtin").help_tags() end, desc = "ヘルプを検索" },
    },
  },

  -- VSCodeのワークスペース全体置換に相当する機能
  {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" },
    opts = {},
    keys = {
      {
        "<leader>sr",
        function() require("grug-far").open() end,
        mode = { "n", "x" },
        desc = "プロジェクト全体を検索・置換",
      },
    },
  },

  -- Neovim内のフローティングウィンドウからLazyGitを使う
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>gg",
        function()
          if vim.fn.executable("lazygit") ~= 1 then
            vim.notify("LazyGit本体が見つかりません。wingetでJesseDuffield.lazygitを導入してください。", vim.log.levels.WARN)
            return
          end
          vim.cmd("LazyGit")
        end,
        desc = "LazyGitを開く",
      },
    },
  },

  -- Gitの変更一覧・差分表示・ファイル履歴
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<Cmd>DiffviewOpen<CR>", desc = "Gitの差分一覧を開く" },
      { "<leader>gh", "<Cmd>DiffviewFileHistory %<CR>", desc = "現在のファイルのGit履歴" },
    },
  },

  -- VSCodeのエディタータブに相当するバッファー一覧
  {
    "akinsho/bufferline.nvim",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        show_buffer_icons = false,
        show_buffer_close_icons = false,
        show_close_icon = false,
        always_show_bufferline = true,
        separator_style = "thin",
        offsets = {
          {
            filetype = "NvimTree",
            text = "エクスプローラー",
            highlight = "Directory",
            separator = true,
          },
        },
      },
    },
    keys = {
      { "[b", "<Cmd>BufferLineCyclePrev<CR>", desc = "前のファイルへ切り替え" },
      { "]b", "<Cmd>BufferLineCycleNext<CR>", desc = "次のファイルへ切り替え" },
    },
  },

  -- VSCodeの問題パネルに相当する診断一覧
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<Cmd>Trouble diagnostics toggle<CR>", desc = "プロジェクトの診断一覧" },
      { "<leader>xb", "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "現在のファイルの診断一覧" },
    },
  },

  -- Leaderキーの後に使用可能な操作を一覧表示する
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 250,
      icons = { mappings = false },
      spec = {
        { "<leader>n", group = "Google Driveノート" },
        { "<leader>a", group = "AIエージェント" },
        { "<leader>g", group = "Git" },
        { "<leader>s", group = "検索・置換" },
        { "<leader>b", group = "バッファー" },
        { "<leader>x", group = "問題・診断" },
      },
    },
  },

  -- 括弧・引用符を自動で閉じる
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = false,
      disable_filetype = { "TelescopePrompt", "grug-far" },
    },
  },

  -- VSCodeの統合ターミナルに相当する機能
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = "ToggleTerm",
    opts = {
      direction = "horizontal",
      size = 14,
      start_in_insert = true,
      persist_size = true,
      shell = vim.fn.has("win32") == 1
          and (vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell")
          or vim.o.shell,
    },
    keys = {
      { "<leader>tt", "<Cmd>ToggleTerm<CR>", desc = "ターミナルの開閉" },
    },
  },

  -- Google Drive for desktopの同期フォルダーをObsidian互換のMarkdownノートとして管理する
  -- リンク/バックリンク、タグ、日次ノート、テンプレート、全文検索を提供する
  -- Driveを直接操作するのではなく、Windows上に同期されたローカルファイルを編集する
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- 最新の安定リリースを使用する
    enabled = notes_available,
    lazy = false, -- ノートのリンク補完とLSPを開いた直後から利用できるようにする
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {
      legacy_commands = false,
      workspaces = {
        { name = "google-drive", path = notes_directory },
      },
      picker = { name = "telescope.nvim" },
      link = {
        style = "wiki", -- [[ノート名]] 形式でリンクする
        format = "shortest",
        auto_update = false, -- 意図しない一括置換を避ける
      },
      daily_notes = {
        enabled = true,
        folder = "daily",
        date_format = "YYYY-MM-DD",
        default_tags = { "daily" },
        workdays_only = false,
      },
      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },
      -- インデックスはNeovimのキャッシュ領域に配置され、Drive上へ同期しない。
      cache = { enabled = true },
    },
    keys = {
      { "<leader>nn", "<Cmd>Obsidian new<CR>", desc = "新しいノートを作成" },
      { "<leader>nd", "<Cmd>Obsidian today<CR>", desc = "今日の日次ノートを開く" },
      { "<leader>nf", "<Cmd>Obsidian quick_switch<CR>", desc = "ノートをタイトルから検索" },
      { "<leader>ns", "<Cmd>Obsidian search<CR>", desc = "ノート全文を検索" },
      { "<leader>nb", "<Cmd>Obsidian backlinks<CR>", desc = "現在のノートへのバックリンク" },
      { "<leader>nl", "<Cmd>Obsidian links<CR>", desc = "現在のノートのリンク一覧" },
      { "<leader>nt", "<Cmd>Obsidian tags<CR>", desc = "ノートのタグを検索" },
      { "<leader>np", "<Cmd>Obsidian new_from_template<CR>", desc = "テンプレートから新規ノート" },
      { "<leader>ni", "<Cmd>Obsidian follow_link<CR>", desc = "カーソル位置のノートリンクを開く" },
      { "<leader>nD", "<Cmd>Obsidian dailies<CR>", desc = "日次ノート一覧" },
    },
  },

  -- Antigravity CLI、Claude Code、CodexをNeovimの右側または下側で操作する
  -- SidekickはCLIの起動・切り替えと編集対象のコンテキスト共有を担当する
  -- エージェント本体のインストール、認証、課金は各CLI側で別途行う
  {
    "folke/sidekick.nvim",
    -- ヘルスチェックを起動直後から使用できるよう、遅延読み込みを解除する
    lazy = false,
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {
      nes = { enabled = false },
      cli = {
        -- 外部CLIによる保存済みファイルの更新をNeovim側へ通知する
        -- 編集中の未保存バッファーを強制上書きする設定ではない
        watch = true,
        picker = "telescope",
        -- Windows Terminalではtmux/zellijを要求せず、Neovimのターミナルで実行する
        mux = { enabled = false },
        win = {
          -- 横幅が足りない場合は下部へ配置し、ファイルツリーと編集領域を保つ
          -- Windows Terminalを広く使う場合はVSCode風の右サイドバーになる
          layout = vim.o.columns >= 160 and "right" or "bottom",
          split = {
            width = 72,
            height = math.max(12, math.floor(vim.o.lines * 0.4)),
          },
        },
        tools = {
          -- Antigravity IDEの起動コマンドではなく、公式Antigravity CLI（agy）を利用する
          antigravity = { cmd = { "agy" } },
          -- Sidekickが用意しているCLI設定を使用する
          claude = { cmd = { claude_executable } },
          -- Windowsではcmd.exe経由でnpm版Codexの.cmdラッパーを起動する。
          codex = { cmd = codex_command },
        },
        prompts = {
          explain_ja = "現在のコードについて、日本語で処理の流れと注意点を説明してください。\n{this}",
          review_ja = "次のファイルをレビューし、重大度順に問題点を挙げてください。変更は実行しないでください。\n{file}",
          diagnostics_ja = "次のファイルの診断を調べ、原因と修正案を説明してください。\n{file}\n{diagnostics}",
          tests_ja = "現在のコードに対するテスト設計を提案してください。既存テストや規約も確認してください。\n{this}",
        },
      },
    },
    keys = {
      {
        "<leader>aa",
        function() require("sidekick.cli").toggle() end,
        desc = "使用中のAIエージェント画面を開閉する",
      },
      {
        "<leader>as",
        function() require("sidekick.cli").select({ filter = { installed = true } }) end,
        desc = "インストール済みAIエージェントを選択する",
      },
      {
        "<leader>ag",
        function() open_ai_agent("antigravity", "agy") end,
        desc = "Antigravity CLIを開く",
      },
      {
        "<leader>ac",
        function() open_ai_agent("claude", claude_executable) end,
        desc = "Claude Codeを開く",
      },
      {
        "<leader>ao",
        function() open_ai_agent("codex", codex_command[1]) end,
        desc = "Codex CLIを開く",
      },
      {
        "<leader>af",
        function() require("sidekick.cli").send({ msg = "{file}" }) end,
        desc = "現在のファイルパスをAIへ送る",
      },
      {
        "<leader>av",
        function() require("sidekick.cli").send({ msg = "{selection}" }) end,
        mode = "x",
        desc = "選択したコードをAIへ送る",
      },
      {
        "<leader>at",
        function() require("sidekick.cli").send({ msg = "{this}" }) end,
        mode = { "n", "x" },
        desc = "現在のコード位置または選択範囲をAIへ送る",
      },
      {
        "<leader>ap",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "x" },
        desc = "AIへ送るプロンプトを選択する",
      },
      {
        "<leader>ad",
        function() require("sidekick.cli").close() end,
        desc = "AIエージェントのセッションを終了する",
      },
    },
  },

  -- LSPと外部ツールの管理。MasonのbinディレクトリをPATHへ追加する
  {
    "mason-org/mason.nvim",
    lazy = false,
    opts = { PATH = "prepend" },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
  },

  -- LSPの補完候補、パス補完、スニペットを提供する。
  {
    "saghen/blink.cmp",
    version = "1.*", -- 互換性のあるv1系に固定し、開発中のv2を使用しない
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "default" },
      completion = {
        documentation = { auto_show = true },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
  },

  -- Python、TypeScript、TOML、YAML、Lua用のLSPを導入する
  {
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
    },
    config = function()
      -- LSPの補完能力をblink.cmpと共有する
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              diagnosticMode = "openFilesOnly",
            },
          },
        },
      })

      -- init.lua内のvim APIをLuaの標準的なグローバルとして扱う
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { library = { vim.env.VIMRUNTIME } },
            telemetry = { enable = false },
          },
        },
      })

      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "ts_ls", "taplo", "yamlls", "lua_ls" },
        automatic_enable = true,
      })
    end,
  },

  -- Linter・Formatter本体を起動時に不足分だけインストールする
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = false,
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = { "ruff", "eslint_d", "yamllint", "prettier", "stylua" },
      auto_update = false,
      run_on_start = true,
      start_delay = 1000,
    },
  },

  -- 保存前の自動整形。プロジェクトの設定ファイルを各ツールに解釈させる
  {
    "stevearc/conform.nvim",
    lazy = false,
    config = function()
      local conform = require("conform")
      conform.setup({
        formatters_by_ft = {
          python = { "ruff_format" },
          javascript = { "prettier" },
          javascriptreact = { "prettier" },
          typescript = { "prettier" },
          typescriptreact = { "prettier" },
          toml = { "taplo" },
          yaml = { "prettier" },
          lua = { "stylua" },
        },
        format_on_save = function(bufnr)
          -- 対象外のファイルには保存時の整形を適用しない
          local supported = {
            python = true,
            javascript = true,
            javascriptreact = true,
            typescript = true,
            typescriptreact = true,
            toml = true,
            yaml = true,
            lua = true,
          }
          if not supported[vim.bo[bufnr].filetype] then
            return nil
          end
          return { timeout_ms = 2000, lsp_format = "never" }
        end,
      })

      vim.api.nvim_create_user_command("Format", function()
        conform.format({ async = true, lsp_format = "never" })
      end, { desc = "現在のファイルをフォーマットする" })

      map({ "n", "x" }, "<leader>f", function()
        conform.format({ async = true, lsp_format = "never" })
      end, { desc = "手動でフォーマット" })
    end,
  },

  -- Ruff・ESLint・yamllintの診断をLSPの診断と併用する
  {
    "mfussenegger/nvim-lint",
    lazy = false,
    config = function()
      local lint = require("lint")
      local lint_group = vim.api.nvim_create_augroup("UserLanguageLint", { clear = true })
      local eslint_configs = {
        "eslint.config.js",
        "eslint.config.cjs",
        "eslint.config.mjs",
        "eslint.config.ts",
        "eslint.config.cts",
        "eslint.config.mts",
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.cjs",
        ".eslintrc.json",
        ".eslintrc.yaml",
        ".eslintrc.yml",
      }

      local function has_eslint_config(bufnr)
        local filename = vim.api.nvim_buf_get_name(bufnr)
        if filename == "" then
          return false
        end
        return #vim.fs.find(eslint_configs, {
          path = vim.fs.dirname(filename),
          upward = true,
        }) > 0
      end

      local function run_linter(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then
          return
        end

        local filetype = vim.bo[bufnr].filetype
        local commands = {
          python = "ruff",
          javascript = "eslint_d",
          javascriptreact = "eslint_d",
          typescript = "eslint_d",
          typescriptreact = "eslint_d",
          yaml = "yamllint",
        }
        local command = commands[filetype]
        if not command or vim.fn.executable(command) ~= 1 then
          return
        end
        -- ESLintはプロジェクトの設定がある場合のみ実行する
        if command == "eslint_d" and not has_eslint_config(bufnr) then
          return
        end

        vim.api.nvim_buf_call(bufnr, function()
          lint.try_lint({ command })
        end)
      end

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_group,
        callback = function(event)
          run_linter(event.buf)
        end,
      })

      vim.api.nvim_create_user_command("Lint", function()
        run_linter(vim.api.nvim_get_current_buf())
      end, { desc = "現在のファイルのLintを実行する" })
    end,
  },

  -- Tree-sitterは0.11と0.12でAPIが異なるため、使用ブランチを切り替える
  -- パーサーの導入にはCコンパイラが必要で、0.12以降はtree-sitter CLIも必要
  {
    "nvim-treesitter/nvim-treesitter",
    branch = vim.fn.has("nvim-0.12") == 1 and "main" or "master",
    lazy = false,
    config = function()
      local parsers = {
        "python", "javascript", "typescript", "tsx", "toml", "yaml", "lua",
      }
      local has_compiler = vim.fn.executable("cc") == 1
        or vim.fn.executable("gcc") == 1
        or vim.fn.executable("clang") == 1
        or vim.fn.executable("cl") == 1

      if vim.fn.has("nvim-0.12") == 1 then
        local ts = require("nvim-treesitter")
        if has_compiler and vim.fn.executable("tree-sitter") == 1 then
          ts.install(parsers)
        end

        vim.api.nvim_create_autocmd("FileType", {
          pattern = {
            "python", "javascript", "javascriptreact", "typescript",
            "typescriptreact", "toml", "yaml", "lua",
          },
          callback = function(event)
            -- パーサー未導入なら従来の構文ハイライトへフォールバックする
            pcall(vim.treesitter.start, event.buf)
          end,
        })
      else
        require("nvim-treesitter.configs").setup({
          ensure_installed = has_compiler and parsers or {},
          highlight = { enable = true },
          indent = { enable = false },
        })
      end
    end,
  },
}, {
  install = { colorscheme = { "molokai", "habamax" } },
  checker = { enabled = false },
})

set_custom_highlights()

-- 言語別のインデント設定。旧.vimrcの共通設定は対象外のファイルに維持する
local language_indents = {
  python = 4,
  javascript = 2,
  javascriptreact = 2,
  typescript = 2,
  typescriptreact = 2,
  toml = 2,
  yaml = 2,
  lua = 2,
}

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = vim.tbl_keys(language_indents),
  callback = function(event)
    local width = language_indents[vim.bo[event.buf].filetype]
    if not width then
      return
    end

    local buffer = vim.bo[event.buf]
    buffer.expandtab = true
    buffer.tabstop = width
    buffer.shiftwidth = width
    buffer.softtabstop = width
    buffer.spell = false
  end,
})

-- 診断の表示形式を統一する
vim.diagnostic.config({
  virtual_text = { spacing = 2, source = "if_many" },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded" },
})

-- LSPがアタッチされたバッファーにだけ操作用キーを設定する
vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(event)
    local buffer_map = function(lhs, rhs, description)
      map("n", lhs, rhs, {
        buffer = event.buf,
        silent = true,
        desc = description,
      })
    end

    buffer_map("gd", vim.lsp.buf.definition, "定義へ移動")
    buffer_map("gD", vim.lsp.buf.declaration, "宣言へ移動")
    buffer_map("gR", vim.lsp.buf.references, "参照一覧を表示")
    buffer_map("K", vim.lsp.buf.hover, "シンボルの情報を表示")
    buffer_map("<leader>rn", vim.lsp.buf.rename, "シンボル名を変更")
    buffer_map("<leader>ca", vim.lsp.buf.code_action, "コードアクション")
    buffer_map("<leader>dd", function()
      vim.diagnostic.open_float({ scope = "cursor" })
    end, "カーソル位置の診断を表示")
    buffer_map("[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, "前の診断へ移動")
    buffer_map("]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, "次の診断へ移動")
  end,
})

-- ファイルツリーは起動時に常時表示し、編集中のファイルがあれば編集側にフォーカスを残す
map("n", "<leader>e", "<Cmd>NvimTreeToggle<CR>", { desc = "ファイルツリー表示の切り替え" })
map("n", "<leader>ef", "<Cmd>NvimTreeFindFile<CR>", { desc = "現在のファイルをツリーで選択" })
map("n", "<leader>gs", "<Cmd>Git<CR>", { desc = "Gitステータスを表示（vim-fugitive）" })
map("n", "<leader>bd", "<Cmd>bdelete<CR>", { desc = "現在のファイルを閉じる" })
vim.api.nvim_create_user_command("Nt", "NvimTreeToggle", {})

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  callback = function()
    local has_file_argument = vim.fn.argc() > 0
    vim.schedule(function()
      local ok, tree = pcall(require, "nvim-tree.api")
      if not ok then
        return
      end
      tree.tree.open({ focus = not has_file_argument, find_file = has_file_argument })
    end)
  end,
})

-- CLI自身がEscを使うため、すべてのターミナルでEsc連打を奪わない
-- ターミナルのノーマルモードへの移行はCtrl+\の後にCtrl+nを押す
-- SidekickペインではCtrl+qでノーマルモード、Ctrl+zで編集側へ戻れる

-- ツリーや検索UIにはスペルチェックを適用しない
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "NvimTree", "TelescopePrompt", "grug-far" },
  callback = function()
    vim.opt_local.spell = false
  end,
})
