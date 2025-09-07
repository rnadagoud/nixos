{ config, pkgs, ... }:

{
  # Development environment configuration
  # This solves your Python/Node version management issues from Arch
  
  # Direnv configuration for automatic per-project environments
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    config = {
      global = {
        load_dotenv = true;
        warn_timeout = "30s";
        hide_env_diff = true;
      };
    };
  };
  
  # Development tools
  home.packages = with pkgs; [
    # Version managers (but we'll use direnv instead)
    # pyenv  # Not needed with direnv
    # nvm    # Not needed with direnv
    
    # Language servers
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.pyright
    rust-analyzer
    gopls
    jdt-language-server
    
    # Build tools
    gcc
    gnumake
    cmake
    pkg-config
    
    # Database tools
    postgresql
    sqlite
    
    # Testing tools
    nodePackages.jest
    python311Packages.pytest
    python311Packages.pytest-cov
    
    # Package managers
    nodePackages.npm
    nodePackages.yarn
    nodePackages.pnpm
    python311Packages.pip
    python311Packages.poetry
    python311Packages.pipenv
    
    # Container tools
    docker-compose
    podman-compose
    buildah
    skopeo
    
    # Git tools
    gh
    lazygit
    git-crypt
    
    # Development utilities
    jq
    yq
    httpie
    curl
    wget
    tree
    ripgrep
    fd
    bat
    exa
    fzf
  ];
  
  # Shell configuration for development
  programs.zsh.initExtra = ''
    # Development environment setup
    export PATH="$HOME/.local/bin:$PATH"
    
    # Python development
    export PYTHONPATH="$HOME/.local/lib/python3.11/site-packages:$PYTHONPATH"
    
    # Node.js development
    export NODE_PATH="$HOME/.local/lib/node_modules:$NODE_PATH"
    
    # Go development
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$PATH"
    
    # Rust development
    export PATH="$HOME/.cargo/bin:$PATH"
    
    # Development aliases
    alias dev="cd ~/projects"
    alias ll="exa -l"
    alias la="exa -la"
    alias tree="exa --tree"
    alias cat="bat"
    alias grep="rg"
    alias find="fd"
    
    # Git aliases
    alias gs="git status"
    alias ga="git add"
    alias gc="git commit"
    alias gp="git push"
    alias gl="git log --oneline"
    alias gd="git diff"
    alias gb="git branch"
    alias gco="git checkout"
    
    # Docker aliases
    alias d="docker"
    alias dc="docker-compose"
    alias dps="docker ps"
    alias di="docker images"
    
    # Development functions
    mkproject() {
        if [ -z "$1" ]; then
            echo "Usage: mkproject <project-name>"
            return 1
        fi
        
        mkdir -p ~/projects/$1
        cd ~/projects/$1
        
        # Create basic .envrc for direnv
        cat > .envrc << EOF
    # Development environment for $1
    use nix
    EOF
        
        # Create basic git repo
        git init
        git add .envrc
        git commit -m "Initial commit with direnv configuration"
        
        echo "Project $1 created in ~/projects/$1"
        echo "Run 'direnv allow' to activate the environment"
    }
    
    # Python project setup
    mkpython() {
        if [ -z "$1" ]; then
            echo "Usage: mkpython <project-name>"
            return 1
        fi
        
        mkproject $1
        cat > .envrc << EOF
    # Python development environment for $1
    use nix
    
    # Python packages
    python -m venv .venv
    source .venv/bin/activate
    EOF
        
        # Create requirements.txt
        touch requirements.txt
        
        # Create basic Python structure
        mkdir -p src tests
        touch src/__init__.py
        touch tests/__init__.py
        
        echo "Python project $1 created with virtual environment"
    }
    
    # Node.js project setup
    mknode() {
        if [ -z "$1" ]; then
            echo "Usage: mknode <project-name>"
            return 1
        fi
        
        mkproject $1
        cat > .envrc << EOF
    # Node.js development environment for $1
    use nix
    
    # Node.js packages
    npm init -y
    EOF
        
        echo "Node.js project $1 created"
    }
  '';
  
  # VS Code configuration for development
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      # Language support
      ms-python.python
      ms-vscode.vscode-typescript-next
      ms-vscode.vscode-json
      rust-lang.rust-analyzer
      golang.go
      
      # Development tools
      ms-vscode.vscode-eslint
      esbenp.prettier-vscode
      bradlc.vscode-tailwindcss
      ms-vscode.vscode-docker
      ms-kubernetes-tools.vscode-kubernetes-tools
      
      # Git
      eamodio.gitlens
      
      # Nix
      jnoortheen.nix-ide
      
      # Direnv
      mkhl.direnv
    ];
    
    userSettings = {
      "editor.formatOnSave" = true;
      "editor.codeActionsOnSave" = {
        "source.fixAll.eslint" = true;
      };
      "python.defaultInterpreterPath" = "python3";
      "python.terminal.activateEnvironment" = true;
      "typescript.preferences.importModuleSpecifier" = "relative";
      "files.autoSave" = "afterDelay";
      "files.autoSaveDelay" = 1000;
      "workbench.colorTheme" = "Default Dark+";
      "terminal.integrated.defaultProfile.linux" = "zsh";
    };
  };
  
  # Neovim configuration for development
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    
    # Basic configuration
    extraConfig = ''
      " Basic settings
      set number
      set relativenumber
      set tabstop=4
      set shiftwidth=4
      set expandtab
      set autoindent
      set smartindent
      set cursorline
      set showmatch
      set incsearch
      set hlsearch
      set ignorecase
      set smartcase
      set backspace=indent,eol,start
      set wildmenu
      set wildmode=longest:full,full
      set clipboard=unnamedplus
      
      " Color scheme
      colorscheme default
      set background=dark
      
      " Key mappings
      let mapleader = " "
      nnoremap <leader>w :w<CR>
      nnoremap <leader>q :q<CR>
      nnoremap <leader>h :nohlsearch<CR>
      nnoremap <leader>t :terminal<CR>
      
      " File type specific settings
      autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab
      autocmd FileType javascript setlocal tabstop=2 shiftwidth=2 expandtab
      autocmd FileType typescript setlocal tabstop=2 shiftwidth=2 expandtab
      autocmd FileType json setlocal tabstop=2 shiftwidth=2 expandtab
      autocmd FileType yaml setlocal tabstop=2 shiftwidth=2 expandtab
      autocmd FileType html setlocal tabstop=2 shiftwidth=2 expandtab
      autocmd FileType css setlocal tabstop=2 shiftwidth=2 expandtab
    '';
  };
}