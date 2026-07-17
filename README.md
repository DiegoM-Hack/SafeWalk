# 🛡️ SafeWalk — Llega seguro a casa

[![Flutter](https://img.shields.io/badge/Flutter-Framework-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-Language-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Google Maps](https://img.shields.io/badge/Google%20Maps-SDK-4285F4?style=for-the-badge&logo=googlemaps&logoColor=white)](https://maps.google.com)

**SafeWalk** es una aplicación móvil orientada a la seguridad personal durante trayectos urbanos. Acompaña al usuario a lo largo de su recorrido, permitiendo compartir su ubicación en tiempo real, gestionar contactos de emergencia vinculados, activar alertas de auxilio inmediatas (SOS) con notificaciones push y registrar un historial completo de llegadas seguras.

---

## 👥 Equipo de Desarrollo

| Integrante | Rol | Aporte Principal |
| :--- | :--- | :--- |
| **Diego Alexander Montaluisa Sapatanga** | Scrum Master / Integración | Arquitectura base, autenticación, flujo de inicio de sesión e integración general. |
| **Kevin Fernando Almeida Arreaga** | Arquitecto / Contactos | CRUD de contactos de emergencia, Cloud Functions para vinculación por correo y reglas de Firestore. |
| **Joahn Mateo Cárdenas Sillo** | Desarrollador SOS y Notificaciones | Botón SOS, alertas geolocalizadas, seguimiento en tiempo real y notificaciones push (FCM). |
| **Pablo Emilio Erazo Ortega** | Desarrollador GPS y Mapas | Integración de Google Maps SDK, cálculo y trazado de rutas mediante Directions API. |
| **Alessia de los Ángeles Pérez Palacios** | Desarrolladora Historial, Perfil & UI | Pantalla de historial de recorridos, perfil de usuario, refinamiento visual de UI y pruebas del sistema. |

---

## 🎯 Objetivos y Alcance (MVP)

- 🔐 **Autenticación:** Registro e inicio de sesión de usuarios con Firebase Authentication.
- 👥 **Red de Emergencia:** CRUD completo para añadir, consultar, actualizar y eliminar contactos de seguridad vinculados por correo.
- 🗺️ **Rutas y Navegación:** Visualización en tiempo real sobre Google Maps y trazado de rutas óptimas con la Directions API.
- 🚨 **Alerta SOS con Ubicación:** Envío inmediato de la ubicación actual a contactos vinculados en momentos de riesgo.
- 🔔 **Notificaciones Push:** Alertas automáticas mediante Firebase Cloud Messaging y Cloud Functions al activar el botón SOS.
- 📜 **Historial y Perfil:** Registro detallado de viajes realizados y estado de llegadas seguras.

---

## 🛠️ Tecnologías y Herramientas

| Componente | Tecnología | Descripción |
| :--- | :--- | :--- |
| **Lenguaje / UI** | Flutter & Dart | Desarrollo multiplataforma |
| **Gestión de Estado** | Provider | Control del estado global de la aplicación |
| **Base de Datos & Auth** | Firebase (Auth & Firestore) | Almacenamiento NoSQL en tiempo real y autenticación |
| **Lógica Backend** | Cloud Functions & Cloud Messaging | Eventos automáticos en la nube y notificaciones push |
| **Geolocalización & Mapas** | Google Maps SDK & Geolocator | Renderizado de mapas e interactividad GPS |
| **APIs Externas** | Google Maps Directions API | Cálculo y renderizado visual de trayectos |

---

## 🚀 Funcionalidades Clave

- 🔑 **Autenticación Segura:** Control de acceso directo para cada usuario registrado.
- 📲 **Contactos SOS Vinculados:** Conexión automática entre cuentas mediante correo electrónico gracias a Cloud Functions.
- 📍 **Seguimiento GPS en Vivo:** Trazado activo de la posición del usuario en el mapa durante el desplazamiento.
- 🆘 **Botón de Auxilio:** Disparo instantáneo de alerta con coordenadas exactas e inicio de seguimiento de emergencia.
- 📂 **Historial de Trayectos:** Almacenamiento local/nube de rutas previas indicando duración y distancia recorridas.

---

## 📸 Evidencias de Pantallas

<align="center">

| 01. Login / Registro | 02. Inicio y Rutas en Mapa |
| :---: | :---: |
| *(Agrega aquí el link de tu imagen/captura)* | *(Agrega aquí el link de tu imagen/captura)* |
| *Acceso a la plataforma* | *Trazado de trayecto sobre Google Maps* |

<br/>

| 03. Botón SOS / Emergencia | 04. Contactos e Historial |
| :---: | :---: |
| *(Agrega aquí el link de tu imagen/captura)* | *(Agrega aquí el link de tu imagen/captura)* |
| *Emisión de alerta y ubicación en tiempo real* | *Gestión de red de apoyo e historial de llegadas seguras* |

</align>

---

## 🧠 Arquitectura del Proyecto

El código está organizado bajo principios de separación de responsabilidades y la estructura **Provider** recomendada para proyectos Flutter:

```text
lib/
├── core/                  # Configuración, temas visuales y rutas de la app
│   ├── config/
│   ├── routes/
│   └── theme/
├── models/                # Modelos de datos (User, EmergencyContact, Trip, Message)
├── providers/             # Gestión de estado mediante Provider (Auth, Contact, Location, SOS, etc.)
├── screens/               # Vistas principales de la aplicación
│   ├── auth/              # Login, registro y recuperación
│   ├── contacts/          # CRUD de contactos de emergencia
│   ├── history/           # Historial de recorridos
│   ├── home/              # Pantalla principal
│   ├── map/               # Visualización e interacción con el mapa
│   ├── profile/           # Perfil del usuario
│   └── sos/               # Pantalla de emergencia y alerta activa
├── services/              # Conectores externos (Firestore, Location, Directions API, Notifications)
└── widgets/               # Componentes reutilizables de UI

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

# 👥 Link de social

https://vt.tiktok.com/ZSX5j9Jc4/ 

**Escuela Politécnica Nacional**
**ESFOT**

---

