@echo OFF

setlocal ENABLEEXTENSIONS
set "DATA_DIR=EnergiCore"
set "REG_DIR=Energi"
set "EXE_NAME=energi-qt.exe"
set "MN_CONF=masternode.conf"
set "DEFAULT_EXE_LOCATION=%ProgramFiles%\EnergiCore\energi-qt.exe"
set "MN_OUTPUT_FILE=nrg.mn.txt"
set "SCRIPT_URL=raw.githubusercontent.com/mikeytown2/masternode/master/energid.sh"
set "SCRIPT_NAME=energid.sh"

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

REM ~ set /p walletpid= <"%ValueValue%\pid.txt"
REM ~ if exist "%ValueValue%\pid.txt" (
  REM ~ del "%ValueValue%\pid.txt"
  REM ~ @echo Stop %DATA_DIR% wallet.
  REM ~ TIMEOUT /T 3
  REM ~ @echo "taskkill /PID %walletpid% /F"
  REM ~ taskkill /PID %walletpid% /F
REM ~ )

@echo Going to the %DATA_DIR% folder.
cd "%ValueValue%"

@echo Downloading needed files.
if exist "%ValueValue%\plink.exe" (
  del "%ValueValue%\plink.exe"
)
bitsadmin /RESET /ALLUSERS
bitsadmin /TRANSFER Plink /DOWNLOAD /PRIORITY FOREGROUND "https://the.earth.li/~sgtatham/putty/latest/w32/plink.exe" "%ValueValue%\plink.exe"

set "SEARCH_REG=0"
if Not exist "%DEFAULT_EXE_LOCATION%" (
  set "SEARCH_REG=1"
)
if %SEARCH_REG% == 1 (
  echo.>"%ValueValue%\registry.txt"
  FOR /F "usebackq skip=2 tokens=2* " %%A IN (`REG QUERY HKLM\SYSTEM\ControlSet001\services\SharedAccess\Parameters\FirewallPolicy\FirewallRules /v "TCP*%EXE_NAME%" 2^>nul`) DO (
    echo %%B >>"%ValueValue%\registry.txt"
  )
  grep -o "App=.*%EXE_NAME%" "%ValueValue%\registry.txt" | grep -io "[B-O].*" > exe.tmp
  set /p DEFAULT_EXE_LOCATION= < "%ValueValue%\exe.tmp"
  del "%ValueValue%\exe.tmp"
  del "%ValueValue%\registry.txt"
)
echo Location of exe: %DEFAULT_EXE_LOCATION%

echo.
echo Get VPS info
set /p ip="Enter VPS IP: "
echo.
set /p pass="Enter VPS Password: "
echo Run 
echo  masternode outputs 
echo in your desktop wallet console (tools - debug console)
set txid=
echo. 
set /p txid="Enter txhash: "
IF [%txid%] == [] (
  echo no txid set
) 

echo Connecting to VPS; please don't press any keys.
echo y | "%ValueValue%\plink.exe" -ssh root@%ip% -pw %pass% "exit"
echo Setup Masternode.

if [%txid%] == [] (
  set txid=-1
  echo No txhash was provided.
) else (
  echo Setting up the node with with %txid%
)

echo. | "%ValueValue%\plink.exe" -ssh root@%ip% -pw %pass% " wget -4qo- %SCRIPT_URL% -O %SCRIPT_NAME% ; bash %SCRIPT_NAME% -1 %txid% -1 -1 Y y ; echo 'done' ; exit ; logout "
echo Setup Done.
echo. | "%ValueValue%\plink.exe" -ssh root@%ip% -pw %pass% " rm -f %SCRIPT_NAME% ; tail -1 /root/%MN_OUTPUT_FILE% ; exit " > masternode.new.conf
echo Copy of string done.

copy /b %MN_CONF%+masternode.new.conf out.txt
del %MN_CONF%
move out.txt %MN_CONF%
del masternode.new.conf
del "%ValueValue%\plink.exe"
cd "%mycwd%"
echo Please restart the desktop wallet
echo
pause
