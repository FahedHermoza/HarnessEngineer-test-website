# Domain Model

## Core Concepts

- **Tarjeta digital:** documento único publicado; la unidad que se comparte.
- **Perfil:** identidad mostrada (avatar, Nombre, Handle, Tagline).
- **Enlace:** canal accionable, con tipo, etiqueta, icono, URL destino y orden.
- **Contacto (vCard):** representación exportable de Fahed para la agenda del visitante.
- **Escaneo:** evento de acceso a la Tarjeta digital (NFC, QR o enlace compartido).

## Relationships

- La Tarjeta digital contiene un Perfil y una lista ordenada de Enlaces.
- La Contacto (vCard) resume el Perfil y el Celular/Correo, e incluye los Enlaces.
- Un Escaneo abre la Tarjeta digital; no se registra ni persiste.
- El Perfil y los Enlaces no dependen de ningún dato del visitante.

## States and Lifecycles

La Tarjeta digital no tiene estado interno. Su ciclo es de publicación:

1. **Borrador:** archivos locales (`index.html`, `assets/`) validados por `./init.sh`.
2. **Publicada:** desplegada manualmente en **Cloudflare Workers static assets** y accesible
   por `https://fahed-hermoza-card.fahedhermoza.workers.dev/` con HTTPS. Criterio de
   publicación: los cinco paths (`/`, `/styles.css`, `/assets/avatar.jpg`,
   `/assets/og-image.jpg` y `/assets/fahedhermoza.vcf`) responden 200; el HTML y los assets
   publicados coinciden byte a byte con el repo; y `canonical`/`og:url`/imágenes sociales
   apuntan a esa misma URL.
3. **Actualizada:** se editan Enlaces o Perfil, se ejecuta el gate y el propietario vuelve a
   desplegar manualmente.
4. **Retirada:** la URL deja de estar disponible (caso no previsto en el MVP).

## Important Scenarios

- Un visitante escanea la Tarjeta NFC y abre la página en su teléfono.
- Un visitante abre el portafolio y luego vuelve a la Tarjeta digital.
- Un visitante pulsa "Guardar contacto" y queda registrado en su agenda con teléfono y correo.
- Fahed agrega o reordena un Enlace y vuelve a desplegar.

## Edge Cases

- **Avatar ausente:** si `assets/avatar.jpg` no carga, mostrar un fallback con las iniciales "FH".
- **Fuente no disponible:** usar una pila de respaldo del sistema sin romper el layout.
- **Enlace caído:** el destino puede estar fuera de servicio; la página no lo detecta (fuera de alcance).
- **Navegador sin NFC:** el visitante usa el Código QR o el enlace compartido.
- **Sin app para `tel:` o `mailto:`:** el sistema decide la app; la página no puede forzarla.
- **vCard en iOS/Android:** el comportamiento de descarga difiere; el propietario reportó
  importación correcta en ambos el 2026-11-21, sin detalle de dispositivos adjunto.
- **Vista previa social:** aunque `og-image.jpg` y las URLs absolutas sean correctas, el
  unfurl puede fallar por caché o política del cliente; no se garantiza desde el dominio.

## Rediseño acordado (estado futuro, 2026-11-21)

- Los siete Enlaces conservan sus destinos. Cinco se presentan como botones grandes
  (Instagram, Facebook, WhatsApp, LinkedIn y Portafolio); Celular y Correo pasan a
  Acciones rápidas del Perfil. La posición visual no cambia sus datos en la vCard.
- La Vista QR abre desde la Tarjeta, codifica su URL pública y vuelve a la Tarjeta al
  cerrarse. Copiar Enlace y Guardar PNG operan sobre esa misma URL/imagen.
- Compartir Tarjeta usa el mecanismo nativo del dispositivo cuando existe y ofrece
  copia de la URL con confirmación visible en caso contrario. No almacena datos del visitante.
- Guardar contacto sigue descargando la vCard estática. El nuevo pie ofrece además un
  Enlace textual a WhatsApp. «NFC CONNECT» y el punto verde son ornamentales; no expresan
  una conexión ni un estado de presencia verificable.
- Casos de excepción a validar: navegador sin API de compartir o permiso de portapapeles,
  JavaScript desactivado, QR que no escanea, cierre por teclado y retorno del foco al
  control que abrió la Vista QR.
