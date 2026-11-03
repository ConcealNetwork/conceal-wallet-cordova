@echo off

REM DEPRECATED - DO NOT USE
REM
REM This script previously rebuilt www\ by pulling the old conceal-web-wallet
REM repository as a Git subtree. That wallet is deprecated and this repository
REM now ships www\ as a committed static export of conceal-next-wallet.
REM
REM Running the old script would delete the current www\ bundle
REM (rmdir /s /q www) and replace it with the deprecated wallet, so it now aborts.
REM
REM To regenerate the web bundle, run from conceal-next-wallet:
REM   npm run cordova
REM which builds the export and post-processes it into ..\conceal-wallet-cordova\www.

echo ERROR: setup-web-wallet.bat is deprecated and intentionally disabled.
echo.
echo It used to replace www\ with the deprecated conceal-web-wallet subtree,
echo which would destroy the current conceal-next-wallet bundle committed here.
echo.
echo To regenerate the web bundle, run from a checkout of conceal-next-wallet:
echo   npm run cordova
echo.
echo See README.md and FDROID_SUBMISSION.md for the bundle provenance.
exit /b 1
