@echo off
chcp 65001
set PLATFORM_PATH="C:\Program Files\1cv8\8.3.25.1234\bin\1cv8.exe"
set REPO_SRC_DIR=.\git_src

echo Начало выгрузки конфигураций...

for /d %%i in (*) do (
    if exist "%%i\1Cv8.1CD" (
        echo Выгрузка базы: %%i
        mkdir "%REPO_SRC_DIR%\%%i"
        %PLATFORM_PATH% DESIGNER /F "%CD%\%%i" /DumpConfigToFiles "%CD%\%REPO_SRC_DIR%\%%i" /Out "%CD%\%REPO_SRC_DIR%\%%i_log.txt" -NoTruncate
    )
)

echo Все конфигурации выгружены!
pause
