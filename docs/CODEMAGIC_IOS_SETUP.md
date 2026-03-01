# Configuración de Codemagic para build y subida a iOS

Sigue los pasos de la [guía oficial](https://docs.codemagic.io/yaml-quick-start/building-a-native-ios-app/) (y [Flutter](https://docs.codemagic.io/yaml-quick-start/building-a-flutter-app)) para tener el build y la publicación funcionando.

## 1. Añadir la app en Codemagic

1. Entra en [Codemagic](https://codemagic.io) y en **Applications** haz clic en **Add application**.
2. Conecta el repositorio (GitHub/GitLab/Bitbucket) donde está el código.
3. Selecciona el proyecto y el tipo **Flutter**.
4. Haz clic en **Finish: Add application**.

## 2. Crear y escanear `codemagic.yaml`

- El archivo `codemagic.yaml` está en la raíz del repo.
- En la app en Codemagic: elige la rama, luego **Check for configuration file** para que detecte el YAML.

## 3. Code signing (iOS)

### 3.1 App Store Connect API key

1. En [App Store Connect](https://appstoreconnect.apple.com) → **Users and Access** → **Integrations** → **App Store Connect API**.
2. Clic en **+** para crear una nueva API key.
3. Nombre (ej. "Codemagic"), acceso **App Manager**. Clic en **Generate**.
4. **Download API Key** (solo se puede descargar una vez). Anota **Issuer ID** y **Key ID**.

### 3.2 Añadir la API key en Codemagic

1. Codemagic → **Team settings** → **Team integrations** → **Developer Portal** → **Manage keys**.
2. **Add key**: nombre, Issuer ID, Key ID y subir el archivo `.p8`.

### 3.3 Certificado de distribución

1. **codemagic.yaml settings** → **Code signing identities** → pestaña **iOS certificates**.
2. Opciones:
   - **Upload certificate**: subir tu `.p12` (Distribution) con contraseña y un **Reference name**.
   - **Generate new certificate**: si tienes la API key, Codemagic puede generar uno (tipo **Apple Distribution**).
   - **Fetch certificate**: si ya fue creado por Codemagic, puedes recuperarlo desde Apple.

### 3.4 Provisioning profile

1. Misma sección **Code signing identities** → pestaña **iOS provisioning profiles**.
2. **Upload** tu perfil `.mobileprovision` con un **Reference name**, o **Fetch profiles** si usas la API key (elegir el perfil **App Store** para `com.whalyze.wra5`).

## 4. Variables en `codemagic.yaml`

En el YAML debes definir (o usar grupos de variables):

| Variable | Dónde obtenerla |
|----------|------------------|
| `APP_STORE_APPLE_ID` | App Store Connect → tu app → **General** → **App Information** → **Apple ID** (número). |
| Nombre de la integración `app_store_connect` | El **Reference name** que diste a la API key en Codemagic (en el YAML: `integrations: app_store_connect: TU_NOMBRE`). |

En `codemagic.yaml`:

- Sustituye `REPLACE_WITH_YOUR_APPLE_ID` por tu **Application Apple ID** numérico.
- Sustituye `codemagic` en `integrations: app_store_connect: codemagic` por el nombre de tu API key en Codemagic si es distinto.
- En `publishing.email.recipients` pon tu email (o los que quieras para notificaciones).

## 5. Build y artefactos

El workflow en `codemagic.yaml` ya incluye:

- `xcode-project use-profiles` (code signing).
- `flutter pub get` y `pod install`.
- `flutter build ipa` con versión automática desde App Store Connect.
- Artefactos: `build/ios/ipa/*.ipa` y logs.

Solo necesitas disparar el workflow (manual o por rama/evento que hayas configurado).

## 6. Publicación

- **TestFlight**: con `submit_to_testflight: true` el IPA se sube a App Store Connect y queda disponible para TestFlight. Opcionalmente configura `beta_groups`.
- **App Store**: cuando quieras enviar a revisión, pon `submit_to_app_store: true`.

La primera vez es recomendable crear la ficha de la app en App Store Connect y, si acaso, subir la primera versión a mano; después la automatización con Codemagic será más sencilla.

## Referencias

- [iOS native apps - Codemagic](https://docs.codemagic.io/yaml-quick-start/building-a-native-ios-app/)
- [Flutter apps - Codemagic](https://docs.codemagic.io/yaml-quick-start/building-a-flutter-app)
- [Code signing iOS](https://docs.codemagic.io/flutter-code-signing/ios-code-signing)
- [App Store Connect publishing](https://docs.codemagic.io/yaml-publishing/app-store-connect)
