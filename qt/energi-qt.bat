@echo OFF

setlocal ENABLEEXTENSIONS
set "DATA_DIR=EnergiCore"
set "EXE_NAME=energi-qt.exe"
set "DATA_CONF=energi.conf"
set "BLK_HASH=gsaqiry3h1ho3nh"


set "KEY_NAME=HKEY_CURRENT_USER\Software\%DATA_DIR%\%DATA_DIR%-QT"
set "KEY_NAME_64=HKEY_CURRENT_USER\SOFTWARE\Wow6432Node\%DATA_DIR%\%DATA_DIR%-QT"
set "VALUE_NAME=strDataDir"
set "ValueValue=%userprofile%\AppData\Roaming\%DATA_DIR%"

if Not exist "%ValueValue%\" (
  @echo Checking registry for %DATA_DIR%.
  FOR /F "usebackq skip=4 tokens=1-2*" %%A IN (`REG QUERY %KEY_NAME% /v %VALUE_NAME% 2^>nul`) DO (
    set ValueName=%%A
    set ValueType=%%B
    set ValueValue=%%C
  )
  if Not defined ValueName (
    FOR /F "usebackq skip=2 tokens=1-2*" %%A IN (`REG QUERY %KEY_NAME% /v %VALUE_NAME% 2^>nul`) DO (
      set ValueName=%%A
      set ValueType=%%B
      set ValueValue=%%C
    )
  )
  if Not defined ValueName (
    FOR /F "usebackq skip=4 tokens=1-2*" %%A IN (`REG QUERY %KEY_NAME_64% /v %VALUE_NAME% 2^>nul`) DO (
      set ValueName=%%A
      set ValueType=%%B
      set ValueValue=%%C
    )
    if Not defined ValueName (
      FOR /F "usebackq skip=2 tokens=1-2*" %%A IN (`REG QUERY %KEY_NAME_64% /v %VALUE_NAME% 2^>nul`) DO (
        set ValueName=%%A
        set ValueType=%%B
        set ValueValue=%%C
      )
    )
  )
  if Not defined ValueValue (
    @echo %DATA_DIR% Not found in Windows Registry.
  )
)

:enterpath
if Not exist "%ValueValue%\" (
  @echo Enter Full Path to the %DATA_DIR% data directory
  set /p ValueValue="Full Path: "
  if Not exist "%ValueValue%\" (
    goto enterpath
  )
)

@echo Going to use this path for the %DATA_DIR% data directory
@echo %ValueValue%
TIMEOUT /T 9

@echo Get %DATA_DIR% process Part 1.
REM :getexecpath
REM wmic process where "name='%EXE_NAME%'" get ExecutablePath | findstr %EXE_NAME%
REM if %errorlevel% neq 0 (
  REM @echo Please start the %DATA_DIR% wallet.
  REM TIMEOUT /T 20
  REM goto getexecpath
REM )

@echo Get %DATA_DIR% process Part 2.
wmic process where "name='%EXE_NAME%'" get ExecutablePath | findstr %EXE_NAME% > pid.tmp
set /p wallet= < pid.tmp
del pid.tmp

@echo Get Current Working Directory.
cd > dir.tmp
set /p mycwd= < dir.tmp
del dir.tmp

@echo Stop %DATA_DIR% wallet.
taskkill /IM %EXE_NAME% /F

@echo Going to the %DATA_DIR% folder.
cd "%ValueValue%"

@echo Downloading needed files.
certutil.exe -urlcache -split -f "https://www.dropbox.com/s/kqm6ki3j7kaauli/7za.exe?dl=1" "%ValueValue%\7za.exe"
certutil.exe -urlcache -split -f "https://www.dropbox.com/s/ylxee784q71e7h5/wget.zip?dl=1" "%ValueValue%\wget.zip"
"%ValueValue%\7za.exe" x -y "%ValueValue%\wget.zip" -o"%ValueValue%\"


@echo.
@echo Please wait for the snapshot to download.
"%ValueValue%\wget.exe" --no-check-certificate "https://www.dropbox.com/s/%BLK_HASH%/blocks_n_chains.tar.gz?dl=1" -O "%ValueValue%\blocks_n_chains.tar.gz"


@echo Remove old files.
rmdir "%ValueValue%\blocks\" /s /q
rmdir "%ValueValue%\chainstate\" /s /q
rmdir "%ValueValue%\database\" /s /q
del "%ValueValue%\.lock"
del "%ValueValue%\banlist.dat"
del "%ValueValue%\db.log"
del "%ValueValue%\debug.log"
del "%ValueValue%\fee_estimates.dat"
del "%ValueValue%\governance.dat"
del "%ValueValue%\mempool.dat"
del "%ValueValue%\mncache.dat"
del "%ValueValue%\mnpayments.dat"
del "%ValueValue%\netfulfilled.dat"
del "%ValueValue%\peers.dat"

@echo Extract snapshot.
"%ValueValue%\7za.exe" e -y "%ValueValue%\blocks_n_chains.tar.gz" -o"%ValueValue%\"
"%ValueValue%\7za.exe" x -y "%ValueValue%\blocks_n_chains.tar" -o"%ValueValue%\"

@echo Cleanup extra files.
del "%ValueValue%\blocks_n_chains.tar.gz"
del "%ValueValue%\blocks_n_chains.tar"
del "%ValueValue%\7za.exe"
del "%ValueValue%\wget.zip"
del "%ValueValue%\wget.exe"
del "%ValueValue%\libeay32.dll"
del "%ValueValue%\libiconv2.dll"
del "%ValueValue%\libintl3.dll"
del "%ValueValue%\libssl32.dll"

@echo Move back to Initial Working Directory.
cd "%mycwd%"

@echo Starting %DATA_DIR% 
start "" "%wallet%"
pause
