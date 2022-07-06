Contents
=================

* [Contents](#contents)
* [arttime](#arttime)
   * [Purpose/features](#purposefeatures)
* [Call for artists](#call-for-artists)
   * [What does and doesn't constitute text art?](#what-does-and-doesnt-constitute-text-art)
* [Screenshots](#screenshots)
* [Installation](#installation)
* [Troubleshooting](#troubleshooting)
* [Acknowledgements](#acknowledgements)
<!-- Created by https://github.com/ekalinin/github-markdown-toc -->


# arttime
🧜🏼‍♀️ Beauty of text art meets functionality of a feature-rich clock / timer / pattern-based time manager ⏰. ``arttime`` brings curated text-art to otherwise artless terminal emulators of starving developers and other users who can use terminal.

## Purpose/features
- Bring curated text/ascii art to artless terminals, currently 300+ high-quality text art to choose from
- Provide a feature-rich alarm timer/time manager for commandline.
  - Set multiple timers, supports specifying delta in time (like ``1h 30m`` from now) or absoulte time (like ``Dec 22 2:45PM EST``).
  - Configurable pattern-based time management: Set a repeating pattern of times to get notifications at. This makes [Pomodoro Technique](https://en.wikipedia.org/wiki/Pomodoro_Technique) just one of billions of patterns possible for time management, and makes you set a pattern that works for you. Entire time management program can be paused+delayed and un-paused by pressing a key (``p``). Note: for now even absolute goals like ``1PM`` get delayed, in future users will be able to override that. 
  - Or just loop forever or N number of times over a set of timers. Example: get a notification every day at 8AM; 12PM; 5PM.
  - Shows time passed since a timer expired or times pending to for every timer (press ``i`` after setting multiple goals)
  - Always shows some delta in time which is hard to track: 1) time since arttime started, 2) time pending for next timer, 3) time passed since last timer expired.
  - Interactively switch time zones.
  - A configurable text-based progress bar shows what percentage of the timer is complete/pending. Example: >>>>------ (--style 0) ■■■■□□□□□□ (--style 1)
- Native desktop notifications for timer, notification identifies the instance of arttime it came from
- Provide users with 1 line of text under art to share their mind, display their activism
- Support animated text art: flip-flop between two related ascii arts every second
- Support 24-bit RGB text art produced from jpeg, etc stickers/images/photographs
- Support productivity: mindful suspension (``Ctrl-z``) and continuation (``fg``). Doesn't occupy terminal screen or consume power while suspended, but still shows correct elapsed time when continued.
- Random art selection makes it a fun game, or serious tarot-style reading for believers in The Random
- Provide a publishing platform for text/ascii art artists (text art is meant for terminals, not museums)
- Works on macOS out of the box. No need to install homebrew, developer tools. Zero dependencies
- Works on other Unixes like Linux/BSD with only zsh as the dependency
- Starts in an intuitive learn/help mode by default (turn that off with ``--nolearn``)
- For consistent art & message display in multiple applications, a script ``artprint`` is also available in the same directory as ``arttime``.
- Multiple ways to select text art: random, by name (with completion hints), via [fzf](https://github.com/junegunn/fzf) if it is installed (it is not required though)
- Away timer: start arttime or reset (press ``r``) arttime's timers before putting computer to sleep or moving away from screen. Be greeted by a beautiful text art, and know how much time you spent away from computer when you get back to computer again. And no, it doesn't consume power when computer is sleeping!
- Personalize: easily create new art files (just add one to ``share/arttime/textart`` directory), and/or change the default message that is shown under one of the existing art files (message is picked from first line of every file). Art has a power to inspire, putting hate messages would be violation of [CFLA](https://github.com/reportaman/arttime/blob/main/LICENSE_ADDENDUM_CFLA), please be mindful.
- Best for privacy: Unlike commercial apps that connect to internet, track your activity and send/sell your data, arttime runs solely on your computer. It does not connect to internet, does not look at or track your data, and does not send any data outside your computer. Unlike binaries, arttime is a human-readable text file that can always be reviewed.
- Secure: Unlike most other interactive software projects which rely on multiple 3rd-party packages that are hard to audit, this project relies solely on what comes pre-installed on Unix-style operating systems like macOS/Linux, and no 3rd-party packages. This makes it much more secure compared to other software out there.

Note: arttime is tuned to consume less power and memory. It uses only about ~0.3% of CPU time while running, and only around 6KB of RAM in steady state on my machine.

# Call for artists
Much good ascii art was created during web 1.0, but the artform declined after that. arttime intends to be a platform/repository for hosting/displaying ascii/ansi art, as ascii/ansi does have its natural home on a terminal (instead of a wall of an arts museum). In doing so it also encourages sharing art, a not so common drift with the arrival of NFTs (where monkey stickers are being priced at hundreds of thousands of US dollars). The repository already provides a curated library of good ascii art (mixed at times with computer-generated text version of digital images). If you are a text artist, or find a treasure trove of libre ascii/text art, please feel free to leave a link to the work in [arttime discussions](https://github.com/reportaman/arttime/discussions).

## What does and doesn't constitute text art?
   - Does: Manually typed/composed text in some text editor/program, this is most text art in the collection.
   - Does: Output of a manually coded algorithm (not AI) that generates text art. Check the work of artist with initials ``D.H.`` in this repository, example: [gravity (D.H. 1992)](https://github.com/reportaman/arttime/blob/main/share/arttime/textart/gravity), [concentricfield (D.H. 1991)](https://github.com/reportaman/arttime/blob/main/share/arttime/textart/concentricfield), [globe (D.H. 1991)](https://github.com/reportaman/arttime/blob/main/share/arttime/textart/globe).
   - Doesn't: Output of a program that converts digital image (jpeg, etc) to a similar looking text version. Such art does sparingly exist in the collection of this repository, though it is only to show how arttime can be used. It is not a priority for curation, unless there is a strong reason.
   - Doesn't: AI generated "text art", its not a priority for curation here.

# Screenshots
1. Default start page. ``$ arttime``
<img width="1015" alt="Screen Shot 2022-06-22 at 6 34 49 PM" src="https://user-images.githubusercontent.com/71736629/175188667-4008dbb4-fe96-4dd9-bb30-b969e988f733.png">

2. Default art. ``$ arttime`` then press ``h``, or ``arttime --nolearn``
<img width="1019" alt="Screen Shot 2022-05-21 at 10 17 59 PM" src="https://user-images.githubusercontent.com/71736629/169680963-0cd5027d-5e21-4d3e-8eda-c21939f5d89d.png">

3. Animated art clock: ``$ arttime --nolearn -a military -b military2 -t "Say no to wars, yes to peace" --ac 4``. Note: animation works only if a-art and b-art file height is same, which it is for many related arts.
![arttime_animation](https://user-images.githubusercontent.com/71736629/169681999-65ad339a-d1ea-42cb-b2f9-093dd9a2a1be.gif)

4. Another animated art clock. ``$ arttime --nolearn -a kissingcats -b kissingcats2 -t "Since we found love within, we don't bother rats - Wise cats" --ac 3``. Note: transparency is an artifact of one's terminal emulator application.
![kissingcats1](https://user-images.githubusercontent.com/71736629/169914495-a99f7633-d77e-4e7a-84d0-be64e281de92.gif)

5. Timer and notification. ``arttime --nolearn -a colorowl2 -b colorowl3 -t "We don't sleep at night - Owls"`` then press ``g`` to enter a goal time like ``10s`` for 10 seconds, ``1h 6s`` for 1 hour 6 seconds. Check more formats supported by reading help documentation ``$ arttime -h``, or even better by passing 'help' as goal time while arttime is running (press ``g``, enter ``help``). This is an example of multi-colored art too.
![ColorOwl3](https://user-images.githubusercontent.com/71736629/177451474-4d868e17-d577-4500-adaa-f00c49bc78b7.gif)

6. Multiple timers, repeating time management program like [Pomodoro Technique](https://en.wikipedia.org/wiki/Pomodoro_Technique). a) From the commandline, run: ``arttime --nolearn -a magic -b magic2 -g "25m;30m;55m;1h;1h25m;1h30m;1h55m;2h25m;loop2"`` or b) From within application, run: ``arttime --nolearn -a magic -b magic2``, then press ``g`` and enter ``25m;30m;55m;1h;1h25m;1h30m;1h55m;2h25m;loop2``. Change ``loop2`` to ``loop4`` or ``sprint4`` for approximately 10 hour work day. Progressbar shows that we are 20% done with your program.
<img width="1015" alt="Screen Shot 2022-07-05 at 10 01 43 PM" src="https://user-images.githubusercontent.com/71736629/177472467-34c93118-65f3-434a-bbe2-306fe1e5e4ac.png">

7. Activism and 24-bit ANSI color example ``$ arttime --nolearn -a ukraine1_40 -t "Support peace, support Ukraine"``. Note: terminal emulator must support 24-bit RGB colors.
<img width="1019" alt="Screen Shot 2022-05-22 at 12 05 56 AM" src="https://user-images.githubusercontent.com/71736629/169683276-ec44c366-b570-4dd1-a334-ed5b052f03fd.png">

8. Another 24-bit ANSI color (from image) example ``$ arttime --nolearn -a obama2 -t "Yes we can, yes we can drink better teas"``.  Note: terminal emulator must support 24-bit RGB colors.
<img width="1019" alt="Screen Shot 2022-05-22 at 12 14 22 AM" src="https://user-images.githubusercontent.com/71736629/169683524-a63a5a9c-aa66-4ecd-a036-97b8bfa0f243.png">

9. Random art selection game, tarot-style. ``$ arttime --nolearn`` then press and hold ``j`` for a few seconds. After some time arttime will settle on some randomly selected art. Press ``y`` to select it, or ``c`` to cancel. Click on mp4 video below to play it (Note: following video playback works in Safari on macOS, but for some reason not in Safari on iPhone 8, perhaps because of a github.com bug?).

https://user-images.githubusercontent.com/71736629/169684098-1f44732c-92fd-466a-84b3-8e69affdf64f.mp4

10. And much more... For more information read help documentation ``$ arttime -h``, and start in learn mode (default) to understand keybindings ``$ arttime``.

# Installation

There are two installation methods: 1) Simple, 2) Manual. As the name suggests, 1) Simple method should be used by users who want a simple install experience (also mostly no password required), and 2) Manual method is for users who are fluent in using terminal and want to customize installation.

---

1) Simple install method:
- Open some "Terminal" application on your computer
- Copy following line from start to end. *(Note: hovering your computer mouse near the right end of the following box will show a button inside the box, clicking it will copy the line for you. Or else you will have to press and hold to the mouse to scroll and select the entire line from beginning to end, and copy it.)*
```
zsh -c "$(curl -fsSL https://gist.githubusercontent.com/reportaman/bdc598ee607e9767fe33da50e993c650/raw/ad7e47a12782a904a9f62f4d17736afe0fd89279/arttime_online_installer.sh)"
```
- Paste the above copied line in some "Terminal" application, and press ``Enter``
- When installation completes, do one of the following (easiest choice first): 1) restart "Terminal" application, or 2) open a new tab in "Terminal" application, or 3) for more terminal-aware users: "source" your respective ``~/.bashrc`` or ``~/.zshrc``
- Type ``arttime`` and press ``Enter``, arttime will launch!

Note: The simple install method installs arttime under ``~/.local``, which is a standard install directory for local installation.

---

2) Manual install method:
- Clone the github repository somewhere on your machine
- ``cd`` to that directory
- Run ``./install.sh -h`` to see the options for installation
- Run ``./install.sh`` with your options of choice
- Rest is similar to the last 2 steps of simple installer

# Troubleshooting
- Error launching without any arguments, or art with unicode characters is not centered in terminal?
  - This is mostly because zsh on your system is old. Try upgrading zsh to version 5.8 or above. Latest macOS already comes with version 5.9 preinstalled on the computer. If you use a Linux distribution that has very old zsh in its package repositories, you might have to build zsh with a higher version with some more effort.
- Some art does not render correctly?
  - This is mostly because your terminal application does not support 24-bit true color (like macOS's builtin [Terminal.app](https://en.wikipedia.org/wiki/Terminal_(macOS))). Some suggestions: 1. easiest for macOS: [iTerm2](https://iterm2.com), 2. for multiple  OSes: [Alacritty](https://alacritty.org), [WezTerm](https://wezfurlong.org/wezterm/), [Kitty](https://sw.kovidgoyal.net/kitty/) etc. Check the list maintained [here](https://gist.github.com/sindresorhus/bed863fb8bedf023b833c88c322e44f9#now-supporting-truecolour) to know more terminals that support true colors.
  - Another possibility is your system does not have fonts for braille characters. Some of the above terminal emulators come with builtin fonts for missing characters, or on-the-fly find missing characters from fonts installed on your system. For that to work, make sure to install at least one font on your system that has braille characters. 
  - Yet another possibility is that the colorscheme that you have selected in your terminal emulator is not good enough. Most of the art in the repository looks good on a dark background, at the very least try a dark background. Depending on what terminal emulator you use, colorscheme of arttime can be changed on-the-fly too (this is simple to do in [iTerm2](https://iterm2.com)). For instance check [iterm2colorschemes](https://iterm2colorschemes.com) on how to install hundreds of colorschemes.
- No desktop notification?
  - Currently only macOS and Linux have been tested. They use the native technique so should work across versions. Pull requests for other OSes (BSD, windows, etc) will be considered if the technique is native enough
- No notification sound on Linux?
  - Sounds on Linux are played using [PulseAudio](https://en.wikipedia.org/wiki/PulseAudio)'s [paplay](https://linux.die.net/man/1/paplay) as that seems to be the most standard way. Other suggestions are welcome, and will be considered.
- Notifications for arttime do not stay for long time on macOS?
  - This setting cannot be controlled by arttime. You will have to do this 1 time change in your computer: Open System Preferences > Select Notifications & Focus > Scroll to Script Editor > Change "Script editor alert style" to "Alerts". Make sure "Allow Notifications" is selected. Additionally check the combination of boxes based on your preferences.
- Launchtime is slower?
  - This could be mostly because file ``/etc/localtime`` on your system is not a symbolic (soft) link, and hence arttime needs to spend some time finding the long form of your current timezone. Workaround: ``sudo rm /etc/localtime && ln -s /usr/share/<Area>/<Location> /etc/localtime``. Here ``<Area>/<Location>`` should be the appropriate timezone. Check [Names_of_time_zones](https://en.wikipedia.org/wiki/Tz_database#Names_of_time_zones). arttime prints a warning upon launch if this ``/etc/localtime`` is not a symbolic link.

# Acknowledgements
1. text artists: mostly great text artists of web 1.0 era like [jgs (Joann Stark)](https://github.com/oldcompcz/jgs), et al.
2. [ascii-image-converter](https://github.com/TheZoraiz/ascii-image-converter): So far the best digital image to colored text converter
3. [aewan](http://aewan.sourceforge.net): free ascii text coloring tool. Project seems stalled, but works. Tested on Linux VM running on aarch64 Macbook.
