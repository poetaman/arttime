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
    zparseopts -D -E -F - \
        l=local_arg_array \
        -local=local_arg_array \
        g=global_arg_array \
        -global=global_arg_array \
        p:=prefix_arg_array \
        -prefix:=prefix_arg_array \
        h=help_arg_array \
        -help=help_arg_array \
        || return
else
    zparseopts -D -E - \
        l=local_arg_array \
        -local=local_arg_array \
        g=global_arg_array \
        -global=global_arg_array \
        p:=prefix_arg_array \
        -prefix:=prefix_arg_array \
        h=help_arg_array \
        -help=help_arg_array \
        || return
    if [[ "${#@}" != "0" ]]; then
        printf "Error: install.sh does not understand the following part of passed options,\n    "
        printf ' %s ' "[1m[4m$@[0m"
        printf '\n%s\n' "check the valid options by invoking install.sh with --help"
        exit 1
    fi
fi

local_arg="$local_arg_array[-1]"
global_arg="$global_arg_array[-1]"
prefix_arg="$prefix_arg_array[-1]"
help_arg="$help_arg_array[-1]"
machine="$(uname -s)"

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

printdirerror $installdircode $installdir
printdirerror $bindircode $bindir
printdirerror $artdircode $artdir

if [[ ! ${#direrrorarray[@]} -eq 0 ]]; then
    for i ("$direrrorarray[@]"); do
        printf "$i\n"
    done
    exit 1
fi

# If we are here, we can successfully install
installerdir="${0:a:h}"

# Copy bin files
cd $installerdir/bin
cp arttime $bindir/arttime
cp artprint $bindir/artprint

# Copy share files
cd $installerdir/share/arttime/textart

artfilearray=()
artfilearray=(*(.))
artfilearraysize="${#artfilearray}"
tput_cuu1=$(echoti cuu1)
echoti civis
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

if ! command -v less &>/dev/null; then
    echo "[4mDEPENDS[0m: Command 'less' not found, arttime will default to 'more'.\n         Though installing 'less' is recommended for better experience."
fi

if [[ $machine =~ ^.*(Linux|BSD).*$ ]]; then
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
elif [[ $machine =~ ^Darwin.*$ ]]; then
    echo "[4mNote[0m: Notification settings on macOS are not fully in control of an application.\n      To check if you have desired notification settings, open following link.\n      https://github.com/poetaman/arttime/issues/11"
fi

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
    if [[ ! -z $profile ]]; then
        echo "\n# Following line was automatically added by arttime installer" >>$HOME/$profile
        echo 'export PATH='"$bindir"':$PATH' >>$HOME/$profile
        echo 'Note: Added export PATH='"$bindir"':$PATH to ~/'"$profile"
        echo "Installation complete!\nSource ~/$profile or restart terminal. Then type 'arttime' and press Enter to start arttime."
    else
        echo "Installation [31m*[0malmost[31m*[0m complete! To start using arttime, follow these steps:\n    1) Add $bindir to your PATH environment variable in appropriate file,\n    2) Open a new terminal session, type 'arttime' and press Enter.\nTo run it right away from this shell, execute arttime by specifying its full path:\n       $bindir/arttime"
    fi
fi
echoti cnorm
