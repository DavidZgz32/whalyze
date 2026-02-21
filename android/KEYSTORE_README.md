# Firma de release para Android

Para subir el AAB/APK a Google Play necesitas firmar en modo **release**.

## 1. Crear el keystore (solo una vez)

En una terminal, desde la carpeta **android** del proyecto:

```bash
cd android
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Te pedirá:
- Contraseña del keystore (guárdala bien)
- Contraseña de la key (puedes usar la misma)
- Nombre, organización, etc. (pueden ser de ejemplo)

**Importante:** Guarda una copia segura de `upload-keystore.jks` y las contraseñas. Si las pierdes, no podrás actualizar la app en Play Store.

## 2. Crear key.properties

Copia el ejemplo y edita con tus datos:

```bash
copy key.properties.example key.properties
```

Abre `key.properties` y sustituye:

- `storePassword` = contraseña del keystore
- `keyPassword` = contraseña de la key (suele ser la misma)
- `keyAlias` = `upload` (el alias que usaste en keytool)
- `storeFile` = `upload-keystore.jks` (si está en la carpeta android)

Si guardaste el `.jks` en otra ruta, pon la ruta relativa a la carpeta **android**, por ejemplo: `../mi-keystore.jks`.

## 3. Generar el AAB firmado

Desde la raíz del proyecto (Wra5):

```bash
flutter build appbundle
```

El archivo estará en: `build/app/outputs/bundle/release/app-release.aab`. Ese es el que debes subir a Play Console.
