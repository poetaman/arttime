![](https://img.shields.io/badge/Coded%20By%20Human-100%25-brightgreen)

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://user-images.githubusercontent.com/71736629/193433608-82c23055-3556-40e4-b98f-ab4c47c9460c.png">
  <img alt="Representative screenshot of arttime" src="https://user-images.githubusercontent.com/71736629/193433617-c3c683ff-ea4a-4cc2-91f6-e8ffeea18ac5.png">
</picture>

Contents
=================

* [Contents](#contents)
* [arttime](#arttime)
   * [Purpose/features](#purposefeatures)
* [Call for artists](#call-for-artists)
   * [What does and doesn't constitute text art?](#what-does-and-doesnt-constitute-text-art)
* [Screenshots](#screenshots)
* [Installation](#installation)
   * [Try arttime in docker?](#try-arttime-in-docker)
* [Troubleshooting](#troubleshooting)
* [Acknowledgements](#acknowledgements)
<!-- Created by https://github.com/ekalinin/github-markdown-toc -->


# arttime
Beauty of text-art meets functionality of a feature-rich clock / timer / pattern-based time manager in terminal. In addition to its functional/productivity features, ``arttime`` brings curated text-art to otherwise artless terminal emulators of starving developers and other users who can use terminal. It is a cross-platform application with native notifications/sounds that runs well on macOS, Linux, BSD Unixes, and Windows WSL.

Artime is rooted in Unix philosophy. You can also feed keystrokes into it from a file, pipe, string or unrelated process instead of just typing them; control gets cleanly transferred to your keyboard when the respective file, pipe, or string ends.

## Purpose/features
- Bring curated text/ascii art to artless terminals, currently 500+ high-quality ASCII, ANSI, PETSCII, Unicode text art to choose from
- Provide a feature-rich alarm timer/time manager for commandline.
  - Set multiple timers, supports specifying delta in time (like ``1h 30m`` from now) or absoulte time (like ``Dec 22 2:45PM EST``).
  - Configurable pattern-based time management: Set a repeating pattern of times to get notifications at. This makes [Pomodoro Technique](https://en.wikipedia.org/wiki/Pomodoro_Technique) just one of billions of patterns possible for time management, and makes you set a pattern that works for you. Entire time management program can be paused+delayed and un-paused by pressing a key (``p``). Note: for now even absolute goals like ``1PM`` get delayed, in future users will be able to override that. 
  - Or just loop forever or N number of times over a set of timers. Example: get a notification every day at 8AM; 12PM; 5PM.
  - Show deltas in time which are hard to track: 1) time since arttime started, 2) time pending for upcoming timer (press ``i`` to see all timers), 3) time passed since last timer expired.
  - Interactively switch time zones.
  - Fully configurable text-based progress bar shows what percentage of the timer is complete/pending
  - History saves last 1000 timers/time management programs
- Native desktop notifications for timer, notification identifies the instance of arttime it came from
- Provide users with 1 line of text under art to share their mind, like on a thought board
- Support animated text art: flip-flop between two related ascii arts every second
- Support productivity: mindful suspension (``Ctrl-z``) and continuation (``fg``). Doesn't occupy terminal screen or consume power while suspended, but still shows correct elapsed time when continued.
- Provide a publishing platform for text artists (text art is meant for terminals, not museums)
- Works on macOS out of the box. No need to install homebrew, developer tools. Zero dependencies!
- Works on other Unixes like Linux/BSD with only zsh as the dependency
- For consistent art & message display in multiple applications, a script ``artprint`` is also available in the same directory as ``arttime``.
- Multiple ways to select text art: 1) random; 2) by name (with completion hints); 3) via [fzf](https://github.com/junegunn/fzf), if it is installed (not required though)
- Away timer: start arttime or reset (press ``r``) arttime's timers before putting computer to sleep or moving away from screen. Be greeted by a beautiful text art, and know how much time you spent away from computer when you get back to computer again. And no, it doesn't consume power when computer is sleeping.
- Feed keystrokes from anywhere: Unlike most interactive applications, arttime provides first-class support for feeding keystrokes from all imaginable sources: string, file, pipe, or unrelated process. This enables many exciting features. To begin, press ``k`` from within arttime to see many pre-installed examples, and read more details in [arttime wiki: feed keys from anywhere](https://github.com/poetaman/arttime/wiki#feed-keystrokes-from-anywhere).
- Expressive timers: Associate different art, color, and message with your timers. This makes your timers more expressive, and personalized. To check preinstalled examples: press ``k``, type ``timer`` and press ``Tab``.
- History, completion, globbing, search: All prompts store 1000 unique previous values in history, just press ``Up``/``Down`` arrows on the prompt to scroll history. More keybindings listed in arttime wiki: [Modes and keybindings](https://github.com/poetaman/arttime/wiki#modes-and-keybindings)
- Storyboards: Quickly create an art [storyboard](https://en.wikipedia.org/wiki/Storyboard) by sequencing art from arttime's collection. To check preinstalled examples: press ``k``, type ``story`` (or ``learn``) and press ``Tab``.
- Best for privacy: Unlike commercial apps that connect to internet, track your activity and send/sell your data, arttime runs solely on your computer. It does not connect to internet, does not look at or track your data, and does not send any data outside your computer. Unlike binaries, arttime is a human-readable text file that can always be reviewed.
- Secure: Unlike most other interactive software projects which rely on multiple 3rd-party packages that are hard to audit, this project relies on what comes pre-installed on Unix-style operating systems like macOS/Linux. Optional features rely on packages which are standard for respective OS. This makes it much more secure compared to other software out there.

Note: arttime is tuned to consume less power and memory. It uses only about ~0.1% of CPU time while running, and only around 6MB of RAM in steady state on my machine.

# Call for artists
Much good ascii art was created during web 1.0, but the artform declined after that. arttime intends to be a platform/repository for hosting/displaying ascii/ansi art, as ascii/ansi does have its natural home on a terminal (instead of a wall of an arts museum). In doing so it also encourages sharing art, a not so common drift with the arrival of NFTs (where monkey stickers are being priced at hundreds of thousands of US dollars). The repository already provides a curated library of good ascii art (mixed at times with computer-generated text version of digital images). If you are a text artist, or find a treasure trove of libre ascii/text art, please feel free to leave a link to the work in [arttime discussions](https://github.com/poetaman/arttime/discussions).

## What does and doesn't constitute text art?
   - Does: Manually typed/composed text in some text editor/program, this is most text art in the collection.
   - Does: Output of a manually coded algorithm (not AI) that generates text art. Check the work of artist with initials ``D.H.`` in this repository, example: [gravity (D.H. 1992)](https://github.com/poetaman/arttime/blob/main/share/arttime/textart/gravity), [concentricfield (D.H. 1991)](https://github.com/poetaman/arttime/blob/main/share/arttime/textart/concentricfield), [globe (D.H. 1991)](https://github.com/poetaman/arttime/blob/main/share/arttime/textart/globe).
   - Doesn't: Output of a program that converts digital image (jpeg, etc) to a similar looking text version. Such art does sparingly exist in the collection of this repository, though it is only to show how arttime can be used. It is not a priority for curation, unless there is a strong reason.
   - Doesn't: AI generated "text art", its not a priority for curation here.

# Screenshots
1. Default start page. ``$ arttime``
<img width="1016" alt="Screenshot 2023-02-09 at 1 19 25 PM" src="https://user-images.githubusercontent.com/71736629/217941620-4fd18160-4364-4f08-aa8d-936bb2bf7743.png">

2. Default art. ``$ arttime`` then press ``h``, or ``arttime --nolearn``
<img width="1019" alt="Screen Shot 2022-05-21 at 10 17 59 PM" src="https://user-images.githubusercontent.com/71736629/169680963-0cd5027d-5e21-4d3e-8eda-c21939f5d89d.png">

3. Animated art clock: ``$ arttime --nolearn -a military -b military2 -t "Say no to wars, yes to peace" --ac 4``. Note: animation works only if a-art and b-art file height is same, which it is for many related arts.
![arttime_animation](https://user-images.githubusercontent.com/71736629/169681999-65ad339a-d1ea-42cb-b2f9-093dd9a2a1be.gif)

4. Another animated art clock. ``$ arttime --nolearn -a kissingcats -b kissingcats2 -t "Since we found love within, we don't bother rats - Wise cats" --ac 3``. Note: transparency is an artifact of one's terminal emulator application.
![kissingcats1](https://user-images.githubusercontent.com/71736629/169914495-a99f7633-d77e-4e7a-84d0-be64e281de92.gif)

5. Timer and notification. ``arttime --nolearn -a colorowl2 -b colorowl3 -t "We don't sleep at night - Owls"`` then press ``g`` to enter a goal time like ``10s`` for 10 seconds, ``1h 6s`` for 1 hour 6 seconds. Check more formats supported by reading help documentation ``$ arttime -h``, or even better by passing 'help' as goal time while arttime is running (press ``g``, enter ``help``). This is an example of multi-colored art too.
![ColorOwl3](https://user-images.githubusercontent.com/71736629/177451474-4d868e17-d577-4500-adaa-f00c49bc78b7.gif)

6. Multiple timers, repeating time management program like [Pomodoro Technique](https://en.wikipedia.org/wiki/Pomodoro_Technique). a) From the commandline, run: ``arttime --nolearn -a magic -b magic2 -g "25m;30m;55m;1h;1h25m;1h30m;1h55m;2h25m;loop2"`` or b) From within application, run: ``arttime --nolearn -a magic -b magic2``, then press ``g`` and enter ``25m;30m;55m;1h;1h25m;1h30m;1h55m;2h25m;loop2``. Change ``loop2`` to ``loop4`` or ``sprint4`` for approximately 10 hour work day. Progressbar shows that we are 20% done with our program.
<img width="1015" alt="Screen Shot 2022-07-05 at 10 01 43 PM" src="https://user-images.githubusercontent.com/71736629/177472467-34c93118-65f3-434a-bbe2-306fe1e5e4ac.png">

7. Expressive timers: The following GIF shows some preinstalled expressive timers. Insipired from [pomodoro](https://en.wikipedia.org/wiki/Pomodoro_Technique) (tomato) technique, some of them are named after other fruits. It's very simple to create your own expressive timer or time management program. Start arttime, press ``k``, type ``t`` followed by ``Tab`` to see all the preinstalled timers.

![arttime_expressivetimers5](https://user-images.githubusercontent.com/71736629/220801403-027556fa-00ba-44ac-bbd5-977a678c8aba.gif)

8. A 24-bit color art example ``$ arttime --nolearn -a obama2 -t "Yes we can, yes we can drink better teas"``.  Note: terminal emulator must support 24-bit RGB colors.
<img width="1019" alt="Screen Shot 2022-05-22 at 12 14 22 AM" src="https://user-images.githubusercontent.com/71736629/169683524-a63a5a9c-aa66-4ecd-a036-97b8bfa0f243.png">

9. Random art selection. ``$ arttime --nolearn`` then press and hold ``j`` for a few seconds. After some time arttime will settle on some randomly selected art. Press ``y`` to select it, or ``c`` to cancel. Click on mp4 video below to play it (Note: following video playback works in Safari on macOS, but for some reason not in Safari on iPhone 8, perhaps because of a github.com bug?).

https://user-images.githubusercontent.com/71736629/206934934-25b4632f-ee56-421a-a120-1c44bcf64ac4.mp4

10. And more... For more information read help documentation ``$ arttime -h``, and start in learn mode (default) to understand keybindings ``$ arttime``.

# Installation

<!--
There are three installation methods: 1) Simple, 2) Manual, 3) Package manager. As the name suggests, 1) Simple method should be used by users who want a simple install experience (also no password required), 2) Manual method is for users who are fluent in using terminal and want the most customize install experience (check any optional dependencies at [arttime dependencies](https://github.com/poetaman/arttime/wiki#dependencies)), 3) Package manager method automates dependency installation, though mostly requires admin password to install.
-->

There are three installation methods: 1) Simple, 2) Manual. As the name suggests, 1) Simple method should be used by users who want a simple install experience (also no password required), 2) Manual method is for users who are fluent in using terminal and want the most customize install experience (check any optional dependencies at [arttime dependencies](https://github.com/poetaman/arttime/wiki#dependencies).

---

1) Simple install method:
- Open some "Terminal" application on your computer
- Copy following line from start to end. *(Note: hovering your computer mouse near the right end of the following box will show a button inside the box, clicking it will copy the line for you. Or else you will have to press and hold to the mouse to scroll and select the entire line from beginning to end, and copy it.)*
```
zsh -c '{url="https://gist.githubusercontent.com/poetaman/bdc598ee607e9767fe33da50e993c650/raw/8487de3cf4cf4a7feff5d3a0d97defad95164eb3/arttime_online_installer.sh"; zsh -c "$(curl -fsSL $url || wget -qO- $url)"}'
```
- Paste the above copied line in "Terminal" application, and press ``Enter``
- Installer will print any further action you need to take before running it.
- Type ``arttime`` and press ``Enter``, arttime will launch!

Note: The simple install method installs arttime under ``~/.local``, which is a standard install directory for local installation. It also clones the arttime github repository under ``~/packages/github/poetaman``.

---

2) Manual install method:
- Clone the github repository somewhere on your machine
- ``cd`` to that directory
- Run ``./install.sh -h`` to see the options for installation
- Run ``./install.sh`` with your options of choice
- Rest is similar to the last 2 steps of simple installer

<!--
---
3) Package manager method:
Arttime might also be available as a package or build receipe in your favorite system distribution.

[![Packaging status](https://repology.org/badge/vertical-allrepos/arttime.svg)](https://repology.org/project/arttime/versions)

If you don't see your favorite distribution and would like to volunteer then get in touch. Useful links: [arttime dependencies](https://github.com/poetaman/arttime/wiki#dependencies), [arttime discussions](https://github.com/poetaman/arttime/discussions), [@ehaupt](https://github.com/ehaupt)'s [FreeBSD PR](https://github.com/poetaman/arttime/pull/25)/[FreeBSD port](https://github.com/freebsd/freebsd-ports/commit/7f2f0cc69b9348a6bfcbdbeee5793616628307b4)/[FreeBSD art](https://github.com/poetaman/arttime/pull/25/commits/943fa08cffaa16a59a9aefbfd432467afc65b1c4). Once you have added a package, open a pull request with some representative art like [FreeBSD mascot](https://github.com/poetaman/arttime/pull/25/commits/943fa08cffaa16a59a9aefbfd432467afc65b1c4) to get representation for your favorite distribution/OS (mascots are preferred over logos).
-->

## Try arttime in docker?
Docker™ being a containerized environment can be a preferred way of trying applications for some geeks. With docker already installed you can give arttime a quick try in a docker container, ***though without arttime's sounds/notifications***. Copy-Paste-Enter the following command in a terminal application after starting [Docker Desktop](https://www.docker.com) on your computer. Note: arttime, its committers or artists don't endorse docker™ in any form or manner. It's presented here only for geeks who know what they are doing and prefer to try it in a container before installing; for everybody else its recommended to jump directly to [Installation](#installation).

Note to docker geeks: arttime will start in UTC timezone unless you have environment variable TZ set to a preferred timezone before running the following command. For a normal [installation](#installation) (not docker), arttime automatically starts in users timezone. There is no clean and portable docker interface to inherit host timezone. You can change the timezone from within arttime, after it launches, by pressing ``z`` and following the instructions (e.g.: California time can be set by entering ``US/Pacific`` [tab based auto-completion hints are provided] after pressing ``z``).
```
docker run -e TERM -e LC_ALL=C.UTF-8 -e TZ -it --rm zshusers/zsh:5.8 zsh -c '
  export SHELL=$(command -v zsh)
  apt update
  apt install -y curl less
  curl -fsSL https://gist.githubusercontent.com/poetaman/bdc598ee607e9767fe33da50e993c650/raw/8487de3cf4cf4a7feff5d3a0d97defad95164eb3/arttime_online_installer.sh | TERM=xterm-256color zsh
  TERM=xterm-256color ~/.local/bin/arttime
  echo "Check more at https://github.com/poetaman/arttime"'
```

# Troubleshooting
- Some art does not render correctly?
  - If the problem is that some arts are centered while others are not, it is because your locale does not have UTF-8 in it. For instance look at the docker [command](https://github.com/poetaman/arttime#try-arttime-in-docker) on this same page. You would require a setting like ``LC_ALL=C.UTF-8``. Unfortunately the same string might not work as there is no standard naming convention (it could be named ``en_US.UTF-8`` instead of ``C.UTF-8`` among other possibilities). Web search is the only way to figure the exact name of UTF-8 locale.
  - This is mostly because your terminal application does not support 24-bit true color (like macOS's builtin [Terminal.app](https://en.wikipedia.org/wiki/Terminal_(macOS))). Some suggestions: 1. easiest for macOS: [iTerm2](https://iterm2.com), 2. for multiple  OSes: [Alacritty](https://alacritty.org), [WezTerm](https://wezfurlong.org/wezterm/), [Kitty](https://sw.kovidgoyal.net/kitty/) etc. Check the list maintained [here](https://gist.github.com/sindresorhus/bed863fb8bedf023b833c88c322e44f9#now-supporting-truecolour) to know more terminals that support true colors.
  - Another possibility is your system does not have fonts for some Unicode characters. Some of the above terminal emulators come with builtin fonts for missing characters, or on-the-fly find missing characters from fonts installed on your system. For that to work, make sure to install at least one font on your system that has a large set of Unicode characters like: [box drawing](https://en.wikipedia.org/wiki/Box_Drawing), [braille](https://en.wikipedia.org/wiki/Braille_Patterns), [legacy computing](https://en.wikipedia.org/wiki/Symbols_for_Legacy_Computing). 
  - Yet another possibility is that the colorscheme that you have selected in your terminal emulator is not good enough. Most of the art in the repository looks good on a dark background, at the very least try a dark background. Depending on what terminal emulator you use, colorscheme of arttime can be changed on-the-fly too (this is simple to do in [iTerm2](https://iterm2.com)). For instance check [iterm2colorschemes](https://iterm2colorschemes.com) on how to install hundreds of colorschemes.
- No desktop notification?
  - Currently macOS, Linux, BSD Unixes, and Windows WSL have been tested. No notification means you need to install a dependency, which varies by OS and Desktop Environment (check [arttime dependencies](https://github.com/poetaman/arttime/wiki#dependencies)). Pull requests for other OSes will be considered.
- No notification sound on Linux/BSD Unix?
  - Sounds on Linux/BSD Unixes are played using whichever sound server system daemon is up and running. Currently only [PulseAudio](https://en.wikipedia.org/wiki/PulseAudio)'s and [PipeWire](https://pipewire.org) are checked. If either is up and running it is directly used (using its native interface), or arttime fallbacks to [vorbis-tool](https://en.wikipedia.org/wiki/Vorbis)'s ``ogg123`` to play sounds. In future more sound servers can be natively supported, but it is always recommended to have [vorbis-tool](https://en.wikipedia.org/wiki/Vorbis) installed as a fallback mechanism for playing sounds.
- Notifications for arttime do not stay for long time on screen?
  - macOS: This setting cannot be controlled by arttime. You will have to do this one time change on your computer: Open System Preferences > Select Notifications & Focus > Scroll to Script Editor > Change "Script editor alert style" to "Alerts". Make sure "Allow Notifications" is selected. Additionally check the combination of boxes based on your preferences. Also change the focus settings as described in next bullet point.
  - Windows WSL: This is a current limitation of the API to Windows notifications, might change in future.
- Notification don't always appear on macOS, example: during a Zoom call?
  - If notifications sometime appear and sometime do not, this is because of macOS "Focus"/"Do not disturb" settings. You will have to do this one time change on your computer: Open System Preferences > Select Notifications & Focus > Select Focus tab > Choose profile "Do not disturb" > In "Allowed notifications from" box select "Apps" tab then press + (i.e. plus) > Search and select "Script Editor" > Press Add. You might have to repeat this process for all focus profiles you use in addition to "Do not disturb".
- Launchtime is slower?
  - This could be mostly because file ``/etc/localtime`` on your system is not a symbolic (soft) link, and hence arttime needs to spend some time finding the long form of your current timezone. Workaround: ``sudo rm /etc/localtime && ln -s /usr/share/<Area>/<Location> /etc/localtime``. Here ``<Area>/<Location>`` should be the appropriate timezone. Check [Names_of_time_zones](https://en.wikipedia.org/wiki/Tz_database#Names_of_time_zones). arttime prints a warning upon launch if this ``/etc/localtime`` is not a symbolic link.

# Acknowledgements
1. text artists: mostly great text artists of web 1.0 era like [jgs (Joann Stark)](https://github.com/oldcompcz/jgs), et al.
2. [ascii-image-converter](https://github.com/TheZoraiz/ascii-image-converter): So far the best digital image to colored text converter
3. [aewan](http://aewan.sourceforge.net): free ascii text coloring tool. Project seems stalled, but works. Tested on Linux VM running on aarch64 Macbook.
