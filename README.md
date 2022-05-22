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

# Screenshots
1. Default start page. ``$ arttime``
<img width="1019" alt="Screen Shot 2022-05-21 at 10 17 45 PM" src="https://user-images.githubusercontent.com/71736629/169680869-ae7e017d-490d-4c71-af46-70f8124cb263.png">

2. Default art. ``$ arttime`` then press ``h``, or ``arttime --nolearn``
<img width="1019" alt="Screen Shot 2022-05-21 at 10 17 59 PM" src="https://user-images.githubusercontent.com/71736629/169680963-0cd5027d-5e21-4d3e-8eda-c21939f5d89d.png">

3. Animated art clock. ``$ arttime --nolearn -a military -b military2 -t "Say no to wars, yes to peace" --ac 4``
![arttime_animation](https://user-images.githubusercontent.com/71736629/169681999-65ad339a-d1ea-42cb-b2f9-093dd9a2a1be.gif)

4. Timer and notification. ``arttime --nolearn -a colorowl2 -b colorowl3 -t "We don't sleep at night - Owls"`` then press ``g`` to enter a goal time like ``6s`` for 6 seconds. Check more formats supported by reading help documentation ``$ arttime -h``
![arttime_timer2](https://user-images.githubusercontent.com/71736629/169683033-b343526c-718a-4515-a1fa-52943a609e18.gif)

