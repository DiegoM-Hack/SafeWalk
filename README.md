# 🛡️ SafeWalk

<div align="center">

Aplicación móvil desarrollada con Flutter para mejorar la seguridad de las personas mediante el seguimiento de ubicación, rutas seguras y un sistema de alertas SOS.

</div>

---

# 📖 Descripción

SafeWalk es una aplicación móvil orientada a la seguridad personal durante desplazamientos.

Su objetivo es permitir que los usuarios compartan su ubicación con personas de confianza y puedan solicitar ayuda rápidamente mediante un botón de emergencia (SOS).

La aplicación integra servicios de Firebase para autenticación, almacenamiento de información y gestión de alertas, además de Google Maps para mostrar la ubicación en tiempo real.

---

# 🎯 Objetivos

## Objetivo General

Desarrollar una aplicación móvil que permita a los usuarios desplazarse de forma más segura mediante herramientas de seguimiento y respuesta ante emergencias.

## Objetivos Específicos

- Registrar e iniciar sesión de usuarios.
- Gestionar contactos de emergencia.
- Visualizar mapas y rutas.
- Compartir la ubicación.
- Enviar alertas SOS.
- Mantener un historial de recorridos.
- Administrar el perfil del usuario.

---

# ✨ Funcionalidades

- ✅ Registro de usuarios
- ✅ Inicio de sesión
- ✅ Recuperación de contraseña
- ✅ Perfil de usuario
- ✅ Gestión de contactos de emergencia
- ✅ Visualización de mapas
- ✅ Seguimiento GPS
- ✅ Historial de recorridos
- ✅ Botón SOS
- ✅ Compartición de ubicación

---

# 🚨 Funcionamiento del botón SOS

Cuando el usuario presiona el botón de emergencia:

1. Se solicita confirmación.
2. Se obtiene la ubicación actual del dispositivo.
3. Se verifica que exista un usuario autenticado.
4. Se registra una alerta en Cloud Firestore.
5. Se almacena:
   - UID del usuario
   - Latitud
   - Longitud
   - Mensaje
   - Estado
   - Fecha y hora
6. Se notifica al usuario si el envío fue exitoso.


---

# 🏗 Arquitectura

```
Flutter
│
├── Core
│     ├── Routes
│     └── Theme
│
├── Models
│
├── Providers
│
├── Services
│
├── Screens
│     ├── Auth
│     ├── Home
│     ├── Map
│     ├── Contacts
│     ├── History
│     ├── Profile
│     └── SOS
│
├── Widgets
│
└── Firebase
      ├── Authentication
      ├── Firestore
      ├── Cloud Messaging
      ├── Analytics
      └── Crashlytics
```

---

# 🛠 Tecnologías utilizadas

| Tecnología | Uso |
|------------|-----|
| Flutter | Desarrollo móvil |
| Dart | Lenguaje de programación |
| Firebase Authentication | Inicio de sesión |
| Cloud Firestore | Base de datos |
| Firebase Messaging | Notificaciones |
| Firebase Analytics | Analítica |
| Firebase Crashlytics | Reporte de errores |
| Google Maps | Visualización de mapas |
| Geolocator | Obtención del GPS |
| Provider | Gestión de estado |

---

# 📂 Estructura del proyecto

```
lib/

core/
models/
providers/
screens/
services/
widgets/

main.dart
app.dart
```

---

# 🔥 Base de datos

## users

Información de cada usuario.

```
users
 └── uid
      ├── name
      ├── email
      ├── phone
      └── createdAt
```

---

## contacts

Contactos de emergencia.

```
users
 └── uid
      └── contacts
```

---

## emergency_alerts

Alertas enviadas.

```
emergency_alerts

uid

latitude

longitude

message

status

createdAt
```

---

# 📍 Flujo de la aplicación

```
Usuario

↓

Inicio de sesión

↓

Pantalla principal

↓

Mapa
│
├── Contactos
├── Historial
├── Perfil
└── SOS

↓

Ubicación GPS

↓

Firestore

↓

Registro de alerta
```

---

# 🚀 Instalación

## Clonar el proyecto

```bash
git clone https://github.com/DiegoM-Hack/SafeWalk.git
```

Entrar al proyecto

```bash
cd SafeWalk
```

Instalar dependencias

```bash
flutter pub get
```

Ejecutar

```bash
flutter run
```

Generar APK

```bash
flutter build apk --release
```

---

# ⚙ Configuración

El proyecto requiere una configuración previa de Firebase.

Es necesario incluir:

```
android/app/google-services.json
```

y configurar:

- Firebase Authentication
- Cloud Firestore
- Firebase Messaging
- Firebase Analytics
- Firebase Crashlytics


---

# 👥 Equipo de desarrollo

Proyecto desarrollado por estudiantes de la

**Escuela Politécnica Nacional**
**ESFOT**

---

