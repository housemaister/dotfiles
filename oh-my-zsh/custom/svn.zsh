# svn function to extend colored svn diff output
function svn() {
    case "$1" in
        diff-plain)
            shift;
            `/usr/bin/which svn` diff --diff-cmd diff "$@"
            ;;
        diff-color|diff)
            shift;
            `/usr/bin/which svn` diff --diff-cmd colordiff "$@"
            ;;
        diff-vim)
            shift;
            `/usr/bin/which svn` diff --diff-cmd $HOME/bin/svndiff -x vimdiff "$@"
            ;;
        diff-filemerge)
            shift;
            `/usr/bin/which svn` diff --diff-cmd $HOME/bin/svndiff -x opendiff "$@"
            ;;
        *)
            if [ -x /usr/bin/colorsvn ]; then
	     /usr/bin/colorsvn "$@"
	    else
	     `/usr/bin/which svn` "$@"
	    fi
            ;;
    esac
}

