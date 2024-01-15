(local {: tbl_extend
        : validate
        :api {: nvim_get_current_win
              : nvim_get_current_buf
              : nvim_buf_get_name
              : nvim_buf_get_option}
        :cmd {: tabnew :language set-language}
        :fn {: stdpath : isdirectory : system : mkdir}
        :loader {:enable enable-cached-loader}} vim)

(enable-cached-loader)

(local {: set_options} (require :helper))
(local {: has-profile} (require :profiles))

(set vim.env.PATH (.. vim.env.PATH ":@addPath@"))
(set vim.env.VISUAL "nvr -cc split --remote-wait +'set bufhidden=wipe'")
(set vim.env.EDITOR "nvr -cc split --remote-wait +'set bufhidden=wipe'")

(let [install-path (.. (stdpath :data) :/site/pack/packer/start/packer.nvim)]
  (when (not= 1 (isdirectory install-path))
    (print "Installing packer...")
    (system [:git
             :clone
             :--depth=1
             "https://github.com/wbthomason/packer.nvim"
             install-path])))

(local {: use : use_rocks :set_handler phandle :startup psetup}
       (require :packer))

(local putil (require :packer.util))

(local {: handle-patches} (require :plugins.packer))

(local spelldir (.. (stdpath :data) :/spell))

(mkdir spelldir :p)

(set vim.g.mapleader "\\")
(set vim.g.maplocalleader "|")
(set vim.g.netrw_use_errorwindow 0)

(set_options vim.opt {; hidden changed buffers
                      :hidden true
                      ; show chars bottom left
                      :showcmd true
                      ; highlight search
                      :hlsearch true
                      ; show position in file
                      :ruler true
                      ; conceal
                      :conceallevel 2
                      :concealcursor :n
                      ; confirm closing unsaved files
                      :confirm true
                      ; line numbers
                      :number true
                      :relativenumber true
                      ; don't break line inside word
                      :linebreak true
                      ; jump while searching
                      :incsearch true
                      ; search case
                      :ignorecase true
                      :smartcase true
                      ; GUI colors
                      :termguicolors true
                      :synmaxcol 300
                      ; split buffers bottom right
                      :splitbelow true
                      :splitright true
                      ; save undo history
                      :undofile true
                      ; spell
                      :spell true
                      :spelloptions [:camel :noplainbuffer]
                      :spelllang [:en :de :cjk]
                      :spellfile (.. spelldir :/custom.utf-8.add)
                      ; cursor line
                      :cursorline true
                      ; updatetime for CursorHold
                      :updatetime 300
                      ; color column
                      :colorcolumn :+1
                      ; ! Don't use tmp file
                      :shelltemp false
                      :mouse ""
                      :background :dark
                      :timeoutlen 500
                      :diffopt [:internal
                                :filler
                                :closeoff
                                :vertical
                                "linematch:102"]
                      :completeopt [:menuone :noselect]
                      :omnifunc "syntaxcomplete#Complete"
                      :showbreak "─→"
                      :list true
                      :listchars {:tab "──" :trail "❯" :nbsp "˰"}
                      ; indent
                      :expandtab true
                      :tabstop 4
                      :shiftwidth 4
                      ; folding
                      :foldmethod :indent
                      :foldlevelstart 99
                      ; scrolling
                      :scrolljump -10
                      :scrolloff 8})

(set-language :en_US.utf8)

(phandle :patches handle-patches)

(lambda plug-config-str [plugin function]
  (.. "require('plugins." plugin "')." function "()"))

(lambda u [url ?opts ?disable]
  (let [opts (if (= nil ?opts) {} ?opts)
        disable (if (= nil ?disable) false ?disable)
        plugin-opts (tbl_extend :force opts {1 url : disable :file nil}
                                (if opts.file
                                    {:setup (if opts.setup
                                                (plug-config-str opts.file
                                                                 :setup))
                                     :config (if (or opts.config
                                                     (not opts.setup))
                                                 (plug-config-str opts.file
                                                                  :config))}
                                    {}))]
    (use plugin-opts)))

(psetup {1 (fn []
             (u :wbthomason/packer.nvim)
             ;; local plugins
             ;; "~/Documents/private/repos/compare-remotes.nvim"
             (u :aaron-p1/compare-remotes.nvim {:file :compare-remotes})
             ;; "~/Documents/private/repos/match-visual.nvim"
             (u :aaron-p1/match-visual.nvim {:file :match-visual})
             ;; "~/Documents/private/repos/virt-notes.nvim"
             (u :aaron-p1/virt-notes.nvim
                {:file :virt-notes :after :telescope.nvim})
             ;; improvements
             (u :m4xshen/hardtime.nvim
                {:file :hardtime
                 :requires [:MunifTanjim/nui.nvim :nvim-lua/plenary.nvim]})
             ;; color scheme
             (u :ellisonleao/gruvbox.nvim {:file :gruvbox})
             (u :rcarriga/nvim-notify {:file :notify :after :telescope.nvim})
             ;; small text utilities
             (u :numToStr/Comment.nvim {:file :comment})
             (u :kylechui/nvim-surround {:file :surround})
             (u :tpope/vim-unimpaired {:file :unimpaired})
             (u :tpope/vim-repeat)
             (u :tpope/vim-abolish)
             (u :tpope/vim-characterize)
             (u :monaqa/dial.nvim {:file :dial})
             (u :AndrewRadev/splitjoin.vim {:file :splitjoin :setup true})
             (u :Wansmer/treesj {:file :treesj})
             (u :NvChad/nvim-colorizer.lua {:file :colorizer})
             (u :lukas-reineke/indent-blankline.nvim {:file :indent-blankline})
             (u :windwp/nvim-autopairs {:file :autopairs :after :nvim-cmp})
             (u :windwp/nvim-ts-autotag {:after :nvim-treesitter})
             (u :andymass/vim-matchup
                {:file :matchup
                 :setup true
                 :config true
                 :after :nvim-treesitter})
             (u :rlane/pounce.nvim {:file :pounce})
             (u :nvim-pack/nvim-spectre
                {:requires [:nvim-lua/plenary.nvim] :file :spectre})
             ;; status line
             (u :nvim-lualine/lualine.nvim
                {:file :lualine :requires [:kyazdani42/nvim-web-devicons]})
             (u :nvim-treesitter/nvim-treesitter
                {:file :treesitter :run ":TSUpdate"})
             (u :nvim-treesitter/nvim-treesitter-textobjects
                {:file :treesitter-textobjects
                 :requires :nvim-treesitter/nvim-treesitter
                 :after :nvim-treesitter})
             (u :mizlan/iswap.nvim {:file :iswap :after :nvim-treesitter})
             ;; syntax
             (u :sheerun/vim-polyglot {:file :polyglot :setup true})
             (u :dylon/vim-antlr)
             ;; helper
             (u :folke/which-key.nvim {:file :which-key})
             (u :deris/vim-shot-f)
             ;; git
             (u :tpope/vim-fugitive
                {:file :fugitive
                 :cmd [:Git
                       :GBrowse
                       :Gdiffsplit
                       :Gwrite
                       :Gread
                       :Gedit
                       :GRename
                       :GMove]})
             (u :lewis6991/gitsigns.nvim
                {:file :gitsigns
                 :requires [:nvim-lua/plenary.nvim]
                 :after :vim-fugitive})
             (u :sindrets/diffview.nvim
                {:file :diffview :requires [:nvim-lua/plenary.nvim]})
             ;; file manager
             (u :kyazdani42/nvim-tree.lua
                {:file :tree
                 :requires [:kyazdani42/nvim-web-devicons]
                 :after :telescope.nvim})
             (u :stevearc/oil.nvim {:file :oil})
             ;; fuzzy finder
             (u :nvim-telescope/telescope.nvim
                {:file :telescope
                 :requires [:nvim-lua/popup.nvim
                            :nvim-lua/plenary.nvim
                            :benfowler/telescope-luasnip.nvim]
                 :after [:telescope-fzf-native.nvim
                         :telescope-symbols.nvim
                         :trouble.nvim]})
             (u :nvim-telescope/telescope-fzf-native.nvim {:run :make})
             (u :nvim-telescope/telescope-symbols.nvim)
             (u :nvim-telescope/telescope-dap.nvim
                {:file :telescope-dap
                 :requires [:nvim-telescope/telescope.nvim
                            :mfussenegger/nvim-dap]
                 :after [:telescope.nvim :nvim-dap]})
             (u :stevearc/dressing.nvim
                {:file :dressing :after :telescope.nvim})
             ;; snippets
             (u :L3MON4D3/LuaSnip {:file :luasnip})
             (u :rafamadriz/friendly-snippets
                {:file :friendly-snippets :after [:LuaSnip]})
             ;; lsp
             (u :neovim/nvim-lspconfig
                {:file :lspconfig
                 :after [:nvim-cmp :telescope.nvim :schemastore.nvim]})
             (u :kosayoda/nvim-lightbulb
                {:patches :change-lightbulb-char.patch
                 :file :lightbulb
                 :requires [:antoinemadec/FixCursorHold.nvim]})
             ;; orgmode
             (u :nvim-orgmode/orgmode
                {:file :orgmode :requires [:nvim-treesitter/nvim-treesitter]})
             ;; elixir
             (u :elixir-tools/elixir-tools.nvim
                {:file :elixir-tools
                 :tag :stable
                 :requires :nvim-lua/plenary.nvim})
             ;; json
             (u :b0o/schemastore.nvim)
             ;; java
             (u :mfussenegger/nvim-jdtls)
             (u :jose-elias-alvarez/null-ls.nvim
                {:file :null-ls
                 :requires [:nvim-lua/plenary.nvim]
                 :after :nvim-lspconfig})
             (u :hrsh7th/nvim-cmp
                {:file :cmp :requires [:onsails/lspkind.nvim]})
             (u :hrsh7th/cmp-buffer)
             (u :hrsh7th/cmp-path)
             (u :hrsh7th/cmp-calc)
             (u :hrsh7th/cmp-cmdline)
             (u :dmitmel/cmp-cmdline-history)
             (u :saadparwaiz1/cmp_luasnip)
             (u :hrsh7th/cmp-omni)
             (u :hrsh7th/cmp-nvim-lsp)
             (u :dmitmel/cmp-digraphs {:patches :add-prefix.patch})
             (u :David-Kunz/cmp-npm {:requires [:nvim-lua/plenary.nvim]})
             ;; DEPENDENCIES: nodejs
             (u :github/copilot.vim {:file :copilot})
             ;; diagnostics
             (u :folke/trouble.nvim
                {:file :trouble :requires :kyazdani42/nvim-web-devicons})
             ;; dap
             (u :mfussenegger/nvim-dap {:file :dap :keys [:<F5> :<F8>]})
             (u :theHamsta/nvim-dap-virtual-text
                {:file :dap-virtual-text
                 :requires [:mfussenegger/nvim-dap]
                 :after :nvim-dap})
             (u :rcarriga/nvim-dap-ui
                {:file :dap-ui
                 :requires [:mfussenegger/nvim-dap]
                 :after :nvim-dap})
             (u :vim-test/vim-test)
             ;; tex
             (u :lervag/vimtex {:file :vimtex})
             (u :jalvesaq/Nvim-R {:file :r})
             (use_rocks :fun))
         :config {:display {:open_fn (fn []
                                       (let [bufnr (nvim_get_current_buf)
                                             bufname (nvim_buf_get_name bufnr)
                                             bufmod (nvim_buf_get_option bufnr
                                                                         :modified)]
                                         (when (or (not= "" bufname) bufmod)
                                           (tabnew))
                                         (values true (nvim_get_current_win)
                                                 (nvim_get_current_buf))))}}})

(local setup-modules [:overrides
                      :keymaps
                      :autocmd
                      :features.error-buffer
                      :features.macro-insert-paste
                      :features.paste-plugin-link
                      :features.plugin-links
                      :features.run-profile
                      :features.scratch-buffer
                      :features.swap-textobjects
                      :features.training])

(each [_ mod-name (ipairs setup-modules)]
  (let [mod (require mod-name)]
    (mod.setup)))
