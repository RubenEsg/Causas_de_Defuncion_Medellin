# ============================================================
#  global.R
#  Modelo de Clasificación - Causas de Defunción (Medellín)
# ============================================================

# ── Paquetes ─────────────────────────────────────────────────
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(DT)
library(randomForest)
library(caret)
library(reshape2)
library(scales)

# ── Carga de datos ───────────────────────────────────────────
URL_DATOS <- "https://raw.githubusercontent.com/RubenEsg/Causas_de_Defuncion_Medellin/main/data/defunciones.csv"

datos_raw <- tryCatch({
  message("[global.R] Descargando datos desde GitHub...")
  df <- read.csv(URL_DATOS, sep = ",", encoding = "UTF-8", stringsAsFactors = FALSE)
  message("[global.R] Descarga exitosa — ", nrow(df), " registros.")
  df
}, error = function(e) {
  message("[global.R] Fallo GitHub: ", conditionMessage(e), " — intentando local...")
  tryCatch(
    read.csv("defunciones.csv", sep = ",", fileEncoding = "latin1", stringsAsFactors = FALSE),
    error = function(e2) { message("[global.R] Fallo local: ", conditionMessage(e2)); NULL }
  )
})

# ============================================================
#  FUNCIÓN DE LIMPIEZA Y PREPARACIÓN DE DATOS
# ============================================================
# ── NA del dato crudo (antes de limpieza) para el gráfico de faltantes ─
INFO_NA_CRUDO <- if (!is.null(datos_raw)) {
  # Códigos centinela que DANE usa para "sin información"
  CENTINELAS <- c("", "Sin informacion", "9", "99", "999", "998")
  datos_raw %>%
    mutate(across(everything(), as.character)) %>%
    summarise(across(everything(),
                     ~ sum(is.na(.) | trimws(.) %in% CENTINELAS))) %>%
    tidyr::pivot_longer(everything(),
                        names_to  = "Variable",
                        values_to = "Faltantes") %>%
    mutate(Pct = round(Faltantes / nrow(datos_raw) * 100, 1)) %>%
    arrange(desc(Faltantes))
} else NULL

preparar_datos <- function(df) {
  if (is.null(df)) return(NULL)
  
  reporte <- list()   # acumula estadísticas del proceso
  
  n_inicial <- nrow(df)
  message("\n========================================")
  message(" INICIO LIMPIEZA DE DATOS")
  message("========================================")
  message("Registros iniciales: ", n_inicial)
  
  # ----------------------------------------------------------
  # 1. VARIABLE TARGET — filtrar vacíos y "Sin informacion"
  # ----------------------------------------------------------
  df <- df %>%
    filter(
      !is.na(NOM_667_OPS_GRUPO),
      trimws(NOM_667_OPS_GRUPO) != "",
      trimws(NOM_667_OPS_GRUPO) != "Sin informacion"
    )
  reporte$target_eliminados <- n_inicial - nrow(df)
  message("\n[1] Target (NOM_667_OPS_GRUPO)")
  message("    Eliminados por vacío/sin info: ", reporte$target_eliminados)
  
  # ----------------------------------------------------------
  # 2. SEXO — código 3 y 9 = indeterminado/sin info → NA
  #    Decisión: eliminar (son < 1% en DANE, no imputables)
  # ----------------------------------------------------------
  antes <- nrow(df)
  df <- df %>%
    mutate(SEXO = ifelse(as.character(SEXO) %in% c("3","9","99"), NA, as.character(SEXO)))
  na_sexo <- sum(is.na(df$SEXO))
  pct_sexo <- round(na_sexo / nrow(df) * 100, 2)
  message("\n[2] SEXO — NAs tras limpiar códigos centinela: ", na_sexo, " (", pct_sexo, "%)")
  if (pct_sexo <= 2) {
    df <- df %>% filter(!is.na(SEXO))
    message("    Accion: ELIMINAR filas (", pct_sexo, "% <= 2%)")
  } else {
    df <- df %>% mutate(SEXO = ifelse(is.na(SEXO), "9", SEXO))  # categoria "No informado"
    message("    Accion: CATEGORIA 'No informado' (", pct_sexo, "% > 2%)")
  }
  df$SEXO <- factor(df$SEXO)
  
  # ----------------------------------------------------------
  # 3. EST_CIVIL — código 9 = sin información → NA
  #    Si NA <= 5%: imputar con moda; si no: categoría propia
  # ----------------------------------------------------------
  df <- df %>%
    mutate(EST_CIVIL = ifelse(as.character(EST_CIVIL) %in% c("9","99"), NA, as.character(EST_CIVIL)))
  na_ec <- sum(is.na(df$EST_CIVIL))
  pct_ec <- round(na_ec / nrow(df) * 100, 2)
  message("\n[3] EST_CIVIL — NAs: ", na_ec, " (", pct_ec, "%)")
  if (pct_ec <= 5) {
    moda_ec <- names(sort(table(df$EST_CIVIL), decreasing = TRUE))[1]
    df <- df %>% mutate(EST_CIVIL = ifelse(is.na(EST_CIVIL), moda_ec, EST_CIVIL))
    message("    Accion: IMPUTAR con moda = '", moda_ec, "'")
  } else {
    df <- df %>% mutate(EST_CIVIL = ifelse(is.na(EST_CIVIL), "9", EST_CIVIL))
    message("    Accion: CATEGORIA 'No informado'")
  }
  df$EST_CIVIL <- factor(df$EST_CIVIL)
  
  # ----------------------------------------------------------
  # 4. NIVEL_EDU — código 99 = sin información → NA
  #    Si NA <= 5%: imputar con moda; si no: categoría propia
  # ----------------------------------------------------------
  df <- df %>%
    mutate(NIVEL_EDU = ifelse(as.character(NIVEL_EDU) %in% c("99","999"), NA, as.character(NIVEL_EDU)))
  na_edu <- sum(is.na(df$NIVEL_EDU))
  pct_edu <- round(na_edu / nrow(df) * 100, 2)
  message("\n[4] NIVEL_EDU — NAs: ", na_edu, " (", pct_edu, "%)")
  if (pct_edu <= 5) {
    moda_edu <- names(sort(table(df$NIVEL_EDU), decreasing = TRUE))[1]
    df <- df %>% mutate(NIVEL_EDU = ifelse(is.na(NIVEL_EDU), moda_edu, NIVEL_EDU))
    message("    Accion: IMPUTAR con moda = '", moda_edu, "'")
  } else {
    df <- df %>% mutate(NIVEL_EDU = ifelse(is.na(NIVEL_EDU), "99", NIVEL_EDU))
    message("    Accion: CATEGORIA 'No informado'")
  }
  df$NIVEL_EDU <- factor(df$NIVEL_EDU)
  
  # ----------------------------------------------------------
  # 5. SEG_SOCIAL — código 9 = sin información → NA
  # ----------------------------------------------------------
  df <- df %>%
    mutate(SEG_SOCIAL = ifelse(as.character(SEG_SOCIAL) %in% c("9","99"), NA, as.character(SEG_SOCIAL)))
  na_seg <- sum(is.na(df$SEG_SOCIAL))
  pct_seg <- round(na_seg / nrow(df) * 100, 2)
  message("\n[5] SEG_SOCIAL — NAs: ", na_seg, " (", pct_seg, "%)")
  if (pct_seg <= 5) {
    moda_seg <- names(sort(table(df$SEG_SOCIAL), decreasing = TRUE))[1]
    df <- df %>% mutate(SEG_SOCIAL = ifelse(is.na(SEG_SOCIAL), moda_seg, SEG_SOCIAL))
    message("    Accion: IMPUTAR con moda = '", moda_seg, "'")
  } else {
    df <- df %>% mutate(SEG_SOCIAL = ifelse(is.na(SEG_SOCIAL), "9", SEG_SOCIAL))
    message("    Accion: CATEGORIA 'No informado'")
  }
  df$SEG_SOCIAL <- factor(df$SEG_SOCIAL)
  
  # ----------------------------------------------------------
  # 6. ANO — rango válido: 2005–año actual
  #    Outliers: eliminar (año incorrecto no es imputable)
  # ----------------------------------------------------------
  df <- df %>% mutate(ANO = as.integer(ANO))
  ano_inv <- sum(df$ANO < 2005 | df$ANO > as.integer(format(Sys.Date(), "%Y")), na.rm = TRUE)
  message("\n[6] ANO — fuera de rango [2005, hoy]: ", ano_inv)
  df <- df %>% filter(ANO >= 2005, ANO <= as.integer(format(Sys.Date(), "%Y")))
  message("    Accion: ELIMINAR filas con año inválido")
  
  # ----------------------------------------------------------
  # 7. MES — rango válido: 1–12
  # ----------------------------------------------------------
  df <- df %>% mutate(MES = as.integer(MES))
  mes_inv <- sum(df$MES < 1 | df$MES > 12, na.rm = TRUE)
  message("\n[7] MES — fuera de rango [1,12]: ", mes_inv)
  df <- df %>% filter(MES >= 1, MES <= 12)
  message("    Accion: ELIMINAR filas con mes inválido")
  
  # ----------------------------------------------------------
  # 8. EDAD_SIMPLE — variable numérica con outliers
  #
  #    Paso A: Códigos centinela DANE (999, 998) → NA
  #    Paso B: Dominio biológico imposible (> 120) → NA
  #    Paso C: Outliers estadísticos por IQR
  #            límite_inf = Q1 - 3*IQR  (relajado porque hay muchas muertes infantiles)
  #            límite_sup = Q3 + 3*IQR
  #    Paso D: Si NA <= 3%: imputar con mediana; si no: eliminar
  # ----------------------------------------------------------
  df <- df %>% mutate(EDAD_SIMPLE = as.integer(EDAD_SIMPLE))
  
  # A+B: centinelas y dominio
  df <- df %>%
    mutate(EDAD_SIMPLE = ifelse(EDAD_SIMPLE %in% c(998, 999) | EDAD_SIMPLE > 120,
                                NA, EDAD_SIMPLE))
  na_edad_cd <- sum(is.na(df$EDAD_SIMPLE))
  
  # C: IQR (factor 3 para no perder muertes infantiles/neonatales legítimas)
  q1   <- quantile(df$EDAD_SIMPLE, 0.25, na.rm = TRUE)
  q3   <- quantile(df$EDAD_SIMPLE, 0.75, na.rm = TRUE)
  iqr  <- q3 - q1
  lim_inf <- max(0, q1 - 3 * iqr)   # nunca negativo
  lim_sup <- q3 + 3 * iqr
  
  out_edad <- sum(!is.na(df$EDAD_SIMPLE) &
                    (df$EDAD_SIMPLE < lim_inf | df$EDAD_SIMPLE > lim_sup))
  df <- df %>%
    mutate(EDAD_SIMPLE = ifelse(!is.na(EDAD_SIMPLE) &
                                  (EDAD_SIMPLE < lim_inf | EDAD_SIMPLE > lim_sup),
                                NA, EDAD_SIMPLE))
  
  na_edad_total <- sum(is.na(df$EDAD_SIMPLE))
  pct_edad      <- round(na_edad_total / nrow(df) * 100, 2)
  
  message("\n[8] EDAD_SIMPLE")
  message("    Rango IQR: [", lim_inf, ", ", lim_sup, "]")
  message("    NAs por centinelas/dominio: ", na_edad_cd)
  message("    NAs adicionales por outlier IQR: ", out_edad)
  message("    Total NAs: ", na_edad_total, " (", pct_edad, "%)")
  
  # D: imputar o eliminar
  if (pct_edad <= 3) {
    med_edad <- median(df$EDAD_SIMPLE, na.rm = TRUE)
    df <- df %>% mutate(EDAD_SIMPLE = ifelse(is.na(EDAD_SIMPLE), med_edad, EDAD_SIMPLE))
    message("    Accion: IMPUTAR con mediana = ", med_edad, " (", pct_edad, "% <= 3%)")
  } else {
    df <- df %>% filter(!is.na(EDAD_SIMPLE))
    message("    Accion: ELIMINAR filas (", pct_edad, "% > 3%)")
  }
  
  # ----------------------------------------------------------
  # 9. ETAREO_QUIN — reconstruir desde EDAD_SIMPLE limpia
  #    para garantizar coherencia interna
  # ----------------------------------------------------------
  construir_etareo <- function(edad) {
    breaks <- c(0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,Inf)
    labels <- c("0-4","5-9","10-14","15-19","20-24","25-29",
                "30-34","35-39","40-44","45-49","50-54","55-59",
                "60-64","65-69","70-74","75-79","80+")
    cut(edad, breaks = breaks, labels = labels, right = FALSE, include.lowest = TRUE)
  }
  df <- df %>% mutate(ETAREO_QUIN = construir_etareo(EDAD_SIMPLE))
  message("\n[9] ETAREO_QUIN — reconstruida desde EDAD_SIMPLE limpia")
  
  # ----------------------------------------------------------
  # 10. TARGET como factor
  # ----------------------------------------------------------
  df <- df %>%
    mutate(NOM_667_OPS_GRUPO = factor(trimws(NOM_667_OPS_GRUPO)))
  message("\n[10] NOM_667_OPS_GRUPO — ", nlevels(df$NOM_667_OPS_GRUPO), " grupos")
  
  # ----------------------------------------------------------
  # RESUMEN FINAL
  # ----------------------------------------------------------
  n_final <- nrow(df)
  message("\n========================================")
  message(" RESUMEN LIMPIEZA")
  message("========================================")
  message("Registros iniciales : ", n_inicial)
  message("Registros finales   : ", n_final)
  message("Eliminados totales  : ", n_inicial - n_final,
          " (", round((n_inicial - n_final) / n_inicial * 100, 2), "%)")
  message("NAs restantes       : ", sum(is.na(df)))
  message("========================================\n")
  
  df
}

# ── Aplicar limpieza ─────────────────────────────────────────
datos <- preparar_datos(datos_raw)

# ── Fallback demo ────────────────────────────────────────────
if (is.null(datos)) {
  DATOS_ORIGEN <- "demo"
  message("[global.R] Usando datos demo (500 registros).")
  set.seed(42)
  grupos <- c("Causas externas", "Enfermedades del sistema circulatorio",
              "Neoplasias", "Enfermedades infecciosas", "Otras causas")
  datos <- data.frame(
    SEXO        = factor(sample(c("1","2"), 500, replace = TRUE)),
    EST_CIVIL   = factor(sample(as.character(1:6), 500, replace = TRUE)),
    NIVEL_EDU   = factor(sample(as.character(c(1,2,3,4)), 500, replace = TRUE)),
    SEG_SOCIAL  = factor(sample(as.character(1:5), 500, replace = TRUE)),
    ETAREO_QUIN = factor(sample(c("0-4","5-9","25-29","45-49","65-69","80+"), 500, replace = TRUE)),
    ANO         = sample(2012:2022, 500, replace = TRUE),
    MES         = sample(1:12, 500, replace = TRUE),
    EDAD_SIMPLE = sample(0:99, 500, replace = TRUE),
    NOM_667_OPS_GRUPO = factor(sample(grupos, 500, replace = TRUE,
                                      prob = c(0.3,0.25,0.2,0.15,0.1)))
  )
} else {
  DATOS_ORIGEN <- "real"
}

# ── Features para el modelo ──────────────────────────────────
FEATURES <- c("SEXO","EST_CIVIL","NIVEL_EDU","SEG_SOCIAL",
              "ETAREO_QUIN","ANO","MES","EDAD_SIMPLE")

datos_modelo <- datos %>%
  select(all_of(FEATURES), NOM_667_OPS_GRUPO) %>%
  na.omit()

grupos_disponibles <- levels(datos_modelo$NOM_667_OPS_GRUPO)

# ── Paleta de colores ─────────────────────────────────────────
PAL <- c("#2C3E50","#E74C3C","#3498DB","#2ECC71","#F39C12",
         "#9B59B6","#1ABC9C","#E67E22","#D35400","#27AE60")