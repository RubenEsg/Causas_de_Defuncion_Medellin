# ============================================================
#  ui.R
#  Modelo de Clasificación - Causas de Defunción (Medellín)
# ============================================================

ui <- dashboardPage(
  skin = "blue",

  dashboardHeader(
    title = tags$span(
      tags$img(src = "https://medata.gov.co/themes/medata/logo.png",
               height = "30px", style = "margin-right:8px;"),
      "Causas de Defunción Medellín"
    ),
    titleWidth = 320
  ),

  dashboardSidebar(
    width = 220,
    sidebarMenu(
      id = "tabs",
      menuItem("Introducción",   tabName = "intro",   icon = icon("info-circle")),
      menuItem("Objetivos",      tabName = "obj",     icon = icon("bullseye")),
      menuItem("Problema",       tabName = "prob",    icon = icon("exclamation-triangle")),
      menuItem("EDA",            tabName = "eda",     icon = icon("chart-bar"),
        menuSubItem("Resumen",         tabName = "eda_res"),
        menuSubItem("Visualizaciones", tabName = "eda_viz"),
        menuSubItem("Tabla de datos",  tabName = "eda_tab")
      ),
      menuItem("Entrenamiento",  tabName = "train",   icon = icon("cogs"),
        menuSubItem("Selección de modelo",  tabName = "tr_sel"),
        menuSubItem("Métricas",             tabName = "tr_met"),
        menuSubItem("Matriz de confusión",  tabName = "tr_conf")
      ),
      menuItem("Predicción",     tabName = "pred",    icon = icon("stethoscope"),
        menuSubItem("Formulario",        tabName = "pr_form"),
        menuSubItem("Resultado",         tabName = "pr_res"),
        menuSubItem("Probabilidad",      tabName = "pr_prob")
      )
    )
  ),

  dashboardBody(
    tags$head(tags$style(HTML("
      .skin-blue .main-header .logo { background-color:#1a252f; }
      .skin-blue .main-header .navbar { background-color:#2c3e50; }
      .skin-blue .main-sidebar { background-color:#2c3e50; }
      .content-wrapper, .right-side { background-color:#f4f6f9; }
      .box { border-radius:8px; }
      .info-box { border-radius:8px; }
      h2.seccion { color:#2c3e50; border-left:5px solid #3498db;
                   padding-left:12px; margin-bottom:20px; }
      p.justificado { text-align:justify; font-size:15px; line-height:1.7; }
    "))),

    tabItems(

      # ── INTRODUCCIÓN ───────────────────────────────────────
      tabItem("intro",

        # Encabezado con fondo oscuro
        fluidRow(
          box(
            width = 12, solidHeader = TRUE, status = "primary",
            title = tags$span(icon("info-circle"), " Contexto del Proyecto"),
            tags$div(
              style = "background:linear-gradient(135deg,#1a252f,#2c3e50); color:white; border-radius:10px; padding:24px 28px; margin-bottom:16px;",
              tags$h3(style = "margin-top:0; color:#f39c12; font-weight:bold;",
                icon("heartbeat"), " Causas de Defunción en Medellín: Análisis y Clasificación"),
              tags$p(style = "font-size:15px; line-height:1.8; color:#ecf0f1; margin-bottom:0;",
                "El estudio de la mortalidad constituye uno de los indicadores más relevantes en salud pública.",
                " Este proyecto integra técnicas de ", tags$strong(style="color:#f39c12;", "análisis exploratorio de datos (EDA)"),
                " y ", tags$strong(style="color:#f39c12;", "aprendizaje automático (Machine Learning)"),
                " para examinar y predecir las causas de defunción registradas en Medellín entre 2012 y 2023,",
                " a partir de variables demográficas, temporales y socioeconómicas."
              )
            ),
            fluidRow(
              column(8,
                h2("¿De qué trata este proyecto?", class = "seccion"),
                p(class = "justificado",
                  "Se trabaja con el ", strong("Registro de Defunciones de Medellín"),
                  ", publicado en el portal de datos abiertos ",
                  tags$a(href = "https://medata.gov.co/node/16570", "MeData (medata.gov.co)", target = "_blank"),
                  ". El conjunto contiene aproximadamente ", strong("145.000 registros"),
                  " del período ", strong("2012–2023"),
                  " e incluye variables demográficas (sexo, edad, estado civil, nivel educativo),",
                  " variables de aseguramiento en salud, información territorial y, como variable central,",
                  " la ", strong("causa básica de defunción"), " codificada según la nomenclatura OPS 667."
                ),
                p(class = "justificado",
                  "El proyecto sigue un flujo de trabajo en tres etapas. Primero, un ",
                  strong("análisis exploratorio"), " que examina la estructura del dataset, distribuciones,",
                  " patrones temporales y posibles inconsistencias. Segundo, el ",
                  strong("entrenamiento de un modelo de clasificación"),
                  " (Random Forest o Árbol de decisión) capaz de predecir el grupo de causa de muerte",
                  " a partir de los atributos del caso. Tercero, un módulo de ",
                  strong("predicción interactiva"),
                  " donde el usuario puede ingresar los datos de un nuevo caso y obtener la causa de muerte",
                  " más probable junto con las probabilidades por categoría."
                ),
                p(class = "justificado",
                  "La variable objetivo del modelo es ", strong("NOM_667_OPS_GRUPO"),
                  ", que agrupa las defunciones en grandes categorías como enfermedades del sistema circulatorio,",
                  " causas externas, neoplasias, enfermedades infecciosas y parasitarias, entre otras.",
                  " Esta clasificación sigue los estándares internacionales de la Organización Panamericana de la Salud (OPS)."
                )
              ),
              column(4,
                tags$div(
                  style = "background:#2c3e50; color:white; border-radius:10px; padding:18px; text-align:center;",
                  tags$h4(style = "margin-top:0; color:#f39c12;", icon("database"), " Dataset"),
                  tags$hr(style = "border-color:#ffffff33;"),
                  tags$p(style = "font-size:22px; font-weight:bold; margin:4px 0;", "~145.000"),
                  tags$p(style = "font-size:12px; color:#bdc3c7; margin:0;", "registros"),
                  tags$hr(style = "border-color:#ffffff33;"),
                  tags$p(style = "font-size:22px; font-weight:bold; margin:4px 0;", "2012 – 2023"),
                  tags$p(style = "font-size:12px; color:#bdc3c7; margin:0;", "período analizado"),
                  tags$hr(style = "border-color:#ffffff33;"),
                  tags$p(style = "font-size:22px; font-weight:bold; margin:4px 0;", "9"),
                  tags$p(style = "font-size:12px; color:#bdc3c7; margin:0;", "variables de análisis"),
                  tags$hr(style = "border-color:#ffffff33;"),
                  tags$p(style = "font-size:22px; font-weight:bold; margin:4px 0;", "OPS 667"),
                  tags$p(style = "font-size:12px; color:#bdc3c7; margin:0;", "nomenclatura de causas")
                )
              )
            )
          )
        ),

        # Tarjetas de etapas del proyecto
        fluidRow(
          box(
            width = 12, solidHeader = TRUE, status = "info",
            title = tags$span(icon("map"), " Etapas del Proyecto"),
            fluidRow(
              column(4,
                tags$div(style = "border:1px solid #3498db; border-radius:8px; padding:16px; background:#eaf4fc; height:160px;",
                  tags$div(style = "display:flex; align-items:center; margin-bottom:10px;",
                    tags$span(style = "background:#3498db; color:white; border-radius:50%; width:36px; height:36px; display:flex; align-items:center; justify-content:center; margin-right:10px; font-weight:bold; font-size:16px;", "1"),
                    tags$strong(style = "font-size:14px;", "Exploración de Datos (EDA)")
                  ),
                  tags$p(style = "font-size:13px; color:#555; margin:0;",
                    "Resumen estadístico, distribuciones por sexo/edad/año, análisis territorial",
                    " y relación entre variables demográficas y causas de muerte.")
                )
              ),
              column(4,
                tags$div(style = "border:1px solid #27ae60; border-radius:8px; padding:16px; background:#eafaf1; height:160px;",
                  tags$div(style = "display:flex; align-items:center; margin-bottom:10px;",
                    tags$span(style = "background:#27ae60; color:white; border-radius:50%; width:36px; height:36px; display:flex; align-items:center; justify-content:center; margin-right:10px; font-weight:bold; font-size:16px;", "2"),
                    tags$strong(style = "font-size:14px;", "Entrenamiento del Modelo")
                  ),
                  tags$p(style = "font-size:13px; color:#555; margin:0;",
                    "Selección de algoritmo (Random Forest / Árbol de decisión), partición",
                    " train/test, evaluación con métricas (accuracy, kappa, precisión, recall) y matriz de confusión.")
                )
              ),
              column(4,
                tags$div(style = "border:1px solid #8e44ad; border-radius:8px; padding:16px; background:#f5eef8; height:160px;",
                  tags$div(style = "display:flex; align-items:center; margin-bottom:10px;",
                    tags$span(style = "background:#8e44ad; color:white; border-radius:50%; width:36px; height:36px; display:flex; align-items:center; justify-content:center; margin-right:10px; font-weight:bold; font-size:16px;", "3"),
                    tags$strong(style = "font-size:14px;", "Predicción Interactiva")
                  ),
                  tags$p(style = "font-size:13px; color:#555; margin:0;",
                    "Ingreso manual de datos de un caso (sexo, edad, régimen, año),",
                    " predicción del grupo de causa más probable y visualización de probabilidades por categoría.")
                )
              )
            )
          )
        ),

        # Info boxes
        fluidRow(
          infoBox("Cobertura temporal", "2012 – 2023",       icon = icon("calendar"),    color = "blue",   width = 3),
          infoBox("Registros",          "~145.000",           icon = icon("database"),    color = "green",  width = 3),
          infoBox("Fuente",             "MeData Medellín",    icon = icon("globe"),       color = "orange", width = 3),
          infoBox("Modelo",             "Random Forest / Rpart", icon = icon("cogs"),    color = "purple", width = 3)
        )
      ),

      # ── OBJETIVOS ─────────────────────────────────────────
      tabItem("obj",

        # Objetivo general
        fluidRow(
          box(
            width = 12, solidHeader = TRUE, status = "success",
            title = tags$span(icon("bullseye"), " Objetivo General"),
            tags$div(
              style = "background:linear-gradient(135deg,#1e8449,#27ae60); color:white; border-radius:10px; padding:20px 24px;",
              tags$p(style = "font-size:15px; line-height:1.8; margin:0;",
                "Desarrollar una aplicación interactiva que integre el ",
                tags$strong("análisis exploratorio de datos (EDA)"),
                " y la construcción de un ",
                tags$strong("modelo de clasificación supervisado"),
                " sobre el registro de defunciones de Medellín (2012–2023), con el fin de identificar",
                " patrones de mortalidad, evaluar la capacidad predictiva de variables demográficas y",
                " socioeconómicas, y facilitar la toma de decisiones en salud pública a través de",
                " herramientas interactivas de visualización y predicción."
              )
            )
          )
        ),

        # Objetivos específicos con tarjetas por eje temático
        fluidRow(
          box(
            width = 12, solidHeader = TRUE, status = "primary",
            title = tags$span(icon("list-ol"), " Objetivos Específicos"),

            # Eje 1: Datos
            tags$h4(style = "color:#2c3e50; border-left:4px solid #3498db; padding-left:10px; margin-bottom:12px;",
              icon("database"), " Eje 1 — Gestión y calidad de los datos"),
            fluidRow(
              column(6,
                tags$div(style = "border:1px solid #d5d8dc; border-radius:8px; padding:14px; background:#eaf4fc; margin-bottom:14px;",
                  tags$div(style = "display:flex; align-items:flex-start;",
                    tags$span(style = "background:#3498db; color:white; border-radius:50%; min-width:28px; height:28px; display:flex; align-items:center; justify-content:center; margin-right:10px; font-weight:bold;", "1"),
                    tags$p(style = "font-size:13px; color:#333; margin:0;",
                      "Examinar la ", strong("estructura y calidad"), " del conjunto de datos, identificando tipos de",
                      " variables, valores faltantes, inconsistencias y transformaciones necesarias para el análisis.")
                  )
                )
              ),
              column(6,
                tags$div(style = "border:1px solid #d5d8dc; border-radius:8px; padding:14px; background:#eaf4fc; margin-bottom:14px;",
                  tags$div(style = "display:flex; align-items:flex-start;",
                    tags$span(style = "background:#3498db; color:white; border-radius:50%; min-width:28px; height:28px; display:flex; align-items:center; justify-content:center; margin-right:10px; font-weight:bold;", "2"),
                    tags$p(style = "font-size:13px; color:#333; margin:0;",
                      "Describir el comportamiento de las defunciones mediante ", strong("variables demográficas"),
                      " (sexo, edad, estado civil, nivel educativo y régimen de afiliación al sistema de salud).")
                  )
                )
              )
            ),

            # Eje 2: EDA
            tags$h4(style = "color:#2c3e50; border-left:4px solid #e67e22; padding-left:10px; margin-bottom:12px;",
              icon("chart-bar"), " Eje 2 — Análisis exploratorio"),
            fluidRow(
              column(6,
                tags$div(style = "border:1px solid #d5d8dc; border-radius:8px; padding:14px; background:#fef9e7; margin-bottom:14px;",
                  tags$div(style = "display:flex; align-items:flex-start;",
                    tags$span(style = "background:#e67e22; color:white; border-radius:50%; min-width:28px; height:28px; display:flex; align-items:center; justify-content:center; margin-right:10px; font-weight:bold;", "3"),
                    tags$p(style = "font-size:13px; color:#333; margin:0;",
                      "Analizar la ", strong("distribución temporal"), " de la mortalidad, identificando tendencias anuales,",
                      " variaciones mensuales y patrones estacionales en los registros.")
                  )
                )
              ),
              column(6,
                tags$div(style = "border:1px solid #d5d8dc; border-radius:8px; padding:14px; background:#fef9e7; margin-bottom:14px;",
                  tags$div(style = "display:flex; align-items:flex-start;",
                    tags$span(style = "background:#e67e22; color:white; border-radius:50%; min-width:28px; height:28px; display:flex; align-items:center; justify-content:center; margin-right:10px; font-weight:bold;", "4"),
                    tags$p(style = "font-size:13px; color:#333; margin:0;",
                      "Explorar ", strong("diferencias territoriales y poblacionales"), " para detectar grupos de riesgo",
                      " y comportamientos diferenciales en distintos segmentos de la población de Medellín.")
                  )
                )
              )
            ),
            fluidRow(
              column(12,
                tags$div(style = "border:1px solid #d5d8dc; border-radius:8px; padding:14px; background:#fef9e7; margin-bottom:14px;",
                  tags$div(style = "display:flex; align-items:flex-start;",
                    tags$span(style = "background:#e67e22; color:white; border-radius:50%; min-width:28px; height:28px; display:flex; align-items:center; justify-content:center; margin-right:10px; font-weight:bold;", "5"),
                    tags$p(style = "font-size:13px; color:#333; margin:0;",
                      "Estudiar la frecuencia y distribución de las principales ", strong("causas de defunción (OPS 667)"),
                      " y su relación con variables sociodemográficas relevantes, como nivel educativo y régimen de salud.")
                  )
                )
              )
            ),

            # Eje 3: Modelo
            tags$h4(style = "color:#2c3e50; border-left:4px solid #8e44ad; padding-left:10px; margin-bottom:12px;",
              icon("cogs"), " Eje 3 — Modelado y predicción"),
            fluidRow(
              column(6,
                tags$div(style = "border:1px solid #d5d8dc; border-radius:8px; padding:14px; background:#f5eef8; margin-bottom:14px;",
                  tags$div(style = "display:flex; align-items:flex-start;",
                    tags$span(style = "background:#8e44ad; color:white; border-radius:50%; min-width:28px; height:28px; display:flex; align-items:center; justify-content:center; margin-right:10px; font-weight:bold;", "6"),
                    tags$p(style = "font-size:13px; color:#333; margin:0;",
                      "Construir y evaluar un ", strong("modelo de clasificación supervisado"),
                      " (Random Forest / Árbol de decisión) para predecir el grupo de causa de muerte",
                      " a partir de variables demográficas y socioeconómicas.")
                  )
                )
              ),
              column(6,
                tags$div(style = "border:1px solid #d5d8dc; border-radius:8px; padding:14px; background:#f5eef8; margin-bottom:14px;",
                  tags$div(style = "display:flex; align-items:flex-start;",
                    tags$span(style = "background:#8e44ad; color:white; border-radius:50%; min-width:28px; height:28px; display:flex; align-items:center; justify-content:center; margin-right:10px; font-weight:bold;", "7"),
                    tags$p(style = "font-size:13px; color:#333; margin:0;",
                      "Evaluar el rendimiento del modelo con métricas estándar (", strong("accuracy, kappa,"),
                      " precisión, recall) y analizar la importancia de variables para interpretar",
                      " los factores más determinantes en la predicción.")
                  )
                )
              )
            ),
            fluidRow(
              column(12,
                tags$div(style = "border:1px solid #d5d8dc; border-radius:8px; padding:14px; background:#f5eef8; margin-bottom:4px;",
                  tags$div(style = "display:flex; align-items:flex-start;",
                    tags$span(style = "background:#8e44ad; color:white; border-radius:50%; min-width:28px; height:28px; display:flex; align-items:center; justify-content:center; margin-right:10px; font-weight:bold;", "8"),
                    tags$p(style = "font-size:13px; color:#333; margin:0;",
                      "Implementar un módulo de ", strong("predicción interactiva"),
                      " que permita al usuario ingresar los datos de un caso individual y obtener",
                      " el grupo de causa de muerte más probable junto con la distribución de probabilidades por categoría.")
                  )
                )
              )
            )
          )
        )
      ),

      # ── PROBLEMA ──────────────────────────────────────────
      tabItem("prob",

        # Contexto + pregunta
        fluidRow(
          box(
            width = 12, solidHeader = TRUE, status = "danger",
            title = tags$span(icon("exclamation-triangle"), " Planteamiento del Problema"),
            fluidRow(
              column(8,
                p(class = "justificado",
                  "La mortalidad es uno de los indicadores más importantes en salud pública. En Medellín, el registro ",
                  "de defunciones acumula más de ", strong("145.000 casos entre 2012 y 2023"), " con variables demográficas, ",
                  "socioeconómicas, temporales y clínicas. La magnitud y diversidad del dataset dificulta identificar ",
                  "patrones sin un proceso sistemático de exploración."
                ),
                tags$blockquote(
                  style = "font-size:15px; border-left:4px solid #e74c3c; padding-left:14px; margin-top:12px; background:#fdf2f2; border-radius:4px; padding:12px 14px;",
                  tags$em("¿Qué patrones y diferencias relevantes pueden identificarse en los registros de defunciones ",
                  "de Medellín entre 2012 y 2023 a partir de variables demográficas, temporales y clínicas?")
                )
              ),
              column(4,
                tags$div(
                  style = "background:#2c3e50; color:white; border-radius:10px; padding:18px; text-align:center;",
                  tags$h4(style = "margin-top:0; color:#f39c12;", icon("database"), " Dataset"),
                  tags$hr(style = "border-color:#ffffff33;"),
                  tags$p(style = "font-size:22px; font-weight:bold; margin:4px 0;", "~145.000"),
                  tags$p(style = "font-size:12px; color:#bdc3c7; margin:0;", "registros"),
                  tags$hr(style = "border-color:#ffffff33;"),
                  tags$p(style = "font-size:22px; font-weight:bold; margin:4px 0;", "2012 – 2023"),
                  tags$p(style = "font-size:12px; color:#bdc3c7; margin:0;", "período"),
                  tags$hr(style = "border-color:#ffffff33;"),
                  tags$p(style = "font-size:22px; font-weight:bold; margin:4px 0;", "9"),
                  tags$p(style = "font-size:12px; color:#bdc3c7; margin:0;", "variables de análisis")
                )
              )
            )
          )
        ),

        # Variable objetivo
        fluidRow(
          box(
            width = 12, solidHeader = TRUE, status = "warning",
            title = tags$span(icon("star"), " Variable Objetivo — NOM_667_OPS_GRUPO"),
            fluidRow(
              column(5,
                tags$div(
                  style = "background:#fef9e7; border-left:5px solid #f39c12; border-radius:6px; padding:14px;",
                  tags$h4(style = "margin-top:0; color:#d68910;", "¿Qué es?"),
                  tags$p("Clasifica cada defunción en un ", strong("grupo de causa de muerte"),
                    " según la nomenclatura OPS 667. Es la variable que el modelo aprende a predecir."),
                  tags$h4(style = "color:#d68910;", "Tipo de variable"),
                  tags$p(tags$span(class="label label-warning", "Categórica nominal"), " — múltiples clases"),
                  tags$h4(style = "color:#d68910;", "Valores frecuentes"),
                  tags$ul(style = "padding-left:18px; font-size:13px;",
                    tags$li("Enfermedades del sistema circulatorio"),
                    tags$li("Causas externas"),
                    tags$li("Neoplasias (tumores)"),
                    tags$li("Enfermedades infecciosas y parasitarias"),
                    tags$li("Otras causas")
                  )
                )
              ),
              column(7,
                plotlyOutput("plot_target_preview", height = 280)
              )
            )
          )
        ),

        # Variables relacionadas — tarjetas
        fluidRow(
          box(
            width = 12, solidHeader = TRUE, status = "primary",
            title = tags$span(icon("th"), " Variables Relacionadas"),
            tags$p(style = "color:#7f8c8d; margin-bottom:16px;",
              "Estas variables se usan como predictores del modelo. En la pestaña ", strong("EDA"),
              " se analiza cada una en detalle."
            ),
            fluidRow(

              # EDAD_SIMPLE
              column(3,
                tags$div(style = "border:1px solid #d5d8dc; border-radius:8px; padding:14px; margin-bottom:12px; background:white;",
                  tags$div(style = "display:flex; align-items:center; margin-bottom:8px;",
                    tags$span(style = "background:#3498db; color:white; border-radius:50%; width:32px; height:32px; display:flex; align-items:center; justify-content:center; margin-right:10px;",
                      icon("user", style = "font-size:14px;")),
                    tags$strong("EDAD_SIMPLE")
                  ),
                  tags$span(class = "label label-info", "Numérica continua"), tags$br(), tags$br(),
                  tags$p(style = "font-size:12px; color:#555; margin:0;",
                    "Edad en años al momento del fallecimiento. Rango: 0 – 99 años."),
                  tags$hr(style = "margin:8px 0;"),
                  tags$small(style = "color:#7f8c8d;", icon("lightbulb-o"), " Alta influencia en el modelo")
                )
              ),

              # SEXO
              column(3,
                tags$div(style = "border:1px solid #d5d8dc; border-radius:8px; padding:14px; margin-bottom:12px; background:white;",
                  tags$div(style = "display:flex; align-items:center; margin-bottom:8px;",
                    tags$span(style = "background:#9b59b6; color:white; border-radius:50%; width:32px; height:32px; display:flex; align-items:center; justify-content:center; margin-right:10px;",
                      icon("venus-mars", style = "font-size:14px;")),
                    tags$strong("SEXO")
                  ),
                  tags$span(class = "label label-default", "Categórica binaria"), tags$br(), tags$br(),
                  tags$p(style = "font-size:12px; color:#555; margin:0;",
                    "1 = Masculino, 2 = Femenino. Diferencias importantes en causas externas y circulatorias."),
                  tags$hr(style = "margin:8px 0;"),
                  tags$small(style = "color:#7f8c8d;", icon("lightbulb-o"), " Diferencias por grupo de causa")
                )
              ),

              # ETAREO_QUIN
              column(3,
                tags$div(style = "border:1px solid #d5d8dc; border-radius:8px; padding:14px; margin-bottom:12px; background:white;",
                  tags$div(style = "display:flex; align-items:center; margin-bottom:8px;",
                    tags$span(style = "background:#2ecc71; color:white; border-radius:50%; width:32px; height:32px; display:flex; align-items:center; justify-content:center; margin-right:10px;",
                      icon("users", style = "font-size:14px;")),
                    tags$strong("ETAREO_QUIN")
                  ),
                  tags$span(class = "label label-success", "Categórica ordinal"), tags$br(), tags$br(),
                  tags$p(style = "font-size:12px; color:#555; margin:0;",
                    "Grupo etario quinquenal: 0-4, 5-9, … 80+. Resume la edad en rangos poblacionales."),
                  tags$hr(style = "margin:8px 0;"),
                  tags$small(style = "color:#7f8c8d;", icon("lightbulb-o"), " Relacionada con EDAD_SIMPLE")
                )
              ),

              # SEG_SOCIAL
              column(3,
                tags$div(style = "border:1px solid #d5d8dc; border-radius:8px; padding:14px; margin-bottom:12px; background:white;",
                  tags$div(style = "display:flex; align-items:center; margin-bottom:8px;",
                    tags$span(style = "background:#e74c3c; color:white; border-radius:50%; width:32px; height:32px; display:flex; align-items:center; justify-content:center; margin-right:10px;",
                      icon("hospital-o", style = "font-size:14px;")),
                    tags$strong("SEG_SOCIAL")
                  ),
                  tags$span(class = "label label-danger", "Categórica nominal"), tags$br(), tags$br(),
                  tags$p(style = "font-size:12px; color:#555; margin:0;",
                    "Régimen de salud: Contributivo, Subsidiado, Vinculado, Especial."),
                  tags$hr(style = "margin:8px 0;"),
                  tags$small(style = "color:#7f8c8d;", icon("lightbulb-o"), " Refleja condición socioeconómica")
                )
              )
            ),

            fluidRow(

              # NIVEL_EDU
              column(3,
                tags$div(style = "border:1px solid #d5d8dc; border-radius:8px; padding:14px; margin-bottom:12px; background:white;",
                  tags$div(style = "display:flex; align-items:center; margin-bottom:8px;",
                    tags$span(style = "background:#f39c12; color:white; border-radius:50%; width:32px; height:32px; display:flex; align-items:center; justify-content:center; margin-right:10px;",
                      icon("graduation-cap", style = "font-size:14px;")),
                    tags$strong("NIVEL_EDU")
                  ),
                  tags$span(class = "label label-warning", "Categórica ordinal"), tags$br(), tags$br(),
                  tags$p(style = "font-size:12px; color:#555; margin:0;",
                    "Nivel educativo: Sin escolaridad, Primaria, Secundaria, Técnico, Universitario."),
                  tags$hr(style = "margin:8px 0;"),
                  tags$small(style = "color:#7f8c8d;", icon("lightbulb-o"), " Proxy de nivel socioeconómico")
                )
              ),

              # EST_CIVIL
              column(3,
                tags$div(style = "border:1px solid #d5d8dc; border-radius:8px; padding:14px; margin-bottom:12px; background:white;",
                  tags$div(style = "display:flex; align-items:center; margin-bottom:8px;",
                    tags$span(style = "background:#1abc9c; color:white; border-radius:50%; width:32px; height:32px; display:flex; align-items:center; justify-content:center; margin-right:10px;",
                      icon("heart", style = "font-size:14px;")),
                    tags$strong("EST_CIVIL")
                  ),
                  tags$span(class = "label label-default", "Categórica nominal"), tags$br(), tags$br(),
                  tags$p(style = "font-size:12px; color:#555; margin:0;",
                    "Estado civil: Soltero, Casado, Viudo, Separado, Unión libre."),
                  tags$hr(style = "margin:8px 0;"),
                  tags$small(style = "color:#7f8c8d;", icon("lightbulb-o"), " Correlaciona con redes de apoyo")
                )
              ),

              # ANO
              column(3,
                tags$div(style = "border:1px solid #d5d8dc; border-radius:8px; padding:14px; margin-bottom:12px; background:white;",
                  tags$div(style = "display:flex; align-items:center; margin-bottom:8px;",
                    tags$span(style = "background:#2c3e50; color:white; border-radius:50%; width:32px; height:32px; display:flex; align-items:center; justify-content:center; margin-right:10px;",
                      icon("calendar", style = "font-size:14px;")),
                    tags$strong("ANO")
                  ),
                  tags$span(class = "label label-default", "Numérica entera"), tags$br(), tags$br(),
                  tags$p(style = "font-size:12px; color:#555; margin:0;",
                    "Año de defunción: 2012 a 2023. Captura tendencias temporales y eventos como el COVID-19."),
                  tags$hr(style = "margin:8px 0;"),
                  tags$small(style = "color:#7f8c8d;", icon("lightbulb-o"), " Tendencias a largo plazo")
                )
              ),

              # MES
              column(3,
                tags$div(style = "border:1px solid #d5d8dc; border-radius:8px; padding:14px; margin-bottom:12px; background:white;",
                  tags$div(style = "display:flex; align-items:center; margin-bottom:8px;",
                    tags$span(style = "background:#e67e22; color:white; border-radius:50%; width:32px; height:32px; display:flex; align-items:center; justify-content:center; margin-right:10px;",
                      icon("clock-o", style = "font-size:14px;")),
                    tags$strong("MES")
                  ),
                  tags$span(class = "label label-default", "Numérica entera"), tags$br(), tags$br(),
                  tags$p(style = "font-size:12px; color:#555; margin:0;",
                    "Mes de defunción: 1 (enero) a 12 (diciembre). Detecta estacionalidad en la mortalidad."),
                  tags$hr(style = "margin:8px 0;"),
                  tags$small(style = "color:#7f8c8d;", icon("lightbulb-o"), " Patrones estacionales")
                )
              )
            )
          )
        )
      ),

      # ── EDA: Resumen ───────────────────────────────────────
      tabItem("eda_res",

        # Fila 1: KPIs principales
        fluidRow(
          valueBoxOutput("vb_total",    width = 3),
          valueBoxOutput("vb_grupos",   width = 3),
          valueBoxOutput("vb_anio",     width = 3),
          valueBoxOutput("vb_edad_med", width = 3)
        ),
        fluidRow(
          valueBoxOutput("vb_masculino", width = 3),
          valueBoxOutput("vb_femenino",  width = 3),
          valueBoxOutput("vb_top_causa", width = 3),
          valueBoxOutput("vb_miss",      width = 3)
        ),

        # Fila 2: Top causas + distribución de edad
        fluidRow(
          box(width = 7, title = "Top 10 causas de defunción", solidHeader = TRUE, status = "primary",
            plotlyOutput("plot_top_causas", height = 320)
          ),
          box(width = 5, title = "Distribución de edad", solidHeader = TRUE, status = "info",
            plotlyOutput("plot_hist_edad", height = 320)
          )
        ),

        # Fila 3: Valores faltantes por variable + distribución sexo
        fluidRow(
          box(width = 6, title = "Valores faltantes por variable (dato crudo)", solidHeader = TRUE, status = "warning",
            plotlyOutput("plot_missing", height = 360)
          ),
          box(width = 3, title = "Distribución por sexo", solidHeader = TRUE, status = "success",
            plotlyOutput("plot_sexo_pie", height = 260)
          ),
          box(width = 3, title = "Defunciones por mes", solidHeader = TRUE, status = "danger",
            plotlyOutput("plot_mes_bar", height = 260)
          )
        )
      ),

      # ── EDA: Visualizaciones ───────────────────────────────
      tabItem("eda_viz",

        # Filtro global
        fluidRow(
          box(width = 12, solidHeader = TRUE, status = "primary",
              title = tags$span(icon("filter"), " Filtros globales"),
            fluidRow(
              column(3, selectInput("filt_grupo", "Grupo de causa:",
                                    choices = c("Todos" = "Todos", grupos_disponibles),
                                    selected = "Todos")),
              column(3, selectInput("filt_sexo", "Sexo:",
                                    choices = c("Todos" = "Todos",
                                                "Masculino" = "1", "Femenino" = "2"),
                                    selected = "Todos")),
              column(3, sliderInput("filt_ano", "Rango de años:",
                                    min = 2012, max = 2023, value = c(2012, 2023), sep = "")),
              column(3, sliderInput("filt_edad", "Rango de edad:",
                                    min = 0, max = 99, value = c(0, 99)))
            )
          )
        ),

        # Sección 1: Distribución univariada
        fluidRow(
          box(width = 12, solidHeader = TRUE, status = "primary",
              title = tags$span(icon("bar-chart"), " 1. Distribución de variables"),
            fluidRow(
              column(3,
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
              ),
              column(9, plotlyOutput("plot_eda", height = 380))
            )
          )
        ),

        # Sección 2: Análisis por causa
        fluidRow(
          box(width = 6, title = tags$span(icon("heartbeat"), " 2a. Edad por grupo de causa"),
              solidHeader = TRUE, status = "warning",
            plotlyOutput("plot_edad_grupo", height = 350)
          ),
          box(width = 6, title = tags$span(icon("venus-mars"), " 2b. Causa por sexo"),
              solidHeader = TRUE, status = "danger",
            plotlyOutput("plot_causa_sexo", height = 350)
          )
        ),

        # Sección 3: Temporal
        fluidRow(
          box(width = 8, title = tags$span(icon("line-chart"), " 3a. Evolución anual por grupo de causa"),
              solidHeader = TRUE, status = "success",
            plotlyOutput("plot_trend", height = 320)
          ),
          box(width = 4, title = tags$span(icon("th"), " 3b. Defunciones por mes y año"),
              solidHeader = TRUE, status = "info",
            plotlyOutput("plot_heatmap_mes_ano", height = 320)
          )
        ),

        # Sección 4: Variables socioeconómicas
        fluidRow(
          box(width = 6, title = tags$span(icon("graduation-cap"), " 4a. Causa por nivel educativo"),
              solidHeader = TRUE, status = "primary",
            plotlyOutput("plot_edu_causa", height = 340)
          ),
          box(width = 6, title = tags$span(icon("hospital-o"), " 4b. Causa por régimen de salud"),
              solidHeader = TRUE, status = "warning",
            plotlyOutput("plot_seg_causa", height = 340)
          )
        )
      ),

      # ── EDA: Tabla ────────────────────────────────────────
      tabItem("eda_tab",
        fluidRow(
          box(width = 12, solidHeader = TRUE, status = "info",
              title = tags$span(icon("table"), " Tabla de datos navegable"),
            fluidRow(
              column(3, selectInput("tab_grupo", "Grupo de causa:",
                                     choices = c("Todos", grupos_disponibles), selected = "Todos")),
              column(2, selectInput("tab_sexo", "Sexo:",
                                     choices = c("Todos", "Masculino"="1", "Femenino"="2"),
                                     selected = "Todos")),
              column(3, sliderInput("tab_ano", "Año:", min = 2012, max = 2023,
                                     value = c(2012, 2023), sep = "")),
              column(2, sliderInput("tab_edad", "Edad:", min = 0, max = 99,
                                     value = c(0, 99))),
              column(2, br(),
                     actionButton("tab_reset", "Limpiar filtros",
                                  icon = icon("undo"), class = "btn-default btn-sm"))
            ),
            hr(),
            fluidRow(
              column(3, uiOutput("tab_conteo")),
              column(9, DTOutput("tabla_datos"))
            )
          )
        )
      ),

      # ── ENTRENAMIENTO: Selección ───────────────────────────
      tabItem("tr_sel",
        box(width = 4, title = "Configuración", solidHeader = TRUE, status = "primary",
          radioButtons("modelo_tipo", "Algoritmo:",
                       choices = c("Random Forest"             = "rf",
                                   "Árbol de decisión (rpart)" = "rpart"),
                       selected = "rf"),
          sliderInput("tr_split", "% datos entrenamiento:", 60, 90, 75, 5),
          numericInput("rf_trees", "Núm. árboles (RF):", 100, 50, 500, 50),
          actionButton("btn_entrenar", "Entrenar modelo",
                        icon = icon("play"), class = "btn-success btn-block"),
          br(),
          tags$small("El entrenamiento puede tardar unos segundos según el tamaño de los datos.")
        ),
        box(width = 8, title = "Importancia de variables", solidHeader = TRUE, status = "success",
          plotlyOutput("plot_importancia", height = 380),
          verbatimTextOutput("train_log")
        )
      ),

      # ── ENTRENAMIENTO: Métricas ────────────────────────────
      tabItem("tr_met",
        box(width = 12, title = "Métricas de evaluación", solidHeader = TRUE, status = "warning",
          fluidRow(
            valueBoxOutput("vb_acc",  width = 3),
            valueBoxOutput("vb_kap",  width = 3),
            valueBoxOutput("vb_prec", width = 3),
            valueBoxOutput("vb_rec",  width = 3)
          ),
          hr(),
          h4("Reporte completo por clase"),
          verbatimTextOutput("metricas_detalle")
        )
      ),

      # ── ENTRENAMIENTO: Conf Matrix ─────────────────────────
      tabItem("tr_conf",
        box(width = 12, title = "Matriz de confusión", solidHeader = TRUE, status = "danger",
          plotlyOutput("plot_confmat", height = 520)
        )
      ),

      # ── PREDICCIÓN: Formulario ─────────────────────────────
      tabItem("pr_form",
        box(width = 6, title = "Datos del paciente", solidHeader = TRUE, status = "primary",
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
                           choices = c("Soltero(a)"=1, "Casado(a)"=2, "Viudo(a)"=3,
                                       "Separado(a)"=4, "Unión libre"=5, "Sin info"=9)),
              selectInput("p_edu", "Nivel educativo:",
                           choices = c("Sin escolaridad"=0, "Primaria"=1, "Secundaria"=2,
                                       "Técnico"=3, "Universitario"=4, "Sin info"=99)),
              selectInput("p_seg", "Seg. social:",
                           choices = c("Contributivo"=1, "Subsidiado"=2, "Vinculado"=3,
                                       "Especial"=4, "Sin info"=9))
            )
          ),
          fluidRow(
            column(6, numericInput("p_ano", "Año:", 2023, 2000, 2030)),
            column(6, selectInput("p_mes", "Mes:", choices = setNames(1:12,
                       c("Ene","Feb","Mar","Abr","May","Jun",
                         "Jul","Ago","Sep","Oct","Nov","Dic"))))
          ),
          actionButton("btn_predecir", "Predecir causa de muerte",
                        icon = icon("search"), class = "btn-primary btn-block")
        ),
        box(width = 6, title = "Instrucciones", solidHeader = TRUE, status = "info",
          p("Complete los datos demográficos del caso y presione ", strong("Predecir"), "."),
          tags$ul(
            tags$li("Asegúrese de haber entrenado el modelo en la pestaña Entrenamiento."),
            tags$li("Los resultados muestran el grupo de causa de muerte más probable."),
            tags$li("La visualización de probabilidad indica la certeza del modelo para cada clase.")
          ),
          br(),
          uiOutput("pred_alerta")
        )
      ),

      # ── PREDICCIÓN: Resultado ──────────────────────────────
      tabItem("pr_res",
        fluidRow(
          box(width = 6, title = "Resultado de la predicción",
              solidHeader = TRUE, status = "success",
            uiOutput("pred_resultado")
          ),
          box(width = 6, title = "Resumen del caso ingresado",
              solidHeader = TRUE, status = "info",
            tableOutput("pred_caso")
          )
        )
      ),

      # ── PREDICCIÓN: Probabilidad ───────────────────────────
      tabItem("pr_prob",
        box(width = 12, title = "Probabilidad por grupo de causa",
            solidHeader = TRUE, status = "warning",
          plotlyOutput("plot_prob", height = 420)
        )
      )

    ) # /tabItems
  ) # /dashboardBody
) # /dashboardPage
