# arttime
🧜🏼‍♀️ Beauty of text art meets functionality of clock/timer ⏰. ``arttime`` brings curated text-art to otherwise artless terminal emulators of starving developers and other users who can use terminal. 

Purpose/features:
- Bring curated text/ascii art to artless terminals
- Provide a simple yet smart alarm/timer for commandline
- Native desktop notifications for timer, notification identifies the instance of arttime it came from
- Provide developers with 1 line under art to display their activism
- Support animated text art: flip-flop between two related ascii arts every second
- Support 24-bit RGB text art produced from jpeg, etc stickers/images/photographs
- Random art selection makes it a fun game, or serious tarot-style reading for believers in The Random
- Provide a publishing platform for text/ascii art artists (text art is meant for terminals, not museums)
- Provide a curated text art library for users 
- Provide a developer-centric experience: mindful suspension (Ctrl-z) and continuation
- Works on macOS out of the box. No need to install homebrew, developer tools
- Works on other Unixes like Linux/BSD with only zsh as the dependency
- Starts in an intuitive learn/help mode by default (turn that off with ``--nolearn``)
- For consistent art & message display in multiple applications, a script ``artprint`` is also available in the same directory as ``arttime``.

# Call for artists
Much good ascii art was created during web 1.0, but the artform declined after that. arttime intends to be a platform/repository for hosting/displaying ascii/ansi art, as ascii/ansi does have its natural home on a terminal (instead of a wall of an arts museum). In doing so it also encourages sharing art, a not so common drift with the arrival of NFTs (where monkey stickers are being priced at hundreds of thousands of US dollars). The repository already provides a curated library of good ascii art (mixed at times with computer-generated text version of digital images).

# Screenshots
1. Default start page. ``$ arttime``
<img width="1019" alt="Screen Shot 2022-05-21 at 10 17 45 PM" src="https://user-images.githubusercontent.com/71736629/169680869-ae7e017d-490d-4c71-af46-70f8124cb263.png">

2. Default art. ``$ arttime`` then press ``h``, or ``arttime --nolearn``
<img width="1019" alt="Screen Shot 2022-05-21 at 10 17 59 PM" src="https://user-images.githubusercontent.com/71736629/169680963-0cd5027d-5e21-4d3e-8eda-c21939f5d89d.png">

3. Animated art clock. ``$ arttime --nolearn -a military -b military2 -t "Say no to wars, yes to peace" --ac 4``
![arttime_animation](https://user-images.githubusercontent.com/71736629/169681999-65ad339a-d1ea-42cb-b2f9-093dd9a2a1be.gif)

4. Timer and notification. ``arttime --nolearn -a colorowl2 -b colorowl3 -t "We don't sleep at night - Owls"`` then press ``g`` to enter a goal time like ``6s`` for 6 seconds. Check more formats supported by reading help documentation ``$ arttime -h``. This is an example of colorful art too.
![arttime_timer2](https://user-images.githubusercontent.com/71736629/169683033-b343526c-718a-4515-a1fa-52943a609e18.gif)

5. Activism and 24-bit ANSI color example ``$ arttime --nolearn -a ukraine1_40 -t "Support peace, support Ukraine"``. Note: terminal emulator must support 24-bit RGB colors.
<img width="1019" alt="Screen Shot 2022-05-22 at 12 05 56 AM" src="https://user-images.githubusercontent.com/71736629/169683276-ec44c366-b570-4dd1-a334-ed5b052f03fd.png">

6. Another 24-bit ANSI color (from image) example ``$ arttime --nolearn -a obama2 -t "Yes we can, yes we can drink better teas"``.  Note: terminal emulator must support 24-bit RGB colors.
<img width="1019" alt="Screen Shot 2022-05-22 at 12 14 22 AM" src="https://user-images.githubusercontent.com/71736629/169683524-a63a5a9c-aa66-4ecd-a036-97b8bfa0f243.png">

7. Random art selection game, tarot-style. ``$ arttime --nolearn`` then press and hold ``j`` for a few seconds. After some time arttime will settle on some randomly selected art. Press ``y`` to select it, or ``c`` to cancel. Click on mp4 video below to play it (it's GIF makes loading this web page slow).

https://user-images.githubusercontent.com/71736629/169684098-1f44732c-92fd-466a-84b3-8e69affdf64f.mp4

8. And much more... For more information read help documentation ``$ arttime -h``, and start in learn mode (default) to understand keybindings ``$ arttime``.

# Installation
At the moment, only manual installation is possible.

Follow these steps:
1. Clone or download the git repository to a preffered location. Cloning is preffered for future updates via ``git pull``.
2. Add this command to your ``.zshrc`` or ``.bashrc`` file, depending on your login shell.

```
alias artprint="<path_to_arttime_directory>/bin/artprint"
alias arttime="<path_to_arttime_directory>/bin/arttime"
```

3. Open new terminal or source your respective ``.zshrc`` or ``.bashrc`` again.
4. Run command ``arttime``

# Acknowledgements
1. text artists: mostly great text artists of web 1.0 era like [jgs (Joann Stark)](https://github.com/oldcompcz/jgs), et al.
2. [ascii-image-converter](https://github.com/TheZoraiz/ascii-image-converter): So far the best digital image to text image converter
3. [aewan](http://aewan.sourceforge.net): free ascii text coloring tool. Project seems stalled, but works. Tested on Linux VM running on aarch64 Macbook.
