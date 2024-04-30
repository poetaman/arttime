# Copyrights 2022 Aman Mehra.
# Check ../LICENSE_CODE, ../LICENSE_ART, and ../LICENSE_ADDENDUM_CFLA
# files to know the terms of license
# License files are also on github: https://github.com/poetaman/arttime

# This is main source file of arttime that can be invoked like this:
#       zsh -fi arttime.zsh [args]
# Though you don't need to invoke it like that if arttime is installed
# on your system. In that case it is preferable arttime like this:
#       arttime [args]

autoload -Uz is-at-least
if ! is-at-least "5.7"; then
    echo "Error: your zsh version $ZSH_VERSION is less than the required version: 5.7"
    exit 1
fi

arttime_version="2.3.2"

zmodload zsh/zselect
zmodload zsh/zutil
zmodload zsh/datetime
zmodload zsh/terminfo
zmodload zsh/system
zmodload zsh/complist
autoload -Uz compinit; compinit
setopt nomonitor
setopt extendedglob
setopt globcomplete
#zstyle ':completion:*' completer _expand _complete _approximate _match
#zstyle ':completion::expand*' expand glob substitute sort all-expansions add-space
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
setopt nobeep
setopt menucomplete
#setopt badpattern
setopt alwayslastprompt
setopt listrowsfirst
#zstyle ':completion:*:default' list-prompt   '%S%m%s'
zstyle ':completion:*:default' select-prompt '%S%m%s'
setopt histignorespace
setopt histignorealldups
setopt sharehistory
setopt noincappendhistory
setopt appendhistory
statedir=$HOME/.local/state/arttime
if [[ ! -d  $statedir/hist ]]; then
    if ! mkdir -p $statedir/hist; then
        print "E: Could not create $statedir/hist"
        exit 1
    fi
fi
if [[ ! -w $statedir/hist ]]; then
    print "E: Directory $statedir/hist is not writable, please change it's write permission before proceeding."
    exit 1
fi
histcmd="fc -pa"
fc -p

bindkey -e
bindkey "^R" history-incremental-pattern-search-backward
bindkey "^F" history-incremental-pattern-search-forward
autoload -Uz history-beginning-search-menu
zle -N history-beginning-search-menu
bindkey '^L' history-beginning-search-menu
autoload -Uz history-pattern-search
zle -N history-pattern-search-backward history-pattern-search
zle -N history-pattern-search-forward history-pattern-search
bindkey '^K' history-pattern-search-backward
bindkey '^J' history-pattern-search-forward
zstyle ':completion:*' menu select
bindkey -M menuselect '^M' .accept-line
#setopt AUTO_LIST
#zstyle ':completion:*:*:*:*:default' list-colors ${(s.:.)LSCOLORS}
#zstyle ':completion:*:*:*:*:descriptions' format '%F{blue}-- %D %d --%f'

# NOTE: enable minute/nonblocking mode if/when its functional,
# or remove it completely as sample rate is a waste now that
# we account for execution delay in loop to set timer
#   m=minute_arg \
#   n=nonblocking_arg \
#   s:=samples_arg \
# This means all functions ending in _nonblocking, etc are unreachable for now 

# NOTE: To allow user to specify fully custom time format in future add
#     -tf-local:=tflocal_arg \
#     -tf-other:=tfother_arg \

if is-at-least "5.8"; then
    zparseoptscmd='zparseopts -D -E -F - '
else
    zparseoptscmd='zparseopts -D -E - '
fi

$(printf "$zparseoptscmd") \
   a:=artname_arg \
   b:=flipartname_arg \
   -random=random_arg \
   t:=title_arg \
   g:=goal_arg \
   k:=keyfile_arg \
   -keypoem:=keyfile_arg \
   h=help_arg \
   m=man_arg \
   -theme:=theme_arg \
   -tc:=titlecolor_arg \
   -ac:=artcolor_arg \
   -style:=style_arg \
   -pa:=pbpendingchar_arg \
   -pb:=pbcompletechar_arg \
   -pl:=pblength_arg \
   -hours:=hours_arg \
   -debug=debug_arg \
   -nolearn=nolearn_arg \
   -line-editor:=lineeditor_arg \
   -version=version_arg \
   -help=help_arg \
   -man=man_arg \
   || return
# NOTE: --line-editor and --debug are "undocumented" options that are not printed by --help
#   --debug
#       As the name suggests, it is for debug. It's meaning might change over time.
#   --line-editor [zle|readline]
#       There is a bug in zsh's line editor interface that makes it more desirable to
#       read a line using bash on slower machines/connections. It avoids a flicker on last line
#       of screen; on fast machines this problem won't occur. This option might get removed
#       at some point, and it is not recommended for use. The line editor passed with this
#       option only applies to keybindings 'g' (set goal) and 'm' (set title message).
#       Another reason to not use this is it that arttime will add more zle-specific completion
#       features in future, and they might not be available with readline.

if [[ "${#@}" != "0" ]]; then
    printf "Error: arttime does not understand the following part of passed options,\n    "
    printf ' %s ' "[1m[4m$@[0m"
    printf '\n%s\n' "check the valid options by invoking arttime with --help"
    exit 1
fi

function printhelp {
read -r -d '' VAR <<-'EOF'
Usage:
    arttime [OPTION]...

Option summary:
    -a <name>
        name of a-art file from artdir
    -b <name>
        name of b-art file from artdir
    -t <str>
        text placed under art
    --random
        select random art from arttime's collection
    -g <time[;time;...;[loop[N]]]>
         set timers
    --hours <12|24>
        show times in 12 or 24 hour format
    -k, --keypoem <name|file|fifo>
        feed keystrokes from a keypoem file/fifo.
    --ac <num>
        art color, value between 0-15
    --tc <num>
        title color, value between 0-15
    --theme <light|dark>
        theme
    --style <0|1>
        style number
    --pa <str>
        char/str to denote pending part of progress bar
    --pb <str>
        char/str to denote complete part of progress bar
    --pl <num>
        progress bar length
    --nolearn
        don't show keybindings upon launch
    --version
        Print version number of arttime, and exit
    -m, --man
        Open arttime's manual
    -h, --help
        Print help string, and exit

For more information on arttime, try:
    $ arttime -m
    $ man arttime
EOF
echo $VAR
}

# directories
bindir="${0:A:h}/../../../bin"
artdir="$bindir/../share/arttime/textart"

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

if [[ ! -z $help_arg[-1] ]]; then
    printhelp
    exit 0
elif [[ ! -z $man_arg[-1] ]]; then
    setopt monitor
    docdir="$bindir/../share/arttime/doc"
    mandir="$bindir/../share/man/man1"
    if [[ -f $docdir/arttime.1.ans ]]; then
        if command -v less &>/dev/null; then
            LESS="" exec less -SRKP 'Press q to quit\. Use arrow keys, j/k, PageDown, PageUp to scroll\.' $docdir/arttime.1.ans
        elif command -v most &>/dev/null; then
            COLORTERM=16 exec most $docdir/arttime.1.ans
        else
            exec cat $docdir/arttime.1.ans
        fi
    fi
    if command -v less &>/dev/null; then
        export LESS=""
        export LESS_TERMCAP_md=$(echoti setaf 4; echoti bold)
        export LESS_TERMCAP_us=$(echoti setaf 5; echoti sitm 2>/dev/null)
        export LESS_TERMCAP_ue=$(echoti sgr0)
    fi
    export MANWIDTH=80
    export MANROFFOPT=""
    export GROFF_SGR=1
    if [[ -f $mandir/arttime.1.gz ]]; then
        if [[ $machine == "Linux" ]]; then
            export MANPAGER="less -SRK" 
            export MANLESS="Press q to quit\. Use arrow keys, j/k, PageDown, PageUp to scroll\."
            exec command man --nh --nj $mandir/arttime.1.gz
        elif [[ $machine == "Darwin" ]] && command -v gman &>/dev/null; then
            export MANPAGER="less -SRK" 
            export MANLESS="Press q to quit\. Use arrow keys, j/k, PageDown, PageUp to scroll\."
            exec command gman --nh --nj $mandir/arttime.1.gz
        elif command -v man &>/dev/null; then
            export MANPAGER="less -SRKP \"Press q to quit\. Use arrow keys, j/k, PageDown, PageUp to scroll\.\"" 
            exec command man $mandir/arttime.1.gz
        else
            echo "E: command 'man' not found"
            exit 1
        fi
    else
        echo "E: arttime manual not found"
        exit 1
    fi
elif [[ ! -z $version_arg[-1] ]]; then
    echo "$arttime_version"
    exit 0
fi


function trimwhitespace {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

if [[ $machine = "Linux" ]]; then
    datecmd="date"
    dateisgnu="1"
else
    if command -v gdate &> /dev/null; then
        datecmd="gdate"
        dateisgnu="1"
    else
        datecmd="date"
        if date -d '0' '+%s' &>/dev/null; then
            dateisgnu="1"
        else
            dateisgnu="0"
        fi
    fi
fi

datehelpstr=""
function setdatehelpstr {
    if [[ $dateisgnu = "1" ]]; then
read -r -d '' datehelpstr <<-'EOF'
You reached this help page because you entered an [31mincorrect[0m
value for goal time or used an [31munrecognized[0m format or entered 'help'.

arttime supports two types of time formats: 1) Native, 2) External.
External formats are enabled by GNU date, which is [32mINSTALLED[0m on your
system, and should be preferred (as they can be very expressive).

One can set multiple goals, and even sprint (loop) over a pattern of goals
multiple times. Multiple goals or a pattern of goals can be specified by
separating them with a semi-colon (;). Goals can be repeated by specifying
the last goal as 'loop'/'sprint' (to sprint forever) or 'loopN'/'sprintN'
(to sprint N number of times). See section 3) below to learn how to set
multiple goals, and/or a pattern of goals to repeat.

1) Native (simple, relative) formats:
    1m (1 minute from now)
    30s (30 seconds from now)
    48h (48 hours from now)
    2d 10s (2 days 10 seconds from now)
    1h 1m 1s (1 hour 1 minute 1 seconds from now)
    500m (500 minutes from now)
    400m 100s (400 minutes and 100 seconds from now)
    etc...

Native format can have any of: Ad Bh Cm Ds, where A/B/C/D are numbers.

2) External (simple/complex, absolute/relative, very expressive) formats:
    10AM (upcoming 10AM, local timezone unless specified)
    10:30AM IST (upcoming 10:30AM Indian Standard Time)
    May 26 10:30AM IST (10:30AM on May 26 in Indian Standard Time)
        Note: there is no comma after date 'May 26'
    next friday (upcoming friday)
    1min, +1min, 1 min, +1 minute, +1 minutes (1 minute from now)
    1min 30sec, 1min 30sec (1 minute 30 sec from now)
    next friday +4 hours (4AM on next friday in local time zone)
    next monday 1PM (1PM on next monday in local time zone)
    next monday 1PM IST (1PM on next monday in Indian Standard Time)
    and much more...
    
For detailed documentation on External date/time formats please refer:
    Web:      https://www.gnu.org/software/coreutils/date 
    Locally:  $ info '(coreutils) date invocation'
and jump directly to the section on "Date input formats".

3) Multiple and/or pattern of repeating goals:
    10s;20s (10 seconds and 20 seconds from now)
    10s;20s;1PM (10 seconds and 20 seconds from now, at 1PM in local time zone)
    10s;loop, 10s;sprint (every 10 seconds, repeat forever)
    10s;loop4, 10s;sprint4 (after 10 seconds, sprint 4 times)
    10s;1m;loop2 (after 10 seconds and 1m from now, sprint 2 times)
    5m;1PM;2PM;3PM;4PM;loop (after 5m from now and at 1-4 PM, repeat forever)
    25m;30m;55m;1h;1h25m;1h30m;1h55m;2h25m;loop (pattern of Pomodoro Technique)
EOF
    else
read -r -d '' datehelpstr <<-'EOF'
You reached this help page because you entered an [31mincorrect[0m
value for goal time or used an [31munrecognized[0m format or entered 'help'.

arttime supports two types of time formats: 1) Native, 2) External.
External formats are enabled by GNU date, which is [31mNOT INSTALLED[0m on your
please search the web to find if/how to install GNU date on your system.
If installed, it will open up the possibility of being very expressive in
specifying goal date/time. After installing GNU date, restart arttime.

One can set multiple goals, and even sprint (loop) over a pattern of goals
multiple times. Multiple goals or a pattern of goals can be specified by
separating them with a semi-colon (;). Goals can be repeated by specifying
the last goal as 'loop'/'sprint' (to sprint forever) or 'loopN'/'sprintN'
(to sprint N number of times). See section 3) below to learn how to set
multiple goals, and/or a pattern of goals to repeat.

1) Native (simple, relative, should work on your system) formats:
    1m (1 minute from now)
    30s (30 seconds from now)
    48h (48 hours from now)
    2d 10s (2 days 10 seconds from now)
    1h 1m 1s (1 hour 1 minute 1 seconds from now)
    500m (500 minutes from now)
    400m 100s (400 minutes and 100 seconds from now)
    etc...

Native format can have any of: Ad Bh Cm Ds, where A/B/C/D are numbers.

2) External (very expressive, though won't work on your system) formats:
    10AM (upcoming 10AM, local timezone unless specified)
    10:30AM IST (upcoming 10:30AM Indian Standard Time)
    May 26 10:30AM IST (10:30AM on May 26 in Indian Standard Time)
        Note: there is no comma after date 'May 26'
    next friday (upcoming friday)
    1min, +1min, 1 min, +1 minute, +1 minutes (1 minute from now)
    1min 30sec, 1min 30sec (1 minute 30 sec from now)
    next friday +4 hours (4AM on next friday in local time zone)
    next monday 1PM (1PM on next monday in local time zone)
    next monday 1PM IST (1PM on next monday in Indian Standard Time)
    and much more...
    
For detailed documentation on External date/time formats please refer:
    Web:      https://www.gnu.org/software/coreutils/date 
    Locally:  $ info '(coreutils) date invocation'
and jump directly to the section on "Date input formats".

3) Multiple and/or pattern of repeating goals:
    10s;20s (10 seconds and 20 seconds from now)
    10s;20s;1PM (10 seconds and 20 seconds from now, at 1PM in local time zone)
    10s;loop, 10s;sprint (every 10 seconds, repeat forever)
    10s;loop4, 10s;sprint4 (after 10 seconds, sprint 4 times)
    10s;1m;loop2 (after 10 seconds and 1m from now, sprint 2 times)
    5m;1PM;2PM;3PM;4PM;loop (after 5m from now and at 1-4 PM, repeat forever)
    25m;30m;55m;1h;1h25m;1h30m;1h55m;2h25m;loop (pattern of Pomodoro Technique)
EOF
    fi
}

function getaart {
    if [[ $helpactive = "1" ]]; then
        echo $restoreartname
    else
        echo $artname
    fi
}

function getbart {
    if [[ $helpactive = "1" ]]; then
        if [[ -z $restoreflipartname ]]; then
            return 1
        else
            echo $restoreflipartname
        fi
    else
        if [[ -z $flipartname ]]; then
            return 1
        else
            echo $flipartname
        fi
    fi
}

function notetimezone {
    if [[ -z $TZ ]]; then
        local etclocaltime="/etc/localtime"
        if [[ -L $etclocaltime ]]; then
            tzlong=$(sed -n 's/^.*zoneinfo[^/]*\/\(.*\)$/\1/p' <<<"${etclocaltime:A}")
        else
            echo "W: make $etclocaltime a symlink for faster load time" >/dev/stderr
            tzlong=$(find /usr/share/zoneinfo/* -type f | while read fname; do cmp -s "$etclocaltime" "$fname" && sed -n 's/^.*zoneinfo[^/]*\/\(.*\)$/\1/p'<<<"$fname" && break; done)
        fi
    else
        if [[ -f $TZ && $TZ =~ ^.*zoneinfo[^/]*/.*$ ]]; then
            tzlong=$(sed -n 's/^.*zoneinfo[^/]*\/\(.*\)$/\1/p' <<<${TZ:A})
        else
            tzlong=$TZ
        fi
        #if [[ -z $tzlong ]]; then
        #    tzlong="$TZ"
        #fi
    fi
    tzshort=$(strftime '%Z')
}
notetimezone
tzlonginit="$tzlong"
tzshortinit="$tzshort"
tzlongcurrent="$tzlong"
tzshortcurrent="$tzshort"

# Function to push desktop notifications
function notifydesktop {
    local notifytitle="ARTTIME"
    local notifysubtitle=$(strftime "%a %b %d, %Y $hms %Z")
    local CR=$'\r'
    if [[ $printsprints = "1" ]]; then
        if [[ $goalmaxsprint != "-" ]]; then
            local notifymessage="sprint-$goalsprint/$goalmaxsprint "
        else
            local notifymessage="sprint-$goalsprint "
        fi
    else
        local notifymessage=""
    fi
    if [[ $goalmaxptreff -gt 1 ]]; then
        local goalptrofmaxstr="-$goalptr/$goalmaxptreff"
    else
        local goalptrofmaxstr=""
    fi
    notifymessage+="goal$goalptrofmaxstr: $goalstr"
    if bart=$(getbart); then
        notifymessage+="${CR}arts: $(getaart), $(getbart)"
    else
        notifymessage+="${CR}art: $(getaart)"
    fi
    notifymessage+="${CR}ID: $$"
    if [[ $machine = "Darwin" ]]; then
        local notifystr="display notification \"$notifymessage\" with title \"$notifytitle\" subtitle \"$notifysubtitle\" sound name \"Blow\""
        osascript -e $notifystr 2>/dev/null
    elif [[ $machine = "Linux" || $machine = "BSD" ]]; then
        [[ -z $XDG_DATA_DIRS ]] && export XDG_DATA_DIRS="$HOME/.local/share:/usr/share/xfce4:/usr/local/share:/usr/share"
        read -r freedesk_message_sound <<(print -rC1 -- ${(s[:])^XDG_DATA_DIRS}/sounds/freedesktop/stereo/message-new-instant.oga(ND))
        if command -v paplay &>/dev/null && pulseaudio --check &>/dev/null; then
            soundcommand="paplay"
        elif command -v pw-play &>/dev/null && {pactl info 2>/dev/null | grep "Server Name" 2>/dev/null | grep "PipeWire" &>/dev/null}; then
            soundcommand="pw-play" 
        else
            soundcommand="ogg123"
        fi
        [[ -n $freedesk_message_sound && -e $freedesk_message_sound ]] && $soundcommand $freedesk_message_sound &>/dev/null &
        notify-send -u critical $notifytitle "$notifysubtitle${CR}$notifymessage" &>/dev/null
    elif [[ $machine == "WSL" ]]; then
        wsl-notify-send.exe --category "$notifytitle" "$notifysubtitle${CR}$notifymessage" &>/dev/null
    fi
}

# Look at TODO note on lines 10-16, minute/nonblocking mode, sample rate is disabled
#updateonminute="${minute_arg[-1]}"
#nonblocking="${nonblocking_arg[-1]}"
#samples="${samples_arg[-1]}"
updateonminute=""
nonblocking=""
# The following options are functional, and complete
artname="${artname_arg[-1]}"
title="${title_arg[-1]}"
flipartname="${flipartname_arg[-1]}"
randomarg="${random_arg[-1]}"
theme="${theme_arg[-1]}"
goal="${goal_arg[-1]}"
termwidth="$COLUMNS"
termheight="$LINES"
artcolorarg="${artcolor_arg[-1]}"
titlecolorarg="${titlecolor_arg[-1]}"
style="${style_arg[-1]}"
pbcompletechar="${pbcompletechar_arg[-1]}"
pbpendingchar="${pbpendingchar_arg[-1]}"
pblength="${pblength_arg[-1]}"
debug="${debug_arg[-1]}"
nolearn="${nolearn_arg[-1]}"
#tflocal="${tflocal_arg[-1]}"
#tfother="${tfother_arg[-1]}"
hoursfmt="$hours_arg[-1]"
lineeditor="${lineeditor_arg[-1]}"
keyfilearg="${keyfile_arg[-1]}"

hm12="%I:%M%p"
hms12="%I:%M:%S%p"
hm24="%H:%M"
hms24="%H:%M:%S"

# This function sets hm, hms, tflocal, tfother used in rest of the program
function settimeformats {
    if [[ $hoursfmt = "12" || $hoursfmt = "" ]]; then
        hoursfmt="12"
        hm="$hm12"
        hms="$hms12"
    elif [[ $hoursfmt = "24"  ]]; then
        hm="$hm24"
        hms="$hms24"
    else
        printf "E: --hours can only be passed a value of 24 or 12 (default)\n"
        exit 1
    fi
    tflocal="%s|%b %d, $hm"
    tfother="%s|%b %d, $hm %Z"
}
settimeformats

timeformat=$tflocal

if [[ ! -z $debug ]]; then
    tchar="|"
    debugopt="--debug"
else
    tchar=" "
    debugopt=""
fi


if [[ -z $artname && ! -z $flipartname ]]; then
    printf "E: if b-art is passed, a-art should also be passed\n"
    exit 1
fi

if [[ ! -z $artname || ! -z $flipartname ]] && [[ ! -z $randomarg ]]; then
    printf "E: if --random is passed, a-art/b-art should not be\n"
    exit 1
fi

if [[ $lineeditor == "" || $lineeditor == "zle" ]]; then
    usereadline="0"
elif [[ $lineeditor == "readline" ]]; then
    if command -v bash &>/dev/null; then
        usereadline="1"
    else
        printf "E: --line-editor readline requires bash installed\n"
        exit 1
    fi
else
    printf "E: --line-editor can only accept values: readline or zle (default)\n"
    exit 1
fi

function checkartfile {
    local artfile=""
    if [[ ! -z "$1" ]]; then
        if [[ -f "${1/#\~/$HOME}" ]]; then
            artfile="${1/#\~/$HOME}"
        else
            artfile="$artdir/${1}"
        fi
        if [[ ! -f "$artfile" ]]; then
            return 1
        fi
    fi
    return 0
}
checkartfile $artname
if [[ "$?" != "0" ]]; then
    printf "E: artfile not found for a-art: $artname\n"
    exit 1
fi
checkartfile $flipartname
if [[ "$?" != "0" ]]; then
    printf "E: artfile not found for b-art: $flipartname\n"
    exit 1
fi

if [[ ! -z $randomarg ]]; then
    prevdir=$PWD
    cd $artdir
    RANDOM="${EPOCHREALTIME#*.}"
    defaultshuffle=(^tarot-*(.Nnoe['REPLY=$RANDOM']))
    cd $prevdir
    defaultart="$defaultshuffle[1]"
else
    defaultart="butterfly"
fi

if [[ ! -z "$nolearn" ]]; then
    helpactive="0"
    if [[ -z "$artname" ]]; then
        artname="$defaultart"
    fi
    restoreartname="help"
    if [[ ! -z "$flipartname" ]]; then
        restoreflipartname="$flipartname"
    fi
else
    helpactive="1"
    if [[ -z "$artname" ]]; then
        restoreartname="$defaultart"
    else
        restoreartname="$artname"
    fi
    if [[ ! -z "$flipartname" ]]; then
        restoreflipartname="$flipartname"
    fi
    artname="help"
    flipartname=""
fi

if [[ $artcolorarg = "" ]]; then
    artcolorarg="1"
elif ! [[ $artcolorarg =~ ^([0-9]|1[0-5])$ ]]; then
    echo "W: artcolor (--ac) accepts takes range [0:15], defaulting to 1" >&2
    artcolorarg="1"
fi

if [[ $titlecolorarg = "" ]]; then
    titlecolorarg="2"
elif ! [[ $titlecolorarg =~ ^([0-9]|1[0-5])$ ]]; then
    echo "W: titlecolor (--tc) accepts takes range [0:15] defaulting to 2" >&2
    titlecolorarg="2"
fi

function keyfilefeed {
    local keyfilepath=$(trimwhitespace "$1")
    if [[ -e $bindir/../share/arttime/keypoems/$keyfilepath ]]; then
        keyfilepath=$bindir/../share/arttime/keypoems/$keyfilepath
    elif [[ -e "${keyfilepath/#\~/$HOME}" ]]; then
        keyfilepath="${keyfilepath/#\~/$HOME}"
    elif [[ -e "${keyfilepath/\$HOME/$HOME}" ]]; then
        keyfilepath="${keyfilepath/\$HOME/$HOME}"
    else
        return 1
    fi
    if [[ -p $keyfilepath ]]; then
        local fileispipe="1"
    elif [[ -f $keyfilepath ]]; then
        local fileispipe="0"
    else
        return 2
    fi
    if [[ $keyfilepath =~ ^.*_([1-9][0-9]*)(b|bps)$ ]]; then
        local centidelay=$((100/match[1]))
    elif [[ $keyfilepath =~ ^.*_([1-9][0-9]+)(ms|mspb)$ ]]; then
        local centidelay=$((match[1]/10))
    elif [[ $keyfilepath =~ ^.*_([1-9][0-9]*)(s|spb)$ ]]; then
        local centidelay=$((match[1]*100))
    else
        local centidelay="0"
    fi
    [[ ! -z $streamfd ]] && { exec {streamfd}>&-; unset streamfd; }
    if [[ $centidelay == "0" ]]; then
        if [[ $fileispipe == "1" ]]; then
            exec {streamfd}<>$keyfilepath
        else
            exec {streamfd}<$keyfilepath
        fi            
    else
        if [[ $fileispipe == "1" ]]; then
            coproc { trap -; while sysread -s1 -i0; do zselect -t $centidelay; printf "$REPLY"; done <>$keyfilepath }
            exec {streamfd}<&p
        else
            coproc { trap -; while sysread -s1 -i0; do zselect -t $centidelay; printf "$REPLY"; done <$keyfilepath }
            exec {streamfd}<&p
        fi
    fi
    return 0
}

handoff="0"
modestrnorm=""
modestrscript="$(echoti cub 6)SCRIPT"
modestrpos=$(echoti cup $termheight $((termwidth-1)))
function setmodestr {
    if [[ $streamclosed == "1" ]]; then
        modestr=$modestrnorm
    else
        modestr=$modestrpos$modestrscript
    fi
}

if [[ -t 0 ]]; then
    streamclosed="1"
    streamfd=""
    if [[ $keyfilearg != "" ]]; then
        if keyfilefeed "$keyfilearg"; then
            streamclosed="0"
        else
            printf "E: -k/--keypoem can either be passed a file/fifo name under\n      $bindir/../share/arttime/keypoems/\n   or full path to a file/fifo that has keystrokes for arttime.\n"
            exit 1
        fi
    fi
else
    unset streamfd
    exec {streamfd}>&0
    exec 0>&-
    exec 0>&1
    streamclosed="0"
fi
setmodestr

inputstr=""
promptstrpost=""
function readstr {
    inputstr="$1"
    if [[ $streamclosed == "1" ]] && [[ -z $2 ]]; then
        vared -h -t $TTY -p "$promptstr%{$tput_cnorm%} " -c inputstr; retstatus="$?"
    else
        while read -r -s -k1 -t0 tempttychar && [[ $tempttychar != "p" ]] ; do : ; done
        [[ ! -z $2 ]] && printf "${tput_el}${promptstr}${tput_cnorm} ${inputstr}"
        local inputchard=""
        local inputcharint=0
        local inputchardint=0
        retstatus="1"
        while true; do
            readchar "" "$2" || { inputstr=""; break; }
            inputcharint=$(printf '%d' "'$inputchar")
            if ((inputcharint == 10 || inputcharint == 13 )); then
                retstatus="0"
                [[ ! -z $2 ]] && printf "$promptstrpost"
                break
            elif ((inputchardint == 92 && inputcharint == 110)); then
                inputstr="${inputstr:0:-1}"
                retstatus="0"
                [[ ! -z $2 ]] && printf "$tput_cub1 $tput_cub1$promptstrpost"
                break
            else
                if [[ ! -z $inputchar ]]; then
                    inputchard=$inputchar
                    inputchardint=$(printf '%d' "'$inputchar")
                    inputstr+=$inputchar
                    [[ ! -z $2 ]] && printf $inputchar
                else
                    retstatus="1"
                    inputstr=""
                    break
                fi
            fi
        done
    fi
    return $retstatus
}

inputchar=""
function readchar {
    inputchar=""
    if [[ ! -z $1 ]]; then
        local timeout="-t$1"
    else
        local timeout=""
    fi
    if [[ $streamclosed == "1" ]] && [[ -z $2 ]]; then
        read -r -s $timeout -k1 inputchar; retstatus="$?"
    else
        ERRNO=0
        sysread -s1 $timeout -i$streamfd inputchar; retstatus=$?; reterrno=$ERRNO
        case "$retstatus" in
            "0"|"4")
                retstatus=0
                [[ $tempttychar != "p" ]] && read -r -s -k1 -t0 tempttychar
                if [[ $tempttychar == "p" ]]; then
                    tempttychar=""
                    printf "$tput_sc$modestrpos$(echoti cub 6)PAUSED$tput_rc"
                    trap "tstpdone=1" TSTP
                    trap "contdone=1" CONT
                    tstpdone="0"
                    kill -TSTP 0 &>/dev/null
                    while [[ $tstpdone == "0" ]]; do zselect -t 10; done
                    unset tstpdone
                    while [[ $tempttychar != "p" ]]; do read -r -s -k1 tempttychar; done
                    printf "$tput_sc$modestr$tput_rc"
                    contdone="0"
                    kill -CONT 0 &>/dev/null
                    while [[ $contdone == "0" ]]; do zselect -t 10; done
                    unset contdone
                    trap "trapstop_blocking" TSTP
                    trap "trapcont_blocking" CONT
                    tempttychar=""
                fi
                ;;
            *)
                trap "intdone=1" INT
                intdone="0"
                kill -s INT 0 &>/dev/null
                while [[ $intdone == "0" ]]; do zselect -t 10; done
                unset intdone
                while read -r -s -k1 -t0 inputchar ; do : ; done
                inputchar=""
                streamclosed="1"
                exec {streamfd}>&-
                unset streamfd
                exec {streamfd}>&1
                sttyset
                setmodestr
                handoff="1"
                trap "trapint_blocking" INT
                ;;
        esac
    fi
    return $retstatus
}
function slurp {
    local slurpchar
    if [[ $streamclosed == "1" ]]; then
        while read -r -s -k1 -t0 slurpchar ; do : ; done 
    else
        while sysread -s1 -t0 -i$streamfd slurpchar ; do : ; done
    fi
}


tputset_str=$(echoti rmam 2>/dev/null; echoti civis; echoti smcup)
function tputset { printf "$tputset_str"; }
tputreset_str=$(echoti rmcup; echoti smam 2>/dev/null; echoti cnorm)
function tputreset { printf "$tputreset_str"; }

regexpart='[[:space:]]*([0-9]+)([dhms])[[:space:]]*'
regex1='^'$regexpart'$'
regex2='^'$regexpart$regexpart'$'
regex3='^'$regexpart$regexpart$regexpart'$'
regex4='^'$regexpart$regexpart$regexpart$regexpart'$'

function getseconds {
    amount="$1"
    suffix="$2"
    if [[ $suffix = "d" ]]; then
        echo $(( amount*86400 ))
    elif [[ $suffix = "h" ]]; then
        echo $(( amount*3600 ))
    elif [[ $suffix = "m" ]]; then
        echo $(( amount*60 ))
    elif [[ $suffix = "s" ]]; then
        echo $amount
    fi
}

function setgoaltime {
    local currenttime="$2"
    local goal="$1"
    local goaltime=""
    local goaltimestr=""
    local goalstatus="0"
    if [[ $goal =~ $regex1 ]]; then
        goaltime=$(getseconds $match[1] $match[2])
        goaltime=$(( currenttime+goaltime ))
    elif [[ $goal =~ $regex2 ]]; then
        local goaltime1=$(getseconds $match[1] $match[2])
        local goaltime2=$(getseconds $match[3] $match[4])
        goaltime=$(( currenttime+goaltime1+goaltime2 ))
    elif [[ $goal =~ $regex3 ]]; then
        local goaltime1=$(getseconds $match[1] $match[2])
        local goaltime2=$(getseconds $match[3] $match[4])
        local goaltime3=$(getseconds $match[5] $match[6])
        goaltime=$(( currenttime+goaltime1+goaltime2+goaltime3 ))
    elif [[ $goal =~ $regex4 ]]; then
        local goaltime1=$(getseconds $match[1] $match[2])
        local goaltime2=$(getseconds $match[3] $match[4])
        local goaltime3=$(getseconds $match[5] $match[6])
        local goaltime4=$(getseconds $match[7] $match[8])
        goaltime=$(( currenttime+goaltime1+goaltime2+goaltime3+goaltime4 ))
    elif goaltime=$($datecmd -d $goal '+%s' 2>/dev/null ); then
        if [[ $goaltime -gt $currenttime ]]; then
        elif goaltime=$($datecmd -d "$goal +1days" '+%s' 2>/dev/null); then
            if [[ $goaltime -gt $currenttime ]]; then
                goalstatus="1"
                #echoti cup 0 0
                #echoti el
                #printf "Today's $goal has passed, setting goal time to tomorrow's $goal"
                #sleep 2
            else
                goaltime='-'
                goalstatus="2"
            fi
        fi
    else
        goaltime='-'
        goalstatus="2"
    fi
    #echo "$ goal:$goal, goaltime:$goaltime"
    if [[ $goaltime != '-' ]]; then
        local tmpgoaltime=$(strftime $timeformat $goaltime)
        local tmpgoaltimearray=(${(s/|/)tmpgoaltime})
        goaltimestr=$tmpgoaltimearray[2]
        #if goaltimestr=$($datecmd -d "@$goaltime" "+%b %d, %I:%M%p" 2>/dev/null); then
        #elif goaltimestr=$($datecmd -jf "%s" $goaltime "+%b %d, %I:%M%p" 2>/dev/null); then
        #else
        #    goaltimestr=""
        #fi
    else
        goaltimestr=""
    fi
    returngoaltime="$goaltime"
    returngoaltimestr="$goaltimestr"
    returngoalstatus="$goalstatus"
    #return $returnval
    #echo "$ goal:$goal, goaltime:$goaltime, goaltimestr:$goaltimestr"
}

#goaltimes=()
#goaltimesstrs=()
#goalvalids=()
goalarray=()
goalarraysorted=()
goalentry=""
goalsprint="1"

function setnextgoal {
    if [[ $goalptr != $goalmaxptr ]] then;
        local lastgoaltime="$goaltime"
        local lastgoaltimestr="$goaltimestr"
        goalptr=$((goalptr+1))
        goalentry="$goalarraysorted[$goalptr]"
        #$returngoaltime;$numgoals;$returngoalstatus;$returngoaltimestr;$goal
        local goalentryarray=(${(s/;/)goalentry})
        goaltime="$goalentryarray[1]"
        goalnum="$goalentryarray[2]"
        local localgoalnum="$goalnum"
        goalstatus="$goalentryarray[3]"
        goaltimestr="$goalentryarray[4]"
        local localgoaltimestr="$goaltimestr"
        goalstr="$goalentryarray[5]"
        if [[ $goalstr = "loop" ]]; then
            if [[ $localgoaltimestr = "-" ]]; then
                local lastgoalptr="$goalptr"
                goalsprint=$((goalsprint+1))
                accumulatedsprinttime="0"
                sprintstarttime=$(strftime '%s')
                setgoals $sprintstarttime
                goaldone="0"
                #goalarraysorted[-1]=("loop;$localgoalnum;0;-;loop")
            elif [[ $localgoaltimestr -gt 1 ]]; then
                local lastgoalptr="$goalptr"
                goalsprint=$((goalsprint+1))
                accumulatedsprinttime="0"
                sprintstarttime=$(strftime '%s')
                setgoals $sprintstarttime
                goaldone="0"
                goalarraysorted[-1]=("loop;$localgoalnum;0;$((localgoaltimestr-1));loop")
            else
                goaltime="$lastgoaltime"
                goaltimestr="$lastgoaltimestr"
                goalptr="$((goalmaxptr-1))"
                goaldone="1"
            fi
        else
            goaldone="0"
        fi
    fi
}

function setgoals {
    goalmaxptr="0"
    goalptr="0"
    local tmpgoals=(${(s/;/)goal})
    local goal=""
    local numgoals="0"
    local errdetected="0"
    local tmpgoalarray=()
    for goal in "$tmpgoals[@]"; do
        numgoals=$((numgoals+1))
        if [[ $goal =~ ^[[:space:]]*(loop|sprint|x)(.*)$ ]]; then
            goal="loop"
            local match2="$match[2]"
            if [[ $match2 =~ ^([0-9]+)[[:space:]]*$ ]]; then
                returngoaltimestr="$match[1]"
            elif [[ $match2 =~ ^[[:space:]]*$ ]]; then
                returngoaltimestr="-"
            else
                returngoaltimestr=" "
                errdetected="1"
            fi
            if [[ $numgoals = "1" ]]; then
                errdetected="1"
            fi
            returngoaltime="loop"
            tmpgoalarray+=("$returngoaltime;$numgoals;0;$returngoaltimestr;$goal")
            break
        else
            #[[ $goal =~ ^[[:space:]]*(.*)$ ]] && goal="$match[1]"
            goal=${${goal%${goal##*[^[:blank:]]}}#${${goal%${goal##*[^[:blank:]]}}%%[^[:blank:]]*}};
            setgoaltime $goal $1
            if [[ $returngoalstatus = "2" ]]; then
                errdetected="1"
            fi
            tmpgoalarray+=("$returngoaltime;$numgoals;$returngoalstatus;$returngoaltimestr;$goal")
        fi
    done
    if [[ $numgoals -gt 0 ]]; then
        if [[ $errdetected = "0" ]]; then
            goalarray=("${tmpgoalarray[@]}")
            goalarraysorted=("${(o)goalarray[@]}")
            errgoalarray=()
            goalptr="0"
            goalmaxptr="$numgoals"
            setnextgoal
            if [[ $returngoaltime = "loop" && ( $returngoaltimestr = "-" || $returngoaltimestr =~ ^[0-9]+$ ) ]]; then
                printsprints="1"
                goalmaxptreff="$((goalmaxptr-1))"
                goalmaxsprint="$returngoaltimestr"
            else
                printsprints="0"
                goalmaxsprint="1"
                goalmaxptreff="$goalmaxptr"
            fi
            goalentry=$goalarraysorted[$goalmaxptreff]
            goalentryarray=(${(s/;/)goalentry})
            sprintendtime=$goalentryarray[1]
        else
            errgoalarray=("${tmpgoalarray[@]}")
            goalptr="0"
            goalmaxptr="0"
            goalentry=""
            goaltime=""
        fi
    fi
    return $errdetected
}

if [[ ! -z $goal ]]; then
    accumulatedsprinttime="0"
    sprintstarttime=$(strftime '%s')
    setgoals $sprintstarttime
    if [[ "$?" != "0" ]]; then
        echo "E: Goal time must be a valid time format representing future time.\n   Start application, press 'g', enter 'help' to learn more."
        exit 0
    else
    fi
else
    goaltime=""
fi

function exitpause {
    local goalentry
    local goalentryarray
    local goaltimeloc
    local goalnum
    local goalstatus
    local goalstr
    local tmpgoaltime
    local tmpgoaltimearray
    local goaltimestrloc
    local i
    for (( i=$goalptr; i<=$goalmaxptreff; i++ )) do
        goalentry=$goalarraysorted[$i]
        goalentryarray=(${(s/;/)goalentry})
        goaltimeloc=$((goalentryarray[1]+pausedelta))
        goalnum="$goalentryarray[2]"
        goalstatus="$goalentryarray[3]"
        goalstr="$goalentryarray[5]"
        tmpgoaltime=$(strftime $timeformat $goaltimeloc)
        tmpgoaltimearray=(${(s/|/)tmpgoaltime})
        goaltimestrloc=$tmpgoaltimearray[2]
        goalarraysorted[$i]=("$goaltimeloc;$goalnum;$goalstatus;$goaltimestrloc;$goalstr")
        if [[ $i = $goalptr ]]; then
            goaltime="$goaltimeloc"
            goaltimestr="$goaltimestrloc"
        fi
    done
}


if [[ ! -z $updateonminute ]]; then
    sleeptime="60"
    nonblocking="1"
else
    sleeptime="1"
    if [[ ! -z $nonblocking ]]; then
        nonblocking="1"
    else
        nonblocking="0"
    fi
fi

#sleeptimecenti=""
#sleeptimefloat=""
#function setsleeptimecenti {
#    if [[ -z $samples || ! $samples =~ ^[1-9]\|[1-9][0-9]+$ ]]; then
#        samples="1"
#    fi
#    sleeptimecenti=$((sleeptime*100/samples))
#    sleeptimefloat=$((sleeptime*1.0/samples))
#    if [[ $sleeptimecenti = "0" || ! $sleeptimecenti -gt 10 ]]; then
#        sleeptimecenti="10"
#        sleeptimefloat="0.1"
#    fi
#}

#setsleeptimecenti

sttycmd="/bin/stty"
sttyorig=""

function sttyget {
    sttyorig=$($sttycmd -g </dev/tty 2>/dev/null)
}

function sttyset {
    $sttycmd -echo </dev/tty 2>/dev/null
    $sttycmd -icanon min 0 time 0 </dev/tty 2>/dev/null
}

function sttyresetint {
    if [[ $streamclosed == "1" ]]; then
        $sttycmd $sttyorig </dev/tty 2>/dev/null
    else
        $sttycmd $sttyorig </dev/tty 2>/dev/null
        $sttycmd -echo </dev/tty 2>/dev/null
    fi
}

function sttyresetext {
    $sttycmd $sttyorig </dev/tty 2>/dev/null
}

sttyget
sttyset

function setcolors {
    if [[ -z "$theme" || "$theme" = "dark" ]]; then
        artcolor="$artcolorarg"
        titlecolor="$titlecolorarg"
        subtitlecolor="6"
        starttimecolor="5"
        deltatimecolor="3"
        currenttimecolor="5"
        theme="dark"
    else
        artcolor=""
        titlecolor="8"
        subtitlecolor="8"
        starttimecolor="4"
        deltatimecolor="1"
        currenttimecolor="4"
    fi
}
setcolors

prevartname=""
artstringht=""
flipartstringht=""
belowstr=""
artht=""
flipartht=""
function setartstring {
    local localtitle=""
    if [[ ! -z $title ]]; then
        localtitle=$title
    else
        read -r localtitle <$artdir/$artname
    fi
    local maxartstringht=$((termheight-2))
    ((maxartstringht<0)) && maxartstringht="0"
    artstring=$($bindir/artprint -a "$artname" -t "$localtitle" --ac "$artcolor" --tc "$titlecolor" --theme "$theme" $debugopt --width "$termwidth" --height "$termheight" --style "$style"| tail -n $maxartstringht)
    if [[ ! -z $flipartname ]]; then
        flipartstring=$($bindir/artprint -a "$flipartname" -t "$localtitle" --ac "$artcolor" --tc "$titlecolor" --theme "$theme" $debugopt --width "$termwidth" --height "$termheight" --style "$style" | tail -n $maxartstringht)
    fi
    if [[ $artname != $prevartname ]]; then
        #echo "here, $artname, $prevartname"
        if [[ -f "${artname/#\~/$HOME}" ]]; then
            artfile="${artname/#\~/$HOME}"
        else
            artfile="$artdir/${artname}"
        fi
        if [[ ! -f "$artfile" ]]; then
            artfile="/dev/null"
        fi
        artht=$(tail -n +2 $artfile | wc -l)
        artstringht=$(wc -l <<<$artstring)
        belowcurpos=$(($artstringht+2))
        lastlinepos=$(($termheight-1))
        belowstr=""
        if [[ $belowcurpos = $lastlinepos ]]; then
            #belowstr=$(printf "%$(($termwidth-1))s$tchar" " ")
            printf -v tempstr "\n%$(($termwidth-1))s$tchar" " "
            belowstr+=$tempstr
        elif [[ $lastlinepos -gt $belowcurpos ]]; then
            tempstr=""
            for i in {$belowcurpos..$lastlinepos}; do
                printf -v tempstr "\n%$(($termwidth-1))s$tchar" " "
                belowstr+=$tempstr
            done
        else
            belowstr=""
        fi
        if [[ ! -z "$flipartname" ]]; then
            if [[ -f "${flipartname/#\~/$HOME}" ]]; then
                flipartfile="${flipartname/#\~/$HOME}"
            else
                flipartfile="$artdir/${flipartname}"
            fi
            if [[ ! -f "$flipartfile" ]]; then
                flipartfile="/dev/null"
            fi
            flipartht=$(tail -n +2 $flipartfile | wc -l)
            flipartstringht=$(wc -l <<<$flipartstring)
            if [[ "$flipartht" != "$artht" ]]; then
                flipartname=""
                prevartname="$artname"
                return 1
            fi
        fi
        prevartname="$artname"
    fi
    return 0
    #echo "$flipartname, $flipartstringht, $artname, $artstringht, $belowstr"
    #exit
}

tput_cup00=$(echoti cup 0 0)
tput_sc=$(echoti sc)
tput_rc=$(echoti rc)
tput_civis=$(echoti civis)
tput_cnorm=$(echoti cnorm)
tput_smcup=$(echoti smcup)
tput_cuu1=$(echoti cuu1)
tput_cub1=$(echoti cub1)
tput_el=$(echoti el)
tput_clear=$(echoti clear)

toggleflipart="0"
function printart {
    #usr1detected=""
    #trap 'trapusr1detected' USR1
    if [[ ! -z $flipartname && $toggleflipart = "1" ]]; then
        toggleflipart="0"
        if [[ -z $1 ]]; then
            printf "${tput_cup00}\e[38;5;${artcolor}m%s\n" "${flipartstring}"
        else
            # NOTE: For now unreachable, might be needed in future
            printf "${tput_cup00}%s%$((termwidth-${#1}-1))s$tchar\n\e[38;5;${artcolor}m%s\n" "$1" " " "${flipartstring#*$'\n'}"
        fi
    else
        toggleflipart="1"
        if [[ -z $1 ]]; then
            printf "${tput_cup00}\e[38;5;${artcolor}m%s\n" "${artstring}"
        else
            printf "${tput_cup00}%s%$((termwidth-${#1}-1))s$tchar\n\e[38;5;${artcolor}m%s\n" "$1" " " "${artstring#*$'\n'}"
        fi
    fi
    #if [[ "$usr1detected" = "1" ]]; then
    #    trapusr1_both
    #fi
    #trap 'trapusr1_both' USR1
}
if ! setartstring && [[ $helpactive != "1" ]]; then
    printf "W: height of b art does not match that of a art. Try setting b art again."
fi

function setstyle {
    if [[ $style = "0" || $style = "" ]]; then
        currenttimestyle="\e[4m" # regular underline
        passedgoalstyle="\e[7m" # reversed
        style="0"
        [[ -z $pbpendingchar ]] && pbpendingchar='-'
        [[ -z $pbcompletechar ]] && pbcompletechar='>'
        [[ -z $pblength ]] && pblength="10"
    else
        currenttimestyle="\e[4:3m" # curly underline
        passedgoalstyle="\e[9m" # strike-through
        [[ -z $pbpendingchar ]] && pbpendingchar='□'
        [[ -z $pbcompletechar ]] && pbcompletechar='■'
        [[ -z $pblength ]] && pblength="10"
    fi
}
setstyle

function printprogressbar {
    #local probar='**********'
    #local probar='■■■■□□□□□□'
    #local probar='..........'
    #local probar='>>>>>.....'
    if (($1>100)); then
        local percentdone="100.0"
    elif (($1<0)); then
        local percentdone="0.0"
    else
        local percentdone="$1"
    fi
    if [[ $2 =~ ^[0-9]+$ && $2 -gt "1" ]]; then
        local barlen="${2%.*}"
    else
        local barlen="1"
    fi
    local numdone=$(((percentdone/100.0)*barlen))
    if ((numdone<1.0)); then
        numdone="0"
    else
        numdone="${numdone%.*}"
    fi
    local numnotdone=$((barlen-numdone))
    local probar=''
    if [[ $numdone -gt 0 ]]; then
        probar+=$(printf "%.s$pbcompletechar" {1..$numdone})
    fi
    if [[ $numnotdone -gt 0 ]]; then
        probar+=$(printf "%.s$pbpendingchar" {1..$numnotdone})
    fi
    printf "$probar\n"
}
cacheprogressbar100=$(printprogressbar 100.0 $pblength)

ignorewinch="0"
resetstarttime="0"
lasttime=""
function printtime {
    # NOTE: strftime is a builtin replacement for date command
    currenttime=$(strftime $timeformat)
    if [[ "$currenttime" = "$lasttime" ]]; then
        return
    else
        #usr1detected=""
        #trap 'trapusr1detected' USR1
        if [[ ! -z $flipartname && ! -z $lasttime ]]; then
            printart
        fi
    fi
    lasttime="$currenttime"
    currenttimearray=(${(s/|/)currenttime})
    if [[ "$resetstarttime" == "1" ]]; then
        starttime="$currenttime"
        starttimearray=(${(s/|/)currenttime})
    fi
    if [[ ! -z $goaltime ]]; then
        difftime=$((goaltime-currenttimearray[1]))
        timestring0="$currenttimearray[2]"
        timestring0style="$currenttimestyle"
        timestring4="$goaltimestr"
        if [[ ! $difftime -gt 0 ]]; then
            difftime=$(( -difftime ))
            if [[ $goaldone = "0" ]]; then
                local lastgoaltime="$goaltime"
                while ((goaltime == lastgoaltime && goaldone == 0)); do
                    notifydesktop &
                    goaldone="1"
                    setnextgoal
                done
                difftime=$((goaltime-currenttimearray[1]))
                timestring4="$goaltimestr"
            fi
            if [[ $goalmaxptreff -gt 1 ]]; then
                local goalptrofmaxstr="-$goalptr/$goalmaxptreff"
            else
                local goalptrofmaxstr=""
            fi
            if [[ $printsprints = "1" ]]; then
                if [[ $goalmaxsprint != "-" ]]; then
                    timestring1=" | sprint-${goalsprint}/$goalmaxsprint "
                else
                    timestring1=" | sprint-${goalsprint} "
                fi
            else
                timestring1=" | "
            fi
            if [[ $goaldone = "0" ]]; then
                timestring1+="goal$goalptrofmaxstr pending "
                timestring4style=""
            else
                timestring1+="goal$goalptrofmaxstr passed! "
                timestring4style="$passedgoalstyle"
            fi
        else
            if [[ $goalmaxptreff -gt 1 ]]; then
                local goalptrofmaxstr="-$goalptr/$goalmaxptreff"
            else
                local goalptrofmaxstr=""
            fi
            if [[ $printsprints = "1" ]]; then
                if [[ $goalmaxsprint != "-" ]]; then
                    timestring1=" | sprint-${goalsprint}/$goalmaxsprint "
                else
                    timestring1=" | sprint-${goalsprint} "
                fi
            else
                timestring1=" | "
            fi
            timestring1+="goal$goalptrofmaxstr pending "
            timestring4style=""
        fi
    elif [[ $pausegoals = "1" ]]; then
        difftime=$((currenttimearray[1]-pausestart))
        timestring0="$pausestartstr"
        timestring4="$currenttimearray[2]"
        timestring4style="$currenttimestyle"
        timestring0style=""
        if [[ $goalmaxptreff -gt 1 ]]; then
            local goalptrofmaxstr="-$goalptr/$goalmaxptreff"
        else
            local goalptrofmaxstr=""
        fi
        if [[ $printsprints = "1" ]]; then
            if [[ $goalmaxsprint != "-" ]]; then
                timestring1=" | sprint-${goalsprint}/$goalmaxsprint "
            else
                timestring1=" | sprint-${goalsprint} "
            fi
        else
            timestring1=" | "
        fi
        timestring1+="goal$goalptrofmaxstr PAUSED! "
    else
        difftime=$((currenttimearray[1]-starttimearray[1]))
        timestring0="$starttimearray[2]"
        timestring4="$currenttimearray[2]"
        timestring4style="$currenttimestyle"
        timestring0style=""
        timestring1=" | time elapsed "
    fi
    days=$((difftime/86400))
    hours=$((difftime%86400/3600))
    minutes=$((difftime%3600/60))
    seconds=$((difftime%60))
    if [[ $days != "0" ]]; then
        #timestring2="${(l:3::0:)days}d "
        timestring2="${days}d "
    else
        timestring2=""
    fi
    timestring2="$timestring2${(l:2::0:)hours}h "
    timestring2="$timestring2${(l:2::0:)minutes}m "
    if [[ -z $updateonminute ]]; then
        timestring2="$timestring2${(l:2::0:)seconds}s"
    fi
    timestring3=" | "
    #if [[ ! -z $TMUX ]]; then
    #    #ignorewinch=$(tmux show-options -vp -t $TMUX_PANE @arttimeterm-ignorewinch 2>/dev/null)
    #    if [ "$ignorewinch" != "1" ]; then
    #        termwidth="$COLUMNS"
    #    fi
    #else
    #    termwidth="$COLUMNS"
    #fi
    shiftwidth=$((($termwidth-${#timestring0}-${#timestring1}-${#timestring2}-${#timestring3}-${#timestring4})/2))
    # NOTE: following checks are needed so following math expressions do not fail during runtime
    # when the term-width is changed to be too narrow for instance...
    if [[ ! $shiftwidth -gt 0 ]]; then
        shiftwidth=0
    fi
    padwidth=$(($termwidth-${#timestring0}-${#timestring1}-${#timestring2}-${#timestring3}-${#timestring4}-${shiftwidth}-1))
    if [[ ! $padwidth -gt 0 ]]; then
        padwidth=0
    fi
    printf "\r%${shiftwidth}s\e[0m\e[38;5;${starttimecolor}m${timestring0style}$timestring0\e[0m\e[38;5;${subtitlecolor}m$timestring1\e[0m\e[38;5;${deltatimecolor}m$timestring2\e[0m\e[38;5;${subtitlecolor}m$timestring3\e[0m\e[38;5;${currenttimecolor}m${timestring4style}$timestring4\e[0m%${padwidth}s$tchar" " " " "
    if [[  $goaltime != "" && $goaldone = "1" && $goalmaxsprint != "-" ]]; then
        percentdone="100.0"
        progressbar="$cacheprogressbar100"
        printprogressbarflag="1"
    elif [[ $goaltime != "" && $goalmaxsprint != "-" ]]; then
        percentdone=$((((goalsprint-1)*100.0/goalmaxsprint) + (1.0/goalmaxsprint)*(accumulatedsprinttime+currenttimearray[1]-sprintstarttime)*100.0/(accumulatedsprinttime+sprintendtime-sprintstarttime)))
        progressbar=$(printprogressbar $percentdone $pblength)
        printprogressbarflag="1"
    elif [[ $pausegoals = "1" && $goalmaxsprint != "-" ]]; then
        printprogressbarflag="1"
    elif [[ $pausegoals = "1" || $goaltime != "" ]] && [[ $goalmaxsprint = "-" ]]; then
        printprogressbarflag="1"
        progressbar=">--------|"
    else
        printprogressbarflag="0"
    fi
    
    if [[ $belowstr == "" || $1 == "1" || $handoff == "1" ]]; then
        #printprogressbar
        #printbelowstr
        #printmodestr
        if [[ $printprogressbarflag = "1" ]]; then
            #printprogressbar
            shiftwidth=$(((termwidth-${#progressbar})/2))
            [[ ! $shiftwidth -gt 0 ]] && shiftwidth=0
            padwidth=$((termwidth-${#progressbar}-shiftwidth-1))
            [[ ! $padwidth -gt 0 ]] && padwidth=0
            printf "$tput_sc\n%${shiftwidth}s\e[38;5;${artcolor}m%s\e[0m%${padwidth}s$tchar$belowstr$modestr$tput_rc" " " "$progressbar" " "
        else
            #printemptyline
            shiftwidth=$((termwidth-1))
            printf "$tput_sc\n%${shiftwidth}s$tchar$belowstr$modestr$tput_rc" " "
        fi
        handoff="0"
    else
        #printprogressbar
        if [[ $printprogressbarflag = "1" ]]; then
            #printprogressbar
            shiftwidth=$(((termwidth-${#progressbar})/2))
            [[ ! $shiftwidth -gt 0 ]] && shiftwidth=0
            padwidth=$((termwidth-${#progressbar}-shiftwidth-1))
            [[ ! $padwidth -gt 0 ]] && padwidth=0
            printf "\n%${shiftwidth}s\e[38;5;${artcolor}m%s\e[0m%${padwidth}s$tchar$tput_cuu1" " " "$progressbar" " "
        else
            #printemptyline
            shiftwidth=$((termwidth-1))
            printf "\n%${shiftwidth}s$tchar$tput_cuu1" " "
        fi
    fi
    
    #if [[ "$usr1detected" = "1" ]]; then
    #    trapusr1_both
    #fi
    #trap 'trapusr1_both' USR1
}

killdone="0"

function trapint_nonblocking {
    trap -; kill ${1}; command -v pkill &>/dev/null && pkill -P $$; killdone="1"; tputreset; sttyresetext; exit 0;
}

function trapint_blocking {
    if ! [[ $streamclosed == "1" ]]; then
        while sysread -s1 -t0 -i$streamfd inputchar ; do : ; done
        while read -r -s -k1 -t0 inputchar ; do : ; done
        inputchar=""
        inputstr=""
        tempttychar=""
        streamclosed="1"
        exec {streamfd}>&-
        unset streamfd
        exec {streamfd}>&1
        sttyset
        setmodestr
        handoff="1"
        winchdetected="1"
        termwidth=""
        ignorewinch="0"
    fi
}

function trapexit_nonblocking {
    trap -;
    command -v pkill &>/dev/null && pkill -P $$;
    if [[ "$killdone" = "0" ]]; then
        kill ${1}; killdone="1"; tputreset; sttyresetext; exit 0;
    fi
}

function trapexit_blocking {
    rm ~/.cache/arttime/$UID-$$.morestr 2>/dev/null
    trap -; command -v pkill &>/dev/null && pkill -P $$; tputreset; sttyresetext;  set -e; (exit 1);
}

function trapstop_blocking {
    tputreset; sttyresetext; trap - TSTP; suspend; # kill -TSTP $$
}

function trapstop_nonblocking {
    tputreset; sttyresetext; trap - TSTP; suspend; # kill -TSTP $$
}

function trapcont_blocking {
    trap "trapstop_blocking" TSTP;
    #killdone="0"; 
    #sttyget
    sttyset
    tputset
    printart
    printtime "1"
}

function trapcont_nonblocking {
    trap "trapstop_nonblocking" TSTP;
    #killdone="0"; 
    #sttyget
    sttyset
    tputset
    printart
    printtime "1"
}


function askforconfirmation {
    if ! [[ $streamclosed == "1" ]]; then
        while read -r -s -k1 -t0 tempttychar && [[ $tempttychar != "p" ]] ; do : ; done
    fi
    printf "Do you really want to $1? [y/n]:  ${tput_cub1}${tput_cnorm}"
    readchar
    printf "$inputchar"
    if [[ $inputchar = "y" || $inputchar = "Y" ]]; then
        return 0
    else
        return 1
    fi
}

#setopt nomenucomplete
#setopt menu_complete
#zmodload -i zsh/complist
function artselector {
    local restoredir=$PWD
    cd $artdir
    local curcontext=artselector:::
    printf "Select a-art. Press 'Enter' without typing anything to cancel.\nPress tab for completion or Ctrl-d to see all possible artnames.\nAnswer statements ending in '?' with pressing 'y' or 'n'.\n";
    promptstr="Enter artname:"
    compdef _artselector -vared-
    readstr "" $modestr
    compdef -d _artselector -vared-
    cd $restoredir
}
function _artselector {
    case $CURRENT in
        1)
            _files -W $artdir
            ;;
        *)
            ;;
    esac
}
zstyle ':completion:artselector:*:' insert-tab false
#zstyle ':completion:::*:default' menu no select

typeset -a bartarray
function artselector2 {
    local curcontext=artselector2:::
    printf "Set b-art. Finding art that matches height of a-art ($artname)...\nEnter '-' to [31mCLEAR[0m b-art.\nPress a letter, followed by tab key to see possible artnames.\nPress tab for completion or Ctrl-d to see all possible artnames.\nAnswer statements ending in '?' with pressing 'y' or 'n'.\n\nAlternatives (based on height):\n";
    if command -v column &>/dev/null; then
        echo $bartarray  | tr ' ' '\n' | column -c$(echoti cols)
        printf '\n'
    else
        echoti smam 2>/dev/null
        printf '%s  ' $bartarray
        printf '\n\n'
    fi
    promptstr="Enter artname:"
    compdef _artselector2 -vared-
    readstr "" $modestr
    compdef -d _artselector2 -vared-
}
function _artselector2 {
    case $CURRENT in
        1)
            _describe 'possible b-art' bartarray
            ;;
        *)
            ;;
    esac
}
zstyle ':completion:artselector2:*:' insert-tab false

function keyfileselector {
    local restoredir=$PWD
    cd $bindir/../share/arttime/keypoems/ 2>/dev/null
    local curcontext=keyfileselector:::
    printf "Select a file or fifo to load keystrokes from (examples pre-installed).\nPress 'Enter' without typing anything to cancel.\nPress tab for completion or Ctrl-d to see all files.\nUse shell path semantics (like '~/') to get file from non-default location.\nAnswer statements ending in '?' with pressing 'y' or 'n'.\n";
    promptstr="Enter file:"
    local modestrlocal=$modestr
    compdef _keyfileselector -vared-
    readstr "" $modestrlocal || { compdef -d _keyfileselector -vared-; cd $restoredir; return }
    local inputstrexpanded=${inputstr/#\~/$HOME}
    while [[ ! -f $bindir/../share/arttime/keypoems/$inputstr && ! -p $bindir/../share/arttime/keypoems/$inputstr && ! -f $inputstrexpanded && ! -p $inputstrexpanded && ! -z $inputstr ]]; do
        if [[ -d $inputstrexpanded ]]; then
            if [[ $inputstr[-1] != "/" ]]; then
                inputstr=$inputstr'/'
            fi
            readstr $inputstr $modestrlocal || break
        else
            readstr $inputstr $modestrlocal || break
        fi
        inputstr=$(trimwhitespace "$inputstr")
        if [[ $inputstr == "" ]]; then
            break
        fi
        inputstrexpanded=${inputstr/#\~/$HOME}
    done
    compdef -d _keyfileselector -vared-
    cd $restoredir
}
function _keyfileselector {
    case $CURRENT in
        1)
            _files -W $bindir/../share/arttime/keypoems/
            ;;
        *)
            ;;
    esac
}
zstyle ':completion:keyfileselector:*:' insert-tab false

function zoneselector {
    local restorepwd=$PWD
    cd /usr/share/zoneinfo
    local curcontext=zoneselector:::
    promptstr="Enter zonename (press tab):"
    if [[ $streamclosed == "1" ]]; then
        promptstrpost=""
    else
        promptstrpost="\n"
    fi
    printf "Press tab or Ctrl-d key to see possible zonename completions.\nExamples: US/Hawaii, America/Indiana/Knox, Asia/Kolkata, Europe/Athens\nAnswer statements ending in '?' with pressing 'y' or 'n'.\nEnter 'orig' to reset timezone\n";
    local modestrlocal=$modestr
    compdef _zoneselector -vared-
    readstr "" $modestrlocal || { compdef -d _zoneselector -vared-; promptstrpost=""; cd $restoredir; return }
    while [[ ! -f /usr/share/zoneinfo/$inputstr && ! -z $inputstr && $inputstr != "./orig" && $inputstr != "orig" ]]; do
        if [[ $inputstr =~ ^[./]+$ ]]; then
            inputstr="./"
            readstr $inputstr $modestrlocal || break
        elif [[ -d /usr/share/zoneinfo/$inputstr ]]; then
            if [[ $inputstr[-1] != "/" ]]; then
                inputstr=$inputstr'/'
            fi
            readstr $inputstr $modestrlocal || break
        else
            readstr $inputstr $modestrlocal || break
        fi
        inputstr=$(trimwhitespace "$inputstr")
    done
    if [[ $inputstr == "./orig" || $inputstr == "orig" ]]; then
        inputstr=$tzlonginit
    fi
    promptstrpost=""
    compdef -d _zoneselector -vared-
    cd $restorepwd
}
function _zoneselector {
    case $CURRENT in
        1)
            _files -W /usr/share/zoneinfo/
            ;;
        *)
            ;;
    esac
}
zstyle ':completion:zoneselector:*:' insert-tab false

function _emptyselector {
    return
}
zstyle ':completion:emptyselector:*:' insert-tab true

function formattimedelta {
    if [[ ! $1 -gt 0 ]]; then
        local timedelta="$1"
        local timedelta=$(( -timedelta ))
        local timestate=" passed: "
    elif [[ $3 = "1" ]]; then
        local timedelta="$1"
        local timestate=" PAUSED: "
    else
        local timedelta="$1"
        local timestate="pending: "
    fi
    local days=$(($timedelta/86400))
    local hours=$(($timedelta%86400/3600))
    local minutes=$(($timedelta%3600/60))
    local seconds=$(($timedelta%60))
    if [[ $days != "0" || $2 != "0" ]]; then
        if [[ $2 != "0" ]]; then
            local formattedtime="${(l:$2::0:)days}d "
        else
            local formattedtime="${days}d "
        fi
    else
        local formattedtime=""
    fi
    formattedtime="$formattedtime${(l:2::0:)hours}h "
    formattedtime="$formattedtime${(l:2::0:)minutes}m "
    if [[ -z $updateonminute ]]; then
        formattedtime="$formattedtime${(l:2::0:)seconds}s"
    fi
    echo "$timestate$formattedtime"
}

promptstr=""
function zlelineprompt {
    if [[ $belowstr = "" && $printprogressbarflag = "1" ]]; then
        #printprogressbar
        shiftwidth=$(((termwidth-${#progressbar})/2))
        [[ ! $shiftwidth -gt 0 ]] && shiftwidth=0
        padwidth=$((termwidth-${#progressbar}-shiftwidth-1))
        [[ ! $padwidth -gt 0 ]] && padwidth=0
        echoti cup $LINES 0
        printf "%${shiftwidth}s\e[38;5;${artcolor}m%s\e[0m%${padwidth}s$tchar" " " "$progressbar" " "
    else
        #printemptyline
        shiftwidth=$((termwidth-1))
        echoti cup $LINES 0
        printf "%${shiftwidth}s$tchar" " "
    fi
    printf "${tput_cup00}${promptstr} $tput_cnorm"
}
zle -N zlelineprompt

function usr1input_handler {
    local commandkey=$1
    local pprint=true
    if ! [[ $streamclosed == "1" ]]; then
        case $commandkey; in
            "x") commandkey="a";;
            "y") commandkey="b";;
            "M") commandkey="m"; pprint=false ;;
            "A") commandkey="a"; pprint=false ;;
            "B") commandkey="b"; pprint=false ;;
            "G") commandkey="g"; pprint=false ;;
            "Z") commandkey="z"; pprint=false ;;
              *) ;;
        esac
        local streamclosedinit="0"
    else
        local streamclosedinit="1"
    fi
    case "$commandkey" in
        "a"|"b")
            local initialartname="$artname"
            local initialflipartname="$flipartname"
            if [[ $helpactive = "1" ]]; then
                artname="$restoreartname"
                flipartname="$restoreflipartname"
            fi
            if [[ $pprint == false ]]; then
                promptstr=""
                readstr "" ""
                retstatus="$?"
            elif [[ $commandkey = "a" ]]; then
                sttyresetint
                printf "$tput_smcup"
                printf "$tput_clear$modestr$tput_cup00"
                $(printf $histcmd) $statedir/hist/aart.hist 1000 1000
                artselector
                sttyset
                tputset
            else
                $(printf $histcmd) $statedir/hist/bart.hist 1000 1000
                local restoredir=$PWD
                cd $artdir
                local aartheight=$(wc -l "${artname}" | sed -n 's/^[[:space:]]*\([0-9]*\)[[:space:]][[:space:]]*.*$/\1/p')
                bartarray=($(wc -l * | sed -n '$d;s/^[[:space:]]*'"${aartheight}"'[[:space:]][[:space:]]*\(.*\)$/\1/p'))
                if [[ ${#bartarray[@]} -gt 1 ]]; then
                    sttyresetint
                    printf "$tput_smcup"
                    printf "$tput_clear$modestr$tput_cup00"
                    artselector2
                    sttyset
                    tputset
                else
                    printf "${tput_cup00}No other art matches height of a-art '$artname'"
                    inputstr=""
                    readchar 2
                    slurp
                fi
                cd $restoredir
                bartarray=()
            fi
            inputstr=$(trimwhitespace "$inputstr")
            if [[ $inputstr == "" ]]; then
            elif [[ $inputstr == "-" ]]; then
                if [[ $commandkey = "b" ]]; then
                    flipartname=""
                fi
            elif [[ ! -f "$artdir/$inputstr" ]]; then
                $pprint && printf "E: No file found for art: $inputstr\nPress any key to continue..."
                $pprint && readchar 3
                $pprint && slurp
            else
                if [[ $commandkey = "a" ]]; then
                    artname="$inputstr"
                else
                    flipartname="$inputstr"
                fi
            fi
            prevartname=""
            if ! setartstring; then
                if [[ $commandkey = "b" ]]; then
                    $pprint && printf "W: Height of b art does not match that of a art, try setting b art again.\nPress any key to continue..."
                    artname="$initialartname"
                    flipartname="$initialflipartname"
                    setartstring
                    $pprint && readchar 5
                    $pprint && slurp
                else
                    helpactive="0"
                    [[ $streamclosedinit == "1" ]] && ! [[ $inputstr == "" || $inputstr =~ ^[[:space:]]*$ ]] && print -rs -- ${inputstr} &>/dev/null
                fi
            else
                if [[ $inputstr = "" || ! -f "$artdir/$inputstr" ]]; then
                    if [[ $helpactive = "1" ]]; then
                        artname="$initialartname"
                        flipartname="$initialflipartname"
                        setartstring
                    fi
                else
                    helpactive="0"
                    [[ $streamclosedinit == "1" ]] && ! [[ $inputstr == "" || $inputstr =~ ^[[:space:]]*$ ]] && print -rs -- ${inputstr} &>/dev/null
                fi
            fi
            #printart
            #echoti sc
            ;;
        "x"|"y")
            if ! command -v fzf-tmux; then
                echoti cup 0 0
                echo "${tput_el}fzf binary not found, please install it"
                zselect -t 200
                slurp
                return
            fi
            local initialartname="$artname"
            local initialflipartname="$flipartname"
            if [[ $helpactive = "1" ]]; then
                artname="$restoreartname"
                flipartname="$restoreflipartname"
            fi
            tputreset
            sttyresetext
            if [[ $commandkey = "x" ]]; then
                $(printf $histcmd) $statedir/hist/aart.hist 1000 1000
                artnametemp=$(ls $artdir | fzf-tmux --ansi --preview="$bindir/artprint -a {}  --ac \"$artcolor\" --tc $titlecolor --height term --style $style --theme $theme" -p 80%,80%  --preview-window=right,85%)
            else
                $(printf $histcmd) $statedir/hist/bart.hist 1000 1000
                local restoredir=$PWD
                cd $artdir
                local tmpaart=$(getaart)
                local aartheight=$(wc -l "${tmpaart}" | sed -n 's/^[[:space:]]*\([0-9]*\)[[:space:]]*.*$/\1/p')
                artnametemp=$(wc -l * | sed -n '$d;s/^[[:space:]]*'"${aartheight}"'[[:space:]][[:space:]]*\(.*\)$/\1/p' | fzf-tmux --ansi --preview="$bindir/artprint -a {}  --ac \"$artcolor\" --tc $titlecolor --height term --style $style --theme $theme" -p 80%,80%  --preview-window=right,85%)
                cd $restoredir
            fi
            sttyset
            tputset
            artnametemp=$(trimwhitespace "$artnametemp")
            if [[ $artnametemp = "" ]]; then
            elif [[ ! -f "$artdir/$artnametemp" ]]; then
                printf "${tput_cup00}E: No file found for art: $artnametemp\nPress any key to continue..."
                readchar 3
                slurp
            else
                if [[ $commandkey = "x" ]]; then
                    artname="$artnametemp"
                else
                    flipartname="$artnametemp"
                fi
            fi
            prevartname=""
            if ! setartstring; then
            printf "${tput_cup00}W: Height of b art does not match that of a art, try setting b art again.\nPress any key to continue..."
                if [[ $commandkey = "y" ]]; then
                    artname="$initialartname"
                    flipartname="$initialflipartname"
                    setartstring
                fi
                readchar 5
                slurp
            else
                if [[ $artnametemp = "" || ! -f "$artdir/$artnametemp" ]]; then
                    if [[ $helpactive = "1" ]]; then
                        artname="$initialartname"
                        flipartname="$initialflipartname"
                        setartstring
                    fi
                else
                    helpactive="0"
                    [[ $streamclosedinit == "1" ]] && ! [[ $artnametemp == "" || $artnametemp =~ ^[[:space:]]*$ ]] && print -rs -- ${artnametemp} &>/dev/null
                fi
            fi
            #printart
            #echoti sc
            ;;
        "j"|"o")
            jrestoreartname="$artname"
            jrestoreflipartname="$flipartname"
            flipartname=""
            inputchar="$commandkey"
            local modestrlocal=$modestr
            while [[ $inputchar == "$commandkey" ]]; do
                RANDOM="${EPOCHREALTIME#*.}"
                if [[ $commandkey = "j" ]]; then
                    local shuffledart=($artdir/^tarot-*(.Nnoe['REPLY=$RANDOM']))
                else
                    local shuffledart=($artdir/tarot-*(.Nnoe['REPLY=$RANDOM']))
                fi
                for pathname in "$shuffledart[@]"; do
                    if [[ $winchdetected = "1" ]]; then
                        termwidth="$COLUMNS"
                        termheight="$LINES"
                        modestrpos=$(echoti cup $termheight $((termwidth-1)))
                        setmodestr
                        winchdetected="0"
                    fi
                    artname=$(basename "$pathname")
                    prevartname=""
                    setartstring
                    local questionstr="Select this? (c:cancel, $commandkey:next, y:select), name: $artname "
                    printart $questionstr
                    lasttime=""
                    printtime "1"
                    # NOTE: now this pain of overlaying the same string twice is not necessary
                    #printf "${tput_cup00}%s%$((termwidth-${#questionstr}-1))s$tchar\n" "$questionstr" " "
                    readchar "" "$modestrlocal" || break
                    if [[ $inputchar == "y" || $inputchar == "c" || $inputchar == "" ]]; then
                        break
                    fi
                done
            done
            # If response is not 'y', then restore the original state
            if [[ $inputchar != "y" ]]; then
                artname="$jrestoreartname"
                flipartname="$jrestoreflipartname"
                prevartname=""
                setartstring
                printart
                lasttime=""
                printtime "1"
            else
                # NOTE: commented and redundant "if" statement
                # but makes the case we care for clear.
                #if [[ $helpactive = "1" ]]; then
                helpactive="0"
                #fi
            fi
            ;;
        "c")
            if [[ -z $artcolor ]]; then
                artcolor="0"
            elif [[ $artcolor -eq 16 ]]; then
                artcolor=""
            else
                artcolor=$(( (artcolor+1)%16 ))
            fi
            setartstring
            #printart
            ;;
        #"d")
        #    echo "cliwallpaper[$$]: flipartname=$flipartname, lasttime=$lasttime, toggleflipart:$toggleflipart, artname:$artname, flipartht:$flipartht, artht:$artht, artstringht:$artstringht, flipartstringht:$flipartstringht" >> ~/arttime_debug.log
        #    ;;
        "p")
            if [[ $goaltime != "" && $goaldone = "0" || $goaltime = "" && $pausegoals = "1" ]]; then
                sttyresetint
                if [[ $pausegoals = "" || $pausegoals = "0" ]]; then
                    if askforconfirmation "pause goals"; then
                        pausegoals="1"
                        pausestart="$currenttimearray[1]"
                        pausestartstr="$currenttimearray[2]"
                        accumulatedsprinttime=$((currenttimearray[1]-sprintstarttime))
                        goaltime=""
                    fi
                else
                    if askforconfirmation "un-pause goals"; then
                        pauseend=$(strftime '%s')
                        pausedelta=$((pauseend-pausestart))
                        exitpause
                        sprintstarttime="$pauseend"
                        pausegoals="0"
                        goalentry=$goalarraysorted[$goalmaxptreff]
                        goalentryarray=(${(s/;/)goalentry})
                        sprintendtime=$goalentryarray[1]
                    fi
                fi
                sttyset
                echoti civis
            else
                echo "No goals set, so nothing to pause"
                zselect -t 200
                slurp
            fi
            ;;
        "e")
            if [[ ! -z $goal ]]; then
                sttyresetint
                if askforconfirmation "restart previous goal '$goal'"; then
                    goalsprint="1"
                    pausegoals="0"
                    accumulatedsprinttime="0"
                    sprintstarttime=$(strftime '%s')
                    setgoals $sprintstarttime
                fi
                sttyset
                echoti civis
            else
                echo "No goals set, so nothing to restart"
                zselect -t 200
                slurp
            fi
            ;;
        "g")
            inputstr=""
            $pprint && sttyresetint
            if [[ $pprint == false ]]; then
                promptstr=""
                readstr "" ""
                retstatus="$?"
            elif [[ $usereadline == "1" ]]; then
                printf "${tput_cup00}${tput_el}${tput_cnorm}"
                inputstr=$(bash -c 'read -e -p "Enter goal (\"help\" to learn): " retvar; echo $retvar');
                retstatus="0"
            else
                toggleflipart=$(((toggleflipart+1)%2))
                promptstr="Enter goal ('help' to learn):"
                if [[ $streamclosed == "1" ]]; then
                    echoti cup $LINES 0
                    $(printf $histcmd) $statedir/hist/goal.hist 1000 1000
                    local curcontext=emptyselector:::
                    compdef _emptyselector -vared-
                    vared -h -t $TTY -i zlelineprompt -p "%{$tput_cup00$tput_el%}$promptstr " -c inputstr; retstatus="$?"
                    compdef -d _emptyselector -vared-
                    ! [[ $inputstr == "" || $inputstr =~ ^[[:space:]]*$ ]] && print -rs -- ${inputstr} &>/dev/null
                else
                    promptstr="$tput_cup00$promptstr"
                    readstr "" $modestr
                    retstatus="$?"
                fi
            fi
            $pprint && printf "$tput_civis"
            $pprint && sttyset
            if [[ ! -z $inputstr ]]; then
                goal="$inputstr"
                goalsprint="1"
                pausegoals="0"
                accumulatedsprinttime="0"
                sprintstarttime=$(strftime '%s')
                setgoals $sprintstarttime
                if [[ -z $goaltime ]]; then
                    if [[ -z $datehelpstr ]]; then
                        setdatehelpstr
                    fi
                    if command -v less &>/dev/null; then
                        pagernavstr="Press 'q' key to quit this page, scroll keys to scroll till you see [7m(END)[0m."
                        if [[ $streamclosed == "1" ]]; then
                            pagerprintstr="$pagernavstr\n$datehelpstr\n[7m(END)[0m\n"
                            pagerprintstr+=$(printf "~%$((termwidth-2)).s$tchar\n" " " {0..$LINES})
                            pagerprintstr=$(printf "$pagerprintstr")
                            printf "$tput_clear"
                            LESS="" less -R <<<"$pagerprintstr" 2>/dev/null
                        else
                            pagerprintstr=$(printf "$pagernavstr\n$datehelpstr")
                            printf "${tput_clear}${pagerprintstr}\n[7m(END)[0m${modestr}"
                            inputchar=""
                            while readchar && [[ $inputchar != "q" ]]; do :; done
                        fi
                    elif command -v more &>/dev/null; then
                        pagernavstr="Note: 'less' [31mnot found[0m, using 'more'. Press 'q' key to quit this page,\npress 'Enter' to scroll-forward till you see [7m(END)[0m, 'b' to scroll-backwards."
                        pagerprintstr=$(printf "$pagernavstr\n$datehelpstr")
                        if [[ $streamclosed == "1" ]]; then
                            printf "$tput_clear"
                            #more <<<"$pagerprintstr"
                            mkdir -p ~/.cache/arttime
                            printf "$pagerprintstr" >~/.cache/arttime/$UID-$$.morestr
                            more ~/.cache/arttime/$UID-$$.morestr
                            rm ~/.cache/arttime/$UID-$$.morestr
                        else
                            printf "${tput_clear}${pagerprintstr}\n[7m(END)[0m${modestr}"
                            inputchar=""
                            while readchar && [[ $inputchar != "q" ]]; do :; done
                        fi
                    fi
                    echoti civis
                    echoti smcup
                else
                    if [[ $returngoaltime = "loop" && ( $returngoaltimestr = "-" || $returngoaltimestr =~ ^[0-9]+$ ) ]]; then
                        printsprints="1"
                        goalmaxptreff="$((goalmaxptr-1))"
                        goalmaxsprint="$returngoaltimestr"
                    else
                        printsprints="0"
                        goalmaxsprint="1"
                        goalmaxptreff="$goalmaxptr"
                    fi
                    goalentry=$goalarraysorted[$goalmaxptreff]
                    goalentryarray=(${(s/;/)goalentry})
                    sprintendtime=$goalentryarray[1]
                fi
            fi
            ;;
        "f")
            if [[ $hoursfmt = "12" ]]; then
                hoursfmt="24"
            else
                hoursfmt="12"
            fi
            settimeformats
            if [[ $tzshortcurrent != $tzshortinit || $tzlongcurrent != $tzlonginit ]]; then
                timeformat=$tfother
            else
                timeformat=$tflocal
            fi
            starttime=$(strftime $timeformat $starttimearray[1])
            starttimearray=(${(s/|/)starttime})
            if [[ ! -z $goaltime ]]; then
                local tmpgoaltime=$(strftime $timeformat $goaltime)
                local tmpgoaltimearray=(${(s/|/)tmpgoaltime})
                goaltimestr=$tmpgoaltimearray[2]
                local goalentryarray
                local goaltimestrupdated
                for ((i=1;i<=goalmaxptreff;i=i+1)) do
                    #$returngoaltime;$numgoals;$returngoalstatus;$returngoaltimestr;$goal
                    goalentryarray=(${(s/;/)goalarraysorted[$i]})
                    goaltimestrupdated=$(strftime $timeformat $goalentryarray[1])
                    goaltimestrupdated="${goaltimestrupdated#*|}"
                    goalarraysorted[$i]=("$goalentryarray[1];$goalentryarray[2];$goalentryarray[3];$goaltimestrupdated;$goalentryarray[5]")
                done
            fi
            ;;
        "h")
            if [[ $helpactive = "0" ]]; then
                helpactive="1"
                restoreartname="$artname"
                restoreflipartname="$flipartname"
                artname="help"
                flipartname=""
            else
                helpactive="0"
                artname="$restoreartname"
                flipartname="$restoreflipartname"
            fi
            prevartname=""
            setartstring
            local setartstringerr="$?"
            printart;
            lasttime="";
            printtime "1"
            if [[ $setartstringerr = "1" ]]; then
                printf "${tput_cup00}W: Height of b art does not match that of a art, try setting b art again.\nPress any key to continue..."
                readchar 5
                slurp
            fi
            ;;
        "i"|"I")
            local tmpcurtime=$(strftime '%s')
            local infostring=$(strftime "%a %b %d, %Y $hms %Z")
            infostring+=" ($tzlongcurrent)"
            infostring+="$(strftime ' | week %W')"
            infostring+=" | ID: $$ "
            if [[ $helpactive = "1" ]]; then
                if [[ $restoreflipartname != "" ]]; then
                    infostring+=" \narts: a) $restoreartname, b) $restoreflipartname "
                else
                    infostring+=" \narts: a) $restoreartname, b) none "
                fi
            else
                if [[ $flipartname != "" ]]; then
                    infostring+=" \narts: a) $artname, b) $flipartname "
                else
                    infostring+=" \narts: a) $artname, b) none "
                fi
            fi
            if [[ $goaltime != "" && $goaldone = "0" || $goaltime = "" && $pausegoals = "1" ]]; then
                infostring+="\nGoals: "
                # NOTE: first query the last entry to find width of days 
                local goalentryarray=(${(s/;/)goalarraysorted[$goalmaxptreff]})
                local goaltimeunix="$goalentryarray[1]"
                local timepending=$((goaltimeunix-currenttimearray[1]))
                timepending=$((timepending/86400))
                if [[ $timepending != "0" ]]; then
                    local datewidth="${#timepending}"
                else
                    local datewidth="0"
                fi
                for ((i=1;i<=goalmaxptr;i=i+1)) do
                    #$returngoaltime;$numgoals;$returngoalstatus;$returngoaltimestr;$goal
                    goalentryarray=(${(s/;/)goalarraysorted[$i]})
                    local goalnum="$goalentryarray[2]"
                    local goalstatus="$goalentryarray[3]"
                    local goalstr="$goalentryarray[5]"
                    if [[ $goalstr != "loop" ]]; then
                        if ((i>=goalptr && pausegoals==1)); then
                            goaltimeunix=$((currenttimearray[1]+goalentryarray[1]-pausestart))
                            local goaltimestr=$(strftime "%b %d, $hms" $goaltimeunix)
                            timepending=$(formattimedelta $((goaltimeunix-currenttimearray[1])) $datewidth "1")
                        else
                            goaltimeunix="$goalentryarray[1]"
                            local goaltimestr=$(strftime "%b %d, $hms" $goaltimeunix)
                            timepending=$(formattimedelta $((goaltimeunix-currenttimearray[1])) $datewidth "0")
                        fi
                        if ((i>goalptr && pausegoals==1)); then
                            infostring+="\n    $i. est.: $goaltimestr ($timepending), goal: $goalstr "
                        elif ((i==goalptr && pausegoals==1)); then
                            infostring+="\n  > $i. [31mest.: $goaltimestr ($timepending), goal: $goalstr [0m"
                        elif [[ $i = $goalptr ]]; then
                            infostring+="\n  > $i. [31mtime: $goaltimestr ($timepending), goal: $goalstr [0m"
                        else
                            infostring+="\n    $i. time: $goaltimestr ($timepending), goal: $goalstr "
                        fi
                    else
                        if [[ $goalmaxsprint != "-" ]]; then
                            infostring+="\n       sprint $goalsprint/$goalmaxsprint "
                        else
                            infostring+="\n       sprint $goalsprint/infinity "
                        fi
                    fi
                done
            fi
            if [[ $commandkey = "I" ]] || (((termheight <= (goalmaxptr+4)) && goaldone==0 )); then
                if command -v less &>/dev/null; then
                    pagernavstr="Press 'q' key to quit this page, scroll keys to scroll till you see [7m(END)[0m."
                    if [[ $streamclosed == "1" ]]; then
                        pagerprintstr="$pagernavstr\n$infostring\n[7m(END)[0m\n"
                        pagerprintstr+=$(printf "~%$((termwidth-2)).s$tchar\n" " " {0..$LINES})
                        pagerprintstr=$(printf "$pagerprintstr")
                        printf "$tput_clear"
                        LESS="" less -R <<<"$pagerprintstr" 2>/dev/null
                    else
                        pagerprintstr=$(printf "$pagernavstr\n$infostring")
                        printf "${tput_clear}${pagerprintstr}\n[7m(END)[0m${modestr}"
                        inputchar=""
                        while readchar && [[ $inputchar != "q" ]]; do :; done
                    fi
                elif command -v more &>/dev/null; then
                    pagernavstr="Note: 'less' [31mnot found[0m, using 'more'. Press 'q' key to quit this page,\npress 'Enter' to scroll-forward till you see [7m(END)[0m, 'b' to scroll-backwards."
                    pagerprintstr=$(printf "$pagernavstr\n$infostring")
                    if [[ $streamclosed == "1" ]]; then
                        printf "$tput_clear"
                        #more <<<"$pagerprintstr"
                        mkdir -p ~/.cache/arttime
                        printf "$pagerprintstr" >~/.cache/arttime/$UID-$$.morestr
                        more ~/.cache/arttime/$UID-$$.morestr
                        rm ~/.cache/arttime/$UID-$$.morestr
                    else
                        printf "${tput_clear}${pagerprintstr}\n[7m(END)[0m${modestr}"
                        inputchar=""
                        while readchar && [[ $inputchar != "q" ]]; do :; done
                    fi
                fi
                echoti civis
                echoti smcup
            else
                infostring+="\nPress any key to continue "
                printf "$infostring"
                readchar 5
            fi
#tput -S <<HERE
#            cup 1 0
#            el
#HERE
            slurp
            ;;
        "k")
            if [[ $streamclosed == "1" ]]; then
                sttyresetint
                printf "$tput_smcup"
                printf "$tput_clear$modestr$tput_cup00"
                $(printf $histcmd) $statedir/hist/keypoem.hist 1000 1000
                keyfileselector
                if [[ $inputstr != "" ]]; then
                    keyfilefeed "$inputstr"
                    local returnval="$?"
                    if [[ $returnval != "0" ]]; then
                        if [[ $returnval == "1" ]]; then
                            printf "E: File not found $inputstr\nPress any key to continue..."
                        else
                            printf "E: File is neither regular nor fifo $inputstr\nPress any key to continue..."
                        fi
                        readchar 3
                        slurp
                    else
                        [[ $streamclosedinit == "1" ]] && ! [[ $inputstr == "" || $inputstr =~ ^[[:space:]]*$ ]] && print -rs -- ${inputstr} &>/dev/null
                        streamclosed="0"
                        setmodestr
                    fi
                fi
                sttyset
                tputset
            else
                sttyresetint
                if askforconfirmation "exit SCRIPT mode"; then
                    trap "intdone=1" INT
                    intdone="0"
                    kill -s INT 0 &>/dev/null
                    while [[ $intdone == "0" ]]; do zselect -t 10; done
                    unset intdone
                    while read -r -s -k1 -t0 inputchar ; do : ; done
                    streamclosed="1"
                    exec {streamfd}>&-
                    unset streamfd
                    exec {streamfd}>&1
                    sttyset
                    setmodestr
                    handoff="1"
                    trap "trapint_blocking" INT
                fi
                sttyset
                echoti civis
            fi
            ;;
        "l")
            if [[ $goaltime != "" || $pausegoals = "1" ]]; then
                sttyresetint
                if askforconfirmation "clear goals"; then
                    goaltime=""
                    pausegoals="0"
                fi
                sttyset
                echoti civis
            else
                echo "No active goal to clear"
                zselect -t 200
                slurp
            fi
            ;;
        "m")
            inputstr=""
            $pprint && sttyresetint
            if [[ $pprint == false ]]; then
                promptstr=""
                readstr "" ""
                retstatus="$?"
            elif [[ $usereadline == "1" ]]; then
                printf "${tput_cup00}${tput_el}${tput_cnorm}"
                inputstr=$(bash -c 'read -e -p "Enter title message (\"orig\" to reset): " retvar; echo $retvar');
                retstatus="0"
            else
                toggleflipart=$(((toggleflipart+1)%2))
                promptstr="Enter title message ('orig' to reset):"
                if [[ $streamclosed == "1" ]]; then
                    echoti cup $LINES 0
                    $(printf $histcmd) $statedir/hist/message.hist 1000 1000
                    local curcontext=emptyselector:::
                    compdef _emptyselector -vared-
                    vared -h -t $TTY -i zlelineprompt -p "%{$tput_cup00$tput_el%}$promptstr " -c inputstr; retstatus="$?"
                    compdef -d _emptyselector -vared-
                    ! [[ $inputstr == "" || $inputstr =~ ^[[:space:]]*$ ]] && print -rs -- ${inputstr} &>/dev/null
                else
                    promptstr="$tput_cup00$promptstr"
                    readstr "" $modestr
                    retstatus="$?"
                fi
            fi
            $pprint && printf "$tput_civis"
            $pprint && sttyset
            if [[ $inputstr = "" || $retstatus != "0" ]]; then
            elif [[ $inputstr = "-" ]]; then
                title=' - '
            elif [[ $inputstr = "orig" ]]; then
                title=""
            else
                title="$inputstr"
            fi
            prevartname=""
            setartstring
            #printart
            ;;
        "r")
            sttyresetint
            if askforconfirmation "reset start time, and goal"; then
                resetstarttime="1"
                goaltime=""
                pausegoals="0"
            fi
            sttyset
            echoti civis
            ;;
        "q")
            sttyresetint
            if askforconfirmation "quit arttime"; then
                sttyresetext
                trap -;
                command -v pkill &>/dev/null && pkill -P $$;
                echoti cup $LINES 0
                printf "\n"
                tputreset;
                if [[ $trapintactive = "1" ]]; then
                    set -e
                    (exit 130)
                else
                    exit 0
                fi
            fi
            echoti civis
            sttyset
            ;;
        #"s")
        #    echoti cup 0 0
        #    echoti el
        #    tempsamples=""
        #    sttyreset
        #    echoti cnorm
        #    if [[ ! -z $updateonminute ]]; then
        #        # XXX: look here
        #        printf "Enter samples per minute (current value = $samples): "
        #    else
        #        printf "Enter samples per seconds (current value = $samples): "
        #    fi
        #    read tempsamples
        #    $sttycmd -echo
        #    $sttycmd -icanon min 0 time 0
        #    echoti civis
        #    if [[ -z $tempsamples || ! $tempsamples =~ ^([1-9]\|[1-9][0-9]+)$ ]]; then
        #        echoti cup 0 0
        #        printf "Error: samples should be an integer > 0"
        #        zselect -t 200
        #    else
        #        samples="$tempsamples"
        #        setsleeptimecenti
        #        #echo "Samples: $samples, sleeptime: $sleeptime, sleeptimecenti: $sleeptimecenti"
        #        #zselect -t 300
        #    fi
        #    ;;
        "t")
            if [[ -z $theme || $theme = "dark" ]]; then
                theme="light"
            else
                theme="dark"
            fi
            setcolors
            setartstring
            #printart
            ;;
        "z")
            if [[ $pprint == false ]]; then
                promptstr=""
                readstr "" ""
                retstatus="$?"
                if [[ $inputstr == "./orig" || $inputstr == "orig" ]]; then
                    inputstr=$tzlonginit
                elif [[ ! -f /usr/share/zoneinfo/$inputstr ]]; then
                    inputstr=""
                fi
            else
                sttyresetint
                $(printf $histcmd) $statedir/hist/zone.hist 1000 1000
                printf "$tput_smcup"
                printf "$tput_clear$modestr$tput_cup00"
                zoneselector
                sttyset
                tputset
            fi
            if [[ ! -z $inputstr ]]; then
                [[ $streamclosedinit == "1" ]] && ! [[ $inputstr == "" || $inputstr =~ ^[[:space:]]*$ ]] && print -rs -- ${inputstr} &>/dev/null
                TZ=$inputstr
                notetimezone
                tzlongcurrent="$tzlong"
                tzshortcurrent="$tzshort"
                if [[ $tzshortcurrent != $tzshortinit || $tzlongcurrent != $tzlonginit ]]; then
                    timeformat=$tfother
                else
                    timeformat=$tflocal
                fi
                starttime=$(strftime $timeformat $starttimearray[1])
                starttimearray=(${(s/|/)starttime})
                if [[ ! -z $goaltime ]]; then
                    local tmpgoaltime=$(strftime $timeformat $goaltime)
                    local tmpgoaltimearray=(${(s/|/)tmpgoaltime})
                    goaltimestr=$tmpgoaltimearray[2]
                    local goalentryarray
                    local goaltimestrupdated
                    for ((i=1;i<=goalmaxptreff;i=i+1)) do
                        #$returngoaltime;$numgoals;$returngoalstatus;$returngoaltimestr;$goal
                        goalentryarray=(${(s/;/)goalarraysorted[$i]})
                        goaltimestrupdated=$(strftime $timeformat $goalentryarray[1])
                        goaltimestrupdated="${goaltimestrupdated#*|}"
                        goalarraysorted[$i]=("$goalentryarray[1];$goalentryarray[2];$goalentryarray[3];$goaltimestrupdated;$goalentryarray[5]")
                    done
                fi
            fi
            ;;
        *)
            commandkeyint=$(printf '%d' "'$commandkey")
            if [[ $streamclosed == "1" ]] || ((commandkeyint != 10 && commandkeyint != 13 && commandkeyint != 45)); then
                    echo "Press 'h' to see which keys do what"
                    zselect -t 200
                    slurp
            fi
            ;;
    esac
}

#usr1detected=""
#function trapusr1detected {
#    usr1detected="1"
#}

function trapusr1_both {
    # NOTE: disable C-z when executing this trap
    trap '' TSTP
#tput -S <<HERE
#    sc
#    cup 0 0
#HERE
    printf "${tput_sc}${tput_cup00}"
    # slurp previous user input
    inputchar="$1"
    if [[ -z $inputchar ]]; then
        #while read -k1 dummy ; do : ; done 
        printf "\r ⌨ ";
        readchar 2
        printf "$inputchar "
    else
        #while read -k1 dummy ; do : ; done 
    fi
    if [[ ! -z "$inputchar" ]]; then
        usr1input_handler $inputchar
    fi
#tput -S <<HERE
#    cup 0 0
#    el
#    rc
#HERE
    printart
    lasttime=""
    printtime "1"
    resetstarttime="0"
    if [[ $nonblocking = "1" ]]; then
        trap "trapstop_nonblocking" TSTP
    else
        trap "trapstop_blocking" TSTP
    fi
}

function arttime_blocking {
    difftime="0"
    hours="0"
    minutes="0"
    seconds="0"
    starttime=$(strftime $timeformat)
    starttimearray=(${(s/|/)starttime})
    printtime "1"
    trap "trapint_blocking" INT
    trap "trapexit_blocking" EXIT TERM HUP QUIT
    #trap "trapusr1_both" USR1
    trap "trapstop_blocking" TSTP
    trap "trapcont_blocking" CONT
    while true; do
        #zselect -t "$sleeptimecenti"
        if [[ $winchdetected = "1" ]]; then
            trapwinch
        fi
        epochtimereal=$EPOCHREALTIME
        epochtimerealarray=("${(@s/./)epochtimereal}")
        timetoepoch=$((1.0 - 0.$epochtimerealarray[2] + 0.01))
        if [[ $streamclosed == "1" ]]; then
            read -r -s -t $timetoepoch -k1 tmpusrinput; retstatus="$?"
        else
            ERRNO=0
            sysread -s1 -t $timetoepoch -i$streamfd tmpusrinput; retstatus=$?; reterrno=$ERRNO
            case "$retstatus" in
                "0"|"4")
                    [[ $tempttychar != "p" ]] && read -r -s -k1 -t0 tempttychar
                    if [[ $tempttychar == "p" ]]; then
                        tempttychar=""
                        printf "$tput_sc$modestrpos$(echoti cub 6)PAUSED$tput_rc"
                        trap "tstpdone=1" TSTP
                        trap "contdone=1" CONT
                        tstpdone="0"
                        kill -TSTP 0 &>/dev/null
                        while [[ $tstpdone == "0" ]]; do zselect -t 10; done
                        unset tstpdone
                        while [[ $tempttychar != "p" ]]; do read -r -s -k1 tempttychar; done
                        printf "$tput_sc$modestr$tput_rc"
                        contdone="0"
                        kill -CONT 0 &>/dev/null
                        while [[ $contdone == "0" ]]; do zselect -t 10; done
                        unset contdone
                        trap "trapstop_blocking" TSTP
                        trap "trapcont_blocking" CONT
                        tempttychar=""
                    fi
                    ;;
                *)
                    trap "intdone=1" INT
                    intdone="0"
                    kill -s INT 0 &>/dev/null
                    while [[ $intdone == "0" ]]; do zselect -t 10; done
                    unset intdone
                    while read -r -s -k1 -t0 inputchar ; do : ; done
                    streamclosed="1"
                    exec {streamfd}>&-
                    unset streamfd
                    exec {streamfd}>&1
                    sttyset
                    setmodestr
                    handoff="1"
                    trap "trapint_blocking" INT
                    ;;
            esac
            [[ $tmpusrinput == '-' ]] && retstatus="1"
        fi
        if [[ $retstatus = "0" ]]; then
            trapusr1_both "$tmpusrinput"
        fi
        #if [[ -z $artcolor ]]; then
        #    artcolor="0"
        #elif [[ $artcolor -eq 16 ]]; then
        #    artcolor=""
        #else
        #    artcolor=$(( (artcolor+1)%16 ))
        #fi
        #setartstring
        if [[ $winchdetected = "1" ]]; then
            trapwinch
        else
            #printart
            printtime
        fi
    done
}


function arttime_nonblocking {
    difftime="0"
    hours="0"
    minutes="0"
    seconds="0"
    starttime=$(strftime $timeformat)
    starttimearray=(${(s/|/)starttime})
    printtime
    #trap "trapusr1_both" USR1
    trap "trapcont_nonblocking" CONT
    trap "trapstop_nonblocking" TSTP
    while true; do
        #ARGV0="arttimesleep" sleep $sleeptime &
        zselect -t $sleeptimecenti &
        sleeppid="$!"
        trap "trapint_nonblocking $sleeppid" INT QUIT
        trap "trapexit_nonblocking $sleeppid" EXIT TERM HUP
        wait $sleeppid
        printtime
    done
}

winchdetected="0"

function setwinch {
    winchdetected="1"
}

function trapwinch {
    winchdetected="0"
    if [[ ! -z $TMUX ]]; then
        ignorewinch=$(tmux show-options -vp -t $TMUX_PANE @arttimeterm-ignorewinch 2>/dev/null)
        if [[ "$ignorewinch" != "1" ]]; then
            if [[ ! "$termwidth" -eq "$COLUMNS" || ! "$termheight" -eq "$LINES"  ]]; then
                termwidth="$COLUMNS"
                termheight="$LINES"
                modestrpos=$(echoti cup $termheight $((termwidth-1)))
                setmodestr
                printf "$tput_clear"; prevartname=""; setartstring; printart; lasttime=""; printtime "1"
            fi
        fi
    else
        if [[ ! "$termwidth" -eq "$COLUMNS" || ! "$termheight" -eq "$LINES"  ]]; then
            termwidth="$COLUMNS"
            termheight="$LINES"
            modestrpos=$(echoti cup $termheight $((termwidth-1)))
            setmodestr
            printf "$tput_clear"; prevartname=""; setartstring; printart; lasttime=""; printtime "1"
        fi
    fi
    if [[ $winchdetected = "1" ]]; then
        trapwinch
    fi
}

tputset
printart
trap 'setwinch' WINCH
if [[ $nonblocking = "1" ]]; then
    arttime_nonblocking
else
    arttime_blocking
fi
tputreset
sttyresetext
