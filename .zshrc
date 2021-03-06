#!/usr/bin/zsh
## Application homes

# Configure rvm
[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm


# Configure JDK
export JAVA_HOME=/System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home
export JDK_HOME=$JAVA_HOME

export PATH=$JDK_HOME/bin:$PATH

# MACPORTS
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
export MANPATH=$MANPATH:/opt/local/man

# ENV
LESS="iRwm"
# Allow less to view *.gz etc. files.
export LESSOPEN='| /opt/local/bin/lesspipe.sh %s' # From macports
#eval "$(lesspipe)"
GREP_COLOR="38;5;$HOSTCOLORCODE"
GREP_OPTIONS="--color=auto"
CLICOLOR=1
PAGER=less
# Colorized ls, with options
#eval "$(dircolors)" # doesn't work on os x
LS_COLORS="$LS_COLORS*.JPG=01;35:*.GIF=01;35:*.jpeg=01;35:*.pcx=01;35:*.png=01;35:*.pnm=01;35:*.bz2=01;31:*.mpg=01;38:*.mpeg=01;38:*.MPG=01;38:*.MPEG=01;38:*.m4v=01;038:*.mp4=01;038:*.swf=01;038:*.avi=01;38:*.AVI=01;38:*.wmv=01;38:*.WMV=01;38:*.asf=01;38:*.ASF=01;38:*.mov=01;38:*.MOV=01;38:*.mp3=01;39:*.ogg=01;39:*.MP3=01;39:*.Mp3=01;39"
ZLS_COLORS=$LS_COLORS
LS_OPTIONS="-p -l -h -G" # --color for linux?

HISTFILE=~/.zshhist
HISTSIZE=1000
SAVEHIST=1000000


# Functions

function yammerapps-local {
  export CLIENT_CONFIG="~/.yammer-local"
  export PLATFORM_HOST="http://yammer.localhost"
  yammerapps release
}

function yammerapps-staging {
  export CLIENT_CONFIG="~/.yammer-staging"
  export PLATFORM_HOST="https://www.staging.yammer.com"
  yammerapps release
}

function stat {
    if [ -d ".svn" ]; then
svn status
  elif [ -d ".git" ]; then
git status
  elif [ -d ".hg" ]; then
hg status
  fi
}

function qwhich {
    result=`which $@ 2> /dev/null`
    [[ $? == 0 ]] && echo $result
}

function alias_exists {
  name=$1
  value=$2
  command=$3
  [[ $command = "" ]] && command=$value
  if [[ -x `qwhich $command` ]]; then
	alias $name="$value"
  fi
}

function chpwd {
  [[ -t 1 ]] || return
  case $TERM in
	sun-cmd) print -Pn "\e]l%~\e\\"
	  ;;
	*xterm*|rxvt|(dt|k|E|e)term|eterm-color) print -Pn "\e]2;%~ | %M\a"
      ;;
  esac
}

# Aliases
alias g=egrep
alias p=ping
alias top=htop
alias ps='ps auxwww'
alias h='history'
alias s=sudo
alias su='sudo -s'
alias mkdir='mkdir -p'
alias ls="ls $LS_OPTIONS"

alias_exists tail inotail
alias_exists top htop

# Configure prompt
autoload -U colors && colors
hashMod () {
        HASH="0x`echo $1 | md5`" # mac
        # HASH="0x`echo $1 | md5sum`" # linux
        DEC=$(($HASH[0,15]))
        RESULT=`expr $DEC % $2`
}
HOSTNAME=`hostname`
PROMPT_COLORS=(black red green yellow blue magenta cyan white)
hashMod "$HOSTNAME" 8
PROMPT_HOST_CODE=$RESULT
PROMPT_HOST="%{$fg[$PROMPT_COLORS[$PROMPT_HOST_CODE]]%}%m%{$reset_color%}"
PROMPT_ERROR="%0(?..[%{$fg_bold[red]%}%?%{$reset_color%}])"
PROMPT_USER="%n"
PS1="$PROMPT_ERROR%*[$PROMPT_USER@$PROMPT_HOST]%3c %# "

# Options

# Directories
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_silent
setopt chase_links

# Completion
setopt always_to_end
setopt list_types

# Expansion and globbing
setopt extended_glob

# History
setopt inc_append_history
setopt extended_history
setopt hist_find_no_dups
setopt share_history
setopt HIST_REDUCE_BLANKS

# I/O
setopt aliases
setopt correct_all

# Job control
setopt auto_continue
setopt check_jobs
setopt no_hup
setopt long_list_jobs

# Prompt
setopt prompt_percent


# Modules

zmodload -i zsh/zle
zmodload -i zsh/complist
zmodload -i zsh/compctl
zmodload -i zsh/computil


# Config

# Set the titlebar when we change directories
chpwd()
# Emacs keybindings
bindkey -e
# No limits.
ulimit -c unlimited


# ZLE
function history-search-end {
    integer ocursor=$CURSOR

    if [[ $LASTWIDGET = history-beginning-search-*-end ]]; then
      # Last widget called set $hbs_pos.
      CURSOR=$hbs_pos
    else
      hbs_pos=$CURSOR
    fi

    if zle .${WIDGET%-end}; then
      # success, go to end of line
      zle .end-of-line
    else
      # failure, restore position
      CURSOR=$ocursor
      return 1
    fi
}
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "\e[A" history-beginning-search-backward-end
bindkey "\e[B" history-beginning-search-forward-end
#bindkey "^[[A" history-beginning-search-backward-end
#bindkey "^[[B" history-beginning-search-forward-end
bindkey "\eOA" history-beginning-search-backward-end
bindkey "\eOB" history-beginning-search-forward-end
zle -N history-beginning-search-menu-space-end history-beginning-search-menu
bindkey "\e\e[A" history-beginning-search-menu-space-end
bindkey "\e\eOA" history-beginning-search-menu-space-end
bindkey "\C-z" undo
bindkey " " magic-space
bindkey '^i' expand-or-complete-prefix
bindkey "^[[Z" reverse-menu-complete
bindkey "^[" send-break
bindkey "^[e" backward-kill-word
bindkey "^[w" backward-kill-word
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char-or-list
if [[ $TERM == "xterm" ]];then
  bindkey '^[[7~'  vi-beginning-of-line                                   # Home
  bindkey '^[[8~'  vi-end-of-line                                         # End
elif [[ $TERM == "vt100" ]];then
  bindkey '^[Oq'  beginning-of-line                                       # Home
  bindkey '^[Op'  end-of-line                                             # End
elif [[ $TERM == "linux" ]]; then
  bindkey '^[[1~'  beginning-of-line                                      # Home
  bindkey '^[[4~'  end-of-line                                            # End
elif [[ $TERM == "ansi" ]]; then
  bindkey '^[[H'  beginning-of-line                                   # Home
  bindkey '^[[F'  end-of-line                                         # End
else
true
fi


# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' insert-unambiguous true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=** r:|=**' 'l:|=* r:|=*'
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' menu select=1
zstyle ':completion:*' original true
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' prompt 'Errors %e'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle :compinstall filename '/home/mike/.zshrc'

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# In order for this to work, set "HashKnownHosts no" in ~/.ssh/config | /etc/ssh/config
hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts </etc/hosts)"}:#[0-9]*}%%\ *}%%,*})
zstyle ':completion:*:hosts' $hosts 

autoload -Uz compinit
compinit
# End of lines added by compinstall


# YAMMER
export DISPLAY=:0.0
export PATH=/opt/ruby-enterprise-current/bin:/opt/local/lib/postgresql84/bin:$PATH
export HOPTOAD_KEY=a6924e39ff98e6ce14555afc0dc1bb43

export SCALA_HOME=~/bin/scala
export PATH=$SCALA_HOME/bin:$PATH
