@echo off

setlocal ENABLEEXTENSIONS
set "DATA_DIR=EnergiCore"
set "ValueValue=%userprofile%\AppData\Roaming\%DATA_DIR%"

set "REG_DIR=Energi"
set "EXE_NAME=energi-qt.exe"
set "DEFAULT_EXE_LOCATION=%ProgramFiles%\EnergiCore\energi-qt.exe"

set "KEY_NAME=HKEY_CURRENT_USER\Software\%REG_DIR%\%REG_DIR%-QT"
set "KEY_NAME_64=HKEY_CURRENT_USER\SOFTWARE\Wow6432Node\%REG_DIR%\%REG_DIR%-QT"
set "VALUE_NAME=strDataDir"

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
@echo Enter Full Path to the %DATA_DIR% data directory you wish to use
@echo Please do not include the trailing slash \
@echo Default is currently %ValueValue% (blank enter to use default)
set /p ValueValue="Full Path: " || SET "ValueValue=%ValueValue%"
if Not exist "%ValueValue%\" (
  echo "Folder must already exist."
  goto enterpath
)

@echo Going to use this path for the %DATA_DIR% data directory
@echo %ValueValue%
TIMEOUT /T 1

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

echo Starting %DATA_DIR%
if ["%wallet%"] == [""] (
  echo Running %DEFAULT_EXE_LOCATION% -datadir=%ValueValue%
  start "" "%DEFAULT_EXE_LOCATION%" "-datadir=%ValueValue%"
) else (
  echo Running %wallet% -datadir=%ValueValue%
  start "" "%wallet%" "-datadir=%ValueValue%"
)

@echo Window will close in 15 seconds
TIMEOUT /T 15
