# Asistencia Vehicular Nic — Web App

Una aplicación web moderna diseñada para ofrecer servicios de asistencia vehicular en carretera de Nicaragua. La plataforma permite a los usuarios explorar los servicios disponibles, ver trabajos realizados con evidencia fotográfica y solicitar asistencia inmediata vía WhatsApp o llamada directa.

---

## Características Principales

* **Catálogo de Servicios:** Visualización clara de servicios (cambio de llanta, paso de corriente, cerrajería vehicular, diagnóstico de baterías, etc.).
* **Galería en Tiempo Real:** Integración directa con **Supabase Storage** para mostrar fotografías de trabajos realizados almacenadas en la nube.
* **Diseño Responsive:** Interfaz limpia adaptada para navegadores móviles y de escritorio.
* **Acceso Directo a Asistencia:** Botón flotante para contacto rápido por WhatsApp y llamadas de emergencia.
* **Rendimiento y Carga Rápida:** Optimizado con Flutter Web y CDN para ofrecer respuestas inmediatas en carretera.

---

## Tecnologías Utilizadas

* **Frontend:** [Flutter Web](https://flutter.dev/) (Dart)
* **Backend & Storage:** [Supabase](https://supabase.com/) (PostgreSQL & Supabase Storage)
* **Fuentes & Estilos:** `google_fonts` (Poppins)
* **Alojamiento:** [Vercel](https://vercel.com/) / [Cloudflare](https://www.cloudflare.com/)
* **IDE:** Visual Studio Code

---

## Paleta de Colores

| Elemento | Color | Hex | ARGB (Flutter) |
| :--- | :--- | :--- | :--- |
| **Azul Principal** | Azul Marino | `#0A4B82` | `0xFF0A4B82` |
| **Naranja Acento** | Naranja Vivo | `#E86C00` | `0xFFE86C00` |
| **Cyan Detalle** | Celeste | `#00A3E0` | `0xFF00A3E0` |
| **Fondo Oscuro** | Negro Grafito | `#0A0A0A` | `0xFF0A0A0A` |

---

## 📁 Estructura del Proyecto

```text
lib/
├── config/             # Configuración global y credenciales
│   ├── app_config.dart
│   └── supabase_config.dart
├── models/             # Modelos de datos (JobImage, etc.)
│   └── job_image.dart
├── screens/            # Pantallas principales
│   └── home_screen.dart
├── services/           # Servicios de conexión con Supabase
│   └── supabase_service.dart
├── widgets/            # Componentes reutilizables de la UI
│   └── job_carousel.dart
└── main.dart           # Punto de entrada de la aplicación
