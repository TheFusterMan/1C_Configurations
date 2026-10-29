@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

set PLATFORM_PATH="C:\Program Files (x86)\1cv8t\8.5.1.1343\bin\1cv8t.exe"
set REPO_SRC_DIR=.\git_src

echo Начало умной выгрузки конфигураций 1С по хеш-суммам...
echo.

if not exist "%REPO_SRC_DIR%" mkdir "%REPO_SRC_DIR%"

for /d %%i in (*) do (
    if exist "%%i\1Cv8.1CD" (
        if not "%%i"=="%REPO_SRC_DIR%" (
            
            set "NEED_EXPORT=0"
            set "DB_FILE=%%i\1Cv8.1CD"
            set "HASH_FILE=%REPO_SRC_DIR%\%%i_hash.txt"
            set "LOG_FILE=%REPO_SRC_DIR%\%%i_log.txt"
            
            :: 1. Считаем текущий MD5-хеш файла базы данных
            for /f "skip=1 tokens=*" %%a in ('certutil -hashfile "%%i\1Cv8.1CD" MD5 ^| findstr /v "CertUtil"') do (
                set "CURRENT_HASH=%%a"
            )
            :: Очищаем пробелы из хеша
            set "CURRENT_HASH=!CURRENT_HASH: =!"

            :: 2. Проверяем, изменился ли хеш с прошлой выгрузки
            if not exist "!HASH_FILE!" (
                set "NEED_EXPORT=1"
            ) else (
                set /p LAST_HASH=<"!HASH_FILE!"
                if not "!CURRENT_HASH!"=="!LAST_HASH!" (
                    set "NEED_EXPORT=1"
                )
            )
            
            :: 3. Если надо — выгружаем
            if "!NEED_EXPORT!"=="1" (
                echo [ИЗМЕНЕНА] Выгрузка базы: %%i...
                if not exist "%REPO_SRC_DIR%\%%i" mkdir "%REPO_SRC_DIR%\%%i"
                
                :: Запуск выгрузки 1С
                %PLATFORM_PATH% DESIGNER /F "%CD%\%%i" /DumpConfigToFiles "%CD%\%REPO_SRC_DIR%\%%i" /Out "%CD%\!LOG_FILE!" -NoTruncate
                
                :: Сохраняем новый хеш только в случае успешного запуска
                echo !CURRENT_HASH!>"!HASH_FILE!"
            ) else (
                echo [ПРОПУЩЕНА] База не изменялась: %%i
            )
        )
    )
)

echo.
echo Все конфигурации проверены! Теперь можно делать git add и git commit.
pause
