#!/usr/bin/env zsh
# Copyrights 2022 Aman Mehra.
# Check ./LICENSE_CODE, ./LICENSE_ART, and ./LICENSE_ADDENDUM_CFLA
# files to know the terms of license
# License files are also on github: https://github.com/poetaman/arttime

autoload -Uz is-at-least
if ! is-at-least "5.7"; then
    echo "Error: your zsh version $ZSH_VERSION is less than the required version: 5.7"
    exit 1
fi

zmodload zsh/terminfo
zmodload zsh/zutil

if is-at-least "5.8"; then
    zparseoptscmd='zparseopts -D -E -F - '
else
    zparseoptscmd='zparseopts -D -E - '
fi

$(printf "$zparseoptscmd") \
    l=local_arg_array \
    -local=local_arg_array \
    g=global_arg_array \
    -global=global_arg_array \
    p:=prefix_arg_array \
    -prefix:=prefix_arg_array \
    -zcompdir:=zcompdir_arg_array \
    -noupdaterc=noupdaterc_arg_array \
    h=help_arg_array \
    -help=help_arg_array \
    || return

if [[ "${#@}" != "0" ]]; then
    printf "Error: install.sh does not understand the following part of passed options,\n    "
    printf ' %s ' "[1m[4m$@[0m"
    printf '\n%s\n' "check the valid options by invoking install.sh with --help"
    exit 1
fi

local_arg="$local_arg_array[-1]"
global_arg="$global_arg_array[-1]"
prefix_arg="$prefix_arg_array[-1]"
help_arg="$help_arg_array[-1]"
zcompdir_arg="$zcompdir_arg_array[-1]"
noupdaterc_arg="$noupdaterc_arg_array[-1]"
unamestr="$(uname -a)"
case "${unamestr}" in
    Linux*)
        if [[ "$unamestr" =~ ^.*[Mm]icrosoft.*$ ]]; then
                machine="WSL"
        else
                machine="Linux"
        fi
        ;;
    Darwin*)    machine="Darwin";;
    *BSD*)      machine="BSD";;
    *)          machine="UNKNOWN:${unamestr}";;
esac

function printhelp {
read -r -d '' VAR <<-'EOF'
Name:
    installer for arttime

Invocation:
    ./install.sh [OPTIONS]...

Description:
    arttime is an application that runs in your terminal emulator. It blends
    beauty of text art with functionality of a feature-rich clock/timer
    /pattern-based time manager. For more information on arttime, run
    ./bin/arttime -h and visit it's github page:
    https://github.com/poetaman/arttime

Options:
    -l --local          Install arttime executables locally in ~/.local/bin
                        and art files in ~/.local/share/arttime/textart
                        Note: This is the default method used when none
                        of -l/-g/-p is provided
                        
    -g --global         Install arttime executables globally in /usr/local/bin
                        and art files in /usr/local/share/arttime/textart
                        
    -p --prefix PREFIX  Install arttime executables in PREFIX/bin
                        and art files in PREFIX/share/arttime/textart

    --zcompdir DIRECTORY
                        Install arttime's zsh completions in DIRECTORY/
                        instead of default ~/.local/share/zsh/functions/
                        If passed - then don't install completions.
                        Note: Make sure to append that path to your zshrc's
                        fpath array before deleting completion caches and
                        calling compinit again. If you are using a zsh plugin
                        system, check what is the best place to add to fpath
                        (mostly in your .zshrc before invoking plugin manager)

    --noupdaterc        By default arttime installer would append a line
                        at the end of user's ~/.zshrc or ~/.bashrc
                        if the effective installation path is not on $PATH
                        Providing this switch disables that, which is
                        especially valuable for package managers

    -h --help           Print this help string for arttime installer, and exit
EOF
echo "$VAR"
}

[[ $help_arg != "" ]] && printhelp && exit 0

count=0
[[ $prefix_arg != "" ]] && count=$((count+1))
[[ $local_arg != "" ]] && count=$((count+1))
[[ $global_arg != "" ]] && count=$((count+1))

if ((count>1)); then
    echo "Error: only one of a) -p/--prefix, b) -l/--local, or c) -g/--global should be passed."
    exit 1
elif ((count==0)); then
    local_arg="1"
fi

if [[ $local_arg != "" ]]; then
    # Install in $HOME/.local/
    installdir="$HOME/.local"
    installtype="local"
elif [[ $global_arg != "" ]]; then
    # Install in /usr/local/
    installdir="/usr/local"
    installtype="global"
else
    # Install in $prefix_arg
    installdir="$prefix_arg"
    installtype="prefix"
fi
bindir="$installdir/bin"
artdir="$installdir/share/arttime/textart"
keypoemdir="$installdir/share/arttime/keypoems"
srcdir="$installdir/share/arttime/src"
if [[ -z $zcompdir_arg ]]; then
    zcompdir="$HOME/.local/share/zsh/functions"
elif [[ $zcompdir_arg == "-" ]]; then
    zcompdir=""
else
    zcompdir="$zcompdir_arg"
fi

function checkdir {
    if [[ -d $1 ]]; then
        if [[ -w $1 ]]; then
            echo "1"
        else
            echo "4"
        fi
    elif [[ -L $1 ]]; then
        if [[ -d "$(readlink $1)" ]]; then
            echo "2"
        else
            echo "5"
        fi
    elif [[ -f $1 ]]; then
        echo "6"
    else
        if /bin/mkdir -p $1 &>/dev/null; then
            echo "3"
        else
            echo "7"
        fi
    fi
}

direrrorarray=()
function printdirerror {
    if [[ $1 == "4" ]]; then
        direrrorarray+=("Error: $2 exists but is not writable directory (check permissions?)")
    elif [[ $1 == "5" ]]; then
        direrrorarray+=("Error: $2 is a symlink but does not point to a directory")
    elif [[ $1 == "6" ]]; then
        direrrorarray+=("Error: $2 exist but is a regular file, not a directory")
    elif [[ $1 == "7" ]]; then
        direrrorarray+=("Error: $2 does't exist and is not creatable directory (check permissions?)")
    fi
}

installdircode=$(checkdir $installdir)
bindircode=$(checkdir $bindir)
artdircode=$(checkdir $artdir)
keypoemdircode=$(checkdir $keypoemdir)
srcdircode=$(checkdir $srcdir)
[[ ! -z $zcompdir ]] && zcompdircode=$(checkdir $zcompdir)

printdirerror $installdircode $installdir
printdirerror $bindircode $bindir
printdirerror $artdircode $artdir
printdirerror $keypoemdircode $keypoemdir
printdirerror $srcdircode $srcdir
[[ ! -z $zcompdir ]] && printdirerror $zcompdircode $zcompdir

if [[ ! ${#direrrorarray[@]} -eq 0 ]]; then
    for i ("$direrrorarray[@]"); do
        printf "$i\n"
    done
    exit 1
fi

# If we are here, we can successfully install
installerdir="${0:a:h}"

# Copy bin files
echo "Copying executables under $bindir"
cd $installerdir/bin
cp arttime $bindir/arttime
cp artprint $bindir/artprint

# Copy sources
echo "Copying sources under $srcdir"
cd $installerdir/share/arttime/src
cp * $srcdir/

# Copy keypoems
echo "Copying keypoems under $keypoemdir"
cd $installerdir/share/arttime/keypoems
cp * $keypoemdir/

if [[ ! -z $zcompdir ]]; then
    # Copy zsh completion files
    echo "Copying zsh completion files under $zcompdir"
    cd $installerdir/share/zsh/functions
    cp * $zcompdir/
fi

# Copy art files
echo "Copying artfiles under $artdir"
cd $installerdir/share/arttime/textart


artfilearray=()
artfilearray=(*(.))
artfilearraysize="${#artfilearray}"
tput_cuu1=$(echoti cuu1)
tput_civis=$(echoti civis)
tput_cnorm=$(echoti cnorm)
printf "$tput_civis"
for ((i = 1; i <= $artfilearraysize; i++)); do
    file="$artfilearray[i]"
    if [[ -f "$artdir/$file" ]]; then
        oldmessage='"Custom message for art goes here"'
        oldmessage="$(head -n1 $artdir/$file)"
        newart="$(tail -n +2 $file)"
        printf '%s\n' "$oldmessage" >$artdir/$file
        printf '%s\n' "$newart" >>$artdir/$file
    else
        cp $file $artdir/$file
    fi
    percentdone=$(((i-1.0)/(artfilearraysize-1.0)*100.0))
    [[ $percentdone -lt 1 ]] && percentdone="0"
    if ((percentdone<1.0)); then
        percentdone="0"
    else
        percentdone="${percentdone%.*}"
    fi
    echo "Progress: ${(l:3:: :)percentdone}% done$tput_cuu1\r"
done
printf "\n"

if [[ ! -z $zcompdir && $fpath[(I)$zcompdir] -eq 0 ]]; then
    echo "[4mNote[0m: If you want zsh shell completion for arttime, add\n         $zcompdir\n      to your fpath, remove completion cache, and rerun compinit"
fi
if ! command -v less &>/dev/null; then
    echo "[4mDEPENDS[0m: Command 'less' not found, arttime will default to 'more'.\n         Though installing 'less' is recommended for better experience."
fi

case "${machine}" in
    "Linux"|"BSD")
        if ! command -v notify-send &>/dev/null; then
            echo "[4mDEPENDS[0m: If you want desktop notifications, you need notify-send."
        fi
        if command -v paplay &>/dev/null; then
            if pulseaudio --check &>/dev/null; then
                pulserunning="1"
            else
                pulserunning="0"
            fi
        fi
        if command -v pw-play &>/dev/null; then
            if {pactl info 2>/dev/null | grep "Server Name" 2>/dev/null | grep "PipeWire" &>/dev/null}; then
                piperunning="1"
            else
                piperunning="0"
            fi
        fi
        if command -v ogg123 &>/dev/null; then
            vorbisinstalled="1"
        fi
        if [[ $pulserunning != "1" && $piperunning != "1" && $vorbisinstalled != "1" ]]; then
            echo "[4mDEPENDS[0m: If you want desktop sounds, you need one of: 1) pulseaudio daemon\n         running, or 2) pipewire daemon running, or 3) vorbis-tools."
        fi
        ;;
    "Darwin")
        echo "[4mNote[0m: Notification settings on macOS are not fully in control of an application.\n      To check if you have desired notification settings, open following link.\n      https://github.com/poetaman/arttime/issues/11"
        ;;
    "WSL")
        if ! command -v wsl-notify-send.exe &>/dev/null; then
            echo "[4mDEPENDS[0m: If you want desktop notifications, you need wsl-notify-send.exe\n         Install it from https://github.com/stuartleeks/wsl-notify-send"
        fi
        ;;
    *) ;;
esac

# Check if path to arttime excutable is on user's $PATH
if [[ ":$PATH:" == *":$bindir:"* ]]; then
    echo "Installation complete!\nType 'arttime' and press Enter to start arttime."
else
    loginshell=$(basename "${SHELL}")
    if [[ $loginshell == *zsh* ]]; then
        profile='.zshrc'
    elif [[ $loginshell == *bash* ]]; then
        #if [[ -e $HOME/.bash_profile ]]; then
        #    profile='.bash_profile'
        #else
        #    profile='.profile'
        #fi
        profile=".bashrc"
    else
        profile=''
    fi
    if [[ $noupdaterc_arg != "" ]]; then
        echo "Installation complete! Type 'arttime' and press Enter to start arttime.\nIf arttime command is not found, try one of following:\n    1) source your *rc file or restart terminal,\n    2) add install directory to PATH in your *rc file and try 1) again."
    elif [[ $profile != "" ]]; then
        echo "\n# Following line was automatically added by arttime installer" >>$HOME/$profile
        echo 'export PATH='"$bindir"':$PATH' >>$HOME/$profile
        echo 'Note: Added export PATH='"$bindir"':$PATH to ~/'"$profile"
        echo "Installation complete!\nSource ~/$profile or restart terminal. Then type 'arttime' and press Enter to start arttime."
    else
        echo "Installation [31m*[0malmost[31m*[0m complete! To start using arttime, follow these steps:\n    1) Add $bindir to your PATH environment variable in appropriate file,\n    2) Open a new terminal session, type 'arttime' and press Enter.\nTo run it right away from this shell, execute arttime by specifying its full path:\n       $bindir/arttime"
    fi
fi
printf "$tput_cnorm"
