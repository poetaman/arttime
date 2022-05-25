Contents
=================

* [arttime](#arttime)
* [Call for artists](#call-for-artists)
* [Screenshots](#screenshots)
* [Installation](#installation)
* [Troubleshooting](#troubleshooting)
* [Acknowledgements](#acknowledgements)
<!-- Created by https://github.com/ekalinin/github-markdown-toc -->


# arttime
🧜🏼‍♀️ Beauty of text art meets functionality of clock/timer ⏰. ``arttime`` brings curated text-art to otherwise artless terminal emulators of starving developers and other users who can use terminal.

Purpose/features:
- Bring curated text/ascii art to artless terminals, currently 300+ high-quality text art to choose from
- Provide a simple yet smart alarm/timer for commandline
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
- Personalize: easily create new art files (just add one to ``share/arttime/textart`` directory), and/or change the default message that is shown under one of the existing art files (message is picked from first line of every file). Art has a power to inspire, putting hate messages would be violation of [CFLA](https://github.com/reportaman/arttime/blob/23360507eb5622d951728b5f71621a1df942e157/LICENSE_ADDENDUM_CFLA), please be mindful.
- Best for privacy: Unlike commercial apps that connect to internet, track your activity and send/sell your data, arttime runs solely on your computer. It does not connect to internet, does not look at or track your data, and does not send any data outside your computer. Unlike binaries, arttime is a human-readable text file that can always be reviewed.

Note-1: By default ``arttime`` is tuned to consume less power, so you will see an occasional increment of 2 seconds in elapsed time. This is ok as the error is always less than 1 second. If you don't want this to happen, set samples per second to 10 from command line ``-s 10`` or from within the application by pressing ``s`` after it starts. On my machine this increases CPU usage from ``0.3%`` to ``1.5%``. I use ``-s 10`` only during presentations.

Note-2: arttime has been designed to be lean, and uses only around 6KB of your RAM while running!


# Call for artists
Much good ascii art was created during web 1.0, but the artform declined after that. arttime intends to be a platform/repository for hosting/displaying ascii/ansi art, as ascii/ansi does have its natural home on a terminal (instead of a wall of an arts museum). In doing so it also encourages sharing art, a not so common drift with the arrival of NFTs (where monkey stickers are being priced at hundreds of thousands of US dollars). The repository already provides a curated library of good ascii art (mixed at times with computer-generated text version of digital images).

# Screenshots
1. Default start page. ``$ arttime``
<img width="1019" alt="Screen Shot 2022-05-23 at 2 27 18 PM" src="https://user-images.githubusercontent.com/71736629/169908634-46536f1a-2f28-4d4b-bd4f-964b041b9450.png">

2. Default art. ``$ arttime`` then press ``h``, or ``arttime --nolearn``
<img width="1019" alt="Screen Shot 2022-05-21 at 10 17 59 PM" src="https://user-images.githubusercontent.com/71736629/169680963-0cd5027d-5e21-4d3e-8eda-c21939f5d89d.png">

3. Animated art clock: ``$ arttime --nolearn -a military -b military2 -t "Say no to wars, yes to peace" --ac 4``. Note: animation works only if a-art and b-art file height is same, which it is for many related arts.
![arttime_animation](https://user-images.githubusercontent.com/71736629/169681999-65ad339a-d1ea-42cb-b2f9-093dd9a2a1be.gif)

4. Another animated art clock. ``$ arttime --nolearn -a kissingcats -b kissingcats2 -t "Since we found love within, we don't bother rats - Wise cats" --ac 3``. Note: transparency is an artifact of one's terminal emulator application.
![kissingcats1](https://user-images.githubusercontent.com/71736629/169914495-a99f7633-d77e-4e7a-84d0-be64e281de92.gif)

5. Timer and notification. ``arttime --nolearn -a colorowl2 -b colorowl3 -t "We don't sleep at night - Owls"`` then press ``g`` to enter a goal time like ``6s`` for 6 seconds. Check more formats supported by reading help documentation ``$ arttime -h``. This is an example of colorful art too.
![arttime_timer2](https://user-images.githubusercontent.com/71736629/169683033-b343526c-718a-4515-a1fa-52943a609e18.gif)

6. Activism and 24-bit ANSI color example ``$ arttime --nolearn -a ukraine1_40 -t "Support peace, support Ukraine"``. Note: terminal emulator must support 24-bit RGB colors.
<img width="1019" alt="Screen Shot 2022-05-22 at 12 05 56 AM" src="https://user-images.githubusercontent.com/71736629/169683276-ec44c366-b570-4dd1-a334-ed5b052f03fd.png">

7. Another 24-bit ANSI color (from image) example ``$ arttime --nolearn -a obama2 -t "Yes we can, yes we can drink better teas"``.  Note: terminal emulator must support 24-bit RGB colors.
<img width="1019" alt="Screen Shot 2022-05-22 at 12 14 22 AM" src="https://user-images.githubusercontent.com/71736629/169683524-a63a5a9c-aa66-4ecd-a036-97b8bfa0f243.png">

8. Random art selection game, tarot-style. ``$ arttime --nolearn`` then press and hold ``j`` for a few seconds. After some time arttime will settle on some randomly selected art. Press ``y`` to select it, or ``c`` to cancel. Click on mp4 video below to play it (Note: following video playback works in Safari on macOS, but for some reason not in Safari on iPhone 8, perhaps because of a github.com bug?).

https://user-images.githubusercontent.com/71736629/169684098-1f44732c-92fd-466a-84b3-8e69affdf64f.mp4

9. And much more... For more information read help documentation ``$ arttime -h``, and start in learn mode (default) to understand keybindings ``$ arttime``.

# Installation
At the moment, only manual installation is possible.

Follow these steps:
1. Clone or download the git repository to a preferred location. Cloning is the preferred method to get future updates via ``git pull``.
2. Add one of the following block of lines to your ``.zshrc`` or ``.bashrc`` file, depending on your login shell. For macOS it is ``.zshrc`` unless you have changed that.
```
export PATH="<path_to_arttime_directory>/bin:$PATH"
```
OR
```
alias artprint="<path_to_arttime_directory>/bin/artprint"
alias arttime="<path_to_arttime_directory>/bin/arttime"
```

3. Open new terminal or source your respective ``.zshrc`` or ``.bashrc`` again.
4. Run command ``arttime``

# Troubleshooting
- Some art does not render correctly?
  - This is mostly because your terminal application does not support 24-bit true color (like macOS's builtin [Terminal.app](https://en.wikipedia.org/wiki/Terminal_(macOS))). Some suggestions: 1. easiest for macOS: [iTerm2](https://iterm2.com), 2. for multiple  OSes: [Alacritty](https://alacritty.org), [WezTerm](https://wezfurlong.org/wezterm/), [Kitty](https://sw.kovidgoyal.net/kitty/) etc. Check the list maintained [here](https://gist.github.com/sindresorhus/bed863fb8bedf023b833c88c322e44f9#now-supporting-truecolour) to know more terminals that support true colors.
  - Another possibility is your system does not have fonts for braille characters. Some of the above terminal emulators come with builtin fonts for missing characters, or on-the-fly find missing characters from fonts installed on your system. For that to work, make sure to install at least one font on your system that has braille characters. 
  - Yet another possibility is that the colorscheme that you have selected in your terminal emulator is not good enough. Most of the art in the repository looks good on a dark background, at the very least try a dark background. Depending on what terminal emulator you use, colorscheme of arttime can be changed on-the-fly too (this is simple to do in [iTerm2](https://iterm2.com)). For instance check [iterm2colorschemes](https://iterm2colorschemes.com) on how to install hundreds of colorschemes.
- No desktop notification?
  - Currently only macOS and Linux have been tested. They use the native technique so should work across versions. Pull requests for other OSes (BSD, windows, etc) will be considered if the technique is native enough
- No notification sound on Linux?
  - Sounds on Linux are played using [PulseAudio](https://en.wikipedia.org/wiki/PulseAudio)'s [paplay](https://linux.die.net/man/1/paplay) as that seems to be the most standard way. Other suggestions are welcome, and will be considered.


# Acknowledgements
1. text artists: mostly great text artists of web 1.0 era like [jgs (Joann Stark)](https://github.com/oldcompcz/jgs), et al.
2. [ascii-image-converter](https://github.com/TheZoraiz/ascii-image-converter): So far the best digital image to colored text converter
3. [aewan](http://aewan.sourceforge.net): free ascii text coloring tool. Project seems stalled, but works. Tested on Linux VM running on aarch64 Macbook.
