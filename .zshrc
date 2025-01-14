# Personal Zsh configuration file. It is strongly recommended to keep all
# shell customization and configuration (including exported environment
# variables such as PATH) in this file or in files sourced from it.
#
# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
zstyle ':z4h:' auto-update      'no'
# Ask whether to auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4h:' auto-update-days '28'

# Keyboard type: 'mac' or 'pc'.
zstyle ':z4h:bindkey' keyboard  'pc'

# Start tmux if not already in tmux.
# zstyle ':z4h:' start-tmux command tmux -u new -A -D -t z4h

if [[ -z "$NO_TMUX" ]]; then
  zstyle ':z4h:' start-tmux command tmux -u new -A -D -t z4h
fi
# zstyle ':z4h:' start-tmux command zsh

# Whether to move prompt to the bottom when zsh starts and on Ctrl+L.
zstyle ':z4h:' prompt-at-bottom 'no'

# Mark up shell's output with semantic information.
zstyle ':z4h:' term-shell-integration 'yes'

# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' forward-char 'accept'

# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs 'no'

# Enable direnv to automatically source .envrc files.
zstyle ':z4h:direnv'         enable 'yes'
# Show "loading" and "unloading" notifications from direnv.
zstyle ':z4h:direnv:success' notify 'yes'

# Enable ('yes') or disable ('no') automatic teleportation of z4h over
# SSH when connecting to these hosts.
zstyle ':z4h:ssh:example-hostname1'   enable 'yes'
zstyle ':z4h:ssh:*.example-hostname2' enable 'no'
# The default value if none of the overrides above match the hostname.
zstyle ':z4h:ssh:*'                   enable 'no'

# Send these files over to the remote host when connecting over SSH to the
# enabled hosts.
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'

# Clone additional Git repositories from GitHub.
#
# This doesn't do anything apart from cloning the repository and keeping it
# up-to-date. Cloned files can be used after `z4h init`. This is just an
# example. If you don't plan to use Oh My Zsh, delete this line.
z4h install ohmyzsh/ohmyzsh || return

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return

# Extend PATH.
path=(~/bin $path)

# Export environment variables.
export GPG_TTY=$TTY

# Source additional local files if they exist.
z4h source ~/.env.zsh

# Use additional Git repositories pulled in with `z4h install`.
#
# This is just an example that you should delete. It does nothing useful.
z4h source ohmyzsh/ohmyzsh/lib/diagnostics.zsh  # source an individual file
z4h load   ohmyzsh/ohmyzsh/plugins/emoji-clock  # load a plugin

# Define key bindings.
z4h bindkey z4h-backward-kill-word  Ctrl+Backspace     Ctrl+H
z4h bindkey z4h-backward-kill-zword Ctrl+Alt+Backspace

z4h bindkey undo Ctrl+/ Shift+Tab  # undo the last command line change
z4h bindkey redo Alt+/             # redo the last undone command line change

z4h bindkey z4h-cd-back    Alt+Left   # cd into the previous directory
z4h bindkey z4h-cd-forward Alt+Right  # cd into the next directory
z4h bindkey z4h-cd-up      Alt+Up     # cd into the parent directory
z4h bindkey z4h-cd-down    Alt+Down   # cd into a child directory

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Define named directories: ~w <=> Windows home directory on WSL.
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

# Define aliases.
alias tree='tree -a -I .git'

# Add flags to existing aliases.
alias ls="${aliases[ls]:-ls} -A"

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu


export EDITOR='nvim'  # nvim
export TEXT_EDITOR="$EDITOR"  # nvim
export ZSH_CONFIG_PATH='~/.zshrc'

alias zsh_config='eval "$TEXT_EDITOR $ZSH_CONFIG_PATH"'
alias shell_config='zsh_config'
alias nvim_config='n ~/.config/nvim/init.lua'
alias nconfig='nvim_config'


export NOTES_GIT_PATH='/home/shandlx/hub/vault/notes'


function get_quick_git(){
  find ~/hub/ -type d -name ".git" -exec dirname {} \; | fzf | xargs -I {} sh -c 'export LAST_QUICK_GIT_PATH="{}"; echo $LAST_QUICK_GIT_PATH';
}

function quick_git(){
  get_quick_git | xargs -I {} git -C {} 
}

function get_last_quick_git(){
  if [ -z "$LAST_QUICK_GIT_PATH" ]; then
    echo "Error: LAST_QUICK_GIT_PATH is not set." >&2
    return 1
  else
    echo "$LAST_QUICK_GIT_PATH"
  fi
}

function last_quick_git(){
  get_last_quick_git | xargs -I {} git -C {} 
}

alias lg='lazygit'
alias qg='quick_git'
alias lqg='last_quick_git'
alias refresh_git_remote='xargs -I {} sh -c "git -C {} pull && git -C {} push"'
alias qgrf='get_quick_git | refresh_git_remote'  # quick git remote refresh
alias lqgrf='get_last_quick_gitg | refresh_git_remote'


alias notes_git='git -C $NOTES_GIT_PATH'
alias notes_remote_sync='notes_git pull && notes_git push'


alias cleanup="sudo pacman -Rns $(pacman -Qdtq)" # Remove unused dependencies


alias update="sudo pacman -Sy"               # Update the system
alias upgrade="sudo pacman -Syu"                     # Update with AUR packages (for yay users)
alias install="sudo pacman -S"               # Install a package
alias remove="sudo pacman -R"                # Remove a package
alias search="pacman -Ss"                    # Search for a package in repos
alias list="pacman -Qe"                      # List explicitly installed packages
alias info="pacman -Qi"                      # Get info about a package
alias orphan="pacman -Qdt"                   # List orphaned packages


alias yupdate="yay -Sy"               # Update the system
alias yupgrade="yay -Syu"                     # Update with AUR packages (for yay users)
alias yinstall="yay -S"                      # Install package from AUR
alias yremove="yay -R"                       # Remove package using yay
alias ysearch="yay -Ss"                      # Search for a package in AUR
alias yclean="yay -Sc --aur"                 # Clean yay cache

alias ll="ls -alh"                           # Detailed list with human-readable sizes
alias la="ls -A"                             # List all files except . and ..
alias l="ls -CF"                             # Compact list
alias mkdir="mkdir -pv"                      # Create directories with verbose output
alias rm="rm -i"                             # Prompt before removing files

alias ip="ip -c"                             # Colorize `ip` command output
alias ports="sudo netstat -tulanp"           # List open ports
alias myip="curl ifconfig.me"                # Get external IP

alias usage="du -sh * | sort -h"             # Show disk usage of files/directories
alias mem="free -h"                          # Show memory usage
alias cpu="lscpu"                            # Display CPU info
alias logs="journalctl -p 3 -xb"             # Show recent critical system logs


alias reboot="sudo systemctl reboot"         # Reboot the system
alias shutdown="sudo systemctl poweroff"     # Shut down the system
alias suspend="sudo systemctl suspend"       # Suspend the system

alias gco="git checkout"
alias gi="git init"
alias gs="git status"                        # Show git status
alias ga="git add"                           # Add changes to staging
alias gc="git commit"                        # Commit changes
alias gp="git push"                          # Push to remote repository
alias gpl="git pull"                          # Push to remote repository
alias gl="git log --oneline --graph"         # Show a concise commit graph
alias gd="git diff"                          # Push to remote repository
alias gai='git diff | sgpt "Generate git commit message, for my changes without extra explanation"'
alias gcai='gai && git add -u | xargs -I {} git commit -m {}'
alias grf='gpl && gp'

alias mirror="sudo reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist" # Update mirrorlist
alias downgrade="downgrade"                 # Use the `downgrade` package
alias pkgfiles="pkgfile"                    # Search for files in packages


alias clr="clear"                            # Clear terminal
alias ..="cd .."                             # Go up one directory
alias ...="cd ../.."                         # Go up two directories
alias edit="nano"                            # Open Nano editor
alias hosts="sudo nano /etc/hosts"           # Edit hosts file

alias cp="cp -i"                             # Prompt before overwriting files
alias mv="mv -i"                             # Prompt before moving files
alias rm="rm -I --preserve-root"             # Prevent accidental deletion


alias n='nvim'
alias reload='exec zsh'

alias python3='python3.10'
alias python='python3.10'
alias pip3='python3.10 -m pip'
alias pip='python3.10 -m pip'


# Ollama
export OLLAMA_DEFAULT_MODEL="llama3.2"

alias ask="ollama run $OLLAMA_DEFAULT_MODEL"


export PASSWORD_STORE_EXTENSION=".md"


# Password Manager (pass)
alias pe='pass edit'
alias prm='pass rm'
alias pg='pass git'
alias pga='pg add'
alias pgc='pg commit'
alias pgrf='pg pull && pg push'



# Docker things
alias d='docker'
alias compose='docker compose'
alias c='compose'
alias ld='lazydocker'
