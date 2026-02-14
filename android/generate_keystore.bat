@echo off
REM Genera el keystore para firmar el AAB de release (Play Store).
REM Ejecutar desde la carpeta android/ (donde está este script).
REM El .jks quedará en android/upload-keystore.jks

set KEYSTORE=upload-keystore.jks
set ALIAS=upload
set VALIDITY=10000

echo Generando %KEYSTORE% con alias %ALIAS%...
keytool -genkey -v -keystore %KEYSTORE% -keyalg RSA -keysize 2048 -validity %VALIDITY% -alias %ALIAS%

echo.
echo Creado: %KEYSTORE%
echo Crea key.properties desde key.properties.example y pon las contraseñas que hayas usado.
pause
