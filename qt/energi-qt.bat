@echo OFF

setlocal ENABLEEXTENSIONS
set "DATA_DIR=EnergiCore"
set "REG_DIR=Energi"
set "EXE_NAME=energi-qt.exe"
set "DATA_CONF=energi.conf"
set "BLK_HASH=gsaqiry3h1ho3nh"
set "DEFAULT_EXE_LOCATION=%ProgramFiles%\EnergiCore\energi-qt.exe"

set "KEY_NAME=HKEY_CURRENT_USER\Software\%REG_DIR%\%REG_DIR%-QT"
set "KEY_NAME_64=HKEY_CURRENT_USER\SOFTWARE\Wow6432Node\%REG_DIR%\%REG_DIR%-QT"
set "VALUE_NAME=strDataDir"
set "ValueValue=%userprofile%\AppData\Roaming\%DATA_DIR%"

@echo Get Current Working Directory.
cd > dir.tmp
set /p mycwd= < dir.tmp
del dir.tmp

cd %userprofile%
set "SEARCH_REG=0"
if Not exist "%ValueValue%\" (
  set "SEARCH_REG=1"
)
if %SEARCH_REG% == 1 (
  echo Checking registry for %DATA_DIR%.
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
wmic process where "name='%EXE_NAME%'" get ExecutablePath | findstr %EXE_NAME% > "%ValueValue%\pid.tmp"
set /p wallet= < "%ValueValue%\pid.tmp"
del "%ValueValue%\pid.tmp"

if ["%wallet%"] NEQ [""] (
  for /F "skip=1" %%A in (
    'wmic process where "name='%EXE_NAME%'" get ProcessID'
  ) do (
    echo %%A >> "%ValueValue%\pid.txt"
  )
)

set /p walletpid= <"%ValueValue%\pid.txt"
if exist "%ValueValue%\pid.txt" (
  del "%ValueValue%\pid.txt"
  @echo Stop %DATA_DIR% wallet.
  TIMEOUT /T 3
  @echo "taskkill /PID %walletpid% /F"
  taskkill /PID %walletpid% /F
)

@echo Going to the %DATA_DIR% folder.
cd "%ValueValue%"

@echo Downloading needed files.
del "%ValueValue%\7za.exe"
del "%ValueValue%\util.7z"
TIMEOUT /T 9
bitsadmin /RESET /ALLUSERS
bitsadmin /TRANSFER DL7zipAndUtil /DOWNLOAD /PRIORITY FOREGROUND "https://www.dropbox.com/s/kqm6ki3j7kaauli/7za.exe?dl=1" "%ValueValue%\7za.exe"  "https://www.dropbox.com/s/x51dx1sg1m9wn7o/util.7z?dl=1" "%ValueValue%\util.7z"
"%ValueValue%\7za.exe" x -y "%ValueValue%\util.7z" -o"%ValueValue%\"

set "SEARCH_REG=0"
if Not exist "%DEFAULT_EXE_LOCATION%" (
  set "SEARCH_REG=1"
)
if %SEARCH_REG% == 1 (
  echo.>"%ValueValue%\registry.txt"
  FOR /F "usebackq skip=2 tokens=2* " %%A IN (`REG QUERY HKLM\SYSTEM\ControlSet001\services\SharedAccess\Parameters\FirewallPolicy\FirewallRules /v "TCP*%EXE_NAME%" 2^>nul`) DO (
	echo %%B >>"%ValueValue%\registry.txt"
	)
  )
  grep -o "App=.*%EXE_NAME%" "%ValueValue%\registry.txt" | grep -io "[B-O].*" > exe.tmp
  set /p DEFAULT_EXE_LOCATION= < "%ValueValue%\exe.tmp"
  del "%ValueValue%\exe.tmp"
  del "%ValueValue%\registry.txt"
)
echo Location of exe: %DEFAULT_EXE_LOCATION%

@echo.
@echo Please wait for the snapshot to download.
"%ValueValue%\wget.exe" --no-check-certificate "https://www.dropbox.com/s/%BLK_HASH%/blocks_n_chains.tar.gz?dl=1" -O "%ValueValue%\blocks_n_chains.tar.gz"

@echo Remove old files.
TIMEOUT /T 3
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
TIMEOUT /T 3
del "%ValueValue%\blocks_n_chains.tar.gz"
del "%ValueValue%\blocks_n_chains.tar"
del "%ValueValue%\7za.exe"
del "%ValueValue%\util.7z"
del "%ValueValue%\grep.exe"
del "%ValueValue%\libeay32.dll"
del "%ValueValue%\libiconv2.dll"
del "%ValueValue%\libintl3.dll"
del "%ValueValue%\libssl32.dll"
del "%ValueValue%\pcre3.dll"
del "%ValueValue%\regex2.dll"
del "%ValueValue%\wget.exe"

@echo Move back to Initial Working Directory.
cd "%mycwd%"

@echo Starting %DATA_DIR%
if ["%wallet%"] == [""] (
  start "" "%DEFAULT_EXE_LOCATION%"
  echo Running %DEFAULT_EXE_LOCATION%
) else (
  start "" "%wallet%"
  echo Running %wallet%
)
pause
