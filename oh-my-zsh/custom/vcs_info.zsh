# The following code is imported from the file 'zsh/functions/vcs_info'
# from <http://ft.bewatermyfriend.org/comp/zsh/zsh-dotfiles.tar.bz2>,
# which distributed under the same terms as zsh itself.

# we will be using two variables, so let the code know now.
zstyle ':vcs_info:*' max-exports 2

# vcs_info() documentation:
#{{{
# REQUIREMENTS:
#{{{
#     This functionality requires zsh version >= 4.1.*.
#}}}
#
# LOADING:
#{{{
# To load vcs_info(), copy this file to your $fpath[] and do:
#   % autoload -Uz vcs_info && vcs_info
#
# To work, vcs_info() needs 'setopt prompt_subst' in your setup.
#}}}
#
# QUICKSTART:
#{{{
# To get vcs_info() working quickly (including colors), you can do the
# following (assuming, you loaded vcs_info() properly - see above):
#
# % RED=$'%{\e[31m%}'
# % GR=$'%{\e[32m%}'
# % MA=$'%{\e[35m%}'
# % YE=$'%{\e[33m%}'
# % NC=$'%{\e[0m%}'
#
# % zstyle ':vcs_info:*' actionformats \
#       "${MA}(${NC}%s${MA})${YE}-${MA}[${GR}%b${YE}|${RED}%a${MA}]${NC} "
#
# % zstyle ':vcs_info:*' formats       \
#       "${MA}(${NC}%s${MA})${Y}-${MA}[${GR}%b${MA}]${NC}%} "
#
# % zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat "%b${RED}:${YE}%r"
#
# % precmd () { vcs_info }
# % PS1='${MA}[${GR}%n${MA}] ${MA}(${RED}%!${MA}) ${YE}%3~ ${VCS_INFO_message_0_}${NC}%# '
#
# Obviously, the las two lines are there for demonstration: You need to
# call vcs_info() from your precmd() function (see 'SPECIAL FUNCTIONS' in
# 'man zshmisc'). Once that is done you need a *single* quoted
# '${VCS_INFO_message_0_}' in your prompt.
#
# Now call the 'vcs_info_printsys' utility from the command line:
#
# % vcs_info_printsys
# # list of supported version control backends:
# # disabled systems are prefixed by a hash sign (#)
# git
# hg
# bzr
# darcs
# svk
# mtn
# svn
# cvs
# cdv
# tla
# # flavours (cannot be used in the disable style; they
# # are disabled with their master [git-svn -> git]):
# git-p4
# git-svn
#
# Ten version control backends as you can see. You may not want all
# of these. Because there is no point in running the code to detect
# systems you do not use. ever. So, there is a way to disable some
# backends altogether:
#
# % zstyle ':vcs_info:*' disable bzr cdv darcs mtn svk tla
#
# If you rerun 'vcs_info_printsys' now, you will see the backends listed
# in the 'disable' style marked as diabled by a hash sign. That means the
# detection of these systems is skipped *completely*. No wasted time there.
#
# For more control, read the reference below.
#}}}
#
# CONFIGURATION:
#{{{
# The vcs_info() feature can be configured via zstyle.
#
# First, the context in which we are working:
#       :vcs_info:<vcs-string>:<user-context>
#
# ...where <vcs-string> is one of:
#   - git, git-svn, git-p4, hg, darcs, bzr, cdv, mtn, svn, cvs, svk or tla.
#
# ...and <user-context> is a freely configurable string, assignable by the
# user as the first argument to vcs_info() (see its description below).
#
# There is are three special values for <vcs-string>: The first is named
# 'init', that is in effect as long as there was no decision what vcs
# backend to use. The second is 'preinit; it is used *before* vcs_info()
# is run, when initializing the data exporting variables. The third
# special value is 'formats' and is used by the 'vcs_info_lastmsg' for
# looking up its styles.
#
# There are two pre-defined values for <user-context>:
#   default  - the one used if none is specified
#   command  - used by vcs_info_lastmsg to lookup its styles.
#
# You may *not* use 'print_systems_' as a user-context string, because it
# is used internally.
#
# You can of course use ':vcs_info:*' to match all VCSs in all
# user-contexts at once.
#
# Another special context is 'formats', which is used by the
# vcs_info_lastmsg() utility function (see below).
#
#
# This is a description of all styles, that are looked up:
#   formats             - A list of formats, used when actionformats is not
#                         used (which is most of the time).
#   actionformats       - A list of formats, used if a there is a special
#                         action going on in your current repository;
#                         (like an interactive rebase or a merge conflict)
#   branchformat        - Some backends replace %b in the formats and
#                         actionformats styles above, not only by a branch
#                         name but also by a revision number. This style
#                         let's you modify how that string should look like.
#   nvcsformats         - These "formats" are exported, when we didn't detect
#                         a version control system for the current directory.
#                         This is useful, if you want vcs_info() to completely
#                         take over the generation of your prompt.
#                         You would do something like
#                           PS1='${VCS_INFO_message_0_}'
#                         to accomplish that.
#   max-exports         - Defines the maximum number if VCS_INFO_message_*_
#                         variables vcs_info() will export.
#   enable              - Checked in the 'init' context. If set to false,
#                         vcs_info() will do nothing.
#   disable             - Provide a list of systems, you don't want
#                         the vcs_info() to check for repositories
#                         (checked in the 'init' context, too).
#   disable-patterns    - A list of patterns that are checked against $PWD.
#                         If the pattern matches, vcs_info will be disabled.
#                         Say, ~/.zsh is a directory under version control,
#                         in which you do not want vcs_info to be active, do:
#                         zstyle ':vcs_info:*' disable-patterns "$HOME/.zsh+(|/*)"
#   use-simple          - If there are two different ways of gathering
#                         information, you can select the simpler one
#                         by setting this style to true; the default
#                         is to use the not-that-simple code, which is
#                         potentially a lot slower but might be more
#                         accurate in all possible cases.
#   use-prompt-escapes  - determines if we assume that the assembled
#                         string from vcs_info() includes prompt escapes.
#                         (Used by vcs_info_lastmsg().
#
# The use-simple style is only available for the bzr backend.
#
# The default values for these in all contexts are:
#   formats             " (%s)-[%b|%a]-"
#   actionformats       " (%s)-[%b]-"
#   branchformat        "%b:%r" (for bzr, svn and svk)
#   nvcsformats         ""
#   max-exports         2
#   enable              true
#   disable             (empty list)
#   disable-patterns    (empty list)
#   use-simple          false
#   use-prompt-escapes  true
#
#
# In normal formats and actionformats, the following replacements
# are done:
#   %s  - The vcs in use (git, hg, svn etc.)
#   %b  - Information about the current branch.
#   %a  - An identifier, that describes the action.
#         Only makes sense in actionformats.
#   %R  - base directory of the repository.
#   %r  - repository name
#         If %R is '/foo/bar/repoXY', %r is 'repoXY'.
#   %S  - subdirectory within a repository. if $PWD is
#         '/foo/bar/reposXY/beer/tasty', %S is 'beer/tasty'.
#
#
# In branchformat these replacements are done:
#   %b  - the branch name
#   %r  - the current revision number
#
# Not all vcs backends have to support all replacements.
# nvcsformat does not perform *any* replacements. It is just a string.
#}}}
#
# ODDITIES:
#{{{
# If you want to use the %b (bold off) prompt expansion in 'formats', which
# expands %b itself, use %%b. That will cause the vcs_info() expansion to
# replace %%b with %b. So zsh's prompt expansion mechanism can handle it.
# Similarly, to hand down %b from branchformat, use %%%%b. Sorry for this
# inconvenience, but it cannot be easily avoided. Luckily we do not clash
# with a lot of prompt expansions and this only needs to be done for those.
# See 'man zshmisc' for details about EXPANSION OF PROMPT SEQUENCES.
#}}}
#
# FUNCTION DESCRIPTIONS (public API):
#{{{
#   vcs_info()
#       The main function, that runs all backends and assembles
#       all data into ${VCS_INFO_message_*_}. This is the function
#       you want to call from precmd() if you want to include
#       up-to-date information in your prompt (see VARIABLE
#       DESCRIPTION below).
#
#   vcs_info_printsys()
#       Prints a list of all supported version control systems.
#       Useful to find out possible contexts (and which of them are enabled)
#       or values for the 'disable' style.
#
#   vcs_info_lastmsg()
#       Outputs the last ${VCS_INFO_message_*_} value. Takes into account
#       the value of the use-prompt-escapes style in ':vcs_info:formats'.
#       It also only prints max-exports values.
#
# All functions named VCS_INFO_* are for internal use only.
#}}}
#
# VARIABLE DESCRIPTION:
#{{{
#   ${VCS_INFO_message_N_}    (Note the trailing underscore)
#       Where 'N' is an integer, eg: VCS_INFO_message_0_
#       These variables are the storage for the informational message the
#       last vcs_info() call has assembled. These are strongly connected
#       to the formats, actionformats and nvcsformats styles described
#       above. Those styles are lists. the first member of that list gets
#       expanded into ${VCS_INFO_message_0_}, the second into
#       ${VCS_INFO_message_1_} and the Nth into ${VCS_INFO_message_N-1_}.
#       These parameters are exported into the environment.
#       (See the max-exports style above.)
#}}}
#
# EXAMPLES:
#{{{
#   Don't use vcs_info at all (even though it's in your prompt):
#   % zstyle ':vcs_info:*' enable false
#
#   Disable the backends for bzr and svk:
#   % zstyle ':vcs_info:*' disable bzr svk
#
#   Provide a special formats for git:
#   % zstyle ':vcs_info:git:*' formats       ' GIT, BABY! [%b]'
#   % zstyle ':vcs_info:git:*' actionformats ' GIT ACTION! [%b|%a]'
#
#   Use the quicker bzr backend (if you do, please report if it does
#   the-right-thing[tm] - thanks):
#   % zstyle ':vcs_info:bzr:*' use-simple true
#
#   Display the revision number in yellow for bzr and svn:
#   % zstyle ':vcs_info:(svn|bzr):*' branchformat '%b%{'${fg[yellow]}'%}:%r'
#
# If you want colors, make sure you enclose the color codes in %{...%},
# if you want to use the string provided by vcs_info() in prompts.
#
# Here is how to print the vcs infomation as a command:
#   % alias vcsi='vcs_info command; vcs_info_lastmsg'
#
#   This way, you can even define different formats for output via
#   vcs_info_lastmsg() in the ':vcs_info:command:*' namespace.
#}}}
#}}}
# utilities
VCS_INFO_adjust () { #{{{
    [[ -n ${vcs_comm[overwrite_name]} ]] && vcs=${vcs_comm[overwrite_name]}
    return 0
}
# }}}
VCS_INFO_check_com () { #{{{
    (( ${+commands[$1]} )) && [[ -x ${commands[$1]} ]] && return 0
    return 1
}
# }}}
VCS_INFO_formats () { # {{{
    setopt localoptions noksharrays
    local action=$1 branch=$2 base=$3
    local msg
    local -i i

    if [[ -n ${action} ]] ; then
        zstyle -a ":vcs_info:${vcs}:${usercontext}" actionformats msgs
        (( ${#msgs} < 1 )) && msgs[1]=' (%s)-[%b|%a]-'
    else
        zstyle -a ":vcs_info:${vcs}:${usercontext}" formats msgs
        (( ${#msgs} < 1 )) && msgs[1]=' (%s)-[%b]-'
    fi

    (( ${#msgs} > maxexports )) && msgs[$(( maxexports + 1 )),-1]=()
    for i in {1..${#msgs}} ; do
        zformat -f msg ${msgs[$i]}                      \
                        a:${action}                     \
                        b:${branch}                     \
                        r:${base:t}                     \
                        s:${vcs}                        \
                        R:${base}                       \
                        S:"$(VCS_INFO_reposub ${base})"
        msgs[$i]=${msg}
    done
    return 0
}
# }}}
VCS_INFO_maxexports () { #{{{
    zstyle -s ":vcs_info:${vcs}:${usercontext}" "max-exports" maxexports || maxexports=2
    if [[ ${maxexports} != <-> ]] || (( maxexports < 1 )); then
        printf 'vcs_info(): expecting numeric arg >= 1 for max-exports (got %s).\n' ${maxexports}
        printf 'Defaulting to 2.\n'
        maxexports=2
    fi
}
# }}}
VCS_INFO_nvcsformats () { #{{{
    setopt localoptions noksharrays
    local c v

    if [[ $1 == 'preinit' ]] ; then
        c=default
        v=preinit
    fi
    zstyle -a ":vcs_info:${v:-$vcs}:${c:-$usercontext}" nvcsformats msgs
    (( ${#msgs} > maxexports )) && msgs[${maxexports},-1]=()
}
# }}}
VCS_INFO_realpath () { #{{{
    # a portable 'readlink -f'
    # forcing a subshell, to ensure chpwd() is not removed
    # from the calling shell (if VCS_INFO_realpath() is called
    # manually).
    (
        (( ${+functions[chpwd]} )) && unfunction chpwd
        setopt chaselinks
        cd $1 2>/dev/null && pwd
    )
}
# }}}
VCS_INFO_reposub () { #{{{
    setopt localoptions extendedglob
    local base=${1%%/##}

    [[ ${PWD} == ${base}/* ]] || {
        printf '.'
        return 1
    }
    printf '%s' ${PWD#$base/}
    return 0
}
# }}}
VCS_INFO_set () { #{{{
    setopt localoptions noksharrays
    local -i i j

    if [[ $1 == '--clear' ]] ; then
        for i in {0..9} ; do
            unset VCS_INFO_message_${i}_
        done
    fi
    if [[ $1 == '--nvcs' ]] ; then
        [[ $2 == 'preinit' ]] && (( maxexports == 0 )) && (( maxexports = 1 ))
        for i in {0..$((maxexports - 1))} ; do
            typeset -gx VCS_INFO_message_${i}_=
        done
        VCS_INFO_nvcsformats $2
    fi

    (( ${#msgs} - 1 < 0 )) && return 0
    for i in {0..$(( ${#msgs} - 1 ))} ; do
        (( j = i + 1 ))
        typeset -gx VCS_INFO_message_${i}_=${msgs[$j]}
    done
    return 0
}
# }}}
# information gathering
VCS_INFO_bzr_get_data () { # {{{
    setopt localoptions noksharrays
    local bzrbase bzrbr
    local -a bzrinfo

    if zstyle -t ":vcs_info:${vcs}:${usercontext}" "use-simple" ; then
        bzrbase=${vcs_comm[basedir]}
        bzrinfo[2]=${bzrbase:t}
        if [[ -f ${bzrbase}/.bzr/branch/last-revision ]] ; then
            bzrinfo[1]=$(< ${bzrbase}/.bzr/branch/last-revision)
            bzrinfo[1]=${${bzrinfo[1]}%% *}
        fi
    else
        bzrbase=${${(M)${(f)"$( bzr info )"}:# ##branch\ root:*}/*: ##/}
        bzrinfo=( ${${${(M)${(f)"$( bzr version-info )"}:#(#s)(revno|branch-nick)*}/*: /}/*\//} )
        bzrbase="$(VCS_INFO_realpath ${bzrbase})"
    fi

    zstyle -s ":vcs_info:${vcs}:${usercontext}" branchformat bzrbr || bzrbr="%b:%r"
    zformat -f bzrbr "${bzrbr}" "b:${bzrinfo[2]}" "r:${bzrinfo[1]}"
    VCS_INFO_formats '' "${bzrbr}" "${bzrbase}"
    return 0
}
# }}}
VCS_INFO_cdv_get_data () { # {{{
    local cdvbase

    cdvbase=${vcs_comm[basedir]}
    VCS_INFO_formats '' "${cdvbase:t}" "${cdvbase}"
    return 0
}
# }}}
VCS_INFO_cvs_get_data () { # {{{
    local cvsbranch cvsbase basename

    cvsbase="."
    while [[ -d "${cvsbase}/../CVS" ]]; do
        cvsbase="${cvsbase}/.."
    done
    cvsbase="$(VCS_INFO_realpath ${cvsbase})"
    cvsbranch=$(< ./CVS/Repository)
    basename=${cvsbase:t}
    cvsbranch=${cvsbranch##${basename}/}
    [[ -z ${cvsbranch} ]] && cvsbranch=${basename}
    VCS_INFO_formats '' "${cvsbranch}" "${cvsbase}"
    return 0
}
# }}}
VCS_INFO_darcs_get_data () { # {{{
    local darcsbase

    darcsbase=${vcs_comm[basedir]}
    VCS_INFO_formats '' "${darcsbase:t}" "${darcsbase}"
    return 0
}
# }}}
VCS_INFO_git_getaction () { #{{{
    local gitaction='' gitdir=$1
    local tmp

    for tmp in "${gitdir}/rebase-apply" \
               "${gitdir}/rebase"       \
               "${gitdir}/../.dotest" ; do
        if [[ -d ${tmp} ]] ; then
            if   [[ -f "${tmp}/rebasing" ]] ; then
                gitaction="rebase"
            elif [[ -f "${tmp}/applying" ]] ; then
                gitaction="am"
            else
                gitaction="am/rebase"
            fi
            printf '%s' ${gitaction}
            return 0
        fi
    done

    for tmp in "${gitdir}/rebase-merge/interactive" \
               "${gitdir}/.dotest-merge/interactive" ; do
        if [[ -f "${tmp}" ]] ; then
            printf '%s' "rebase-i"
            return 0
        fi
    done

    for tmp in "${gitdir}/rebase-merge" \
               "${gitdir}/.dotest-merge" ; do
        if [[ -d "${tmp}" ]] ; then
            printf '%s' "rebase-m"
            return 0
        fi
    done

    if [[ -f "${gitdir}/MERGE_HEAD" ]] ; then
        printf '%s' "merge"
        return 0
    fi

    if [[ -f "${gitdir}/BISECT_LOG" ]] ; then
        printf '%s' "bisect"
        return 0
    fi
    return 1
}
# }}}
VCS_INFO_git_getbranch () { #{{{
    local gitbranch gitdir=$1 tmp actiondir
    local gitsymref='git symbolic-ref HEAD'

    actiondir=''
    for tmp in "${gitdir}/rebase-apply" \
               "${gitdir}/rebase"       \
               "${gitdir}/../.dotest"; do
        if [[ -d ${tmp} ]]; then
            actiondir=${tmp}
            break
        fi
    done
    if [[ -n ${actiondir} ]]; then
        gitbranch="$(${(z)gitsymref} 2> /dev/null)"
        [[ -z ${gitbranch} ]] && [[ -r ${actiondir}/head-name ]] \
            && gitbranch="$(< ${actiondir}/head-name)"

    elif [[ -f "${gitdir}/MERGE_HEAD" ]] ; then
        gitbranch="$(${(z)gitsymref} 2> /dev/null)"
        [[ -z ${gitbranch} ]] && gitbranch="$(< ${gitdir}/MERGE_HEAD)"

    elif [[ -d "${gitdir}/rebase-merge" ]] ; then
        gitbranch="$(< ${gitdir}/rebase-merge/head-name)"

    elif [[ -d "${gitdir}/.dotest-merge" ]] ; then
        gitbranch="$(< ${gitdir}/.dotest-merge/head-name)"

    else
        gitbranch="$(${(z)gitsymref} 2> /dev/null)"

        if [[ $? -ne 0 ]] ; then
            gitbranch="refs/tags/$(git describe --exact-match HEAD 2>/dev/null)"

            if [[ $? -ne 0 ]] ; then
                gitbranch="${${"$(< $gitdir/HEAD)"}[1,7]}..."
            fi
        fi
    fi

    printf '%s' "${gitbranch##refs/[^/]##/}"
    return 0
}
# }}}
VCS_INFO_git_get_data () { # {{{
    setopt localoptions extendedglob
    local gitdir gitbase gitbranch gitaction

    gitdir=${vcs_comm[gitdir]}
    gitbranch="$(VCS_INFO_git_getbranch ${gitdir})"

    if [[ -z ${gitdir} ]] || [[ -z ${gitbranch} ]] ; then
        return 1
    fi

    VCS_INFO_adjust
    gitaction="$(VCS_INFO_git_getaction ${gitdir})"
    gitbase=${PWD%/${$( git rev-parse --show-prefix )%/##}}
    VCS_INFO_formats "${gitaction}" "${gitbranch}" "${gitbase}"
    return 0
}
# }}}
VCS_INFO_hg_get_data () { # {{{
    local hgbranch hgbase file

    hgbase=${vcs_comm[basedir]}

    file="${hgbase}/.hg/branch"
    if [[ -r ${file} ]] ; then
        hgbranch=$(< ${file})
    else
        hgbranch='default'
    fi

    VCS_INFO_formats '' "${hgbranch}" "${hgbase}"
    return 0
}
# }}}
VCS_INFO_mtn_get_data () { # {{{
    local mtnbranch mtnbase

    mtnbase=${vcs_comm[basedir]}
    mtnbranch=${${(M)${(f)"$( mtn status )"}:#(#s)Current branch:*}/*: /}
    VCS_INFO_formats '' "${mtnbranch}" "${mtnbase}"
    return 0
}
# }}}
VCS_INFO_svk_get_data () { # {{{
    local svkbranch svkbase

    svkbase=${vcs_comm[basedir]}
    zstyle -s ":vcs_info:${vcs}:${usercontext}" branchformat svkbranch || svkbranch="%b:%r"
    zformat -f svkbranch "${svkbranch}" "b:${vcs_comm[branch]}" "r:${vcs_comm[revision]}"
    VCS_INFO_formats '' "${svkbranch}" "${svkbase}"
    return 0
}
# }}}
VCS_INFO_svn_get_data () { # {{{
    setopt localoptions noksharrays
    local svnbase svnbranch
    local -a svninfo

    svnbase="."
    while [[ -d "${svnbase}/../.svn" ]]; do
        svnbase="${svnbase}/.."
    done
    svnbase="$(VCS_INFO_realpath ${svnbase})"
    svninfo=( ${${${(M)${(f)"$( svn info )"}:#(#s)(URL|Revision)*}/*: /}/*\//} )

    zstyle -s ":vcs_info:${vcs}:${usercontext}" branchformat svnbranch || svnbranch="%b:%r"
    zformat -f svnbranch "${svnbranch}" "b:${svninfo[1]}" "r:${svninfo[2]}"
    VCS_INFO_formats '' "${svnbranch}" "${svnbase}"
    return 0
}
# }}}
VCS_INFO_tla_get_data () { # {{{
    local tlabase tlabranch

    tlabase="$(VCS_INFO_realpath ${vcs_comm[basedir]})"
    # tree-id gives us something like 'foo@example.com/demo--1.0--patch-4', so:
    tlabranch=${${"$( tla tree-id )"}/*\//}
    VCS_INFO_formats '' "${tlabranch}" "${tlabase}"
    return 0
}
# }}}
# detection
VCS_INFO_detect_by_dir() { #{{{
    local dirname=$1
    local basedir="." realbasedir

    realbasedir="$(VCS_INFO_realpath ${basedir})"
    while [[ ${realbasedir} != '/' ]]; do
        [[ -r ${realbasedir} ]] || return 1
        if [[ -n ${vcs_comm[detect_need_file]} ]] ; then
            [[ -d ${basedir}/${dirname} ]] && \
            [[ -e ${basedir}/${dirname}/${vcs_comm[detect_need_file]} ]] && \
                break
        else
            [[ -d ${basedir}/${dirname} ]] && break
        fi

        basedir=${basedir}/..
        realbasedir="$(VCS_INFO_realpath ${basedir})"
    done

    [[ ${realbasedir} == "/" ]] && return 1
    vcs_comm[basedir]=${realbasedir}
    return 0
}
# }}}
VCS_INFO_bzr_detect() { #{{{
    VCS_INFO_check_com bzr || return 1
    vcs_comm[detect_need_file]=branch/format
    VCS_INFO_detect_by_dir '.bzr'
    return $?
}
# }}}
VCS_INFO_cdv_detect() { #{{{
    VCS_INFO_check_com cdv || return 1
    vcs_comm[detect_need_file]=format
    VCS_INFO_detect_by_dir '.cdv'
    return $?
}
# }}}
VCS_INFO_cvs_detect() { #{{{
    VCS_INFO_check_com cvs || return 1
    [[ -d "./CVS" ]] && [[ -r "./CVS/Repository" ]] && return 0
    return 1
}
# }}}
VCS_INFO_darcs_detect() { #{{{
    VCS_INFO_check_com darcs || return 1
    vcs_comm[detect_need_file]=format
    VCS_INFO_detect_by_dir '_darcs'
    return $?
}
# }}}
VCS_INFO_git_detect() { #{{{
    if VCS_INFO_check_com git && git rev-parse --is-inside-work-tree &> /dev/null ; then
        vcs_comm[gitdir]="$(git rev-parse --git-dir 2> /dev/null)" || return 1
        if   [[ -d ${vcs_comm[gitdir]}/svn ]]             ; then vcs_comm[overwrite_name]='git-svn'
        elif [[ -d ${vcs_comm[gitdir]}/refs/remotes/p4 ]] ; then vcs_comm[overwrite_name]='git-p4' ; fi
        return 0
    fi
    return 1
}
# }}}
VCS_INFO_hg_detect() { #{{{
    VCS_INFO_check_com hg || return 1
    vcs_comm[detect_need_file]=store
    VCS_INFO_detect_by_dir '.hg'
    return $?
}
# }}}
VCS_INFO_mtn_detect() { #{{{
    VCS_INFO_check_com mtn || return 1
    vcs_comm[detect_need_file]=revision
    VCS_INFO_detect_by_dir '_MTN'
    return $?
}
# }}}
VCS_INFO_svk_detect() { #{{{
    setopt localoptions noksharrays extendedglob
    local -a info
    local -i fhash
    fhash=0

    VCS_INFO_check_com svk || return 1
    [[ -f ~/.svk/config ]] || return 1

    # This detection function is a bit different from the others.
    # We need to read svk's config file to detect a svk repository
    # in the first place. Therefore, we'll just proceed and read
    # the other information, too. This is more then any of the
    # other detections do but this takes only one file open for
    # svk at most. VCS_INFO_svk_get_data() get simpler, too. :-)
    while IFS= read -r line ; do
        if [[ -n ${vcs_comm[basedir]} ]] ; then
            line=${line## ##}
            [[ ${line} == depotpath:* ]] && vcs_comm[branch]=${line##*/}
            [[ ${line} == revision:* ]] && vcs_comm[revision]=${line##*[[:space:]]##}
            [[ -n ${vcs_comm[branch]} ]] && [[ -n ${vcs_comm[revision]} ]] && break
            continue
        fi
        (( fhash > 0 )) && [[ ${line} == '  '[^[:space:]]*:* ]] && break
        [[ ${line} == '  hash:'* ]] && fhash=1 && continue
        (( fhash == 0 )) && continue
        [[ ${PWD}/ == ${${line## ##}%:*}/* ]] && vcs_comm[basedir]=${${line## ##}%:*}
    done < ~/.svk/config

    [[ -n ${vcs_comm[basedir]} ]]  && \
    [[ -n ${vcs_comm[branch]} ]]   && \
    [[ -n ${vcs_comm[revision]} ]] && return 0
    return 1
}
# }}}
VCS_INFO_svn_detect() { #{{{
    VCS_INFO_check_com svn || return 1
    [[ -d ".svn" ]] && return 0
    return 1
}
# }}}
VCS_INFO_tla_detect() { #{{{
    VCS_INFO_check_com tla || return 1
    vcs_comm[basedir]="$(tla tree-root 2> /dev/null)" && return 0
    return 1
}
# }}}
# public API
vcs_info_printsys () { # {{{
    vcs_info print_systems_
}
# }}}
vcs_info_lastmsg () { # {{{
    emulate -L zsh
    local -i i

    VCS_INFO_maxexports
    for i in {0..$((maxexports - 1))} ; do
        printf '$VCS_INFO_message_%d_: "' $i
        if zstyle -T ':vcs_info:formats:command' use-prompt-escapes ; then
            print -nP ${(P)${:-VCS_INFO_message_${i}_}}
        else
            print -n ${(P)${:-VCS_INFO_message_${i}_}}
        fi
        printf '"\n'
    done
}
# }}}
vcs_info () { # {{{
    emulate -L zsh
    setopt extendedglob

    [[ -r . ]] || return 1

    local pat
    local -i found
    local -a VCSs disabled dps
    local -x vcs usercontext
    local -ix maxexports
    local -ax msgs
    local -Ax vcs_comm

    vcs="init"
    VCSs=(git hg bzr darcs svk mtn svn cvs cdv tla)
    case $1 in
        (print_systems_)
            zstyle -a ":vcs_info:${vcs}:${usercontext}" "disable" disabled
            print -l '# list of supported version control backends:' \
                     '# disabled systems are prefixed by a hash sign (#)'
            for vcs in ${VCSs} ; do
                [[ -n ${(M)disabled:#${vcs}} ]] && printf '#'
                printf '%s\n' ${vcs}
            done
            print -l '# flavours (cannot be used in the disable style; they' \
                     '# are disabled with their master [git-svn -> git]):'   \
                     git-{p4,svn}
            return 0
            ;;
        ('')
            [[ -z ${usercontext} ]] && usercontext=default
            ;;
        (*) [[ -z ${usercontext} ]] && usercontext=$1
            ;;
    esac

    zstyle -T ":vcs_info:${vcs}:${usercontext}" "enable" || {
        [[ -n ${VCS_INFO_message_0_} ]] && VCS_INFO_set --clear
        return 0
    }
    zstyle -a ":vcs_info:${vcs}:${usercontext}" "disable" disabled

    zstyle -a ":vcs_info:${vcs}:${usercontext}" "disable-patterns" dps
    for pat in ${dps} ; do
        if [[ ${PWD} == ${~pat} ]] ; then
            [[ -n ${vcs_info_msg_0_} ]] && VCS_INFO_set --clear
            return 0
        fi
    done

    VCS_INFO_maxexports

    (( found = 0 ))
    for vcs in ${VCSs} ; do
        [[ -n ${(M)disabled:#${vcs}} ]] && continue
        vcs_comm=()
        VCS_INFO_${vcs}_detect && (( found = 1 )) && break
    done

    (( found == 0 )) && {
        VCS_INFO_set --nvcs
        return 0
    }

    VCS_INFO_${vcs}_get_data || {
        VCS_INFO_set --nvcs
        return 1
    }

    VCS_INFO_set
    return 0
}


