# ScriptUp
Latest tested working version: AHK_L v1.1.29.01, DLL: 1.1.30.00-H001

[AutoHotkey Forum Thread](https://autohotkey.com/boards/viewtopic.php?f=6&t=36656)

Are you tired of having to see tons of AHK scripts running in the processes list? I was. So, I made this: ScriptUp!

![ScriptUp](https://i.imgur.com/8xRso8M.png)

Easily add as many AHK scripts as you'd like, from any folder on your PC, and ScriptUp will house them all under its own process name. You can even compile it to have it run under a readable, separated process name!

# Features

  - When adding a script, you can choose between using the standard, full-featured DLL, and the mini version.
  - You can reload each script individually or all at once.
  - Drag and drop files to add multiple scripts at once.
  - When it starts up, all scripts in the list immediately run.
  - When a file is added, it immediately runs.
  - When a file is removed, it immediately stops the script.
  - As a setting, it can start up at user login.
  - Scripts may be paused and suspended.
  - Each script state is listed and actively updated.

# Limitations and other notes

  - Scripts must be compliant with AutoHotkey_H (usually no or very few issues if it was written for AHK v1.1).
  - If you have "Start on User Login" active and move ScriptUp, it will automatically fix the registry entry (restart ScriptUp from the new path to do so).
  - When running as a compiled script, you must have a shortcut (.lnk) to "Lib" in the same folder as ScriptUp to allow access to the [Standard Library](https://autohotkey.com/docs/Functions.htm#lib).
  - If using an onExit sub/function in one of the added scripts, it must not exceed 30s of process time. If something requires more than that amount of time, [set the value here](ScriptUp.ahk#L70).
  - Do NOT use any variation of #If except for #If. #IfWinActive, #IfWinExist, etc., will make the thread crash on exit. This is due to deprication in __H.
  - SetWorkingDir will be overridden. They will take on the working directory of the worker script, which is in the library. Full paths will need to be used in scripts.
  - With the release of v1, paths to scripts/DLLs may be relative to workerH. You can modify the path while adding a new script or change it in Lib\config.ini.

# Dependencies (included)
  - [AutoHotkey_H v1](https://hotkeyit.github.io/v2/) - The DLL's are required for running the worker as well as the scripts. It will auto-set them initially to the included DLLs, but you can change them from the options tab.
  - [threadMan](https://github.com/Masonjar13/AHK-Library/blob/master/Lib/threadMan.ahk)
    - [_MemoryLibrary](https://github.com/Masonjar13/AHK-Library/blob/master/Required-Libraries/_MemoryLibrary.ahk) [by Hotkeyit](https://autohotkey.com/board/topic/77302-class-ahk-lv2-memorylibrary/)
      - [_Struct](https://github.com/Masonjar13/AHK-Library/blob/master/Required-Libraries/_Struct.ahk) [by Hotkeyit](https://autohotkey.com/board/topic/55150-class-structfunc-sizeof-updated-010412-ahkv2/)

# Contribution
If you'd like to contribute, fork, or make any personal edits, feel free to add your own name and link to the [About section](Lib/guiMake.ahk#L32).

My only request is to keep my name and link in the About section. Other than that, have fun!


# License
MIT
