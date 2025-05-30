@echo off
::   Required Values:
:: TITLEPLAT: platform run using demulshooter
:: TITLENAME: shorthand title of game passed to demulshooter
:: TITLEPATH: path to game/emulator

:::: Main Script
:Loop -- Main Script Code and loop for args parsing
IF NOT [%1]==[] (
    :: Get last game argument, if any, in case it needs concatenating
    IF DEFINED DSSCRIPT_DEBUG IF DEFINED TITLEARGS (
        FOR %%a IN (%TITLEARGS%) DO SET LASTTITLEARG=%%a
    )
    :: In case user accidentally left extra - for a DemulShooter arg
    IF DEFINED DSARGS IF NOT "%DSARGS:~0,1%"=="-" SET DSARGS=-%DSARGS%
    CALL :ParseArgs %1 %2
    SHIFT
    GOTO :Loop
)

IF DEFINED TITLEARGS ECHO Arguments: %TITLEARGS%

:: Check minimum viable vars are set
IF NOT DEFINED TITLEPLAT (
    CALL :PrintHelpAndExit
    ECHO No DemulShooter platform specified!
    PAUSE
    EXIT /B 1
)
IF NOT DEFINED TITLENAME (
    CALL :PrintHelpAndExit
    ECHO No DemulShooter title specified!
    PAUSE
    EXIT /B 1
)
IF NOT DEFINED TITLEPATH (
    CALL :PrintHelpAndExit
    ECHO No game or emulator path specified!
    PAUSE
    EXIT /B 1
)

:: Check if TeknoParrot command is semantically correct
IF /i "%TITLEEXE%"=="TeknoParrotUi.exe" IF NOT DEFINED TITLEARGS (
    ECHO ERROR: Trying to call TeknoParrot without a profile argument does not launch anything! Make sure you add "--profile=GameName.xml" for the game you're trying to run.
    PAUSE
    EXIT /B 1
)

:: Assume that DemulShooter is located here in prefix/drive
IF DEFINED CUSTOMDSPATH (
    IF NOT EXIST "%CUSTOMDSPATH%DemulShooter.exe" (
        ECHO ERROR: DemulShooter.exe not found at "%CUSTOMDSPATH%"
        PAUSE
        EXIT /B 1
    ) ELSE (
        :: Switch to custom dir
        %CUSTOMDSDRIVE%
        cd "%CUSTOMDSPATH%"
    )
) ELSE (
    IF NOT EXIST "C:\DemulShooter\DemulShooter.exe" (
        ECHO ERROR: No DemulShooter available at default path "C:\DemulShooter"
        PAUSE
        EXIT /B 1
    ) ELSE (
        C:
        CD "c:\DemulShooter"
    )
)

:: Get correct exe name based on TITLENAME+TITLEPLAT
:: 32-bit executables
IF %TITLEPLAT%==chihiro     SET DSEXE=DemulShooter.exe
IF %TITLEPLAT%==model2      SET DSEXE=DemulShooter.exe
IF %TITLEPLAT%==demul107a   SET DSEXE=DemulShooter.exe
IF %TITLEPLAT%==dolphin5    SET DSEXE=DemulShooter.exe
IF %TITLEPLAT%==es4         SET DSEXE=DemulShooter.exe
IF %TITLEPLAT%==gamewax     SET DSEXE=DemulShooter.exe
IF %TITLEPLAT%==globalvr    SET DSEXE=DemulShooter.exe
IF %TITLEPLAT%==konami      SET DSEXE=DemulShooter.exe
IF %TITLEPLAT%==lindbergh   SET DSEXE=DemulShooter.exe
IF %TITLEPLAT%==ppmarket    SET DSEXE=DemulShooter.exe
IF %TITLEPLAT%==ringedge2   SET DSEXE=DemulShooter.exe
IF %TITLEPLAT%==ringwide    SET DSEXE=DemulShooter.exe
IF %TITLEPLAT%==ttx         SET DSEXE=DemulShooter.exe
:: Raw Thrills (has some 64-bit titles)
IF %TITLEPLAT%==rawthrill (
     IF %TITLENAME%==nerfa  SET DSEXE=DemulShooterX64.exe
     IF NOT DEFINED DSEXE   SET DSEXE=DemulShooter.exe
)
:: General Windows/Winbedded Arcade titles (mix of 32-bit and 64-bit)
IF %TITLEPLAT%==windows (
    IF %TITLENAME%==bbhut   SET DSEXE=DemulShooterX64.exe
    IF %TITLENAME%==dcop    SET DSEXE=DemulShooterX64.exe
    IF %TITLENAME%==opwolfr SET DSEXE=DemulShooterX64.exe
    IF %TITLENAME%==hotdra  SET DSEXE=DemulShooterX64.exe
    IF NOT DEFINED DSEXE    SET DSEXE=DemulShooter.exe
)
:: 64-bit executables
IF %TITLEPLAT%==alls        SET DSEXE=DemulShooterX64.exe
IF %TITLEPLAT%==arcadepc    SET DSEXE=DemulShooterX64.exe
IF %TITLEPLAT%==es3         SET DSEXE=DemulShooterX64.exe
IF %TITLEPLAT%==flycast     SET DSEXE=DemulShooterX64.exe
IF %TITLEPLAT%==rpcs3       SET DSEXE=DemulShooterX64.exe
IF %TITLEPLAT%==seganu      SET DSEXE=DemulShooterX64.exe

IF NOT DEFINED DSEXE (
    ECHO ERROR: Script has not determined which DemulShooter exe to use! Is the platform name correct?
    PAUSE
    EXIT /B 1
)

:: Start DemulShooter instance
IF NOT DEFINED DSARGS (
         ECHO Starting %DSEXE% for %TITLEPLAT%:%TITLENAME%
) ELSE ( ECHO Starting %DSEXE% for %TITLEPLAT%:%TITLENAME% w/ %DSARGS% )
START /b %DSEXE% -target=%TITLEPLAT% -rom=%TITLENAME% %CUSTOMDSPROF% %DSARGS%

:: CD to game path
%TITLEDRIVE%
cd "%TITLEPATH%"

:: Final cleanup of args, depending on platform
IF %TITLEPLAT%==model2 IF NOT DEFINED TITLEARGS (
    ECHO Running Model 2 without args, setting rom as argument.
    SET TITLEARGS=%TITLENAME%
)

:: Really pedantic printout
IF NOT DEFINED TITLEARGS (
         ECHO Starting "%TITLEEXE%"
) ELSE ( ECHO Starting "%TITLEEXE%" %TITLEARGS% )

:: Start game

START /wait "" "%TITLEEXE%" %TITLEARGS%
EXIT /B %ERRORLEVEL%

:::: END OF MAIN PROGRAM
::
:::: Helper Functions
:ParseArgs -- Parse arguments and store to variables as appropriate
IF DEFINED DSSCRIPT_DEBUG ECHO Parsing %1
IF /i "%~1"=="-dsplatform" IF NOT [%2]==[] (
    SET TITLEPLAT=%~2
    IF DEFINED DSSCRIPT_DEBUG ECHO Set platform to %~2
    EXIT /B 0
)
IF /i "%~1"=="-dsrom" IF NOT [%2]==[] (
    SET TITLENAME=%~2
    IF DEFINED DSSCRIPT_DEBUG ECHO Set rom name to %~2
    EXIT /B 0
)
IF /i "%~1"=="-dspath" IF NOT [%2]==[] IF EXIST "%~f2" (
    SET CUSTOMDSDRIVE=%~d2
    SET CUSTOMDSPATH=%~dp2
    IF DEFINED DSSCRIPT_DEBUG ECHO Set custom DemulShooter path to %~f2
    EXIT /B 0
)
IF /i "%~1"=="-dsconfig" IF NOT [%~x2]==[] (
    SET CUSTOMDSPROF=-profile="%~nx2"
    IF DEFINED DSSCRIPT_DEBUG ECHO Set custom DemulShooter profile to %~nx2
    EXIT /B 0
) ELSE ECHO Custom DemulShooter profile is not a valid .ini file! Make sure argument ends in .ini
IF /i "%~1"=="-dsarg" IF NOT [%2]==[] (
    SET DSARGS=%~2 %DSARGS%
    IF DEFINED DSSCRIPT_DEBUG ECHO Set custom DemulShooter argument -%~2
    EXIT /B 0
)
IF NOT DEFINED TITLEPATH (
    IF EXIST "%~f1" (
        SET TITLEPATH=%~dp1
        SET TITLEEXE=%~nx1
        SET TITLEDRIVE=%~d1
        IF DEFINED DSSCRIPT_DEBUG ECHO Setting path to %~f1
    )
    EXIT /B 1
)
IF NOT DEFINED TITLEARGS (
    :: CMD parser seems to have issues with '=', and we can't fix it here
    :: But any text after '=' becomes the next argument.
    IF EXIST "%~f1" (
            SET TITLEARGS="%~f1"
    )  ELSE SET TITLEARGS=%~1
    EXIT /B 1
) ELSE (
    :: Check last argument if it's got double-dash, and add equals sign
    :: [Fixes TP profile arguments, and maybe others]
    IF "%LASTTITLEARG:~0,2%"=="--" IF NOT "%LASTTITLEARG:~-1%"=="=" (
        SET TITLEARGS=%TITLEARGS%=%~1
        IF DEFINED DSSCRIPT_DEBUG ECHO Concatenating previous argument to %TITLEARGS%=%~1
        EXIT /B 1
    )
    IF EXIST "%~f1" (
           SET TITLEARGS=%TITLEARGS% "%~f1"
    ) ELSE SET TITLEARGS=%TITLEARGS% %~1
    IF DEFINED DSSCRIPT_DEBUG ECHO Adding argument %~1
    EXIT /B 1
)

:::: System functions
:PrintHelpAndExit
ECHO Launches specified game/emulator with DemulShooter.
ECHO.
ECHO DSLauncher     -dsplatform ^<platform^> -dsrom ^<rom^>
ECHO                [-dspath ^<X:\path\to\DemulShooter.exe^>]
ECHO                [-dsconfig ^<customProfile.ini^>]
ECHO                [-dsarg argument] [-dsarg argument2] [...]
ECHO                ^<X:\path\to\game.exe^> [arg] [-arg] [--arg=Arg] [...]
ECHO.
ECHO  -dsplatform          Name of platform to pass to DemulShooter.*
ECHO  -dsrom               Name of rom to pass to DemulShooter.*
ECHO  -dspath              User-specified path to DemulShooter.
ECHO                       When undefined, script defaults to "C:\DemulShooter"
ECHO  -dsconfig            Filename of custom DemulShooter config to use.
ECHO                       Custom config is searched in DemulShooter directory.
ECHO  -dsarg               Defines argument to pass to DemulShooter;
ECHO                       Can be repeated for multiple arguments.
ECHO  arg^|-arg^|--arg=Arg   Defines arguments to pass to game.exe.
ECHO.
ECHO *Refer to "DemulShooter.exe -h" for supported roms.
ECHO.
EXIT /B 0
