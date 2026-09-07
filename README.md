# Finanzas Estudiante

Aplicación Flutter para el control de finanzas personales orientada a estudiantes. Permite registrar ingresos y egresos por mes, llevar un presupuesto con porcentaje disponible, ingresar movimientos por voz y recibir alertas locales cuando el presupuesto está en estado crítico.

## Características

- **Dashboard mensual:** saldo, total de ingresos, egresos y porcentaje disponible del presupuesto con estado visual (OK / advertencia / crítico).
- **Registro de ingresos y egresos** con categorías predefinidas y persistencia local.
- **Entrada por voz:** registra movimientos dictando descripción y monto (`speech_to_text`).
- **Alertas locales:** notifica cuando el presupuesto entra en estado crítico (`flutter_local_notifications`).
- **Ajustes personalizables:** alias del usuario, tema claro/oscuro, color de acento y nombre del mes siguiente.
- **Persistencia local** con `shared_preferences` (no requiere backend).
- Gestión de estado con `provider`.

## Stack técnico

| Componente      | Tecnología                              |
| --------------- | --------------------------------------- |
| Framework       | Flutter 3.47 / Dart 3.13                |
| Estado          | `provider`                              |
| Persistencia    | `shared_preferences`                    |
| Notificaciones  | `flutter_local_notifications` ^19.5.0   |
| Voz             | `speech_to_text`                        |
| Fechas/Intl     | `intl`                                  |

## Requisitos previos

1. **Flutter SDK** (canal stable, >= 3.47). Añade `bin` del SDK al `PATH`.
   - Descarga: [flutter.dev](https://docs.flutter.dev/get-started/install/windows)
2. **Android:** Android SDK/JDK 17+ (para compilar en Android) o aceptar licencias con `flutter doctor --android-licenses`.
3. **Web/Chrome:** Chrome instalado.
4. **Windows desktop:** Visual Studio con la carga de trabajo *Desktop development with C++*.

> En Windows, para builds con plugins se recomienda tener activado el **Developer Mode** (`ms-settings:developers`).

## Configuración del proyecto

El proyecto ya incluye la configuración de **Java 8 desugaring** (requerida por `flutter_local_notifications`) en `android/app/build.gradle.kts`; no es necesario añadirla manualmente.

Instalación de dependencias:

```bash
flutter pub get
```

Verificación de salud del entorno:

```bash
flutter doctor
flutter analyze
```

## Ejecución

### Web (Chrome)

```bash
flutter run -d chrome
```

### Android (dispositivo o emulador)

```bash
flutter devices      # ver dispositivos disponibles
flutter run -d <device-id>
```

### Windows desktop

```bash
flutter run -d windows
```

### Build de producción

```bash
flutter build web
flutter build apk --release
```

## Estructura del proyecto

```
lib/
├── main.dart                     # Punto de entrada e inicialización
├── models/
│   └── movimiento.dart           # Modelo Movimiento y categorías
├── screens/                      # Pantallas (dashboard, ingresos, egresos, ajustes, formularios)
├── services/
│   ├── budget_service.dart       # Lógica de presupuesto y validación
│   ├── storage_service.dart      # Persistencia con shared_preferences
│   ├── notification_service.dart # Notificaciones locales
│   └── voice_parser.dart         # Parseo de entrada por voz
├── state/
│   └── app_state.dart            # AppState (Provider)
├── theme/
│   └── app_theme.dart            # Temas claro/oscuro
└── widgets/                      # Widgets reutilizables
```

## Notas por plataforma

- **Web:** el dictado por voz y las notificaciones locales tienen soporte parcial (dependen del navegador).
- **Android:** principal objetivo de la app; requiere los permisos `POST_NOTIFICATIONS` y `RECORD_AUDIO` (ya declarados en el `AndroidManifest.xml`).