#!/bin/sh
# Genera el keystore para firmar el AAB de release (Play Store).
# Ejecutar desde la carpeta android/ (donde está este script).
# El .jks quedará en android/upload-keystore.jks

KEYSTORE=upload-keystore.jks
ALIAS=upload
VALIDITY=10000

echo "Generando $KEYSTORE con alias $ALIAS..."
keytool -genkey -v -keystore "$KEYSTORE" -keyalg RSA -keysize 2048 -validity $VALIDITY -alias "$ALIAS"

echo ""
echo "Creado: $KEYSTORE"
echo "Crea key.properties desde key.properties.example y pon las contraseñas que hayas usado."
