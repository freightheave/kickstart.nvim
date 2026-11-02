--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is Kickstart?

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving Kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know what this means, type the following:
      - <escape key>
      - :
      - Tutor
      - <enter key>

    (If you already know the Neovim basics, you can skip this step.)

  Once you've completed that, you can continue working through **AND READING** the rest
  of the kickstart init.lua.

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite Neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or Neovim features used in Kickstart.

   NOTE: Look for lines like this

    Throughout the file. These are for you, the reader, to help you understand what is happening.
    Feel free to delete them once you know what you're doing, but they should serve as a guide
    for when you are first encountering a few different constructs in your Neovim config.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = '\\'
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal.
-- Ghostty is running with its stock font, so this stays false for terminal
-- Neovim. The Neovide block directly below turns it on for the GUI, which
-- selects its own font and therefore knows a Nerd Font is available.
vim.g.have_nerd_font = false

-- [[ Neovide (GUI) settings ]]
--  `vim.g.neovide` only exists when Neovim is embedded in Neovide, so terminal
--  Neovim skips this whole block.
--
--  Division of labour: the window frame, font and renderer are configured in
--  ~/.config/neovide/config.toml, because Neovide needs them before Neovim
--  boots. This block is only the things Neovim itself has to set.
if vim.g.neovide then
  -- config.toml pins JetBrainsMono Nerd Font Mono, so every `have_nerd_font`
  -- branch further down (which-key icons, mini.statusline, lazy.nvim's UI,
  -- render-markdown glyphs, diagnostic signs) can use real glyphs instead of the
  -- ASCII/emoji fallbacks.
  --  NOTE: this also flips `enabled` on nvim-web-devicons, so the first Neovide
  --  launch will have lazy.nvim install that plugin.
  vim.g.have_nerd_font = true

  -- GUI apps launched from Finder/Dock/Spotlight inherit launchd's environment
  -- rather than the shell's. This machine's launchd PATH does currently include
  -- Homebrew, but nothing sets it persistently (no LaunchAgent runs `setenv
  -- PATH`), so it can quietly revert. Without Homebrew on PATH this config fails
  -- in non-obvious ways: `tree-sitter` (nvim-treesitter's `main` branch shells
  -- out to the CLI to build parsers), `make` (telescope-fzf-native's build step)
  -- and `node` (pyright and marksman are Node programs) all vanish.
  for _, dir in ipairs { '/opt/homebrew/bin', '/opt/homebrew/sbin', '/usr/local/bin' } do
    if not (':' .. (vim.env.PATH or '') .. ':'):find(':' .. dir .. ':', 1, true) then
      vim.env.PATH = dir .. ':' .. (vim.env.PATH or '')
    end
  end

  -- Left Option has to send Meta, or nvim-paredit's wrap mappings (`<a-w>(`,
  -- `<a-w>[`, `<a-w>{`, configured further down) are physically untypeable -
  -- macOS would insert  π  “  ”  instead. Right Option is left alone so accented
  -- characters still work.
  vim.g.neovide_input_macos_option_key_is_meta = 'only_left'

  -- Breathing room between the window chrome and the text grid.
  vim.g.neovide_padding_top = 8
  vim.g.neovide_padding_bottom = 8
  vim.g.neovide_padding_left = 8
  vim.g.neovide_padding_right = 8

  -- Cursor slides with a full-length smear (Neovide's defaults), everywhere.
  -- Set any of the lengths to 0 to switch that effect off entirely.
  vim.g.neovide_cursor_animation_length = 0.15
  vim.g.neovide_cursor_trail_size = 1.0
  vim.g.neovide_cursor_animate_in_insert_mode = true
  vim.g.neovide_cursor_animate_command_line = true
  -- Particle wake behind the cursor. Other modes: 'railgun', 'pixiedust',
  -- 'sonicboom', 'ripple', 'wireframe', or a list to combine, e.g. { 'torpedo', 'ripple' }.
  vim.g.neovide_cursor_vfx_mode = 'torpedo'
  vim.g.neovide_scroll_animation_length = 0.2
  vim.g.neovide_position_animation_length = 0.1

  -- Soften the backdrop behind Telescope / which-key / LSP floats.
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0
  vim.g.neovide_floating_shadow = true

  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_remember_window_position = true

  -- Pinned dark to match the hard-coded `tokyonight-night` colorscheme below.
  -- 'auto' would track the macOS appearance and flip `background` to light,
  -- which that colorscheme has no light variant to answer with.
  vim.g.neovide_theme = 'dark'

  -- Opaque. For a translucent window use something between 0.8 and 1.0 - but it
  -- costs contrast, which is noticeable with `cursorline` enabled below.
  vim.g.neovide_opacity = 1.0

  -- Confirm before discarding unsaved buffers when the window is closed with the
  -- mouse or Cmd-Q. The `confirm` option set below only covers `:q` typed inside
  -- Neovim, which a GUI window close never goes through.
  vim.g.neovide_confirm_quit = true

  -- [[ macOS Cmd keybindings ]]
  --  `<D-...>` is the Command key. A terminal can never send these, which is why
  --  they live in here rather than with the main keymaps below.
  local function gmap(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
  end

  -- `clipboard=unnamedplus` below already routes y/p through the system
  -- clipboard; these exist purely for macOS muscle memory.
  --  Copy/cut are visual-mode only on purpose: in normal mode `"+y` and `"+d`
  --  are incomplete operators, so Cmd-C with nothing selected would silently
  --  hang waiting for a motion rather than doing nothing.
  gmap('v', '<D-c>', '"+y', 'Copy selection to system clipboard')
  gmap('v', '<D-x>', '"+d', 'Cut selection to system clipboard')
  gmap({ 'n', 'v' }, '<D-v>', '"+p', 'Paste from system clipboard')
  gmap('i', '<D-v>', '<C-r>+', 'Paste from system clipboard')
  gmap('c', '<D-v>', '<C-r>+', 'Paste from system clipboard')
  -- In a terminal buffer, drop to normal mode to paste, then resume inserting.
  gmap('t', '<D-v>', '<C-\\><C-n>"+pi', 'Paste from system clipboard')
  gmap({ 'n', 'i', 'v' }, '<D-s>', '<Cmd>write<CR>', 'Save file')
  gmap('n', '<D-a>', 'ggVG', 'Select all')

  -- Cmd +/-/0 zoom, the way every other macOS app does it.
  vim.g.neovide_scale_factor = 1.0
  local function rescale(by)
    local next_scale = (vim.g.neovide_scale_factor or 1.0) * by
    vim.g.neovide_scale_factor = math.min(math.max(next_scale, 0.5), 3.0)
  end
  gmap('n', '<D-=>', function()
    rescale(1.1)
  end, 'Zoom in')
  gmap('n', '<D-->', function()
    rescale(1 / 1.1)
  end, 'Zoom out')
  gmap('n', '<D-0>', function()
    vim.g.neovide_scale_factor = 1.0
  end, 'Reset zoom')
end

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.opt.confirm = true

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    -- vim.highlight was renamed to vim.hl; the old name is deprecated (removed in 2.0)
    local hl = vim.hl or vim.highlight
    hl.on_yank()
  end,
})

-- [[ Run/Build/Test keymaps ]]
--  Per-language <leader>r keymaps that shell a command into a reused terminal split.
--  No test runner plugin: Go/Python/C don't share a workflow, and Clojure testing
--  stays in the REPL via Conjure rather than being shelled out here.
local runner_buf ---@type integer?
local last_run ---@type { cmd: string, cwd: string }?

local function run_in_terminal(cmd, cwd)
  last_run = { cmd = cmd, cwd = cwd }
  if runner_buf and vim.api.nvim_buf_is_valid(runner_buf) then
    vim.api.nvim_buf_delete(runner_buf, { force = true })
  end
  -- `new`, not `split`: `split` reuses the current buffer, so the `term = true`
  -- jobstart below would convert the source file's own buffer into a terminal.
  vim.cmd 'botright new'
  vim.cmd 'resize 15'
  vim.fn.jobstart(cmd, { term = true, cwd = cwd })
  runner_buf = vim.api.nvim_get_current_buf()
  vim.cmd 'startinsert'
end

vim.keymap.set('n', '<leader>rl', function()
  if last_run then
    run_in_terminal(last_run.cmd, last_run.cwd)
  else
    vim.notify('No previous run to repeat', vim.log.levels.WARN)
  end
end, { desc = '[R]e-run [L]ast' })

-- cmd fields are functions (not strings) so `%` resolves against the file at
-- keypress time, not whenever the buffer's FileType autocmd first fired.
local runners = {
  go = {
    run = function()
      return 'go run .'
    end,
    build = function()
      return 'go build .'
    end,
    test = function()
      return 'go test ./...'
    end,
  },
  python = {
    run = function()
      return 'python3 ' .. vim.fn.shellescape(vim.fn.expand '%:t')
    end,
    test = function()
      return 'pytest ' .. vim.fn.shellescape(vim.fn.expand '%:t')
    end,
  },
  c = {
    run = function()
      return 'cc -Wall -g ' .. vim.fn.shellescape(vim.fn.expand '%:t') .. ' -o /tmp/a.out && /tmp/a.out'
    end,
    build = function()
      return 'cc -Wall -g ' .. vim.fn.shellescape(vim.fn.expand '%:t') .. ' -o /tmp/a.out'
    end,
  },
  lua = {
    run = function()
      return 'lua ' .. vim.fn.shellescape(vim.fn.expand '%:t')
    end,
    test = function()
      return 'busted ' .. vim.fn.shellescape(vim.fn.expand '%:t')
    end,
  },
}

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Set up <leader>r run/build/test keymaps for supported filetypes',
  group = vim.api.nvim_create_augroup('kickstart-run-keymaps', { clear = true }),
  pattern = vim.tbl_keys(runners),
  callback = function(event)
    local cmds = runners[vim.bo[event.buf].filetype]
    local map = function(keys, make_cmd, desc)
      if not make_cmd then
        return
      end
      vim.keymap.set('n', keys, function()
        run_in_terminal(make_cmd(), vim.fn.expand '%:p:h')
      end, { buffer = event.buf, desc = desc })
    end
    map('<leader>rr', cmds.run, '[R]un')
    map('<leader>rb', cmds.build, '[R]un [B]uild')
    map('<leader>rt', cmds.test, '[R]un [T]est')
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to automatically pass options to a plugin's `setup()` function, forcing the plugin to be loaded.
  --

  -- Alternatively, use `config = function() ... end` for full control over the configuration.
  -- If you prefer to call `setup` explicitly, use:
  --    {
  --        'lewis6991/gitsigns.nvim',
  --        config = function()
  --            require('gitsigns').setup({
  --                -- Your gitsigns configuration here
  --            })
  --        end,
  --    }
  --
  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`.
  --
  -- See `:help gitsigns` to understand what the configuration keys do
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
  --
  -- This is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  --
  -- For example, in the following configuration, we use:
  --  event = 'VimEnter'
  --
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).
  --
  -- Then, because we use the `opts` key (recommended), the configuration runs
  -- after the plugin has been loaded as `require(MODULE).setup(opts)`.

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      preset = 'modern',
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.opt.timeoutlen
      delay = 0,
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Document existing key chains
      --  NOTE: this reflects this config's actual bindings, not upstream kickstart's -
      --  <leader>r holds both the run/build/test keys and LSP rename (<leader>rn), so
      --  it's a mixed group rather than a single-purpose one.
      spec = {
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]un / [R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]elescope' },
      },
    },
  },

  -- NOTE: Plugins can specify dependencies.
  --
  -- The dependencies are proper plugin specifications as well - anything
  -- you do for a plugin at the top level, you can do for a dependency.
  --
  -- Use the `dependencies` key to specify the dependencies of a particular plugin

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>th', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>tk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>tf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ts', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>tw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>tg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>td', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>tr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>t.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
    },

    config = function()
      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          pcall(function() --disabling default lsp go to references
            vim.keymap.del({ 'n', 'i', 'v' }, 'grr')
          end)
          pcall(function()
            vim.keymap.del({ 'n', 'i', 'v' }, 'gra')
          end)
          pcall(function()
            vim.keymap.del({ 'n', 'i', 'v' }, 'gri')
          end)
          pcall(function()
            vim.keymap.del({ 'n', 'i', 'v' }, 'grn')
          end)
          -- grt/grx aren't remapped to anything of ours, but leaving them bound means
          -- neovim has to wait out timeoutlen on every `gr` press to see if a longer
          -- `grt`/`grx` sequence follows. Delete them too so `gr` fires immediately.
          pcall(function()
            vim.keymap.del({ 'n', 'i', 'v' }, 'grt')
          end)
          pcall(function()
            vim.keymap.del({ 'n', 'i', 'v' }, 'grx')
          end)
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences') --use telescope go ref instead of nvim default.

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gH', vim.lsp.buf.hover, '[H]over [D]ocs')

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            -- NOTE: not <leader>th - that collides with Telescope's [T]elescope [H]elp
            -- in the buffer-local Telescope map above, silently shadowing it.
            map('<leader>ih', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, 'Toggle [I]nlay [H]ints')
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        clangd = {},
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
            },
          },
        },
        pyright = {},
        ruff = {},
        clojure_lsp = {},
        marksman = {}, -- markdown: link/heading completion, broken-link diagnostics
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`ts_ls`) will work just fine
        -- ts_ls = {},
        --

        lua_ls = {
          -- cmd = { ... },
          -- filetypes = { ... },
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'goimports', -- Used to format Go code (fixes imports)
        'gofumpt', -- Used to format Go code (stricter gofmt)
        'clang-format', -- Used to format C code
        'prettier', -- Used to format Markdown
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- Register our capabilities and per-server settings with the built-in LSP
      -- config store (`:help vim.lsp.config`).
      --
      -- NOTE: mason-lspconfig v2 dropped the `handlers` option that older Kickstart
      -- used to wire this up. Passing it is silently ignored - not an error - so the
      -- `servers` table above (gopls' gofumpt, lua_ls' callSnippet, ...) and these
      -- capabilities never reached any server. Servers still attached via
      -- `automatic_enable`, which is why it looked like it was working.
      vim.lsp.config('*', { capabilities = capabilities })
      for server_name, server in pairs(servers) do
        vim.lsp.config(server_name, server)
      end

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        -- Automatically `vim.lsp.enable()` whatever servers Mason has installed.
        -- stylua is excluded: Mason installs it as a *formatter* for conform.nvim
        -- above, but lspconfig also ships a `stylua` LSP wrapper, so leaving it in
        -- attaches a second, redundant client to every Lua buffer.
        automatic_enable = { exclude = { 'stylua' } },
      }
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = 'never'
        else
          lsp_format_opt = 'fallback'
        end
        return {
          timeout_ms = 500,
          lsp_format = lsp_format_opt,
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        go = { 'goimports', 'gofumpt' },
        python = { 'ruff_format' },
        c = { 'clang-format' },
        markdown = { 'prettier' },
        -- Conform can also run multiple formatters sequentially
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp-signature-help',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = cmp.mapping.confirm { select = true },

          -- If you prefer more traditional completion keymaps,
          -- you can uncomment the following lines
          --['<CR>'] = cmp.mapping.confirm { select = true },
          --['<Tab>'] = cmp.mapping.select_next_item(),
          --['<S-Tab>'] = cmp.mapping.select_prev_item(),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          {
            name = 'lazydev',
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
          { name = 'nvim_lsp_signature_help' },
        },
      }
    end,
  },

  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false }, -- Disable italics in comments
        },
      }

      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  { -- Splash screen shown on startup (renders fine in Neovide, since it's
    -- just buffer content like anything else the GUI draws).
    'folke/snacks.nvim',
    priority = 1000, -- load early, like the colorscheme above, so it's ready before VimEnter
    lazy = false,
    opts = {
      dashboard = {
        sections = {
          { section = 'header' },
          {
            icon = vim.g.have_nerd_font and ' ' or '🗝 ',
            title = 'Keymaps',
            section = 'keys',
            indent = 2,
            padding = 1,
          },
          {
            icon = vim.g.have_nerd_font and ' ' or '🕘 ',
            title = 'Recent Files',
            section = 'recent_files',
            indent = 2,
            padding = 1,
          },
          {
            icon = vim.g.have_nerd_font and ' ' or '📁 ',
            title = 'Projects',
            section = 'projects',
            indent = 2,
            padding = 1,
          },
          { section = 'startup' },
        },
      },
    },
  },

  --Conjure for Clojure
  {
    'Olical/conjure',
    init = function()
      vim.g['conjure#mapping#enable_defaults'] = false
      --evals
      vim.g['conjure#mapping#eval_root_form'] = 'e'
      vim.g['conjure#mapping#eval_current_form'] = 'E'
      vim.g['conjure#mapping#eval_buf'] = 'b'
      vim.g['conjure#mapping#eval_motion'] = 'm'
      --comment flavours
      vim.g['conjure#mapping#eval_comment_root_form'] = 'ce'
      vim.g['conjure#mapping#eval_comment_current_form'] = 'cE'
    end,
  },

  -- paredit
  {
    'freightheave/nvim-paredit',
    config = function()
      local paredit = require 'nvim-paredit'
      paredit.setup {
        -- Should plugin use default keybindings? (default = true)
        use_default_keys = true,
        -- Sometimes user wants to restrict plugin to certain filetypes only or add support
        -- for new filetypes.
        --
        -- Defaults to all supported filetypes.
        filetypes = { 'clojure', 'fennel', 'scheme', 'lisp', 'janet' },

        -- This is some language specific configuration. Right now this is just used for
        -- setting character lists that are considered whitespace.
        languages = {
          clojure = {
            whitespace_chars = { ' ', ',' },
          },
          fennel = {
            whitespace_chars = { ' ', ',' },
          },
        },

        -- This controls where the cursor is placed when performing slurp/barf operations
        --
        -- - "remain" - It will never change the cursor position, keeping it in the same place
        -- - "follow" - It will always place the cursor on the form edge that was moved
        -- - "auto"   - A combination of remain and follow, it will try keep the cursor in the original position
        --              unless doing so would result in the cursor no longer being within the original form. In
        --              this case it will place the cursor on the moved edge
        cursor_behaviour = 'auto', -- remain, follow, auto

        dragging = {
          -- If set to `true` paredit will attempt to infer if an element being
          -- dragged is part of a 'paired' form like as a map. If so then the element
          -- will be dragged along with it's pair.
          auto_drag_pairs = true,
        },

        indent = {
          -- This controls how nvim-paredit handles indentation when performing operations which
          -- should change the indentation of the form (such as when slurping or barfing).
          --
          -- When set to true then it will attempt to fix the indentation of nodes operated on.
          enabled = false,
          -- A function that will be called after a slurp/barf if you want to provide a custom indentation
          -- implementation.
          indentor = require('nvim-paredit.indentation.native').indentor,
        },

        -- list of default keybindings
        keys = {
          ['<localleader>@'] = { paredit.unwrap.unwrap_form_under_cursor, 'Splice sexp' },
          ['>)'] = { paredit.api.slurp_forwards, 'Slurp forwards' },
          ['>('] = { paredit.api.barf_backwards, 'Barf backwards' },

          ['<)'] = { paredit.api.barf_forwards, 'Barf forwards' },
          ['<('] = { paredit.api.slurp_backwards, 'Slurp backwards' },

          ['>e'] = { paredit.api.drag_element_forwards, 'Drag element right' },
          ['<e'] = { paredit.api.drag_element_backwards, 'Drag element left' },

          ['>p'] = { paredit.api.drag_pair_forwards, 'Drag element pairs right' },
          ['<p'] = { paredit.api.drag_pair_backwards, 'Drag element pairs left' },

          ['>f'] = { paredit.api.drag_form_forwards, 'Drag form right' },
          ['<f'] = { paredit.api.drag_form_backwards, 'Drag form left' },

          ['<localleader>o'] = { paredit.api.raise_form, 'Raise form' },
          ['<localleader>O'] = { paredit.api.raise_element, 'Raise element' },

          -- WRAP
          ['<a-w>('] = {
            function()
              paredit.api.wrap_element_under_cursor('(', ')')
            end,
            'Wrap element (',
          },

          ['<a-w>['] = {
            function()
              paredit.api.wrap_element_under_cursor('[', ']')
            end,
            'Wrap element [',
          },

          ['<a-w>{'] = {
            function()
              paredit.api.wrap_element_under_cursor('{', '}')
            end,
            'Wrap element {',
          },

          ['T'] = {
            paredit.api.move_to_top_level_form_head,
            'Jump to next element tail',
            -- by default all keybindings are dot repeatable
            repeatable = false,
            mode = { 'n', 'x', 'o', 'v' },
          },

          ['E'] = {
            paredit.api.move_to_next_element_tail,
            'Jump to next element tail',
            -- by default all keybindings are dot repeatable
            repeatable = false,
            mode = { 'n', 'x', 'o', 'v' },
          },

          ['W'] = {
            paredit.api.move_to_next_element_head,
            'Jump to next element head',
            repeatable = false,
            mode = { 'n', 'x', 'o', 'v' },
          },

          ['B'] = {
            paredit.api.move_to_prev_element_head,
            'Jump to previous element head',
            repeatable = false,
            mode = { 'n', 'x', 'o', 'v' },
          },
          ['gE'] = {
            paredit.api.move_to_prev_element_tail,
            'Jump to previous element tail',
            repeatable = false,
            mode = { 'n', 'x', 'o', 'v' },
          },

          ['('] = {
            paredit.api.move_to_parent_form_start,
            "Jump to parent form's head",
            repeatable = false,
            mode = { 'n', 'x', 'v' },
          },
          [')'] = {
            paredit.api.move_to_parent_form_end,
            "Jump to parent form's tail",
            repeatable = false,
            mode = { 'n', 'x', 'v' },
          },

          -- These are text object selection keybindings which can used with standard `d, y, c`, `v`
          ['af'] = {
            paredit.api.select_around_form,
            'Around form',
            repeatable = false,
            mode = { 'o', 'v' },
          },
          ['if'] = {
            paredit.api.select_in_form,
            'In form',
            repeatable = false,
            mode = { 'o', 'v' },
          },
          ['aF'] = {
            paredit.api.select_around_top_level_form,
            'Around top level form',
            repeatable = false,
            mode = { 'o', 'v' },
          },
          ['iF'] = {
            paredit.api.select_in_top_level_form,
            'In top level form',
            repeatable = false,
            mode = { 'o', 'v' },
          },
          ['ae'] = {
            paredit.api.select_element,
            'Around element',
            repeatable = false,
            mode = { 'o', 'v' },
          },
          ['ie'] = {
            paredit.api.select_element,
            'Element',
            repeatable = false,
            mode = { 'o', 'v' },
          },
        },
      }
    end,
  },

  -- Render markdown in the buffer: styled headings, code blocks, tables,
  -- checkboxes and callouts, without leaving Neovim for a browser preview.
  --  `:RenderMarkdown toggle` turns it off if you want the raw text.
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
    opts = {
      -- The plugin's default symbols assume a Nerd Font. We don't have one
      -- (see vim.g.have_nerd_font at the top), so fall back to plain Unicode
      -- that renders in any font. Flip have_nerd_font to true after installing
      -- one and this automatically uses the nicer default glyphs instead.
      heading = vim.g.have_nerd_font and {} or {
        icons = { '# ', '## ', '### ', '#### ', '##### ', '###### ' },
        position = 'inline',
      },
      code = {
        -- 'language' shows the code block's language without needing file icons
        style = vim.g.have_nerd_font and 'full' or 'language',
        width = 'block',
        left_pad = 2,
        right_pad = 2,
      },
      bullet = vim.g.have_nerd_font and {} or {
        icons = { '•', '◦', '‣', '⁃' },
      },
      checkbox = vim.g.have_nerd_font and {} or {
        unchecked = { icon = '[ ] ' },
        checked = { icon = '[x] ' },
      },
    },
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Icon provider. render-markdown.nvim requires one of mini.icons or
      -- nvim-web-devicons; we already have mini.nvim, so use that rather than
      -- pulling in a second plugin.
      require('mini.icons').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    -- The 'master' branch is incompatible with Neovim 0.12+ (its bundled
    -- query_predicates.lua compat shim clashes with directives Neovim now
    -- implements natively, e.g. crashing on markdown fenced code blocks with
    -- "attempt to call method 'range' (a nil value)"). 'main' is a full,
    -- incompatible rewrite with a different setup API (no more
    -- `.configs`/`opts`) - see below. Requires the `tree-sitter` CLI
    -- (`brew install tree-sitter-cli`), not just a C compiler.
    branch = 'main',
    lazy = false, -- main branch does not support lazy-loading
    build = ':TSUpdate',
    init = function()
      local ensure_installed = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'go',
        'gomod',
        'gosum',
        'gowork',
        'python',
        'clojure',
      }
      local installed = require('nvim-treesitter.config').get_installed()
      local to_install = vim.iter(ensure_installed)
        :filter(function(lang)
          return not vim.tbl_contains(installed, lang)
        end)
        :totable()
      if #to_install > 0 then
        require('nvim-treesitter').install(to_install)
      end

      -- Highlighting and indentation are now provided by Neovim core / this
      -- plugin directly rather than through `.configs` opts.
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          pcall(vim.treesitter.start)
          -- Ruby depends on vim's regex indent rules; leave its indentexpr alone.
          if args.match ~= 'ruby' then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },

  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.neo-tree',
  -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  -- { import = 'custom.plugins' },
  --
  -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
  -- Or use telescope!
  -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
  -- you can continue same window with `<space>sr` which resumes last telescope search
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
