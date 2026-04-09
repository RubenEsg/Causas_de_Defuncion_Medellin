# ============================================================
#  global.R
#  Modelo de Clasificación - Causas de Defunción (Medellín)
#  Cargado una sola vez al iniciar la app
# ============================================================

# ── Paquetes ─────────────────────────────────────────────────
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(dplyr)
library(ggplot2)
library(plotly)
library(DT)
library(randomForest)
library(caret)
library(reshape2)
library(scales)

# ── Carga y preprocesamiento de datos ────────────────────────
datos_raw <- tryCatch(
  read.csv("defunciones.csv",
           sep = ",", encoding = "UTF-8", stringsAsFactors = FALSE),
  error = function(e) NULL
)

preparar_datos <- function(df) {
  if (is.null(df)) return(NULL)

  df <- df %>%
    mutate(
      SEXO        = factor(SEXO),
      EST_CIVIL   = factor(EST_CIVIL),
      NIVEL_EDU   = factor(NIVEL_EDU),
      SEG_SOCIAL  = factor(SEG_SOCIAL),
      ETAREO_QUIN = factor(ETAREO_QUIN),
      ANO         = as.integer(ANO),
      MES         = as.integer(MES),
      EDAD_SIMPLE = as.integer(EDAD_SIMPLE),
      NOM_667_OPS_GRUPO = factor(NOM_667_OPS_GRUPO)
    ) %>%
    filter(!is.na(NOM_667_OPS_GRUPO),
           NOM_667_OPS_GRUPO != "",
           NOM_667_OPS_GRUPO != "Sin informacion")

  df
}

datos <- preparar_datos(datos_raw)

# Datos demo si no hay archivo
if (is.null(datos)) {
  set.seed(42)
  grupos <- c("Causas externas", "Enfermedades del sistema circulatorio",
               "Neoplasias", "Enfermedades infecciosas", "Otras causas")
  datos <- data.frame(
    SEXO        = sample(c("1","2"), 500, replace = TRUE),
    EST_CIVIL   = sample(as.character(1:6), 500, replace = TRUE),
    NIVEL_EDU   = sample(as.character(c(1,2,3,4,99)), 500, replace = TRUE),
    SEG_SOCIAL  = sample(as.character(1:5), 500, replace = TRUE),
    ETAREO_QUIN = sample(c("0-4","5-9","25-29","45-49","65-69","80+"), 500, replace = TRUE),
    ANO         = sample(2012:2022, 500, replace = TRUE),
    MES         = sample(1:12, 500, replace = TRUE),
    EDAD_SIMPLE = sample(0:99, 500, replace = TRUE),
    NOM_667_OPS_GRUPO = factor(sample(grupos, 500, replace = TRUE,
                                       prob = c(0.3,0.25,0.2,0.15,0.1)))
  )
}

# Features para el modelo
FEATURES <- c("SEXO","EST_CIVIL","NIVEL_EDU","SEG_SOCIAL",
              "ETAREO_QUIN","ANO","MES","EDAD_SIMPLE")

datos_modelo <- datos %>%
  select(all_of(FEATURES), NOM_667_OPS_GRUPO) %>%
  na.omit()

grupos_disponibles <- levels(datos_modelo$NOM_667_OPS_GRUPO)

# ── Paleta de colores ─────────────────────────────────────────
PAL <- c("#2C3E50","#E74C3C","#3498DB","#2ECC71","#F39C12",
         "#9B59B6","#1ABC9C","#E67E22","#D35400","#27AE60")
