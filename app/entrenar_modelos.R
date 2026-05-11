# ============================================================
#  entrenar_modelos.R
#  Script independiente para entrenar RF + Árbol de decisión
#  y guardar los resultados en:
#  C:/Users/Usuario/Causas_de_Defuncion_Medellin/app/models/
#
#  Uso: ejecutar este script UNA VEZ (puede tardar varios
#  minutos). Luego la app carga los modelos automáticamente
#  sin necesidad de volver a entrenar.
# ============================================================

# ── 0. CONFIGURACIÓN ─────────────────────────────────────────
RUTA_MODELOS <- "C:/Users/Usuario/Causas_de_Defuncion_Medellin/app/models"
TRAIN_SPLIT  <- 0.75    # proporción de datos para entrenamiento (75%)
RF_TREES     <- 300     # número de árboles del Random Forest

cat("╔══════════════════════════════════════════════════════╗\n")
cat("║   ENTRENAMIENTO DE MODELOS — Causas de Defunción     ║\n")
cat("╚══════════════════════════════════════════════════════╝\n\n")

# ── 1. PAQUETES ──────────────────────────────────────────────
paquetes_necesarios <- c("dplyr", "tidyr", "randomForest", "caret", "tibble")

paquetes_faltantes <- paquetes_necesarios[
  !sapply(paquetes_necesarios, requireNamespace, quietly = TRUE)
]

if (length(paquetes_faltantes) > 0) {
  cat("[INFO] Instalando paquetes faltantes:", paste(paquetes_faltantes, collapse = ", "), "\n")
  install.packages(paquetes_faltantes, dependencies = TRUE)
}

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(randomForest)
  library(caret)
  library(tibble)
})

cat("[OK] Paquetes cargados.\n\n")

# ── 2. CARGA DE DATOS ─────────────────────────────────────────
URL_DATOS <- "https://raw.githubusercontent.com/RubenEsg/Causas_de_Defuncion_Medellin/main/data/defunciones.csv"

cat("[INFO] Descargando datos desde GitHub...\n")

datos_raw <- tryCatch({
  df <- read.csv(URL_DATOS, sep = ",", encoding = "UTF-8", stringsAsFactors = FALSE)
  cat("[OK] Descarga exitosa —", nrow(df), "registros.\n\n")
  df
}, error = function(e) {
  cat("[WARN] Fallo descarga GitHub:", conditionMessage(e), "\n")
  cat("[INFO] Intentando archivo local 'defunciones.csv'...\n")
  tryCatch({
    df <- read.csv("defunciones.csv", sep = ",", fileEncoding = "latin1",
                   stringsAsFactors = FALSE)
    cat("[OK] Carga local exitosa —", nrow(df), "registros.\n\n")
    df
  }, error = function(e2) {
    stop("No se pudo cargar el archivo de datos: ", conditionMessage(e2))
  })
})

# ── 3. FUNCIÓN DE LIMPIEZA (idéntica a global.R) ─────────────
preparar_datos <- function(df) {
  
  n_inicial <- nrow(df)
  cat("══════════════════════════════════════════════\n")
  cat(" LIMPIEZA DE DATOS\n")
  cat("══════════════════════════════════════════════\n")
  cat("Registros iniciales:", n_inicial, "\n\n")
  
  # 3.1 Variable target
  df <- df %>%
    filter(
      !is.na(NOM_667_OPS_GRUPO),
      trimws(NOM_667_OPS_GRUPO) != "",
      trimws(NOM_667_OPS_GRUPO) != "Sin informacion"
    ) %>%
    mutate(NOM_667_OPS_GRUPO = trimws(NOM_667_OPS_GRUPO),
           NOM_667_OPS_GRUPO = ifelse(
             grepl("Signos", NOM_667_OPS_GRUPO, ignore.case = TRUE),
             "Signos, sintomas y afecciones mal definidas",
             NOM_667_OPS_GRUPO
           ))
  cat("[1] Target limpio. Registros restantes:", nrow(df), "\n")
  
  # 3.2 SEXO
  df <- df %>%
    mutate(SEXO = ifelse(as.character(SEXO) %in% c("3","9","99"), NA, as.character(SEXO)))
  pct_sexo <- round(sum(is.na(df$SEXO)) / nrow(df) * 100, 2)
  if (pct_sexo <= 2) {
    df <- df %>% filter(!is.na(SEXO))
    cat("[2] SEXO: eliminadas filas con NA (", pct_sexo, "%)\n")
  } else {
    df <- df %>% mutate(SEXO = ifelse(is.na(SEXO), "9", SEXO))
    cat("[2] SEXO: NAs → categoría '9'\n")
  }
  df$SEXO <- factor(df$SEXO)
  
  # 3.3 EST_CIVIL
  df <- df %>%
    mutate(EST_CIVIL = ifelse(as.character(EST_CIVIL) %in% c("9","99"), NA, as.character(EST_CIVIL)))
  pct_ec <- round(sum(is.na(df$EST_CIVIL)) / nrow(df) * 100, 2)
  if (pct_ec <= 5) {
    moda_ec <- names(sort(table(df$EST_CIVIL), decreasing = TRUE))[1]
    df <- df %>% mutate(EST_CIVIL = ifelse(is.na(EST_CIVIL), moda_ec, EST_CIVIL))
    cat("[3] EST_CIVIL: imputado con moda =", moda_ec, "\n")
  } else {
    df <- df %>% mutate(EST_CIVIL = ifelse(is.na(EST_CIVIL), "9", EST_CIVIL))
    cat("[3] EST_CIVIL: NAs → categoría '9'\n")
  }
  df$EST_CIVIL <- factor(df$EST_CIVIL)
  
  # 3.4 NIVEL_EDU
  df <- df %>%
    mutate(NIVEL_EDU = ifelse(as.character(NIVEL_EDU) %in% c("99","999"), NA, as.character(NIVEL_EDU)))
  df <- df %>% filter(!is.na(NIVEL_EDU))
  df$NIVEL_EDU <- factor(df$NIVEL_EDU)
  cat("[4] NIVEL_EDU: eliminadas filas sin información.\n")
  
  # 3.5 SEG_SOCIAL
  df <- df %>%
    mutate(SEG_SOCIAL = ifelse(as.character(SEG_SOCIAL) %in% c("9","99"), NA, as.character(SEG_SOCIAL)))
  pct_seg <- round(sum(is.na(df$SEG_SOCIAL)) / nrow(df) * 100, 2)
  if (pct_seg <= 5) {
    moda_seg <- names(sort(table(df$SEG_SOCIAL), decreasing = TRUE))[1]
    df <- df %>% mutate(SEG_SOCIAL = ifelse(is.na(SEG_SOCIAL), moda_seg, SEG_SOCIAL))
    cat("[5] SEG_SOCIAL: imputado con moda =", moda_seg, "\n")
  } else {
    df <- df %>% mutate(SEG_SOCIAL = ifelse(is.na(SEG_SOCIAL), "9", SEG_SOCIAL))
    cat("[5] SEG_SOCIAL: NAs → categoría '9'\n")
  }
  df$SEG_SOCIAL <- factor(df$SEG_SOCIAL)
  
  # 3.6 ANO
  df <- df %>%
    mutate(ANO = as.integer(ANO)) %>%
    filter(ANO >= 2005, ANO <= as.integer(format(Sys.Date(), "%Y")))
  cat("[6] ANO: filtrado rango válido.\n")
  
  # 3.7 MES
  df <- df %>%
    mutate(MES = as.integer(MES)) %>%
    filter(MES >= 1, MES <= 12)
  cat("[7] MES: filtrado rango válido.\n")
  
  # 3.8 EDAD_SIMPLE
  df <- df %>% mutate(EDAD_SIMPLE = as.integer(EDAD_SIMPLE))
  df <- df %>%
    mutate(EDAD_SIMPLE = ifelse(EDAD_SIMPLE %in% c(998, 999) | EDAD_SIMPLE > 120,
                                NA, EDAD_SIMPLE))
  q1  <- quantile(df$EDAD_SIMPLE, 0.25, na.rm = TRUE)
  q3  <- quantile(df$EDAD_SIMPLE, 0.75, na.rm = TRUE)
  iqr <- q3 - q1
  lim_inf <- max(0, q1 - 3 * iqr)
  lim_sup <- q3 + 3 * iqr
  df <- df %>%
    mutate(EDAD_SIMPLE = ifelse(!is.na(EDAD_SIMPLE) &
                                  (EDAD_SIMPLE < lim_inf | EDAD_SIMPLE > lim_sup),
                                NA, EDAD_SIMPLE))
  pct_edad <- round(sum(is.na(df$EDAD_SIMPLE)) / nrow(df) * 100, 2)
  if (pct_edad <= 3) {
    med_edad <- median(df$EDAD_SIMPLE, na.rm = TRUE)
    df <- df %>% mutate(EDAD_SIMPLE = ifelse(is.na(EDAD_SIMPLE), med_edad, EDAD_SIMPLE))
    cat("[8] EDAD_SIMPLE: imputado con mediana =", med_edad, "\n")
  } else {
    df <- df %>% filter(!is.na(EDAD_SIMPLE))
    cat("[8] EDAD_SIMPLE: eliminadas filas con NA.\n")
  }
  
  # 3.8b Perinatales coherentes
  df <- df %>%
    filter(!(NOM_667_OPS_GRUPO == "Ciertas afecciones originadas en el periodo perinatal" &
               EDAD_SIMPLE >= 2))
  cat("[8b] Perinatales con edad >= 2: eliminadas.\n")
  
  # 3.9 Reconstruir ETAREO_QUIN
  construir_etareo <- function(edad) {
    breaks <- c(0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,Inf)
    labels <- c("0-4","5-9","10-14","15-19","20-24","25-29",
                "30-34","35-39","40-44","45-49","50-54","55-59",
                "60-64","65-69","70-74","75-79","80+")
    cut(edad, breaks = breaks, labels = labels, right = FALSE, include.lowest = TRUE)
  }
  df <- df %>% mutate(ETAREO_QUIN = construir_etareo(EDAD_SIMPLE))
  cat("[9] ETAREO_QUIN: reconstruida desde EDAD_SIMPLE.\n")
  
  # 3.10 Target como factor
  df <- df %>% mutate(NOM_667_OPS_GRUPO = factor(trimws(NOM_667_OPS_GRUPO)))
  cat("[10] Target:", nlevels(df$NOM_667_OPS_GRUPO), "grupos.\n\n")
  
  cat("══════════════════════════════════════════════\n")
  cat("Registros iniciales :", n_inicial, "\n")
  cat("Registros finales   :", nrow(df), "\n")
  cat("Eliminados          :", n_inicial - nrow(df),
      "(", round((n_inicial - nrow(df)) / n_inicial * 100, 2), "%)\n")
  cat("NAs restantes       :", sum(is.na(df)), "\n")
  cat("══════════════════════════════════════════════\n\n")
  
  df
}

datos <- preparar_datos(datos_raw)

# ── 4. PREPARAR DATOS PARA EL MODELO ─────────────────────────
FEATURES <- c("SEXO","EST_CIVIL","NIVEL_EDU","SEG_SOCIAL",
              "ETAREO_QUIN","ANO","MES","EDAD_SIMPLE")

datos_modelo <- datos %>%
  select(all_of(FEATURES), NOM_667_OPS_GRUPO) %>%
  na.omit()

cat("[INFO] Registros disponibles para modelado:", nrow(datos_modelo), "\n")
cat("[INFO] Clases del target:", nlevels(datos_modelo$NOM_667_OPS_GRUPO), "\n\n")

# ── 5. PARTICIÓN TRAIN / TEST ────────────────────────────────
set.seed(123)
idx   <- createDataPartition(datos_modelo$NOM_667_OPS_GRUPO,
                             p = TRAIN_SPLIT, list = FALSE)
train <- datos_modelo[idx,  ]
test  <- datos_modelo[-idx, ]

cat("[INFO] Tamaño train:", nrow(train), "— test:", nrow(test), "\n\n")

# ── 6. ENTRENAR RANDOM FOREST ────────────────────────────────
cat("╔══════════════════════════════════════════════╗\n")
cat("║  Entrenando Random Forest...                 ║\n")
cat("╚══════════════════════════════════════════════╝\n")

t0_rf <- proc.time()

pesos     <- table(train$NOM_667_OPS_GRUPO)
pesos_inv <- 1 / sqrt(pesos)
pesos_inv <- pesos_inv / sum(pesos_inv)

mod_rf <- randomForest(
  NOM_667_OPS_GRUPO ~ .,
  data      = train,
  ntree     = RF_TREES,
  classwt   = pesos_inv,
  importance = TRUE
)

t1_rf  <- proc.time()
cm_rf  <- confusionMatrix(predict(mod_rf, test), test$NOM_667_OPS_GRUPO)

cat("\n[OK] Random Forest entrenado en",
    round((t1_rf - t0_rf)["elapsed"], 1), "seg.\n")
cat("     Accuracy RF :", round(cm_rf$overall["Accuracy"] * 100, 2), "%\n")
cat("     Kappa RF    :", round(cm_rf$overall["Kappa"], 4), "\n\n")

# ── 7. ENTRENAR ÁRBOL DE DECISIÓN ────────────────────────────
cat("╔══════════════════════════════════════════════╗\n")
cat("║  Entrenando Árbol de decisión (rpart)...     ║\n")
cat("╚══════════════════════════════════════════════╝\n")

t0_rpart <- proc.time()

mod_rpart <- caret::train(
  NOM_667_OPS_GRUPO ~ .,
  data      = train,
  method    = "rpart",
  trControl = trainControl(method = "cv", number = 5)
)

t1_rpart  <- proc.time()
cm_rpart  <- confusionMatrix(predict(mod_rpart, test), test$NOM_667_OPS_GRUPO)

cat("\n[OK] Árbol entrenado en",
    round((t1_rpart - t0_rpart)["elapsed"], 1), "seg.\n")
cat("     Accuracy Árbol:", round(cm_rpart$overall["Accuracy"] * 100, 2), "%\n")
cat("     Kappa Árbol   :", round(cm_rpart$overall["Kappa"], 4), "\n\n")

# ── 8. SELECCIONAR MEJOR MODELO ──────────────────────────────
acc_rf    <- cm_rf$overall["Accuracy"]
acc_rpart <- cm_rpart$overall["Accuracy"]

if (acc_rf >= acc_rpart) {
  mejor_modelo <- mod_rf
  cm_mejor     <- cm_rf
  cat("[INFO] Mejor modelo seleccionado: RANDOM FOREST\n")
} else {
  mejor_modelo <- mod_rpart
  cm_mejor     <- cm_rpart
  cat("[INFO] Mejor modelo seleccionado: ÁRBOL DE DECISIÓN\n")
}

cat("       RF:", round(acc_rf * 100, 2), "%",
    "| Árbol:", round(acc_rpart * 100, 2), "%\n\n")

# ── 9. GUARDAR MODELOS ───────────────────────────────────────
cat("╔══════════════════════════════════════════════╗\n")
cat("║  Guardando modelos...                        ║\n")
cat("╚══════════════════════════════════════════════╝\n")

if (!dir.exists(RUTA_MODELOS)) {
  dir.create(RUTA_MODELOS, recursive = TRUE)
  cat("[INFO] Carpeta creada:", RUTA_MODELOS, "\n")
}

archivo_salida <- file.path(RUTA_MODELOS, "modelos_entrenados.rds")

saveRDS(
  list(
    mejor_modelo   = mejor_modelo,
    cm_mejor       = cm_mejor,
    mod_rf         = mod_rf,
    mod_rpart      = mod_rpart,
    cm_rf          = cm_rf,
    cm_rpart       = cm_rpart,
    fecha_guardado = Sys.time()
  ),
  file     = archivo_salida,
  compress = "xz"       # compresión máxima; usa "gz" si quieres más velocidad
)

size_mb <- round(file.info(archivo_salida)$size / 1024^2, 2)

cat("\n[OK] Modelos guardados en:\n    ", archivo_salida, "\n")
cat("     Tamaño del archivo:", size_mb, "MB\n\n")

# ── 10. RESUMEN FINAL ────────────────────────────────────────
cat("╔══════════════════════════════════════════════╗\n")
cat("║  RESUMEN FINAL                               ║\n")
cat("╚══════════════════════════════════════════════╝\n")
cat(" Registros usados  :", nrow(datos_modelo), "\n")
cat(" Train / Test      :", nrow(train), "/", nrow(test), "\n")
cat(" Clases objetivo   :", nlevels(datos_modelo$NOM_667_OPS_GRUPO), "\n")
cat(" Accuracy RF       :", round(acc_rf    * 100, 2), "%\n")
cat(" Accuracy Árbol    :", round(acc_rpart * 100, 2), "%\n")
cat(" Mejor modelo      :", ifelse(acc_rf >= acc_rpart, "Random Forest", "Árbol"), "\n")
cat(" Archivo guardado  :", archivo_salida, "\n")
cat(" Fecha             :", format(Sys.time(), "%d/%m/%Y %H:%M:%S"), "\n\n")
cat("[LISTO] Reinicia la app de Shiny y los modelos se cargarán automáticamente.\n")

