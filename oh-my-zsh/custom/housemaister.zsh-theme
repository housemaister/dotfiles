# prompt is set by zsh-theme :-(
# but we could source the original gnzh theme and extend the prompt

source "$ZSH/themes/gnzh.zsh-theme"

function zrcautoload() {
    emulate -L zsh
    setopt extended_glob
    local fdir ffile
    local -i ffound

    ffile=$1
    (( found = 0 ))
    for fdir in ${fpath} ; do
        [[ -e ${fdir}/${ffile} ]] && (( ffound = 1 ))
    done

    (( ffound == 0 )) && return 1
    if [[ $ZSH_VERSION == 3.1.<6-> || $ZSH_VERSION == <4->* ]] ; then
        autoload -U ${ffile} || return 1
    else
        autoload ${ffile} || return 1
    fi
    return 0
}

# set colors for use in prompts {{{
if zrcautoload colors && colors 2>/dev/null ; then
    BLUE="%{${fg[blue]}%}"
    RED="%{${fg_bold[red]}%}"
    GREEN="%{${fg[green]}%}"
    CYAN="%{${fg[cyan]}%}"
    MAGENTA="%{${fg[magenta]}%}"
    YELLOW="%{${fg[yellow]}%}"
    WHITE="%{${fg[white]}%}"
    NO_COLOUR="%{${reset_color}%}"
else
    BLUE=$'%{\e[1;34m%}'
    RED=$'%{\e[1;31m%}'
    GREEN=$'%{\e[1;32m%}'
    CYAN=$'%{\e[1;36m%}'
    WHITE=$'%{\e[1;37m%}'
    MAGENTA=$'%{\e[1;35m%}'
    YELLOW=$'%{\e[1;33m%}'
    NO_COLOUR=$'%{\e[0m%}'
fi

precmd () {
    # update VCS information
    vcs_info
}

VCS_INFO_set --nvcs preinit

zstyle ':vcs_info:*' actionformats "${MAGENTA}(${NO_COLOUR}%s${MAGENTA})${YELLOW}-${MAGENTA}[${GREEN}%b${YELLOW}|${RED}%a${MAGENTA}]${NO_COLOUR} " \
                                   "zsh: %r"
zstyle ':vcs_info:*' formats       "${MAGENTA}(${NO_COLOUR}%s${MAGENTA})${YELLOW}-${MAGENTA}[${GREEN}%b${MAGENTA}]${NO_COLOUR}%} " \
                                   "zsh: %r"
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat "%b${RED}:${YELLOW}%r"

local vcs_prompt='${VCS_INFO_message_0_}'


# override PR_USER as we use uid < 1000
# Check the UID
if [[ $UID -ge 500 ]]; then # normal user
  eval PR_USER='${PR_GREEN}%n${PR_NO_COLOR}'
  eval PR_USER_OP='${PR_GREEN}%#${PR_NO_COLOR}'
  local PR_PROMPT='$PR_NO_COLOR➤ $PR_NO_COLOR'
elif [[ $UID -eq 0 ]]; then # root
  eval PR_USER='${PR_RED}%n${PR_NO_COLOR}'
  eval PR_USER_OP='${PR_RED}%#${PR_NO_COLOR}'
  local PR_PROMPT='$PR_RED➤ $PR_NO_COLOR'
fi

local PR_CHROOT='${PR_WHITE}${debian_chroot:+($debian_chroot)}'

if [[ -z "$debian_chroot" ]] && [[ -r /etc/debian_chroot ]] ; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

#PROMPT="╭─${user_host} ${current_dir} ${rvm_ruby} ${git_branch}
#╰─$PR_PROMPT "
PROMPT="╭─$PR_CHROOT ${user_host} ${current_dir} ${vcs_prompt}
╰─$PR_PROMPT "


unfunction zrcautoload


