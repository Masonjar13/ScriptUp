# ScriptUp
Latest tested working version: AHK_L v1.1.28.0, DLL: 1.1.26.01-H001

[AutoHotkey Forum Thread](https://autohotkey.com/boards/viewtopic.php?f=6&t=36656)

Are you tired of having to see tons of AHK scripts running in the processes list? I was. So, I made this: ScriptUp!

![ScriptUp](https://i.imgur.com/g8X8uFw.png)

Easily add as many AHK scripts as you'd like, from any folder on your PC, and ScriptUp will house them all under its own process name. You can even compile it to have it run under a readable, separated process name!

# Features

  - When adding a script, you can choose between using the standard, full-featured DLL, and the mini version.
  - You can reload each script individually or all at once.
  - Drag and drop scripts to add multiple files at once.
  - When it starts up, all scripts in the list immediately run.
  - When a file is added, it immediately runs.
  - When a file is removed, it immediately stops the script.
  - As a setting, it can start up at user login.
  - Scripts may be paused and suspended.
  - Each script state is listed and actively updated.

# Limitations and other notes

  - Scripts must be compliant with AutoHotkey_H (usually no or very few issues if it was written for AHK v1.1).
  - If you have "Start on User Login" active and move ScriptUp, it will automatically fix the registry entry (restart ScriptUp from the new path to do so).
  - When running as a compiled script, you must have a shortcut (.lnk) to "Lib" in the same folder as ScriptUp.
  - If using an onExit sub/function in one of the added scripts, it must not exceed 30s of process time. If something requires more than that amount of time, set `quitTimeout` at `Lib\fileList.ahk:2`.

# Dependencies (included)
  - [AutoHotkey_H v1](https://hotkeyit.github.io/v2/) - The DLL's are required for actually running the scripts. Be sure to use the correct bit-length (must be the same as ScriptUp) as you can't mismatch DLL's and EXE's, eg., 32-bit or 64-bit DLL if ScriptUp is running under 32-bit or 64-bit, respectively.
  - [threadMan](https://github.com/Masonjar13/AHK-Library/blob/master/Lib/threadMan.ahk)
    - [readResource](https://github.com/Masonjar13/AHK-Library/blob/master/Required-Libraries/readResource.ahk) (Not made by me, but I don't recall the thread I got it from, apologies.)
    - [_MemoryLibrary](https://github.com/Masonjar13/AHK-Library/blob/master/Required-Libraries/_MemoryLibrary.ahk) [by Hotkeyit](https://autohotkey.com/board/topic/77302-class-ahk-lv2-memorylibrary/)
      - [_Struct](https://github.com/Masonjar13/AHK-Library/blob/master/Required-Libraries/_Struct.ahk) [by Hotkeyit](https://autohotkey.com/board/topic/55150-class-structfunc-sizeof-updated-010412-ahkv2/)

# Contribution
If you'd like to contribute, fork, or make any personal edits, feel free to add your own name and link to the "About" section. Search for `gui: about` to add your name in, format it as you'd like, and give it `gaboutLink` (if you're adding a link). Then search for the label, `aboutLink:`, and add a new ternary expression.

My only request is to keep my name and link in the About section. Other than that, have fun!


# License
MIT
