# ofelia-shared

Shared CSS, fonts, and icon assets for the 5 OFELIA apps
([tareas](https://github.com/SGarciaMontalvo/tareas),
[bitacora](https://github.com/SGarciaMontalvo/bitacora),
[gestorExpedientes](https://github.com/SGarciaMontalvo/gestorExpedientes),
[gestorSistemaCalidad](https://github.com/SGarciaMontalvo/gestorSistemaCalidad),
[ofelia-agent](https://github.com/SGarciaMontalvo/ofelia-agent)).

Built on top of [`@telefonica/mistica`](https://github.com/Telefonica/mistica-web)
(the Telefonica Design System). Conforms to the global hard-rule:

> **Usar `mistica-web` (Telefónica) para TODA UI.** Nunca improvisar
> estilos. Nunca hardcodear colores — siempre `var(--mistica-color-*)`.

## What lives here

```text
ofelia-shared/
├── css/
│   ├── mistica.css          ← Mistica canónico (common + movistar skin)
│   └── ofelia-base.css      ← utility layer corporativa + @font-face
├── fonts/                   ← Movistar Sans woff2 (de Telefónica brand portal)
├── icons/                   ← set oficial Mistica (futuro, P3)
├── scripts/
│   └── install-movistar-sans.sh   ← helper para instalar binarios
└── docs/                    ← documentación de patrones
```

## Mistica version

| Component | Version | Source |
| --- | --- | --- |
| `mistica-common.css` | latest | https://github.com/Telefonica/mistica-web/blob/master/css/mistica-common.css |
| `movistar.css` | latest | https://github.com/Telefonica/mistica-web/blob/master/css/movistar.css |
| `@telefonica/mistica` (referencia) | latest | https://www.npmjs.com/package/@telefonica/mistica |

Para actualizar Mistica a una nueva versión:

```bash
# Descargar la versión canónica
curl -sL https://raw.githubusercontent.com/Telefonica/mistica-web/master/css/mistica-common.css > css/mistica-common.css.new
curl -sL https://raw.githubusercontent.com/Telefonica/mistica-web/master/css/movistar.css > css/movistar.css.new

# Reemplazar y re-concatenar
mv css/mistica-common.css.new css/mistica-common.css
mv css/movistar.css.new css/movistar.css
cat css/mistica-common.css > css/mistica.css
echo "" >> css/mistica.css
echo "/* === movistar skin === */" >> css/mistica.css
cat css/movistar.css >> css/mistica.css

# Commit
git add css/
git commit -m "chore(mistica): bump to upstream <version>"
```

## Cómo usan este shared las 5 apps

Las apps referencian este repo vía **symlinks** en su `static/css/` y
`static/fonts/`. Esto evita tocar `nginx-router` y mantiene el deploy
atómico por app.

Setup típico al migrar una app:

```bash
cd /home/deploy/projects/<app>
mkdir -p app/static/css app/static/fonts

# Mistica canónico (concatenado)
ln -s ../../../ofelia-shared/css/mistica.css app/static/css/mistica.css

# Utility layer corporativa
ln -s ../../../ofelia-shared/css/ofelia-base.css app/static/css/ofelia-base.css

# Fonts (directorio completo)
ln -s ../../../ofelia-shared/fonts app/static/fonts
```

Después, en `base.html`:

```html
<link rel="stylesheet" href="{{ url_for('static', filename='css/mistica.css') }}">
<link rel="stylesheet" href="{{ url_for('static', filename='css/ofelia-base.css') }}">
<link rel="stylesheet" href="{{ url_for('static', filename='fonts/MovistarSans-Regular.woff2') }}" type="font/woff2" crossorigin>
```

Y en `<body>`:

```html
<body data-mistica-skin="movistar" data-mistica-color-scheme="light">
  <main class="mistica-responsive-layout">
    ...
  </main>
</body>
```

## Movistar Sans — fuente corporativa

Movistar Sans es la fuente designada del skin `movistar` (ver
[Mistica fonts docs](https://github.com/Telefonica/mistica-web/blob/master/doc/fonts.md)).
**No está disponible públicamente** — los binarios `.woff2` deben
obtenerse del **brand portal interno de Telefónica**.

Pesos necesarios:

| Peso | Archivo esperado |
| --- | --- |
| 300 (Light) | `fonts/MovistarSans-Light.woff2` |
| 400 (Regular) | `fonts/MovistarSans-Regular.woff2` |
| 500 (Medium) | `fonts/MovistarSans-Medium.woff2` |
| 700 (Bold) | `fonts/MovistarSans-Bold.woff2` |

Mientras los archivos no estén presentes, el sistema cae a
`'Helvetica', 'Arial', sans-serif` automáticamente (declarado en
`ofelia-base.css`).

### Helper de instalación

```bash
# Tras obtener los .woff2 oficiales (del brand portal interno):
bash scripts/install-movistar-sans.sh /ruta/a/los/woff2/*.woff2

# Verificación:
bash scripts/install-movistar-sans.sh --check
```

## Utility classes disponibles

`ofelia-base.css` define las utility classes canónicas que Mistica
expone como React components (`<Stack>`, `<Inline>`, `<Callout>`,
`<Tag>`, `<Row>`, `<Box>`, `<AccordionItem>`, `<ButtonPrimary>`, etc.)
pero que **no existen en el build CSS-only**.

| Utility | Equivalente React | Notas |
| --- | --- | --- |
| `.stack` + `.stack--{xs,sm,md,lg,xl}` | `<Stack>` | columna flex con gap |
| `.inline` + `.inline--{md,lg}` | `<Inline>` | fila flex con wrap + gap |
| `.list` | `<UnorderedList>` | ul sin estilo |
| `.row` + `.row__title/subtitle/description` | `<RowList><Row>` | tarjeta de fila |
| `.boxed` | `<Boxed>` | contenedor con background container |
| `.callout--{success,warning,error,info,brand}` | `<Callout>` | estados de UI |
| `.flash--{success,error,warning,info}` | — | flashed messages Flask |
| `.tag` + `.tag--{success,warning,error,info,brand,active,inactive,priority-*}` | `<Tag>` | badges |
| `.btn--{primary,secondary,danger,link,small}` | `<ButtonPrimary>` etc. | botones |
| `.field` + `.field__label/help/error` | `<Form>` + fields | formularios |
| `.text-input` / `.select` / `.textarea` | `<TextField>` / `<Select>` | inputs |
| `.breadcrumb` | — | `<nav><ol>` semántico |
| `.accordion-item` + `.accordion-item__summary/content` | `<AccordionItem>` | `<details>` nativo |
| `.status--{borrador,activo,archivado,...}` | — | pills legacy (expediente/sección) |
| `.muted` / `.empty` / `.meta` / `.divider` | — | utilities varias |

## Hard-rule reminder

- **TODO color**: `var(--mistica-color-*)`. Nunca hex.
- **TODO border-radius**: `var(--mistica-border-radius-*)`.
- **TODO font-size**: `mistica-text-{1..10}` o `mistica-text-title{1..4}`.
- **NO sobrescribir** `body { background }` — Mistica lo aplica
  automáticamente vía `[data-mistica-skin]`.
- **NO usar** clases `mistica-stack`, `mistica-callout`, etc. — son
  nombres de componentes React que no existen en el CSS build.
  Usar las utility classes de `ofelia-base.css`.

## License

MIT (this repo). Mistica itself is MIT-licensed by Telefónica.
Movistar Sans is proprietary and licensed internally by Telefónica —
do NOT redistribute outside the organization.
