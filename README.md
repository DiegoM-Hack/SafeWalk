# 🛡️ SafeWalk

SafeWalk es una aplicación móvil desarrollada en Flutter que busca mejorar la seguridad de las personas al desplazarse por la ciudad. 
La aplicación permite compartir la ubicación en tiempo real, gestionar contactos de emergencia y enviar alertas SOS cuando el usuario se encuentre en una situación de riesgo.

---

## 📱 Características

- Registro e inicio de sesión mediante Firebase Authentication.
- Gestión de contactos de emergencia.
- Visualización de ubicación mediante Google Maps.
- Seguimiento de ubicación en tiempo real.
- Historial de recorridos.
- Perfil de usuario.
- Botón SOS con envío de alerta.
- Almacenamiento de información en Cloud Firestore.

---

## 🚨 Funcionalidad SOS

Cuando el usuario presiona el botón **SOS**, la aplicación realiza las siguientes acciones:

1. Solicita confirmación antes de enviar la alerta.
2. Obtiene la ubicación GPS actual del dispositivo.
3. Crea una alerta en Cloud Firestore.
4. Guarda:
   - UID del usuario
   - Latitud
   - Longitud
   - Mensaje de emergencia
   - Estado de la alerta
   - Fecha y hora de creación
5. Mientras la emergencia permanezca activa, la ubicación se actualiza automáticamente.
6. El usuario puede finalizar la emergencia cuando ya no necesite ayuda.

---

## 🛠 Tecnologías utilizadas

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging (FCM)
- Google Maps Flutter
- Geolocator
- Provider

---

## 📂 Estructura del proyecto

```
lib/
│
├── core/
│   ├── routes/
│   └── theme/
│
├── models/
│
├── providers/
│
├── screens/
│   ├── auth/
│   ├── contacts/
│   ├── history/
│   ├── home/
│   ├── map/
│   ├── profile/
│   └── sos/
│
├── services/
│
├── widgets/
│
└── main.dart
```

---

## ⚙️ Instalación

### Clonar el repositorio

```bash
git clone https://github.com/DiegoM-Hack/SafeWalk.git
```

Ingresar al proyecto

```bash
cd SafeWalk
```

Instalar dependencias

```bash
flutter pub get
```

Ejecutar la aplicación

```bash
flutter run
```

Generar APK

```bash
flutter build apk --release
```

El APK generado se encontrará en:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔥 Configuración de Firebase

El proyecto utiliza Firebase para:

- Authentication
- Cloud Firestore
- Firebase Messaging
- Firebase Analytics
- Firebase Storage

Es necesario agregar el archivo:

```
android/app/google-services.json
```

y configurar Firebase según la documentación oficial de FlutterFire.

---

## 🗄 Base de datos (Firestore)

Colecciones principales:

```
users
```

Información de cada usuario.

```
users/{uid}/contacts
```

Contactos de emergencia.

```
emergency_alerts
```

Alertas SOS enviadas.

Cada alerta contiene:

```
uid
latitude
longitude
message
status
createdAt
updatedAt
finishedAt
```

---

## 📍 Flujo de la alerta SOS

```
Usuario

↓

Presiona SOS

↓

Confirma el envío

↓

Obtiene GPS

↓

Guarda alerta en Firestore

↓

Actualiza ubicación

↓

Finaliza la emergencia
```

---

## 👥 Integrantes

Proyecto desarrollado por estudiantes de la ESFOT – Escuela Politécnica Nacional.
