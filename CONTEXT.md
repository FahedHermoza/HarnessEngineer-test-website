# Context

Vocabulario compartido del proyecto. No contiene planes, tareas ni decisiones de implementación.

## Glossary

### Tarjeta digital
Página web estática de una sola vista que reúne la identidad y los Enlaces de contacto de Fahed Hermoza. Es el destino al que apuntan la Tarjeta NFC y el Código QR.

### Tarjeta NFC
Objeto físico con un chip NFC grabado con la URL de la Tarjeta digital. Al acercar un teléfono compatible, se abre la página.

### Código QR
Representación escaneable de la misma URL de la Tarjeta digital, impresa en la tarjeta física o mostrada en pantalla.

### Enlace (Link)
Cada botón accionable de la Tarjeta digital que abre un canal externo. Los Enlaces del MVP son, en orden: Instagram, Facebook, WhatsApp, LinkedIn, Portafolio, Correo y Celular.

### Perfil
Bloque superior de la Tarjeta digital: foto, Nombre, Handle y Tagline.

### Handle
Identificador público `@fahedhermoza`, mostrado bajo el Nombre en el Perfil.

### Tagline
Frase corta bajo el Handle: "Software Engineer & Speaker & Builder".

### Contacto (vCard)
Archivo de contacto descargable que agrupa nombre, teléfono, correo y enlaces, para que el visitante guarde a Fahed en su agenda.

### Escaneo
Cualquier apertura de la Tarjeta digital originada por Tarjeta NFC, Código QR o enlace compartido.

## Rejected / Ambiguous Terms

### "wp"
Usar `WhatsApp`. Motivo: "wp" es ambiguo y podría leerse como WordPress.

### "redes sociales"
Usar la lista explícita de `Enlace`. Motivo: agrupa canales con comportamiento distinto (redes, mensajería, contacto directo, portafolio).

### "celular" / "teléfono"
Usar `Celular` para el número peruano +51 955 116 562. El mismo número se usa en WhatsApp y en la Contacto (vCard).
