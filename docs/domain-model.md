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

1. **Borrador:** archivos locales (`index.html`, `assets/`).
2. **Publicada:** desplegada en Cloudflare Pages y accesible por URL.
3. **Actualizada:** se editan Enlaces o Perfil y se vuelve a desplegar.
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
- **vCard en iOS/Android:** el comportamiento de descarga difiere; debe validarse en ambos.
