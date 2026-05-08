library(dplyr)
library(tidyr)
library(randomForest)
library(caret)

# ── Directorio de trabajo ────────────────────────────────────
setwd("C:/Users/Usuario/Causas_de_Defuncion_Medellin/app")

# ── Cargar y limpiar datos (igual que global.R) ──────────────
source("global.R")

# ── Verificar datos ──────────────────────────────────────────
cat("Registros para modelo:", nrow(datos_modelo), "\n")
cat("Clases:", levels(datos_modelo$NOM_667_OPS_GRUPO), "\n")

# ── Partición ────────────────────────────────────────────────
set.seed(123)
idx   <- createDataPartition(datos_modelo$NOM_667_OPS_GRUPO, p = 0.75, list = FALSE)
train <- datos_modelo[idx, ]
test  <- datos_modelo[-idx, ]

# ── Entrenar Random Forest ───────────────────────────────────
cat("Entrenando Random Forest...\n")
pesos     <- table(train$NOM_667_OPS_GRUPO)
pesos_inv <- 1 / sqrt(pesos)
pesos_inv <- pesos_inv / sum(pesos_inv)

mod_rf <- randomForest(NOM_667_OPS_GRUPO ~ ., data = train,
                       ntree      = 100,
                       classwt    = pesos_inv,
                       importance = TRUE)
cm_rf  <- confusionMatrix(predict(mod_rf, test), test$NOM_667_OPS_GRUPO)
cat("RF Accuracy:", cm_rf$overall["Accuracy"], "\n")

# ── Entrenar Árbol de decisión ───────────────────────────────
cat("Entrenando Árbol de decisión...\n")
mod_rpart <- caret::train(NOM_667_OPS_GRUPO ~ ., data = train,
                          method    = "rpart",
                          trControl = trainControl(method = "cv", number = 5))
cm_rpart  <- confusionMatrix(predict(mod_rpart, test), test$NOM_667_OPS_GRUPO)
cat("Rpart Accuracy:", cm_rpart$overall["Accuracy"], "\n")

# ── Seleccionar mejor modelo ─────────────────────────────────
if (cm_rf$overall["Accuracy"] >= cm_rpart$overall["Accuracy"]) {
  mejor_modelo <- mod_rf
  cm_mejor     <- cm_rf
  cat("Mejor modelo: Random Forest\n")
} else {
  mejor_modelo <- mod_rpart
  cm_mejor     <- cm_rpart
  cat("Mejor modelo: Árbol de decisión\n")
}

# ── Guardar ──────────────────────────────────────────────────
ruta <- "C:/Users/Usuario/Causas_de_Defuncion_Medellin/app/models/modelos_entrenados.rds"

if (!dir.exists(dirname(ruta))) dir.create(dirname(ruta), recursive = TRUE)

saveRDS(list(
  mejor_modelo   = mejor_modelo,
  cm_mejor       = cm_mejor,
  mod_rf         = mod_rf,
  mod_rpart      = mod_rpart,
  cm_rf          = cm_rf,
  cm_rpart       = cm_rpart,
  test_datos     = test,           # necesario para métricas en la app
  fecha_guardado = Sys.time()
), file = ruta, compress = "gz")   # gz: balance entre velocidad y tamaño

cat("Guardado en:", ruta, "\n")

# ── Verificar que se puede leer ──────────────────────────────
m <- readRDS(ruta)
cat("Verificación OK — objetos:", paste(names(m), collapse = ", "), "\n")

