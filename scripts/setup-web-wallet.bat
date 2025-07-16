@echo off
setlocal enabledelayedexpansion

REM Conceal Web Wallet Setup Script for Windows
REM This script sets up the web wallet locally for Cordova integration using Git subtree

echo Starting Conceal Web Wallet setup with Git subtree...

REM 1. Remove www folder contents from git tracking if it exists
echo 1. Removing existing www folder contents from git tracking...
if exist "www" (
    REM Backup our modified files
    echo    Backing up modified files...
    if not exist "temp_backup" mkdir temp_backup
    if exist "www\src\index.html" (
        copy "www\src\index.html" "temp_backup\index.html" >nul
        echo    ✓ Backed up www\src\index.html
    )
    if exist "www\src\index.js" (
        copy "www\src\index.js" "temp_backup\index.js" >nul
        echo    ✓ Backed up www\src\index.js
    )
    
    REM Remove the www directory completely
    rmdir /s /q www
    echo    ✓ www folder removed
) else (
    echo    ✓ www folder doesn't exist, skipping removal
)

REM 2. Add the external repository as a subtree
echo 2. Adding Conceal Web Wallet as Git subtree...
git subtree add --prefix=www https://github.com/ConcealNetwork/conceal-web-wallet.git testing --squash
if %errorlevel% equ 0 (
    echo    ✓ Repository added as subtree successfully
) else (
    echo    ✗ Failed to add repository as subtree
    exit /b 1
)

REM 3. Change to www directory and checkout testing branch (if needed)
echo 3. Switching to testing branch...
cd www
git checkout testing >nul 2>&1 || echo    ✓ Already on testing branch
echo    ✓ Switched to testing branch

REM 4. Install npm dependencies
echo 4. Installing npm dependencies...
call npm install
if %errorlevel% equ 0 (
    echo    ✓ Dependencies installed
) else (
    echo    ✗ Failed to install dependencies
    exit /b 1
)

REM 5. Build the project
echo 5. Building the project...
call node .\node_modules\typescript\bin\tsc --project tsconfig.prod.json && call node build.js
if %errorlevel% equ 0 (
    echo    ✓ Build completed successfully
) else (
    echo    ✗ Build failed
    exit /b 1
)

REM 6. Remove all TypeScript files and markdown files
echo 6. Removing TypeScript and markdown files...
for /r . %%f in (*.ts) do del "%%f" >nul 2>&1
for /r . %%f in (*.md) do del "%%f" >nul 2>&1
echo    ✓ TypeScript and markdown files removed

REM 7. Add cordova.js script to index.html
echo 7. Adding cordova.js script to index.html...
if exist "src\index.html" (
    REM Create a temporary file with cordova.js script added
    powershell -Command "(Get-Content 'src\index.html') -replace '<script', '        <script type=\"text/javascript\" src=\"../cordova.js\"></script>`n<script' | Set-Content 'src\index.html'"
    echo    ✓ cordova.js script added to src\index.html
) else (
    echo    ⚠ Warning: src\index.html not found
)

REM 8. Fix router configuration
echo 8. Fixing router configuration...
if exist "src\index.js" (
    powershell -Command "(Get-Content 'src\index.js') -replace 'new Router_1\.Router\(''\.\/'', ''\.\.\/\.\.\/''\)', 'new Router_1.Router(''\.\/'', ''\.\/'')' | Set-Content 'src\index.js'"
    echo    ✓ Router configuration fixed
) else (
    echo    ⚠ Warning: src\index.js not found
)

REM 9. Fix QR reader paths
echo 9. Fixing QR reader paths...
if exist "src\pages\importFromQr.js" (
    powershell -Command "(Get-Content 'src\pages\importFromQr.js') -replace 'this\.qrReader\.init\(''\/lib\/''\)', 'this.qrReader.init(''/src/lib/'')' | Set-Content 'src\pages\importFromQr.js'"
    echo    ✓ QR reader path fixed in importFromQr.js
)
if exist "src\pages\send.js" (
    powershell -Command "(Get-Content 'src\pages\send.js') -replace 'this\.qrReader\.init\(''\/lib\/''\)', 'this.qrReader.init(''/src/lib/'')' | Set-Content 'src\pages\send.js'"
    echo    ✓ QR reader path fixed in send.js
)
if exist "src\pages\messages.js" (
    powershell -Command "(Get-Content 'src\pages\messages.js') -replace 'this\.qrReader\.init\(''\/lib\/''\)', 'this.qrReader.init(''/src/lib/'')' | Set-Content 'src\pages\messages.js'"
    echo    ✓ QR reader path fixed in messages.js
)

REM 10. Fix worker file paths
echo 10. Fixing worker file paths...
if exist "src\workers\TransferProcessingEntrypoint.js" (
    powershell -Command "(Get-Content 'src\workers\TransferProcessingEntrypoint.js') -replace 'importScripts\(''\.\.\/src\/lib\/', 'importScripts(''\.\.\/lib\/' | Set-Content 'src\workers\TransferProcessingEntrypoint.js'"
    echo    ✓ Worker paths fixed in TransferProcessingEntrypoint.js
)
if exist "src\workers\ParseTransactionsEntrypoint.js" (
    powershell -Command "(Get-Content 'src\workers\ParseTransactionsEntrypoint.js') -replace 'importScripts\(''\.\.\/src\/lib\/', 'importScripts(''\.\.\/lib\/' | Set-Content 'src\workers\ParseTransactionsEntrypoint.js'"
    echo    ✓ Worker paths fixed in ParseTransactionsEntrypoint.js
)

REM 11. Fix all module and dynamic dependency paths (excluding QR reader paths)
echo 11. Fixing all module and dynamic dependency paths...
REM This is complex in batch, so we'll use PowerShell for the find/replace operations
powershell -Command "Get-ChildItem -Path 'src' -Recurse -Filter '*.js' | Where-Object { $_.Name -notmatch 'importFromQr|send|messages' } | ForEach-Object { (Get-Content $_.FullName) -replace '\.\./src/lib/', '../lib/' | Set-Content $_.FullName }"
powershell -Command "Get-ChildItem -Path 'src' -MaxDepth 1 -Filter '*.js' | ForEach-Object { (Get-Content $_.FullName) -replace '\./src/lib/', './lib/' | Set-Content $_.FullName }"
powershell -Command "Get-ChildItem -Path 'src' -Recurse -Filter '*.js' | Where-Object { $_.Name -notmatch 'importFromQr|send|messages' } | ForEach-Object { (Get-Content $_.FullName) -replace '''/src/lib/''', '''/lib/''' | Set-Content $_.FullName }"
echo    ✓ All module and dynamic dependency paths fixed

REM 12. Restore our modified files
echo 12. Restoring modified files...
if exist "..\temp_backup\index.html" (
    copy "..\temp_backup\index.html" "src\index.html" >nul
    echo    ✓ Restored www\src\index.html
)
if exist "..\temp_backup\index.js" (
    copy "..\temp_backup\index.js" "src\index.js" >nul
    echo    ✓ Restored www\src\index.js
)

REM Return to parent directory
cd ..

REM 13. Install required Cordova plugins
echo 13. Installing required Cordova plugins...
call cordova plugin add cordova-plugin-insomnia@~4.3.0
call cordova plugin add cordova-plugin-app-version@~0.1.9
call cordova plugin add cordova-plugin-android-permissions@~1.1.5
call cordova plugin add cordova-plugin-network-information@~3.0.0
echo    ✓ Cordova plugins installed

REM 14. Clean up backup files
echo 14. Cleaning up backup files...
if exist "temp_backup" rmdir /s /q temp_backup
echo    ✓ Backup files cleaned up

REM 15. Commit the subtree changes to the parent repository
echo 15. Committing subtree changes to parent repository...
git add www/
git commit -m "Add Conceal Web Wallet as subtree from testing branch

- Integrated conceal-web-wallet repository as Git subtree
- Applied Cordova-specific modifications
- Fixed file paths for Cordova integration
- Added required Cordova plugins"
if %errorlevel% equ 0 (
    echo    ✓ Changes committed to parent repository
) else (
    echo    ⚠ Warning: Failed to commit changes (maybe no changes to commit)
)

echo.
echo ✓ Conceal Web Wallet setup completed successfully!
echo The web wallet is now part of your Git repository as a subtree.
echo.
echo Next steps:
echo 1. Update your Cordova app to load the local web wallet
echo 2. Test the integration
echo 3. Build your Cordova app
echo.
echo To update the subtree in the future, use:
echo   git subtree pull --prefix=www https://github.com/ConcealNetwork/conceal-web-wallet.git testing --squash

pause 