# ============================================================
#  ui.R  ·  REDISEÑO PREMIUM v2.0
#  Causas de Defunción Medellín — Análisis & Clasificación
#
#  LIBRERÍA RECOMENDADA: bs4Dash (ver comentarios al final)
#  LIBRERÍA ACTUAL: shinydashboard + CSS override completo
# ============================================================

# ── CSS premium completo ─────────────────────────────────────
CSS_PREMIUM <- "
/* ═══════════════════════════════════════════════════════════
   1. FUENTES E IMPORTACIONES
   ═══════════════════════════════════════════════════════════ */
@import url('https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,600;9..40,700&family=Sora:wght@400;600;700;800&display=swap');

/* ═══════════════════════════════════════════════════════════
   2. VARIABLES GLOBALES
   ═══════════════════════════════════════════════════════════ */
:root {
  --p:          #6366f1;
  --p-dark:     #4f46e5;
  --p-light:    #eef2ff;
  --p-ring:     rgba(99,102,241,.25);
  --green:      #10b981;
  --green-lt:   #ecfdf5;
  --red:        #ef4444;
  --red-lt:     #fef2f2;
  --amber:      #f59e0b;
  --amber-lt:   #fffbeb;
  --blue:       #3b82f6;
  --blue-lt:    #eff6ff;
  --sidebar-bg: #0f172a;
  --sidebar-h:  #07101e;
  --body-bg:    #f1f5f9;
  --card-bg:    #ffffff;
  --border:     #e2e8f0;
  --txt1:       #0f172a;
  --txt2:       #475569;
  --txt3:       #94a3b8;
  --sh-sm:  0 1px 3px rgba(0,0,0,.07), 0 1px 2px rgba(0,0,0,.05);
  --sh-md:  0 4px 12px rgba(0,0,0,.08), 0 2px 4px rgba(0,0,0,.04);
  --sh-lg:  0 10px 30px rgba(0,0,0,.09), 0 4px 8px rgba(0,0,0,.04);
  --r:   12px;
  --r-sm: 8px;
  --r-lg: 16px;
}

/* ═══════════════════════════════════════════════════════════
   3. RESET GLOBAL Y TIPOGRAFÍA
   ═══════════════════════════════════════════════════════════ */
*, *::before, *::after { box-sizing: border-box; }

body, .content-wrapper, .main-footer {
  font-family: 'DM Sans', system-ui, -apple-system, sans-serif !important;
  font-size: 14px !important;
  color: var(--txt1) !important;
  -webkit-font-smoothing: antialiased;
}

h1, h2, h3, h4, h5, h6 {
  font-family: 'Sora', 'DM Sans', sans-serif !important;
  font-weight: 700 !important;
  color: var(--txt1) !important;
  letter-spacing: -0.02em;
}

p { color: var(--txt2) !important; line-height: 1.75 !important; }

a { color: var(--p) !important; text-decoration: none !important; }
a:hover { color: var(--p-dark) !important; }

/* ═══════════════════════════════════════════════════════════
   4. HEADER / NAVBAR
   ═══════════════════════════════════════════════════════════ */
.skin-blue .main-header .logo,
.skin-blue .main-header .navbar {
  background-color: var(--sidebar-h) !important;
  border-bottom: 1px solid rgba(255,255,255,.05) !important;
  box-shadow: none !important;
}

.main-header .logo {
  font-family: 'Sora', sans-serif !important;
  font-size: 13px !important;
  font-weight: 700 !important;
  letter-spacing: -0.01em !important;
  color: #f1f5f9 !important;
  padding: 0 16px !important;
  display: flex !important;
  align-items: center !important;
  gap: 10px !important;
}

.skin-blue .main-header .navbar .nav > li > a {
  color: var(--txt3) !important;
}
.skin-blue .main-header .navbar .nav > li > a:hover { color: #f1f5f9 !important; }

/* ═══════════════════════════════════════════════════════════
   5. SIDEBAR MODERNO
   ═══════════════════════════════════════════════════════════ */
.skin-blue .main-sidebar,
.skin-blue .left-side {
  background-color: var(--sidebar-bg) !important;
  border-right: none !important;
  box-shadow: 4px 0 20px rgba(0,0,0,.15) !important;
}

.skin-blue .sidebar-menu > li > a {
  color: #94a3b8 !important;
  font-size: 13px !important;
  font-weight: 500 !important;
  padding: 10px 18px !important;
  border-radius: 0 !important;
  transition: all .15s ease !important;
  border-left: 3px solid transparent !important;
  display: flex !important;
  align-items: center !important;
  gap: 10px !important;
}

.skin-blue .sidebar-menu > li > a:hover {
  color: #f1f5f9 !important;
  background: rgba(99,102,241,.1) !important;
  border-left-color: var(--p) !important;
}

.skin-blue .sidebar-menu > li.active > a,
.skin-blue .sidebar-menu > li.menu-open > a {
  color: #ffffff !important;
  background: rgba(99,102,241,.15) !important;
  border-left-color: var(--p) !important;
  font-weight: 600 !important;
}

.skin-blue .sidebar-menu > li > .treeview-menu {
  background: rgba(0,0,0,.2) !important;
  padding: 4px 0 !important;
}

.skin-blue .treeview-menu > li > a {
  color: #64748b !important;
  font-size: 12.5px !important;
  font-weight: 400 !important;
  padding: 7px 16px 7px 44px !important;
  transition: all .15s ease !important;
}

.skin-blue .treeview-menu > li > a:hover,
.skin-blue .treeview-menu > li.active > a {
  color: #c7d2fe !important;
  background: transparent !important;
}

.skin-blue .treeview-menu > li.active > a {
  color: #a5b4fc !important;
  font-weight: 600 !important;
}

.sidebar-menu .fa, .sidebar-menu .glyphicon {
  width: 16px !important;
  text-align: center !important;
}

/* Sidebar toggle arrow */
.skin-blue .sidebar-menu > li > a > .pull-right-container > .fa-angle-left {
  color: #475569 !important;
}

/* ═══════════════════════════════════════════════════════════
   6. CONTENT WRAPPER
   ═══════════════════════════════════════════════════════════ */
.content-wrapper, .right-side {
  background-color: var(--body-bg) !important;
  min-height: 100vh !important;
}

.content { padding: 24px !important; }
.tab-content { background: transparent !important; }

/* ═══════════════════════════════════════════════════════════
   7. BOX → CARD MODERNO
   ═══════════════════════════════════════════════════════════ */
.box {
  background: var(--card-bg) !important;
  border: 1px solid var(--border) !important;
  border-radius: var(--r) !important;
  box-shadow: var(--sh-sm) !important;
  border-top: none !important;
  margin-bottom: 20px !important;
  overflow: visible !important;
  transition: box-shadow .2s ease !important;
}

.box:hover { box-shadow: var(--sh-md) !important; }

/* Mantiene esquinas redondeadas en header aunque overflow sea visible */
.box > .box-header:first-child {
  border-radius: var(--r) var(--r) 0 0 !important;
  overflow: hidden !important;
}

.box-header {
  background: transparent !important;
  border-bottom: 1px solid var(--border) !important;
  padding: 16px 20px !important;
  display: flex !important;
  align-items: center !important;
}

.box-title {
  font-family: 'Sora', sans-serif !important;
  font-size: 13.5px !important;
  font-weight: 700 !important;
  color: var(--txt1) !important;
  letter-spacing: -0.01em !important;
  display: flex !important;
  align-items: center !important;
  gap: 8px !important;
}

.box-title .fa, .box-title .glyphicon {
  color: var(--p) !important;
  font-size: 13px !important;
}

.box-body {
  padding: 20px !important;
}

/* Acento de color lateral en box con solidHeader */
.box.box-solid > .box-header {
  border-top-left-radius: var(--r) !important;
  border-top-right-radius: var(--r) !important;
}

.box.box-primary.box-solid > .box-header { background: #f5f3ff !important; border-bottom-color: #ddd6fe !important; }
.box.box-success.box-solid  > .box-header { background: #f0fdf4 !important; border-bottom-color: #bbf7d0 !important; }
.box.box-warning.box-solid  > .box-header { background: #fffbeb !important; border-bottom-color: #fde68a !important; }
.box.box-danger.box-solid   > .box-header { background: #fff1f2 !important; border-bottom-color: #fecdd3 !important; }
.box.box-info.box-solid     > .box-header { background: #eff6ff !important; border-bottom-color: #bfdbfe !important; }

.box.box-primary.box-solid > .box-header .box-title { color: var(--p) !important; }
.box.box-success.box-solid  > .box-header .box-title { color: #059669 !important; }
.box.box-warning.box-solid  > .box-header .box-title { color: #d97706 !important; }
.box.box-danger.box-solid   > .box-header .box-title { color: #dc2626 !important; }
.box.box-info.box-solid     > .box-header .box-title { color: var(--blue) !important; }

/* ═══════════════════════════════════════════════════════════
   8. VALUE BOXES — TARJETAS BLANCAS COHESIVAS
   ═══════════════════════════════════════════════════════════ */

/* Base: todas blancas, mismo estilo, sin arcoíris */
.value-box {
  background: var(--card-bg) !important;
  border-radius: var(--r) !important;
  box-shadow: var(--sh-sm) !important;
  border: 1px solid var(--border) !important;
  overflow: hidden !important;
  transition: all .2s ease !important;
  margin-bottom: 20px !important;
}
.value-box:hover {
  box-shadow: var(--sh-md) !important;
  transform: translateY(-2px) !important;
  border-color: #c7d2fe !important;
}

/* Quitar colores de fondo de AdminLTE — paleta unificada */
.value-box.bg-aqua,
.value-box.bg-blue,
.value-box.bg-green,
.value-box.bg-yellow,
.value-box.bg-red,
.value-box.bg-purple,
.value-box.bg-navy,
.value-box.bg-teal,
.value-box.bg-maroon,
.value-box.bg-orange,
.value-box.bg-lime,
.value-box.bg-fuchsia,
.value-box.bg-black,
.value-box.bg-gray {
  background: var(--card-bg) !important;
  color: var(--txt1) !important;
}

/* Ícono: círculo de color por clase AdminLTE */
.value-box .value-box-icon {
  width: 68px !important;
  min-width: 68px !important;
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  font-size: 22px !important;
  border-right: 1px solid var(--border) !important;
  background: var(--p-light) !important;
  color: var(--p) !important;
}

/* Ajusta tono del ícono según la clase original */
.value-box.bg-aqua   .value-box-icon { background: #f0f9ff !important; color: #0284c7 !important; }
.value-box.bg-blue   .value-box-icon { background: var(--p-light)  !important; color: var(--p) !important; }
.value-box.bg-green  .value-box-icon { background: var(--green-lt) !important; color: var(--green) !important; }
.value-box.bg-yellow .value-box-icon { background: var(--amber-lt) !important; color: var(--amber) !important; }
.value-box.bg-red    .value-box-icon { background: var(--red-lt)   !important; color: var(--red)   !important; }
.value-box.bg-purple .value-box-icon { background: #f5f3ff !important; color: #7c3aed !important; }
.value-box.bg-navy   .value-box-icon { background: #f1f5f9 !important; color: #334155 !important; }
.value-box.bg-teal   .value-box-icon { background: #f0fdfa !important; color: #0d9488 !important; }
.value-box.bg-orange .value-box-icon { background: #fff7ed !important; color: #ea580c !important; }
.value-box.bg-maroon .value-box-icon { background: #fdf2f8 !important; color: #be185d !important; }

/* Contenido interno */
.value-box .inner {
  padding: 14px 16px !important;
  flex: 1 !important;
  min-width: 0 !important;        /* permite que el texto haga wrap */
}

/* Número/valor principal */
.value-box h3 {
  font-family: 'Sora', sans-serif !important;
  font-size: 14px !important;
  font-weight: 800 !important;
  letter-spacing: -0.02em !important;
  margin: 0 0 4px !important;
  line-height: 1.25 !important;
  color: var(--txt1) !important;
  white-space: normal !important;
  word-break: break-word !important;
  overflow-wrap: break-word !important;
  hyphens: auto !important;
}

/* Etiqueta descriptiva — fix de overflow para textos largos */
.value-box p {
  font-size: 11px !important;
  font-weight: 600 !important;
  text-transform: uppercase !important;
  letter-spacing: .05em !important;
  margin: 0 !important;
  color: var(--txt3) !important;
  /* texto largo: que haga wrap en vez de salirse */
  white-space: normal !important;
  word-break: break-word !important;
  overflow-wrap: break-word !important;
  line-height: 1.4 !important;
}

/* INFO BOXES */
.info-box {
  border-radius: var(--r) !important;
  box-shadow: var(--sh-sm) !important;
  border: 1px solid var(--border) !important;
  min-height: 72px !important;
  margin-bottom: 20px !important;
  overflow: hidden !important;
  transition: box-shadow .2s ease !important;
}
.info-box:hover { box-shadow: var(--sh-md) !important; }

.info-box-icon {
  border-radius: var(--r) 0 0 var(--r) !important;
  width: 70px !important;
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  font-size: 22px !important;
}

.info-box-content {
  padding: 10px 14px !important;
}

.info-box-text {
  font-size: 11px !important;
  font-weight: 600 !important;
  text-transform: uppercase !important;
  letter-spacing: .06em !important;
  color: var(--txt3) !important;
}

.info-box-number {
  font-family: 'Sora', sans-serif !important;
  font-size: 20px !important;
  font-weight: 700 !important;
  color: var(--txt1) !important;
  letter-spacing: -0.02em !important;
}

/* ═══════════════════════════════════════════════════════════
   9. BOTONES
   ═══════════════════════════════════════════════════════════ */
.btn {
  font-family: 'DM Sans', sans-serif !important;
  font-size: 13px !important;
  font-weight: 600 !important;
  border-radius: var(--r-sm) !important;
  padding: 8px 18px !important;
  transition: all .15s ease !important;
  border: none !important;
  letter-spacing: .01em !important;
  box-shadow: var(--sh-sm) !important;
}

.btn-primary, .btn-success.btn-block:not(.btn-default) {
  background: linear-gradient(135deg, var(--p), var(--p-dark)) !important;
  color: white !important;
  box-shadow: 0 2px 8px var(--p-ring) !important;
}
.btn-primary:hover {
  background: linear-gradient(135deg, var(--p-dark), #3730a3) !important;
  transform: translateY(-1px) !important;
  box-shadow: 0 4px 12px var(--p-ring) !important;
}

.btn-success {
  background: linear-gradient(135deg, var(--green), #059669) !important;
  color: white !important;
  box-shadow: 0 2px 8px rgba(16,185,129,.3) !important;
}
.btn-success:hover {
  transform: translateY(-1px) !important;
  box-shadow: 0 4px 12px rgba(16,185,129,.4) !important;
}

.btn-default {
  background: white !important;
  color: var(--txt2) !important;
  border: 1px solid var(--border) !important;
  box-shadow: var(--sh-sm) !important;
}
.btn-default:hover {
  background: var(--body-bg) !important;
  color: var(--txt1) !important;
  border-color: #cbd5e1 !important;
}

.btn-block {
  width: 100% !important;
  display: block !important;
}

/* ═══════════════════════════════════════════════════════════
   10. FORM CONTROLS MODERNOS
   ═══════════════════════════════════════════════════════════ */
.form-control {
  font-family: 'DM Sans', sans-serif !important;
  font-size: 13px !important;
  color: var(--txt1) !important;
  background: #f8fafc !important;
  border: 1.5px solid var(--border) !important;
  border-radius: var(--r-sm) !important;
  padding: 8px 12px !important;
  height: auto !important;
  min-height: 38px !important;
  box-shadow: none !important;
  transition: border-color .15s ease, box-shadow .15s ease !important;
}
.form-control:focus {
  border-color: var(--p) !important;
  background: white !important;
  box-shadow: 0 0 0 3px var(--p-ring) !important;
  outline: none !important;
}

.selectize-input {
  font-family: 'DM Sans', sans-serif !important;
  font-size: 13px !important;
  border: 1.5px solid var(--border) !important;
  border-radius: var(--r-sm) !important;
  padding: 7px 12px !important;
  background: #f8fafc !important;
  box-shadow: none !important;
  min-height: 38px !important;
}
.selectize-input.focus {
  border-color: var(--p) !important;
  background: white !important;
  box-shadow: 0 0 0 3px var(--p-ring) !important;
}

.selectize-dropdown {
  font-family: 'DM Sans', sans-serif !important;
  font-size: 13px !important;
  border-radius: var(--r-sm) !important;
  border: 1px solid var(--border) !important;
  box-shadow: var(--sh-lg) !important;
  z-index: 99999 !important;
  position: absolute !important;
}

.selectize-dropdown-content .option:hover,
.selectize-dropdown-content .option.active {
  background: var(--p-light) !important;
  color: var(--p-dark) !important;
}

label {
  font-size: 12px !important;
  font-weight: 600 !important;
  color: var(--txt2) !important;
  text-transform: uppercase !important;
  letter-spacing: .05em !important;
  margin-bottom: 6px !important;
  display: block !important;
}

.irs--shiny .irs-bar { background: var(--p) !important; }
.irs--shiny .irs-handle { background: var(--p) !important; border-color: var(--p-dark) !important; }
.irs--shiny .irs-from, .irs--shiny .irs-to, .irs--shiny .irs-single {
  background: var(--p) !important; border-radius: 4px !important;
}

/* Radio & checkbox */
.radio label, .checkbox label {
  font-size: 13px !important;
  font-weight: 400 !important;
  text-transform: none !important;
  letter-spacing: 0 !important;
  color: var(--txt2) !important;
  cursor: pointer !important;
}

/* ═══════════════════════════════════════════════════════════
   11. DATATABLE MODERNO
   ═══════════════════════════════════════════════════════════ */
table.dataTable {
  font-family: 'DM Sans', sans-serif !important;
  font-size: 13px !important;
  border: none !important;
  border-collapse: collapse !important;
}

table.dataTable thead th {
  font-size: 11px !important;
  font-weight: 700 !important;
  text-transform: uppercase !important;
  letter-spacing: .06em !important;
  color: var(--txt3) !important;
  background: var(--body-bg) !important;
  border-bottom: 1.5px solid var(--border) !important;
  padding: 10px 14px !important;
  white-space: nowrap !important;
}

table.dataTable tbody tr {
  border-bottom: 1px solid #f1f5f9 !important;
  transition: background .1s ease !important;
}
table.dataTable tbody tr:hover { background: var(--p-light) !important; }

table.dataTable tbody td {
  padding: 10px 14px !important;
  color: var(--txt2) !important;
  vertical-align: middle !important;
}

.dataTables_wrapper .dataTables_filter input {
  border: 1.5px solid var(--border) !important;
  border-radius: var(--r-sm) !important;
  padding: 6px 12px !important;
  font-family: 'DM Sans', sans-serif !important;
  font-size: 13px !important;
  background: #f8fafc !important;
}
.dataTables_wrapper .dataTables_filter input:focus {
  border-color: var(--p) !important;
  box-shadow: 0 0 0 3px var(--p-ring) !important;
  outline: none !important;
}

.dataTables_wrapper .dataTables_length select {
  border: 1.5px solid var(--border) !important;
  border-radius: var(--r-sm) !important;
  padding: 4px 8px !important;
  background: #f8fafc !important;
  font-family: 'DM Sans', sans-serif !important;
  font-size: 13px !important;
}

.dataTables_paginate .paginate_button {
  border-radius: 6px !important;
  padding: 4px 10px !important;
  font-size: 12px !important;
  font-weight: 600 !important;
  margin: 0 2px !important;
}
.dataTables_paginate .paginate_button.current {
  background: var(--p) !important;
  border-color: var(--p) !important;
  color: white !important;
}
.dataTables_paginate .paginate_button:hover:not(.current) {
  background: var(--p-light) !important;
  border-color: var(--border) !important;
  color: var(--p) !important;
}

/* ── FIX: filtros de columna DT (filter=top) no recortados ─
   dataTables_scrollHead contiene el <thead> con los <select>
   All. Con overflow:visible el menu puede salir del area
   del encabezado y mostrarse sobre el cuerpo de la tabla.
   Se mantiene overflow-x:auto en scrollBody para el scroll
   horizontal y se eleva z-index de los <select> del thead.  */
div.dataTables_scrollHead {
  overflow: visible !important;
}
div.dataTables_scrollBody {
  overflow-x: auto !important;
  /* overflow-y queda como DT lo calcule (auto/scroll) */
}
div.dataTables_scroll {
  overflow: visible !important;
}
/* Los <select> de los filtros de columna flotan sobre la tabla */
table.dataTable thead tr.filters td select,
table.dataTable thead tr.filters td input[type='search'] {
  position: relative !important;
  z-index: 9999 !important;
}
/* Estilo visual de los select de filtro de columna */
table.dataTable thead tr.filters td select {
  width: 100% !important;
  font-family: 'DM Sans', sans-serif !important;
  font-size: 12px !important;
  border: 1.5px solid var(--border) !important;
  border-radius: var(--r-sm) !important;
  padding: 4px 6px !important;
  background: #f8fafc !important;
  color: var(--txt2) !important;
  cursor: pointer !important;
}
table.dataTable thead tr.filters td select:focus {
  border-color: var(--p) !important;
  box-shadow: 0 0 0 3px var(--p-ring) !important;
  outline: none !important;
}
table.dataTable thead tr.filters td input[type='search'] {
  width: 100% !important;
  font-family: 'DM Sans', sans-serif !important;
  font-size: 12px !important;
  border: 1.5px solid var(--border) !important;
  border-radius: var(--r-sm) !important;
  padding: 4px 6px !important;
  background: #f8fafc !important;
}

/* ═══════════════════════════════════════════════════════════
   12. PLOTLY CONTAINER
   ═══════════════════════════════════════════════════════════ */
.plotly { border-radius: var(--r-sm) !important; }
.js-plotly-plot { width: 100% !important; }

/* ═══════════════════════════════════════════════════════════
   13. COMPONENTES PERSONALIZADOS (SECCIONES, BADGES, ETC.)
   ═══════════════════════════════════════════════════════════ */

/* Encabezado hero de sección */
.section-hero {
  background: linear-gradient(135deg, #0f172a 0%, #1e293b 60%, #312e81 100%);
  border-radius: var(--r) !important;
  padding: 32px 36px !important;
  margin-bottom: 8px !important;
  position: relative !important;
  overflow: hidden !important;
}
.section-hero::before {
  content: '';
  position: absolute;
  top: -50px; right: -50px;
  width: 200px; height: 200px;
  background: radial-gradient(circle, rgba(99,102,241,.3) 0%, transparent 70%);
  pointer-events: none;
}
.section-hero h3 {
  color: #f1f5f9 !important;
  font-size: 20px !important;
  margin: 0 0 10px !important;
}
.section-hero p {
  color: #94a3b8 !important;
  margin: 0 !important;
  font-size: 14px !important;
  line-height: 1.7 !important;
  max-width: 680px !important;
}
.section-hero strong { color: #a5b4fc !important; }

/* Stat card oscura */
.stat-card-dark {
  background: rgba(255,255,255,.05) !important;
  border: 1px solid rgba(255,255,255,.1) !important;
  border-radius: var(--r-sm) !important;
  padding: 14px 18px !important;
  text-align: center !important;
}
.stat-card-dark .stat-value {
  font-family: 'Sora', sans-serif !important;
  font-size: 22px !important;
  font-weight: 800 !important;
  color: #f1f5f9 !important;
  letter-spacing: -0.03em !important;
  line-height: 1.2 !important;
}
.stat-card-dark .stat-label {
  font-size: 11px !important;
  font-weight: 500 !important;
  color: #64748b !important;
  text-transform: uppercase !important;
  letter-spacing: .06em !important;
  margin-top: 2px !important;
}

/* Badge de tipo de variable */
.var-badge {
  display: inline-block !important;
  font-size: 10.5px !important;
  font-weight: 700 !important;
  padding: 3px 9px !important;
  border-radius: 999px !important;
  text-transform: uppercase !important;
  letter-spacing: .05em !important;
  margin-bottom: 8px !important;
}
.vb-num  { background: var(--blue-lt)  !important; color: var(--blue)  !important; }
.vb-cat  { background: var(--p-light)  !important; color: var(--p)     !important; }
.vb-bin  { background: var(--green-lt) !important; color: var(--green) !important; }
.vb-ord  { background: var(--amber-lt) !important; color: var(--amber) !important; }
.vb-trg  { background: var(--red-lt)   !important; color: var(--red)   !important; }

/* Tarjeta de variable (panel Problema) */
.var-card {
  background: white !important;
  border: 1px solid var(--border) !important;
  border-radius: var(--r) !important;
  padding: 16px !important;
  margin-bottom: 14px !important;
  transition: all .2s ease !important;
  box-shadow: var(--sh-sm) !important;
}
.var-card:hover {
  border-color: #c7d2fe !important;
  box-shadow: var(--sh-md), 0 0 0 1px var(--p-light) !important;
}
.var-card .vc-icon {
  width: 36px !important; height: 36px !important;
  border-radius: var(--r-sm) !important;
  display: flex !important; align-items: center !important; justify-content: center !important;
  font-size: 15px !important;
  color: white !important;
  margin-bottom: 10px !important;
  flex-shrink: 0 !important;
}
.var-card .vc-name {
  font-weight: 700 !important;
  font-size: 13px !important;
  color: var(--txt1) !important;
  margin-bottom: 2px !important;
}
.var-card .vc-desc {
  font-size: 12px !important;
  color: var(--txt3) !important;
  line-height: 1.55 !important;
  margin: 6px 0 !important;
}
.var-card .vc-insight {
  font-size: 11px !important;
  font-weight: 600 !important;
  color: var(--p) !important;
  display: flex !important;
  align-items: center !important;
  gap: 4px !important;
  margin-top: 6px !important;
}

/* Tarjeta de etapa */
.stage-card {
  background: white !important;
  border: 1px solid var(--border) !important;
  border-radius: var(--r) !important;
  padding: 20px !important;
  height: 100% !important;
  box-shadow: var(--sh-sm) !important;
  transition: all .2s ease !important;
}
.stage-card:hover { box-shadow: var(--sh-md) !important; transform: translateY(-2px) !important; }
.stage-card .stage-num {
  font-family: 'Sora', sans-serif !important;
  font-size: 11px !important;
  font-weight: 800 !important;
  text-transform: uppercase !important;
  letter-spacing: .1em !important;
  margin-bottom: 12px !important;
  display: flex !important;
  align-items: center !important;
  gap: 8px !important;
}
.stage-card .stage-title {
  font-family: 'Sora', sans-serif !important;
  font-size: 15px !important;
  font-weight: 700 !important;
  color: var(--txt1) !important;
  margin-bottom: 8px !important;
}
.stage-card p { font-size: 13px !important; color: var(--txt2) !important; margin: 0 !important; line-height: 1.65 !important; }

/* Objetivo pill */
.obj-item {
  display: flex !important;
  align-items: flex-start !important;
  gap: 12px !important;
  padding: 14px 16px !important;
  background: white !important;
  border: 1px solid var(--border) !important;
  border-radius: var(--r) !important;
  margin-bottom: 10px !important;
  box-shadow: var(--sh-sm) !important;
  transition: box-shadow .2s ease !important;
}
.obj-item:hover { box-shadow: var(--sh-md) !important; }
.obj-item .obj-num {
  font-family: 'Sora', sans-serif !important;
  font-size: 12px !important;
  font-weight: 800 !important;
  min-width: 28px !important;
  height: 28px !important;
  border-radius: 8px !important;
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  color: white !important;
  flex-shrink: 0 !important;
  margin-top: 1px !important;
}
.obj-item p { font-size: 13px !important; color: var(--txt2) !important; margin: 0 !important; line-height: 1.65 !important; }

/* Eje section header */
.eje-header {
  display: flex !important;
  align-items: center !important;
  gap: 10px !important;
  margin: 20px 0 12px !important;
  padding-bottom: 10px !important;
  border-bottom: 1px solid var(--border) !important;
}
.eje-header .eje-dot {
  width: 4px !important; height: 28px !important;
  border-radius: 2px !important;
  flex-shrink: 0 !important;
}
.eje-header .eje-title {
  font-family: 'Sora', sans-serif !important;
  font-size: 13px !important;
  font-weight: 700 !important;
  color: var(--txt1) !important;
  letter-spacing: -.01em !important;
  margin: 0 !important;
  text-transform: none !important;
}
.eje-header .eje-icon { color: var(--txt3) !important; font-size: 13px !important; }

/* Blockquote moderno */
.modern-quote {
  background: var(--p-light) !important;
  border-left: 4px solid var(--p) !important;
  border-radius: 0 var(--r-sm) var(--r-sm) 0 !important;
  padding: 16px 20px !important;
  margin: 16px 0 !important;
}
.modern-quote em {
  font-family: 'Sora', sans-serif !important;
  font-size: 14.5px !important;
  font-style: italic !important;
  color: var(--txt1) !important;
  line-height: 1.7 !important;
}

/* Panel de configuración del modelo */
.config-panel {
  background: #f8fafc !important;
  border: 1px solid var(--border) !important;
  border-radius: var(--r) !important;
  padding: 20px !important;
}

/* Log de entrenamiento */
.training-log {
  background: #0f172a !important;
  color: #94a3b8 !important;
  border-radius: var(--r-sm) !important;
  padding: 14px 16px !important;
  font-family: 'Fira Code', 'Courier New', monospace !important;
  font-size: 12px !important;
  line-height: 1.6 !important;
  max-height: 200px !important;
  overflow-y: auto !important;
  border: none !important;
}

pre.shiny-text-output {
  background: #0f172a !important;
  color: #a5b4fc !important;
  border-radius: var(--r-sm) !important;
  padding: 14px 16px !important;
  font-size: 12px !important;
  border: none !important;
  box-shadow: var(--sh-sm) !important;
}

/* Resultado predicción */
.pred-result-card {
  background: linear-gradient(135deg, var(--green) 0%, #059669 100%) !important;
  border-radius: var(--r) !important;
  padding: 24px !important;
  color: white !important;
  text-align: center !important;
  box-shadow: 0 8px 24px rgba(16,185,129,.3) !important;
}
.pred-result-card .pred-label {
  font-size: 11px !important;
  font-weight: 600 !important;
  text-transform: uppercase !important;
  letter-spacing: .1em !important;
  opacity: .8 !important;
  margin-bottom: 8px !important;
}
.pred-result-card .pred-value {
  font-family: 'Sora', sans-serif !important;
  font-size: 18px !important;
  font-weight: 700 !important;
}

/* Alerta predicción */
.alert { border-radius: var(--r-sm) !important; border: none !important; font-size: 13px !important; }
.alert-warning { background: var(--amber-lt) !important; color: #92400e !important; }
.alert-info    { background: var(--blue-lt)  !important; color: #1e40af !important; }
.alert-danger  { background: var(--red-lt)   !important; color: #991b1b !important; }
.alert-success { background: var(--green-lt) !important; color: #065f46 !important; }

/* Tabla de resumen de caso */
.table-condensed { font-size: 13px !important; }
.table-condensed th {
  background: var(--body-bg) !important;
  color: var(--txt3) !important;
  font-size: 11px !important;
  font-weight: 700 !important;
  text-transform: uppercase !important;
  letter-spacing: .05em !important;
  border: none !important;
  padding: 8px 12px !important;
}
.table-condensed td {
  border-top: 1px solid var(--border) !important;
  padding: 9px 12px !important;
  color: var(--txt2) !important;
  vertical-align: middle !important;
}

/* Conteo DT */
.tab-count-badge {
  display: inline-flex !important;
  align-items: center !important;
  background: var(--p-light) !important;
  color: var(--p) !important;
  border-radius: var(--r) !important;
  padding: 12px 18px !important;
  font-weight: 700 !important;
  font-size: 14px !important;
}
.tab-count-badge .count-num {
  font-family: 'Sora', sans-serif !important;
  font-size: 22px !important;
  font-weight: 800 !important;
}

/* Separador */
hr { border-color: var(--border) !important; margin: 16px 0 !important; }

/* numericInput */
input[type='number'] {
  font-family: 'DM Sans', sans-serif !important;
  font-size: 13px !important;
  border: 1.5px solid var(--border) !important;
  border-radius: var(--r-sm) !important;
  padding: 8px 12px !important;
  background: #f8fafc !important;
  color: var(--txt1) !important;
  box-shadow: none !important;
  transition: border-color .15s !important;
}
input[type='number']:focus {
  border-color: var(--p) !important;
  box-shadow: 0 0 0 3px var(--p-ring) !important;
  background: white !important;
  outline: none !important;
}

/* Scrollbar personalizado */
::-webkit-scrollbar { width: 6px; height: 6px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
::-webkit-scrollbar-thumb:hover { background: #94a3b8; }

/* Loading spinner */
.shiny-spinner-output-container > .load-container { background: transparent !important; }
"

# ── Helpers de componentes ────────────────────────────────────

# KPI stat card para la hero section
heroStat <- function(value, label) {
  tags$div(class = "stat-card-dark",
    tags$div(class = "stat-value", value),
    tags$div(class = "stat-label", label)
  )
}

# Tarjeta de etapa del proyecto
stageCard <- function(num, title, desc, color = "#6366f1") {
  badge_style <- paste0("background:", color, "1a; color:", color, ";")
  tags$div(class = "stage-card",
    tags$div(class = "stage-num",
      tags$span(style = paste0("display:inline-block;background:", color,
        ";color:white;border-radius:6px;padding:2px 9px;font-size:11px;font-weight:800;"), num),
    ),
    tags$div(class = "stage-title", title),
    tags$p(desc)
  )
}

# Tarjeta de objetivo
objItem <- function(num, text, color = "#6366f1") {
  tags$div(class = "obj-item",
    tags$span(class = "obj-num", style = paste0("background:", color, ";"), num),
    tags$p(HTML(text))
  )
}

# Header de eje temático
ejeHeader <- function(icon_name, title, color = "#6366f1") {
  tags$div(class = "eje-header",
    tags$div(class = "eje-dot", style = paste0("background:", color, ";")),
    icon(icon_name, class = "eje-icon"),
    tags$h5(class = "eje-title", title)
  )
}

# Tarjeta de variable
varCard <- function(icon_name, name, badge_class, badge_label, desc, insight, color = "#6366f1") {
  tags$div(class = "var-card",
    tags$div(style = "display:flex; align-items:flex-start; gap:12px;",
      tags$div(class = "vc-icon", style = paste0("background:", color, ";"), icon(icon_name)),
      tags$div(style = "flex:1; min-width:0;",
        tags$div(class = "vc-name", name),
        tags$span(class = paste("var-badge", badge_class), badge_label),
        tags$div(class = "vc-desc", desc),
        tags$div(class = "vc-insight", icon("lightbulb", style = "font-size:10px;"), insight)
      )
    )
  )
}

# ── UI principal ──────────────────────────────────────────────
ui <- dashboardPage(
  skin = "blue",

  # ── HEADER ─────────────────────────────────────────────────
  dashboardHeader(
    titleWidth = 260,
    title = tags$span(
      style = "display:flex; align-items:center; gap:10px; height:50px;",
      tags$div(
        style = "width:30px; height:30px; background:linear-gradient(135deg,#6366f1,#4f46e5); border-radius:8px; display:flex; align-items:center; justify-content:center;",
        icon("heartbeat", style = "color:white; font-size:14px;")
      ),
      tags$div(
        tags$div(style = "font-family:'Sora',sans-serif; font-size:13px; font-weight:800; color:#f1f5f9; line-height:1.1;",
          "Mortalidad MDE"),
        tags$div(style = "font-size:10px; color:#475569; font-weight:400; letter-spacing:.04em;",
          "ANÁLISIS Y CLASIFICACIÓN")
      )
    )
  ),

  # ── SIDEBAR ────────────────────────────────────────────────
  dashboardSidebar(
    width = 240,
    tags$div(style = "padding:20px 16px 8px;",
      tags$div(style = "font-size:10px; font-weight:700; text-transform:uppercase; letter-spacing:.1em; color:#334155; margin-bottom:8px;",
        "NAVEGACIÓN")
    ),
    sidebarMenu(
      id = "tabs",
      menuItem("Introducción",  tabName = "intro",  icon = icon("home")),
      menuItem("Objetivos",     tabName = "obj",    icon = icon("bullseye")),
      menuItem("Planteamiento", tabName = "prob",   icon = icon("search")),
      menuItem("Exploración",   tabName = "eda",    icon = icon("chart-bar"),
        menuSubItem("Resumen estadístico", tabName = "eda_res"),
        menuSubItem("Visualizaciones",     tabName = "eda_viz"),
        menuSubItem("Tabla de datos",      tabName = "eda_tab")
      ),
      menuItem("Modelado",      tabName = "train",  icon = icon("cogs"),
               menuSubItem("Configuración",       tabName = "tr_sel"),
               menuSubItem("Métricas de modelos", tabName = "tr_met_rf")
      ),
      menuItem("Predicción",    tabName = "pred",   icon = icon("magic"),
        menuSubItem("Formulario",   tabName = "pr_form"),
        menuSubItem("Resultado",    tabName = "pr_res"),
        menuSubItem("Probabilidad", tabName = "pr_prob")
      ),
      menuItem("Métricas de los modelos",   tabName = "met_full",   icon = icon("chart-line")),
      menuItem("Predicción · Mejor Modelo", tabName = "pred_mejor", icon = icon("robot"))
    ),
    tags$div(style = "position:absolute; bottom:0; left:0; right:0; padding:16px; border-top:1px solid rgba(255,255,255,.05);",
      tags$div(style = "display:flex; align-items:center; gap:10px;",
        tags$div(style = "width:32px; height:32px; border-radius:8px; background:rgba(99,102,241,.2); display:flex; align-items:center; justify-content:center;",
          icon("database", style = "color:#a5b4fc; font-size:13px;")),
        tags$div(
          tags$div(style = "font-size:11px; font-weight:700; color:#64748b;", "MeData Medellín"),
          tags$div(style = "font-size:10px; color:#334155;", "~145K registros")
        )
      )
    )
  ),

  # ── BODY ───────────────────────────────────────────────────
  dashboardBody(

    tags$head(
      tags$style(HTML(CSS_PREMIUM)),
      tags$meta(name = "viewport", content = "width=device-width, initial-scale=1")
    ),

    tabItems(

      # ══════════════════════════════════════════════════════
      # INTRODUCCIÓN
      # ══════════════════════════════════════════════════════
      tabItem("intro",

        # Hero banner
        fluidRow(
          column(12,
            tags$div(class = "section-hero",
              tags$h3(icon("heartbeat", style = "color:#818cf8; margin-right:10px;"),
                "Causas de Defunción en Medellín"),
              tags$p(
                "Integración de ", tags$strong("Análisis Exploratorio (EDA)"), " y ",
                tags$strong("Machine Learning"), " para examinar y predecir causas de defunción",
                " registradas en Medellín (2012–2023) a partir de variables demográficas,",
                " temporales y socioeconómicas."
              ),
              tags$br(),
              fluidRow(
                column(3, heroStat("~145.000", "registros")),
                column(3, heroStat("2012 – 2023", "período analizado")),
                column(3, heroStat("9 variables", "de análisis")),
                column(3, heroStat("OPS 667", "nomenclatura"))
              )
            )
          )
        ),

        # ¿De qué trata? + etapas
        fluidRow(
          column(8,
            box(
              width = 12, solidHeader = TRUE, status = "primary",
              title = tags$span(icon("info-circle"), " Descripción del proyecto"),
              tags$p(
                "Se trabaja con el ", tags$strong("Registro de Defunciones de Medellín"), ",",
                " publicado en ", tags$a(href = "https://medata.gov.co/node/16570",
                  "MeData", target = "_blank"), ". El conjunto contiene aproximadamente ",
                tags$strong("145.000 registros"), " del período ", tags$strong("2012–2023"),
                " e incluye variables demográficas (sexo, edad, estado civil, nivel educativo),",
                " información de aseguramiento en salud y la ", tags$strong("causa básica de defunción"),
                " codificada según la nomenclatura OPS 667."
              ),
              tags$p(
                "El flujo de trabajo tiene tres etapas: ", tags$strong("análisis exploratorio"),
                " para examinar estructura y distribuciones; ",
                tags$strong("entrenamiento de un clasificador"),
                " (Random Forest / Árbol de decisión) para predecir el grupo de causa de muerte; y un módulo de ",
                tags$strong("predicción interactiva"), " donde el usuario ingresa datos de un caso individual."
              ),
              tags$p(
                "La variable objetivo es ", tags$strong("NOM_667_OPS_GRUPO"),
                ", que agrupa las defunciones en grandes categorías siguiendo",
                " los estándares de la Organización Panamericana de la Salud."
              )
            )
          ),
          column(4,
            box(
              width = 12, solidHeader = TRUE, status = "info",
              title = tags$span(icon("info-circle"), " Fuente de datos"),
              tags$div(style = "display:flex; flex-direction:column; gap:10px;",
                tags$div(style = "display:flex; justify-content:space-between; align-items:center; padding:10px 14px; background:#f8fafc; border-radius:10px;",
                  tags$span(style = "font-size:12px; font-weight:600; color:#64748b; text-transform:uppercase; letter-spacing:.04em;", "Portal"),
                  tags$span(style = "font-weight:700; color:#0f172a; font-size:13px;", "MeData Medellín")
                ),
                tags$div(style = "display:flex; justify-content:space-between; align-items:center; padding:10px 14px; background:#f8fafc; border-radius:10px;",
                  tags$span(style = "font-size:12px; font-weight:600; color:#64748b; text-transform:uppercase; letter-spacing:.04em;", "Registros"),
                  tags$span(style = "font-family:'Sora',sans-serif; font-weight:800; color:#0f172a; font-size:15px;", "~145.000")
                ),
                tags$div(style = "display:flex; justify-content:space-between; align-items:center; padding:10px 14px; background:#f8fafc; border-radius:10px;",
                  tags$span(style = "font-size:12px; font-weight:600; color:#64748b; text-transform:uppercase; letter-spacing:.04em;", "Periodo"),
                  tags$span(style = "font-weight:700; color:#0f172a; font-size:13px;", "2012 – 2023")
                ),
                tags$div(style = "display:flex; justify-content:space-between; align-items:center; padding:10px 14px; background:#f8fafc; border-radius:10px;",
                  tags$span(style = "font-size:12px; font-weight:600; color:#64748b; text-transform:uppercase; letter-spacing:.04em;", "Modelo"),
                  tags$span(style = "font-weight:700; color:#0f172a; font-size:13px;", "RF / Rpart")
                )
              )
            )
          )
        ),

        # Etapas
        fluidRow(
          column(12,
            box(
              width = 12, solidHeader = TRUE, status = "success",
              title = tags$span(icon("map"), " Etapas del proyecto"),
              fluidRow(
                column(4, stageCard("01", "Exploración de datos (EDA)",
                  "Resumen estadístico, distribuciones por sexo / edad / año, análisis territorial y relación entre variables demográficas y causas de muerte.",
                  color = "#3b82f6")),
                column(4, stageCard("02", "Entrenamiento del modelo",
                  "Selección de algoritmo (Random Forest / Árbol de decisión), partición train/test, evaluación con accuracy, kappa, precisión, recall y matriz de confusión.",
                  color = "#6366f1")),
                column(4, stageCard("03", "Predicción interactiva",
                  "Ingreso manual de datos de un caso, predicción del grupo de causa más probable y visualización de probabilidades por categoría.",
                  color = "#10b981"))
              )
            )
          )
        ),

        # Info boxes
        fluidRow(
          infoBox("Cobertura",     "2012 – 2023",           icon = icon("calendar"),  color = "blue",   width = 3),
          infoBox("Registros",     "~145.000",               icon = icon("database"),  color = "green",  width = 3),
          infoBox("Fuente",        "MeData Medellín",        icon = icon("globe"),     color = "purple", width = 3),
          infoBox("Clasificador",  "Random Forest / Rpart", icon = icon("cogs"),      color = "orange", width = 3)
        )
      ),

      # ══════════════════════════════════════════════════════
      # OBJETIVOS
      # ══════════════════════════════════════════════════════
      tabItem("obj",

        # Objetivo general hero
        fluidRow(
          column(12,
            tags$div(class = "section-hero",
              style = "background:linear-gradient(135deg,#064e3b 0%,#065f46 60%,#047857 100%);",
              tags$h3(icon("bullseye", style = "color:#6ee7b7; margin-right:10px;"),
                "Objetivo General"),
              tags$p(
                "Desarrollar una aplicación interactiva que integre el ",
                tags$strong("análisis exploratorio de datos (EDA)"),
                " y la construcción de un ",
                tags$strong("modelo de clasificación supervisado"),
                " sobre el registro de defunciones de Medellín (2012–2023), con el fin de identificar",
                " patrones de mortalidad, evaluar la capacidad predictiva de variables demográficas y",
                " socioeconómicas, y facilitar la toma de decisiones en salud pública."
              )
            )
          )
        ),

        # Objetivos específicos
        fluidRow(
          column(12,
            box(
              width = 12, solidHeader = TRUE, status = "primary",
              title = tags$span(icon("list-ol"), " Objetivos específicos"),

              ejeHeader("database", "Eje 1 — Gestión y calidad de los datos", color = "#3b82f6"),
              fluidRow(
                column(6, objItem("1",
                  "Examinar la <strong>estructura y calidad</strong> del conjunto de datos, identificando tipos de variables, valores faltantes, inconsistencias y transformaciones necesarias para el análisis.",
                  color = "#3b82f6")),
                column(6, objItem("2",
                  "Describir el comportamiento de las defunciones mediante <strong>variables demográficas</strong> (sexo, edad, estado civil, nivel educativo y régimen de afiliación al sistema de salud).",
                  color = "#3b82f6"))
              ),

              ejeHeader("chart-bar", "Eje 2 — Análisis exploratorio", color = "#f59e0b"),
              fluidRow(
                column(6, objItem("3",
                  "Analizar la <strong>distribución temporal</strong> de la mortalidad, identificando tendencias anuales, variaciones mensuales y patrones estacionales.",
                  color = "#f59e0b")),
                column(6, objItem("4",
                  "Explorar <strong>diferencias territoriales y poblacionales</strong> para detectar grupos de riesgo y comportamientos diferenciales en distintos segmentos de la población.",
                  color = "#f59e0b"))
              ),
              fluidRow(
                column(12, objItem("5",
                  "Estudiar la frecuencia y distribución de las principales <strong>causas de defunción (OPS 667)</strong> y su relación con variables sociodemográficas como nivel educativo y régimen de salud.",
                  color = "#f59e0b"))
              ),

              ejeHeader("cogs", "Eje 3 — Modelado y predicción", color = "#6366f1"),
              fluidRow(
                column(6, objItem("6",
                  "Construir y evaluar un <strong>modelo de clasificación supervisado</strong> (Random Forest / Árbol de decisión) para predecir el grupo de causa de muerte a partir de variables demográficas y socioeconómicas.",
                  color = "#6366f1")),
                column(6, objItem("7",
                  "Evaluar el rendimiento del modelo con métricas estándar (<strong>accuracy, kappa</strong>, precisión, recall) y analizar la importancia de variables para interpretar los factores más determinantes.",
                  color = "#6366f1"))
              ),
              fluidRow(
                column(12, objItem("8",
                  "Implementar un módulo de <strong>predicción interactiva</strong> que permita al usuario ingresar los datos de un caso individual y obtener el grupo de causa de muerte más probable con la distribución de probabilidades por categoría.",
                  color = "#6366f1"))
              )
            )
          )
        )
      ),

      # ══════════════════════════════════════════════════════
      # PLANTEAMIENTO DEL PROBLEMA
      # ══════════════════════════════════════════════════════
      tabItem("prob",

        fluidRow(
          column(12,
            tags$div(class = "section-hero",
              style = "background:linear-gradient(135deg,#450a0a 0%,#7f1d1d 60%,#991b1b 100%);",
              tags$h3(icon("search", style = "color:#fca5a5; margin-right:10px;"),
                "Planteamiento del Problema"),
              tags$p(
                "La mortalidad es uno de los indicadores más importantes en salud pública.",
                " En Medellín, el registro de defunciones acumula más de ",
                tags$strong("145.000 casos entre 2012 y 2023"),
                " con variables demográficas, socioeconómicas, temporales y clínicas."
              ),
              tags$div(style = "margin-top:16px;",
                tags$div(class = "modern-quote",
                  style = "background:rgba(255,255,255,.08); border-left-color:#f87171;",
                  tags$em(style = "color:#fecaca;",
                    "¿Qué patrones y diferencias relevantes pueden identificarse en los registros de defunciones",
                    " de Medellín entre 2012 y 2023 a partir de variables demográficas, temporales y clínicas?")
                )
              )
            )
          )
        ),

        # Variable objetivo
        fluidRow(
          column(12,
            box(
              width = 12, solidHeader = TRUE, status = "warning",
              title = tags$span(icon("star"), " Variable objetivo — NOM_667_OPS_GRUPO"),
              fluidRow(
                column(5,
                  tags$div(style = "background:#fffbeb; border-radius:var(--r); padding:16px; height:100%;",
                    tags$div(style = "display:flex; align-items:center; gap:8px; margin-bottom:12px;",
                      tags$span(class = "var-badge vb-trg", "Target / Respuesta"),
                      tags$span(class = "var-badge vb-cat", "Categórica nominal")
                    ),
                    tags$p(style = "font-size:13px; margin-bottom:12px;",
                      "Clasifica cada defunción en un ", tags$strong("grupo de causa de muerte"),
                      " según la nomenclatura OPS 667. Es la variable que el modelo aprende a predecir."),
                    tags$div(style = "font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:.06em; color:#92400e; margin-bottom:8px;",
                      "Valores principales"),
                    tags$div(style = "display:flex; flex-direction:column; gap:5px;",
                      lapply(c("Enfermedades del sistema circulatorio",
                               "Causas externas",
                               "Neoplasias (tumores)",
                               "Enfermedades infecciosas y parasitarias",
                               "Otras causas"), function(v) {
                        tags$div(style = "display:flex; align-items:center; gap:8px;",
                          tags$div(style = "width:6px; height:6px; border-radius:50%; background:#f59e0b; flex-shrink:0;"),
                          tags$span(style = "font-size:12.5px; color:#78350f;", v)
                        )
                      })
                    )
                  )
                ),
                column(7,
                  plotlyOutput("plot_target_preview", height = 280)
                )
              )
            )
          )
        ),

        # Variables relacionadas
        fluidRow(
          column(12,
            box(
              width = 12, solidHeader = TRUE, status = "primary",
              title = tags$span(icon("th"), " Variables predictoras"),
              tags$p(style = "color:var(--txt3); margin-bottom:20px;",
                "Estas variables se usan como predictores del modelo.",
                " En la sección ", tags$strong("Exploración"), " se analiza cada una en detalle."),
              fluidRow(
                column(3, varCard("user", "EDAD_SIMPLE", "vb-num", "Numérica continua",
                  "Edad en años al momento del fallecimiento. Rango: 0–99 años.",
                  "Alta influencia en el modelo", color = "#3b82f6")),
                column(3, varCard("venus-mars", "SEXO", "vb-bin", "Categórica binaria",
                  "1 = Masculino, 2 = Femenino. Diferencias importantes en causas externas y circulatorias.",
                  "Diferencias por grupo de causa", color = "#8b5cf6")),
                column(3, varCard("users", "ETAREO_QUIN", "vb-ord", "Categórica ordinal",
                  "Grupo etario quinquenal: 0-4, 5-9, … 80+. Resume la edad en rangos poblacionales.",
                  "Relacionada con EDAD_SIMPLE", color = "#10b981")),
                column(3, varCard("hospital-o", "SEG_SOCIAL", "vb-cat", "Categórica nominal",
                  "Régimen de salud: Contributivo, Subsidiado, Vinculado, Especial.",
                  "Refleja condición socioeconómica", color = "#ef4444"))
              ),
              fluidRow(
                column(3, varCard("graduation-cap", "NIVEL_EDU", "vb-ord", "Categórica ordinal",
                  "Sin escolaridad, Primaria, Secundaria, Técnico, Universitario.",
                  "Proxy de nivel socioeconómico", color = "#f59e0b")),
                column(3, varCard("heart", "EST_CIVIL", "vb-cat", "Categórica nominal",
                  "Estado civil: Soltero, Casado, Viudo, Separado, Unión libre.",
                  "Correlaciona con redes de apoyo", color = "#06b6d4")),
                column(3, varCard("calendar", "ANO", "vb-num", "Numérica entera",
                  "Año de defunción: 2012 a 2023. Captura tendencias temporales y el COVID-19.",
                  "Tendencias a largo plazo", color = "#0f172a")),
                column(3, varCard("clock-o", "MES", "vb-num", "Numérica entera",
                  "Mes de defunción: 1 (enero) a 12 (diciembre). Detecta estacionalidad.",
                  "Patrones estacionales", color = "#e67e22"))
              )
            )
          )
        )
      ),

      # ══════════════════════════════════════════════════════
      # EDA: RESUMEN
      # ══════════════════════════════════════════════════════
      tabItem("eda_res",

        # KPI row 1
        fluidRow(
          valueBoxOutput("vb_total",    width = 3),
          valueBoxOutput("vb_grupos",   width = 3),
          valueBoxOutput("vb_anio",     width = 3),
          valueBoxOutput("vb_edad_med", width = 3)
        ),

        # KPI row 2
        fluidRow(
          valueBoxOutput("vb_masculino", width = 3),
          valueBoxOutput("vb_femenino",  width = 3),
          valueBoxOutput("vb_top_causa", width = 3),
          valueBoxOutput("vb_miss",      width = 3)
        ),

        # Gráficos
        fluidRow(
          box(width = 7, solidHeader = TRUE, status = "primary",
            title = tags$span(icon("bar-chart"), " Top 10 causas de defunción"),
            plotlyOutput("plot_top_causas", height = 320)
          ),
          box(width = 5, solidHeader = TRUE, status = "info",
            title = tags$span(icon("user"), " Distribución de edad"),
            plotlyOutput("plot_hist_edad", height = 320)
          )
        ),

        fluidRow(
          box(width = 6, solidHeader = TRUE, status = "warning",
            title = tags$span(icon("exclamation-triangle"), " Valores faltantes por variable (dato crudo)"),
            plotlyOutput("plot_missing", height = 360)
          ),
          box(width = 3, solidHeader = TRUE, status = "success",
            title = tags$span(icon("venus-mars"), " Distribución por sexo"),
            plotlyOutput("plot_sexo_pie", height = 260)
          ),
          box(width = 3, solidHeader = TRUE, status = "danger",
            title = tags$span(icon("calendar"), " Defunciones por mes"),
            plotlyOutput("plot_mes_bar", height = 260)
          )
        )
      ),

      # ══════════════════════════════════════════════════════
      # EDA: VISUALIZACIONES
      # ══════════════════════════════════════════════════════
      tabItem("eda_viz",

        # Filtros globales
        fluidRow(
          box(
            width = 12, solidHeader = TRUE, status = "primary",
            title = tags$span(icon("filter"), " Filtros globales"),
            fluidRow(
              column(3,
                selectInput("filt_grupo", "Grupo de causa:",
                  choices = c("Todos" = "Todos", grupos_disponibles), selected = "Todos")
              ),
              column(3,
                selectInput("filt_sexo", "Sexo:",
                  choices = c("Todos" = "Todos", "Masculino" = "1", "Femenino" = "2"),
                  selected = "Todos")
              ),
              column(3,
                sliderInput("filt_ano", "Rango de años:",
                  min = 2012, max = 2023, value = c(2012, 2023), sep = "")
              ),
              column(3,
                sliderInput("filt_edad", "Rango de edad:",
                  min = 0, max = 99, value = c(0, 99))
              )
            )
          )
        ),

        # Distribución univariada
        fluidRow(
          box(
            width = 12, solidHeader = TRUE, status = "primary",
            title = tags$span(icon("bar-chart"), " 1. Distribución de variables"),
            fluidRow(
              column(3,
                tags$div(class = "config-panel",
                  selectInput("eda_var", "Variable:",
                    choices = c("Grupos de causa" = "NOM_667_OPS_GRUPO",
                                "Sexo"            = "SEXO",
                                "Grupo etáreo"    = "ETAREO_QUIN",
                                "Seg. social"     = "SEG_SOCIAL",
                                "Nivel educativo" = "NIVEL_EDU",
                                "Estado civil"    = "EST_CIVIL",
                                "Año"             = "ANO",
                                "Mes"             = "MES")),
                  selectInput("eda_tipo", "Tipo de gráfico:",
                    choices = c("Barras" = "bar", "Circular" = "pie")),
                  checkboxInput("eda_pct", "Mostrar porcentaje", TRUE)
                )
              ),
              column(9, plotlyOutput("plot_eda", height = 380))
            )
          )
        ),

        # Análisis por causa
        fluidRow(
          box(width = 6, solidHeader = TRUE, status = "warning",
            title = tags$span(icon("heartbeat"), " 2a. Edad por grupo de causa"),
            plotlyOutput("plot_edad_grupo", height = 350)
          ),
          box(width = 6, solidHeader = TRUE, status = "danger",
            title = tags$span(icon("venus-mars"), " 2b. Causa por sexo"),
            plotlyOutput("plot_causa_sexo", height = 350)
          )
        ),

        # Temporal
        fluidRow(
          box(width = 8, solidHeader = TRUE, status = "success",
            title = tags$span(icon("line-chart"), " 3a. Evolución anual por grupo de causa"),
            plotlyOutput("plot_trend", height = 320)
          ),
          box(width = 4, solidHeader = TRUE, status = "info",
            title = tags$span(icon("th"), " 3b. Defunciones por mes y año"),
            plotlyOutput("plot_heatmap_mes_ano", height = 340)
          )
        ),

        # Socioeconómicas
        fluidRow(
          box(width = 6, solidHeader = TRUE, status = "primary",
            title = tags$span(icon("graduation-cap"), " 4a. Causa por nivel educativo"),
            plotlyOutput("plot_edu_causa", height = 340)
          ),
          box(width = 6, solidHeader = TRUE, status = "warning",
            title = tags$span(icon("hospital-o"), " 4b. Causa por régimen de salud"),
            plotlyOutput("plot_seg_causa", height = 340)
          )
        )
      ),

      # ══════════════════════════════════════════════════════
      # EDA: TABLA
      # ══════════════════════════════════════════════════════
      tabItem("eda_tab",
        fluidRow(
          box(
            width = 12, solidHeader = TRUE, status = "info",
            title = tags$span(icon("table"), " Tabla de datos navegable"),
            fluidRow(
              column(3,
                selectInput("tab_grupo", "Grupo de causa:",
                  choices = c("Todos", grupos_disponibles), selected = "Todos")
              ),
              column(2,
                selectInput("tab_sexo", "Sexo:",
                  choices = c("Todos", "Masculino" = "1", "Femenino" = "2"), selected = "Todos")
              ),
              column(3,
                sliderInput("tab_ano", "Año:", min = 2012, max = 2023,
                  value = c(2012, 2023), sep = "")
              ),
              column(2,
                sliderInput("tab_edad", "Edad:", min = 0, max = 99, value = c(0, 99))
              ),
              column(2,
                tags$br(),
                actionButton("tab_reset", "Limpiar filtros",
                  icon = icon("undo"), class = "btn-default btn-sm", style = "width:100%;")
              )
            ),
            tags$hr(),
            fluidRow(
              column(3,
                tags$div(style = "background:var(--p-light); border-radius:var(--r); padding:16px; text-align:center;",
                  uiOutput("tab_conteo")
                )
              ),
              column(9, DTOutput("tabla_datos"))
            )
          )
        )
      ),

      # ══════════════════════════════════════════════════════
      # MODELADO: CONFIGURACIÓN
      # ══════════════════════════════════════════════════════
      tabItem("tr_sel",
        fluidRow(
          column(4,
            box(
              width = 12, solidHeader = TRUE, status = "primary",
              title = tags$span(icon("sliders"), " Configuración del entrenamiento"),

              tags$div(class = "config-panel",

                # ── Selector de modelo ────────────────────────
                tags$div(style = "margin-bottom:16px;",
                  tags$label(style = "font-size:12px; font-weight:700; color:var(--txt2);
                                      text-transform:uppercase; letter-spacing:.05em;",
                    "Modelo a entrenar"),
                  radioButtons("sel_modelo", label = NULL,
                    choices = c(
                      "Random Forest"      = "rf",
                      "Árbol de decisión"  = "rpart",
                      "Ambos modelos"      = "ambos"
                    ),
                    selected = "ambos"
                  )
                ),

                tags$hr(style = "margin:8px 0 16px;"),

                sliderInput("tr_split", "% datos entrenamiento:", 60, 90, 75, 5),

                # Parámetro RF: solo visible cuando corresponde
                conditionalPanel(
                  condition = "input.sel_modelo == 'rf' || input.sel_modelo == 'ambos'",
                  numericInput("rf_trees", "Núm. árboles (RF):", 100, 50, 500, 50)
                )
              ),

              tags$br(),
              actionButton("btn_entrenar", "Entrenar modelo",
                           icon = icon("play"), class = "btn-success btn-block"),
              tags$br(),
              actionButton("btn_guardar", "Guardar modelos entrenados",
                           icon = icon("save"), class = "btn-warning btn-block"),
              tags$br(),
              uiOutput("ui_estado_guardado"),
              tags$p(style = "font-size:12px; color:var(--txt3); text-align:center;",
                     icon("info-circle"), " El entrenamiento puede tardar unos minutos.")
            )
          ),
          column(8,
            box(
              width = 12, solidHeader = TRUE, status = "success",
              title = tags$span(icon("star"), " Importancia de variables (Random Forest)"),
              uiOutput("ui_importancia_wrap")
            ),
            box(
              width = 12, solidHeader = TRUE, status = "info",
              title = tags$span(icon("sitemap"), " Log de entrenamiento"),
              tags$div(style = "max-height:200px; overflow-y:auto;",
                verbatimTextOutput("train_log")
              )
            )
          )
        )
      ),

      # ══════════════════════════════════════════════════════
      # MODELADO: MÉTRICAS (unificado con pestañas internas)
      # ══════════════════════════════════════════════════════
      tabItem("tr_met_rf",

        # Alerta si no hay modelos
        uiOutput("met_entrenamiento_alerta"),

        tabsetPanel(
          id = "tabs_metricas",
          type = "tabs",

          # ── Pestaña Random Forest ────────────────────────
          tabPanel(
            title = tags$span(icon("tree"), " Random Forest"),
            value = "tab_rf",
            tags$br(),

            # Banner de estado RF
            uiOutput("met_rf_estado"),
            tags$br(),

            fluidRow(
              valueBoxOutput("vb_acc_rf",  width = 3),
              valueBoxOutput("vb_kap_rf",  width = 3),
              valueBoxOutput("vb_prec_rf", width = 3),
              valueBoxOutput("vb_rec_rf",  width = 3)
            ),

            fluidRow(
              box(width = 6, solidHeader = TRUE, status = "primary",
                title = tags$span(icon("th"), " Matriz de confusión — RF"),
                plotlyOutput("plot_confmat_rf", height = 420)
              ),
              box(width = 6, solidHeader = TRUE, status = "success",
                title = tags$span(icon("star"), " Importancia de variables"),
                plotlyOutput("plot_importancia", height = 320)
              )
            ),

            fluidRow(
              box(width = 12, solidHeader = TRUE, status = "info",
                title = tags$span(icon("list"), " Reporte completo por clase — RF"),
                verbatimTextOutput("metricas_detalle_rf")
              )
            )
          ),

          # ── Pestaña Árbol de Decisión ────────────────────
          tabPanel(
            title = tags$span(icon("sitemap"), " Árbol de Decisión"),
            value = "tab_rpart",
            tags$br(),

            # Banner de estado Rpart
            uiOutput("met_rpart_estado"),
            tags$br(),

            fluidRow(
              valueBoxOutput("vb_acc_rpart",  width = 3),
              valueBoxOutput("vb_kap_rpart",  width = 3),
              valueBoxOutput("vb_prec_rpart", width = 3),
              valueBoxOutput("vb_rec_rpart",  width = 3)
            ),

            fluidRow(
              box(width = 12, solidHeader = TRUE, status = "warning",
                title = tags$span(icon("th"), " Matriz de confusión — Árbol"),
                plotlyOutput("plot_confmat_rpart", height = 420)
              )
            ),

            fluidRow(
              box(width = 12, solidHeader = TRUE, status = "info",
                title = tags$span(icon("list"), " Reporte completo por clase — Árbol"),
                verbatimTextOutput("metricas_detalle_rpart")
              )
            )
          )
        )
      ),

      # ══════════════════════════════════════════════════════
      # PREDICCIÓN: FORMULARIO
      # ══════════════════════════════════════════════════════
      tabItem("pr_form",
        fluidRow(
          column(7,
            box(
              width = 12, solidHeader = TRUE, status = "primary",
              title = tags$span(icon("user"), " Datos del caso"),
              fluidRow(
                column(6,
                  selectInput("p_sexo", "Sexo:", choices = c("Masculino" = "1", "Femenino" = "2")),
                  numericInput("p_edad", "Edad (años):", 45, 0, 120),
                  selectInput("p_etareo", "Grupo etáreo:",
                    choices = c("0-4","5-9","10-14","15-19","20-24","25-29",
                                "30-34","35-39","40-44","45-49","50-54","55-59",
                                "60-64","65-69","70-74","75-79","80+"),
                    selected = "45-49")
                ),
                column(6,
                  selectInput("p_civil", "Estado civil:",
                    choices = c("Soltero(a)" = 1, "Casado(a)" = 2, "Viudo(a)" = 3,
                                "Separado(a)" = 4, "Unión libre" = 5, "Sin info" = 9)),
                  selectInput("p_edu", "Nivel educativo:",
                    choices = c("Sin escolaridad" = 0, "Primaria" = 1, "Secundaria" = 2,
                                "Técnico" = 3, "Universitario" = 4, "Sin info" = 99)),
                  selectInput("p_seg", "Seg. social:",
                    choices = c("Contributivo" = 1, "Subsidiado" = 2, "Vinculado" = 3,
                                "Especial" = 4, "Sin info" = 9))
                )
              ),
              tags$hr(),
              fluidRow(
                column(6, numericInput("p_ano", "Año del registro:", 2023, 2000, 2030)),
                column(6,
                  selectInput("p_mes", "Mes:",
                    choices = setNames(1:12, c("Enero","Febrero","Marzo","Abril","Mayo","Junio",
                                               "Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre")))
                )
              ),
              tags$br(),
              actionButton("btn_predecir", "Predecir causa de muerte",
                icon = icon("magic"), class = "btn-primary btn-block")
            )
          ),
          column(5,
            box(
              width = 12, solidHeader = TRUE, status = "info",
              title = tags$span(icon("info-circle"), " Instrucciones"),
              tags$div(style = "display:flex; flex-direction:column; gap:10px; margin-bottom:16px;",
                tags$div(style = "display:flex; align-items:flex-start; gap:10px; padding:12px; background:var(--p-light); border-radius:var(--r-sm);",
                  tags$span(style = "background:var(--p); color:white; border-radius:50%; width:20px; height:20px; display:flex; align-items:center; justify-content:center; font-size:11px; font-weight:700; flex-shrink:0; margin-top:1px;", "1"),
                  tags$span(style = "font-size:13px; color:var(--txt2);",
                    "Asegúrese de haber entrenado el modelo en la sección ", tags$strong("Modelado."))
                ),
                tags$div(style = "display:flex; align-items:flex-start; gap:10px; padding:12px; background:#f0fdf4; border-radius:var(--r-sm);",
                  tags$span(style = "background:var(--green); color:white; border-radius:50%; width:20px; height:20px; display:flex; align-items:center; justify-content:center; font-size:11px; font-weight:700; flex-shrink:0; margin-top:1px;", "2"),
                  tags$span(style = "font-size:13px; color:var(--txt2);",
                    "Los resultados muestran el grupo de causa de muerte ", tags$strong("más probable."))
                ),
                tags$div(style = "display:flex; align-items:flex-start; gap:10px; padding:12px; background:#fffbeb; border-radius:var(--r-sm);",
                  tags$span(style = "background:var(--amber); color:white; border-radius:50%; width:20px; height:20px; display:flex; align-items:center; justify-content:center; font-size:11px; font-weight:700; flex-shrink:0; margin-top:1px;", "3"),
                  tags$span(style = "font-size:13px; color:var(--txt2);",
                    "La visualización de probabilidades indica la ", tags$strong("certeza del modelo"),
                    " para cada clase.")
                )
              ),
              uiOutput("pred_alerta")
            )
          )
        )
      ),

      # ══════════════════════════════════════════════════════
      # PREDICCIÓN: RESULTADO
      # ══════════════════════════════════════════════════════
      tabItem("pr_res",
        fluidRow(
          box(
            width = 6, solidHeader = TRUE, status = "success",
            title = tags$span(icon("check-circle"), " Resultado de la predicción"),
            uiOutput("pred_resultado")
          ),
          box(
            width = 6, solidHeader = TRUE, status = "info",
            title = tags$span(icon("clipboard"), " Resumen del caso ingresado"),
            tableOutput("pred_caso")
          )
        )
      ),

      # ══════════════════════════════════════════════════════
      # PREDICCIÓN: PROBABILIDAD
      # ══════════════════════════════════════════════════════
      tabItem("pr_prob",
        box(
          width = 12, solidHeader = TRUE, status = "warning",
          title = tags$span(icon("bar-chart"), " Probabilidad por grupo de causa"),
          plotlyOutput("plot_prob", height = 420)
        )
      ),

      # ══════════════════════════════════════════════════════
      # MÉTRICAS DE LOS MODELOS (tab consolidada)
      # ══════════════════════════════════════════════════════
      tabItem("met_full",

        # Alerta si el modelo no ha sido entrenado
        uiOutput("met_alerta"),

        # Comparación de modelos (banner oscuro)
        uiOutput("met_modelo_info"),

        # Fila 1: 6 value boxes
        fluidRow(
          valueBoxOutput("met_vb_acc",  width = 2),
          valueBoxOutput("met_vb_kap",  width = 2),
          valueBoxOutput("met_vb_prec", width = 2),
          valueBoxOutput("met_vb_rec",  width = 2),
          valueBoxOutput("met_vb_f1",   width = 2),
          valueBoxOutput("met_vb_bacc", width = 2)
        ),

        # Fila 2: tabla por clase (DT) + heatmap de confusión
        fluidRow(
          column(6,
            box(
              width = 12, solidHeader = TRUE, status = "primary",
              title = tags$span(icon("table"), " Métricas por clase"),
              DT::DTOutput("met_tabla_clase")
            )
          ),
          column(6,
            box(
              width = 12, solidHeader = TRUE, status = "danger",
              title = tags$span(icon("th"), " Matriz de confusión (heatmap interactivo)"),
              plotlyOutput("met_confmat", height = 400)
            )
          )
        ),

        # Fila 3: importancia de variables
        fluidRow(
          box(
            width = 12, solidHeader = TRUE, status = "success",
            title = tags$span(icon("star"), " Importancia de variables"),
            plotlyOutput("met_importancia", height = 340)
          )
        )
      ),

      # ══════════════════════════════════════════════════════
      # PREDICCIÓN CON EL MEJOR MODELO
      # ══════════════════════════════════════════════════════
      tabItem("pred_mejor",

        fluidRow(
          # Columna izquierda: panel del mejor modelo + formulario
          column(5,
            box(
              width = 12, solidHeader = TRUE, status = "primary",
              title = tags$span(icon("robot"), " Mejor modelo & caso a predecir"),

              # Info del mejor modelo seleccionado automáticamente
              uiOutput("pm_modelo_info"),

              tags$hr(),
              tags$div(
                style = "font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:.07em; color:var(--txt3); margin-bottom:10px;",
                "Datos del caso"
              ),

              fluidRow(
                column(6,
                  selectInput("pm_sexo", "Sexo:",
                    choices = c("Masculino" = "1", "Femenino" = "2")),
                  numericInput("pm_edad", "Edad (años):", 45, 0, 120),
                  selectInput("pm_etareo", "Grupo etáreo:",
                    choices = c("0-4","5-9","10-14","15-19","20-24","25-29",
                                "30-34","35-39","40-44","45-49","50-54","55-59",
                                "60-64","65-69","70-74","75-79","80+"),
                    selected = "45-49")
                ),
                column(6,
                  selectInput("pm_civil", "Estado civil:",
                    choices = c("Soltero(a)" = 1, "Casado(a)" = 2, "Viudo(a)" = 3,
                                "Separado(a)" = 4, "Unión libre" = 5, "Sin info" = 9)),
                  selectInput("pm_edu", "Nivel educativo:",
                    choices = c("Sin escolaridad" = 0, "Primaria" = 1,
                                "Secundaria" = 2, "Técnico" = 3, "Universitario" = 4)),
                  selectInput("pm_seg", "Seg. social:",
                    choices = c("Contributivo" = 1, "Subsidiado" = 2,
                                "Vinculado" = 3, "Especial" = 4, "Sin info" = 9))
                )
              ),
              fluidRow(
                column(6, numericInput("pm_ano", "Año:", 2023, 2000, 2030)),
                column(6,
                  selectInput("pm_mes", "Mes:",
                    choices = setNames(1:12,
                      c("Enero","Febrero","Marzo","Abril","Mayo","Junio",
                        "Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre")))
                )
              ),
              tags$br(),
              uiOutput("pm_alerta"),
              actionButton("btn_predecir2", "Predecir con el mejor modelo",
                icon = icon("robot"), class = "btn-primary btn-block")
            )
          ),

          # Columna derecha: resultado + gráfico + top-5
          column(7,
            box(
              width = 12, solidHeader = TRUE, status = "success",
              title = tags$span(icon("check-circle"), " Resultado de la predicción"),
              uiOutput("pm_resultado")
            ),
            box(
              width = 12, solidHeader = TRUE, status = "warning",
              title = tags$span(icon("bar-chart"), " Probabilidades por grupo (Top 10)"),
              plotlyOutput("pm_prob_plot", height = 280)
            ),
            box(
              width = 12, solidHeader = TRUE, status = "info",
              title = tags$span(icon("list-ol"), " Top 5 probabilidades"),
              DT::DTOutput("pm_top5")
            )
          )
        )
      )

    ) # /tabItems
  ) # /dashboardBody
) # /dashboardPage

# ============================================================
#  RECOMENDACIONES DE LIBRERÍA PARA MODERNIZAR AÚN MÁS
# ============================================================
#
#  OPCIÓN 1: bs4Dash  ✅ RECOMENDADA
#  ─────────────────────────────────────────────────────────
#  install.packages("bs4Dash")
#
#  Por qué:
#   - Drop-in replacement de shinydashboard (misma API)
#   - Bootstrap 4/5 nativo (cards, badges, avatars modernos)
#   - Dark/light mode integrado
#   - Sidebar con mejor UX
#   - valueBox y infoBox más limpios out-of-the-box
#   - Activamente mantenido
#
#  Migración: cambiar 'library(shinydashboard)' por
#             'library(bs4Dash)' y ajustar 'skin' → 'theme'
#
# ─────────────────────────────────────────────────────────
#  OPCIÓN 2: fresh  (complemento a shinydashboard)
#  ─────────────────────────────────────────────────────────
#  install.packages("fresh")
#
#  Por qué:
#   - Crea temas custom para shinydashboard con una línea
#   - Sin cambiar la estructura del ui.R
#   - Ideal para equipos que no quieren migrar
#
#  Uso:
#   mi_tema <- fresh::create_theme(
#     fresh::adminlte_color(light_blue = "#6366f1"),
#     fresh::adminlte_sidebar(width = "240px",
#                             dark_bg = "#0f172a",
#                             dark_hover_bg = "#1e293b"),
#     fresh::adminlte_global(content_bg = "#f1f5f9")
#   )
#   # En dashboardBody: use_theme(mi_tema)
#
# ─────────────────────────────────────────────────────────
#  OPCIÓN 3: bslib  (solo si migras a Shiny nativo)
#  ─────────────────────────────────────────────────────────
#  - Requiere reescribir la UI usando page_sidebar() en vez
#    de dashboardPage. Mayor esfuerzo, pero resultado más
#    moderno y componentes más ricos (cards, grids, accordions).
#
# ─────────────────────────────────────────────────────────
#  VEREDICTO: Mantén shinydashboard + este CSS ahora,
#  y migra a bs4Dash en la siguiente versión del proyecto.
# ============================================================
