return {
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
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        zsh = { 'shfmt' },
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
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
          },
        },
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
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
        --
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

          -- Manually trigger a completion from nvim-cmp.
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
        },
      }
    end,
  },

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
      }

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  { 'github/copilot.vim' },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'github/copilot.vim' }, -- or zbirenbaum/copilot.lua
      { 'nvim-lua/plenary.nvim', branch = 'master' }, -- for curl, log and async functions
    },
    build = 'make tiktoken', -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
    -- See Commands section for default commands if you want to lazy load on them
  },

  {
    'ThePrimeagen/refactoring.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('refactoring').setup {}
      vim.keymap.set('x', '<leader>re', ':Refactor extract ')
      vim.keymap.set('x', '<leader>rf', ':Refactor extract_to_file ')

      vim.keymap.set('x', '<leader>rv', ':Refactor extract_var ')

      vim.keymap.set({ 'n', 'x' }, '<leader>ri', ':Refactor inline_var')

      vim.keymap.set('n', '<leader>rI', ':Refactor inline_func')

      vim.keymap.set('n', '<leader>rb', ':Refactor extract_block')
      vim.keymap.set('n', '<leader>rbf', ':Refactor extract_block_to_file')
    end,
  },

  {
    'amitds1997/remote-nvim.nvim',
    version = '*', -- Pin to GitHub releases
    dependencies = {
      'nvim-lua/plenary.nvim', -- For standard functions
      'MunifTanjim/nui.nvim', -- To build the plugin UI
      'nvim-telescope/telescope.nvim', -- For picking b/w different remote methods
    },
    config = true,
    enable = false,
  },
  {
    dir = '~/oss/remote-nvim.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim', -- For standard functions
      'MunifTanjim/nui.nvim', -- To build the plugin UI
      'nvim-telescope/telescope.nvim', -- For picking b/w different remote methods
    },
    opts = {
      progress_view = {
        type = 'split',
      },
      offline_mode = {
        enabled = false,
        no_github = true,
        -- Add this only if you want to change the path where the Neovim releases are downloaded/located.
        -- Default location is the output of :lua= vim.fn.stdpath("cache") .. "/remote-nvim.nvim/version_cache"
        cache_dir = vim.fn.stdpath 'cache' .. '/remote-nvim.nvim/version_cache',
        -- cache_dir = <custom-path>,
      },
      remote = {
        app_name = 'nvim', -- This directly maps to the value NVIM_APPNAME. If you use any other paths for configuration, also make sure to set this.
        -- List of directories that should be copied over
        copy_dirs = {
          -- What to copy to remote's Neovim config directory
          config = {
            base = vim.fn.stdpath 'config',
            dirs = '*',
            compression = {
              enabled = true,
              additional_opts = { '--exclude-vcs', '--exclude', 'node_modules' },
            },
          },
          -- What to copy to remote's Neovim data directory
          data = {
            base = vim.fn.stdpath 'data',
            dirs = '*',
            -- dirs = {},
            compression = {
              enabled = true,
              additional_opts = { '--exclude-vcs', '--exclude', 'mason', '--exclude', 'lazy' },
            },
          },
          -- What to copy to remote's Neovim cache directory
          cache = {
            base = vim.fn.stdpath 'cache',
            -- dirs = "*",
            dirs = {},
            compression = {
              enabled = true,
              additional_opts = { '--exclude-vcs', '--exclude', 'node_modules' },
            },
          },
          -- What to copy to remote's Neovim state directory
          state = {
            base = vim.fn.stdpath 'state',
            dirs = '*',
            compression = {
              enabled = true,
              additional_opts = { '--exclude-vcs', '--exclude', 'node_modules' },
            },
          },
        },
      },
      client_callback = function(port, workspace_config)
        local window_name = workspace_config.devpod_source_opts.name
        print('Neovim listening on port: ', port)
        local copy_text = ('nvim --server localhost:%s --remote-ui'):format(port)

        vim.fn.setreg('+', copy_text)

        local cmd = ''
        if vim.env.TERM == 'xterm-kitty' then
          -- cmd = ("kitty -e nvim --server localhost:%s --remote-ui"):format(port)
        end
        cmd = ("tmux new-window -n %s \\; send-keys 'nvim --server localhost:%s --remote-ui' C-m \\; select-window -t %s; exit"):format(
          window_name,
          port,
          window_name
        )
        vim.fn.jobstart(cmd, {
          detach = true,
          on_exit = function(job_id, exit_code, event_type)
            print('Client', job_id, 'exited with code', exit_code, 'Event type:', event_type)
          end,
        })
      end,
    },
    config = true,
    enable = false,
  },

  {
    'VPavliashvili/json-nvim',
    ft = 'json', -- only load for json filetype
  },
}
