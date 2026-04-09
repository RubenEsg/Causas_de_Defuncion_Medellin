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
      "Defunciones – Clasificación"
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
        fluidRow(
          box(
            width = 12, solidHeader = TRUE, status = "primary",
            title = "Contexto del Proyecto",
            h2("Análisis Exploratorio de la Mortalidad en Medellín", class = "seccion"),
            p(class = "justificado",
              "El estudio de la mortalidad en una población constituye una herramienta esencial para ",
              "comprender el estado de salud colectiva, identificar grupos de mayor vulnerabilidad y ",
              "apoyar la formulación de estrategias de intervención y políticas públicas basadas en evidencia. ",
              "En Medellín, el registro de defunciones es consolidado por las instituciones prestadoras de salud (IPS), ",
              "reuniendo información de carácter demográfico, geográfico, temporal y clínico sobre cada fallecimiento."
            ),
            p(class = "justificado",
              "En este proyecto se trabaja con un conjunto de datos del ",
              strong("Registro de Defunciones de Medellín"),
              ", publicado en el portal de datos abiertos ",
              tags$a(href = "https://medata.gov.co/node/16570", "MeData (medata.gov.co)", target = "_blank"),
              ", el cual contiene aproximadamente ",
              strong("145.000 registros"),
              " correspondientes al periodo ",
              strong("2012 a 2023"),
              ". Esta base incluye variables relacionadas con sexo, edad, estado civil, nivel educativo, ",
              "afiliación al sistema de salud, ubicación territorial y causa básica de defunción, entre otras."
            ),
            p(class = "justificado",
              "El propósito principal de esta aplicación es desarrollar un ",
              strong("Análisis Exploratorio de Datos (EDA)"),
              " que permita examinar la estructura del conjunto de datos, reconocer distribuciones, detectar patrones ",
              "temporales y territoriales, e identificar posibles inconsistencias o valores faltantes."
            ),
            p(class = "justificado",
              "Además, este análisis constituye la base para la construcción de ",
              strong("dashboards interactivos"),
              " en herramientas como ",
              strong("Shiny en R"),
              " y ",
              strong("Dash en Python"),
              ", orientados a la visualización de hallazgos y a la comunicación efectiva de resultados."
            ),
            hr(),
            fluidRow(
              infoBox("Cobertura temporal", "2012 - 2023",  icon = icon("calendar"),  color = "blue",   width = 4),
              infoBox("Tamaño del dataset", "~145.000 registros", icon = icon("database"), color = "green",  width = 4),
              infoBox("Fuente", "MeData Medellín",           icon = icon("globe"),    color = "orange", width = 4)
            )
          )
        )
      ),

      # ── OBJETIVOS ─────────────────────────────────────────
      tabItem("obj",
        box(
          width = 12, solidHeader = TRUE, status = "success",
          title = "Objetivos del Proyecto",
          h2("Objetivo General", class = "seccion"),
          p(class = "justificado",
            "Realizar un análisis exploratorio de datos sobre el registro de defunciones de Medellín ",
            "correspondiente al periodo 2012-2023, con el fin de comprender la estructura del conjunto ",
            "de datos, identificar patrones de mortalidad y generar información útil para la construcción ",
            "de herramientas interactivas de visualización y apoyo a la toma de decisiones."
          ),
          hr(),
          h2("Objetivos Específicos", class = "seccion"),
          tags$ol(
            tags$li("Examinar la calidad y estructura del conjunto de datos, identificando tipos de variables, ",
                    "valores faltantes, posibles inconsistencias y transformaciones necesarias para su análisis."),
            tags$li("Describir el comportamiento de las defunciones a partir de variables demográficas como sexo, edad, ",
                    "estado civil, nivel educativo y afiliación al sistema de salud."),
            tags$li("Analizar la distribución temporal de la mortalidad en Medellín, identificando tendencias anuales, ",
                    "variaciones mensuales y posibles patrones estacionales en los registros."),
            tags$li("Explorar diferencias territoriales y poblacionales en las defunciones, con el propósito de detectar ",
                    "grupos de riesgo y comportamientos diferenciales entre distintos segmentos de la población."),
            tags$li("Estudiar la frecuencia y distribución de las principales causas de defunción, así como su relación ",
                    "con variables sociodemográficas relevantes."),
            tags$li("Generar visualizaciones claras e interactivas que faciliten la interpretación de los hallazgos y ",
                    "sirvan como base para la implementación de dashboards en Shiny y otras herramientas analíticas.")
          )
        )
      ),

      # ── PROBLEMA ──────────────────────────────────────────
      tabItem("prob",
        box(
          width = 12, solidHeader = TRUE, status = "danger",
          title = "Planteamiento del Problema",
          h2("Descripción", class = "seccion"),
          p(class = "justificado",
            "La mortalidad es uno de los indicadores más importantes en salud pública, ya que permite evaluar ",
            "las condiciones de vida de una población, identificar desigualdades y reconocer las principales ",
            "causas asociadas al fallecimiento."
          ),
          p(class = "justificado",
            "No obstante, la magnitud del conjunto de datos y la diversidad de variables incluidas dificultan ",
            "la identificación rápida de patrones relevantes, como tendencias en el tiempo, diferencias entre grupos ",
            "de edad, variaciones por sexo, comportamientos territoriales o la distribución de las causas de muerte."
          ),
          p(class = "justificado",
            "En este contexto, surge la necesidad de desarrollar un proceso sistemático de exploración y depuración ",
            "de datos que permita comprender la estructura de la base, detectar anomalías y resumir la información más ",
            "relevante de forma clara."
          ),
          hr(),
          h2("Pregunta de Investigación", class = "seccion"),
          tags$blockquote(
            style = "font-size:16px; border-left:4px solid #e74c3c; padding-left:14px;",
            "¿Qué patrones, tendencias y diferencias relevantes pueden identificarse en los registros de defunciones ",
            "de Medellín entre 2012 y 2023 a partir de un análisis exploratorio de variables demográficas, temporales, ",
            "territoriales y clínicas?"
          ),
          hr(),
          h2("Dimensiones de Análisis", class = "seccion"),
          fluidRow(
            column(8,
              tags$table(
                class = "table table-bordered table-hover",
                tags$thead(tags$tr(tags$th("Dimensión"), tags$th("Ejemplos de variables"), tags$th("Propósito"))),
                tags$tbody(
                  tags$tr(tags$td("Demográfica"),    tags$td("SEXO, EDAD_SIMPLE, EST_CIVIL, NIVEL_EDU"), tags$td("Caracterizar la población fallecida")),
                  tags$tr(tags$td("Socioeconómica"), tags$td("SEG_SOCIAL"),                              tags$td("Explorar condiciones de afiliación y cobertura")),
                  tags$tr(tags$td("Temporal"),       tags$td("ANO, MES"),                               tags$td("Identificar tendencias y variaciones en el tiempo")),
                  tags$tr(tags$td("Poblacional"),    tags$td("ETAREO_QUIN"),                            tags$td("Comparar grupos etarios y perfiles de riesgo")),
                  tags$tr(tags$td("Clínica"),        tags$td("NOM_667_OPS_GRUPO"),                      tags$td("Analizar las principales causas de defunción"))
                )
              )
            )
          )
        )
      ),

      # ── EDA: Resumen ───────────────────────────────────────
      tabItem("eda_res",
        fluidRow(
          valueBoxOutput("vb_total",  width = 3),
          valueBoxOutput("vb_grupos", width = 3),
          valueBoxOutput("vb_anio",   width = 3),
          valueBoxOutput("vb_miss",   width = 3)
        ),
        fluidRow(
          box(width = 12, title = "Resumen estadístico", solidHeader = TRUE, status = "info",
            verbatimTextOutput("resumen_str")
          )
        )
      ),

      # ── EDA: Visualizaciones ───────────────────────────────
      tabItem("eda_viz",
        fluidRow(
          box(width = 4, title = "Opciones", solidHeader = TRUE, status = "primary",
            selectInput("eda_var", "Variable a visualizar:",
                        choices = c("Grupos de causa" = "NOM_667_OPS_GRUPO",
                                    "Sexo"            = "SEXO",
                                    "Grupo etáreo"    = "ETAREO_QUIN",
                                    "Año"             = "ANO",
                                    "Seg. social"     = "SEG_SOCIAL")),
            selectInput("eda_tipo", "Tipo de gráfico:",
                        choices = c("Barras" = "bar", "Circular" = "pie")),
            checkboxInput("eda_pct", "Mostrar porcentaje", TRUE)
          ),
          box(width = 8, title = "Distribución", solidHeader = TRUE, status = "primary",
            plotlyOutput("plot_eda", height = 400)
          )
        ),
        fluidRow(
          box(width = 6, title = "Distribución de edad por grupo de causa",
              solidHeader = TRUE, status = "warning",
            plotlyOutput("plot_edad_grupo", height = 350)
          ),
          box(width = 6, title = "Evolución anual por grupo de causa",
              solidHeader = TRUE, status = "success",
            plotlyOutput("plot_trend", height = 350)
          )
        )
      ),

      # ── EDA: Tabla ────────────────────────────────────────
      tabItem("eda_tab",
        box(width = 12, title = "Tabla de datos navegable",
            solidHeader = TRUE, status = "info",
          fluidRow(
            column(4, selectInput("tab_grupo", "Filtrar por grupo:",
                                   choices = c("Todos", grupos_disponibles), selected = "Todos")),
            column(4, selectInput("tab_sexo", "Filtrar por sexo:",
                                   choices = c("Todos", "1" = "1", "2" = "2"), selected = "Todos")),
            column(4, numericInput("tab_filas", "Filas por página:", 10, 5, 50, 5))
          ),
          DTOutput("tabla_datos")
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
