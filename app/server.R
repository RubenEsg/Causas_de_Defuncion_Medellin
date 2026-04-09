# ============================================================
#  server.R
#  Modelo de Clasificación - Causas de Defunción (Medellín)
# ============================================================

server <- function(input, output, session) {

  # ── Modelo reactivo ─────────────────────────────────────
  modelo_rv   <- reactiveVal(NULL)
  metricas_rv <- reactiveVal(NULL)
  test_rv     <- reactiveVal(NULL)

  observeEvent(input$btn_entrenar, {
    withProgress(message = "Entrenando modelo...", value = 0, {
      set.seed(123)
      idx   <- createDataPartition(datos_modelo$NOM_667_OPS_GRUPO,
                                   p = input$tr_split / 100, list = FALSE)
      train <- datos_modelo[idx, ]
      test  <- datos_modelo[-idx, ]
      test_rv(test)

      incProgress(0.3, detail = "Ajustando parámetros...")
      if (input$modelo_tipo == "rf") {
        mod <- randomForest(NOM_667_OPS_GRUPO ~ ., data = train,
                            ntree = input$rf_trees, importance = TRUE)
      } else {
        mod <- caret::train(NOM_667_OPS_GRUPO ~ ., data = train,
                            method = "rpart",
                            trControl = trainControl(method = "cv", number = 5))
      }

      incProgress(0.5, detail = "Evaluando...")
      preds <- predict(mod, test)
      cm    <- confusionMatrix(preds, test$NOM_667_OPS_GRUPO)

      modelo_rv(mod)
      metricas_rv(cm)
    })
    showNotification("✔ Modelo entrenado exitosamente", type = "message", duration = 4)
  })

  # ── VALUE BOXES EDA ──────────────────────────────────────
  output$vb_total  <- renderValueBox(
    valueBox(format(nrow(datos), big.mark = ","), "Registros totales",
             icon("database"), color = "blue"))
  output$vb_grupos <- renderValueBox(
    valueBox(nlevels(datos$NOM_667_OPS_GRUPO), "Grupos de causa",
             icon("tags"), color = "green"))
  output$vb_anio   <- renderValueBox(
    valueBox(paste(range(datos$ANO, na.rm=TRUE), collapse="–"), "Período",
             icon("calendar"), color = "orange"))
  output$vb_miss   <- renderValueBox({
    pct <- round(mean(is.na(datos)) * 100, 1)
    valueBox(paste0(pct, "%"), "Datos faltantes", icon("exclamation"), color = "red")
  })

  output$resumen_str <- renderPrint({
    cat("Dimensiones:", nrow(datos), "filas ×", ncol(datos), "columnas\n\n")
    print(summary(datos %>% select(EDAD_SIMPLE, ANO, MES, SEXO,
                                    EST_CIVIL, SEG_SOCIAL, NOM_667_OPS_GRUPO)))
  })

  # ── GRÁFICO EDA PRINCIPAL ─────────────────────────────────
  output$plot_eda <- renderPlotly({
    var <- input$eda_var
    df  <- datos %>% count(.data[[var]]) %>%
      mutate(pct = n / sum(n) * 100) %>%
      arrange(desc(n)) %>%
      head(12)

    if (input$eda_tipo == "bar") {
      p <- ggplot(df, aes(x = reorder(.data[[var]], n), y = n,
                          fill = .data[[var]],
                          text = if (input$eda_pct)
                            paste0(.data[[var]], "<br>n=", n, " (", round(pct,1), "%)")
                          else paste0(.data[[var]], "<br>n=", n))) +
        geom_col(show.legend = FALSE) +
        coord_flip() +
        scale_fill_manual(values = rep(PAL, length.out = nrow(df))) +
        labs(x = NULL, y = "Frecuencia") +
        theme_minimal(base_size = 12)
      ggplotly(p, tooltip = "text")
    } else {
      plot_ly(df, labels = ~.data[[var]], values = ~n, type = "pie",
              textinfo = if (input$eda_pct) "label+percent" else "label",
              marker = list(colors = PAL))
    }
  })

  output$plot_edad_grupo <- renderPlotly({
    df <- datos %>% filter(!is.na(EDAD_SIMPLE)) %>%
      group_by(NOM_667_OPS_GRUPO) %>%
      filter(n() >= 30) %>% ungroup() %>%
      mutate(G = substr(NOM_667_OPS_GRUPO, 1, 25))
    p <- ggplot(df, aes(x = G, y = EDAD_SIMPLE, fill = G)) +
      geom_boxplot(show.legend = FALSE, outlier.size = 0.5) +
      scale_fill_manual(values = rep(PAL, length.out = n_distinct(df$G))) +
      coord_flip() + labs(x = NULL, y = "Edad") +
      theme_minimal(base_size = 11)
    ggplotly(p)
  })

  output$plot_trend <- renderPlotly({
    df <- datos %>% count(ANO, NOM_667_OPS_GRUPO) %>%
      group_by(NOM_667_OPS_GRUPO) %>% filter(sum(n) >= 50) %>% ungroup() %>%
      mutate(G = substr(NOM_667_OPS_GRUPO, 1, 22))
    p <- ggplot(df, aes(x = ANO, y = n, color = G, group = G)) +
      geom_line(size = 1) + geom_point(size = 2) +
      scale_color_manual(values = PAL) +
      labs(x = "Año", y = "Defunciones", color = NULL) +
      theme_minimal(base_size = 11)
    ggplotly(p)
  })

  # ── TABLA NAVEGABLE ───────────────────────────────────────
  output$tabla_datos <- renderDT({
    df <- datos
    if (input$tab_grupo != "Todos")
      df <- df %>% filter(NOM_667_OPS_GRUPO == input$tab_grupo)
    if (input$tab_sexo != "Todos")
      df <- df %>% filter(SEXO == input$tab_sexo)
    df %>% select(ANO, MES, SEXO, EDAD_SIMPLE, EST_CIVIL,
                  NIVEL_EDU, SEG_SOCIAL, ETAREO_QUIN, NOM_667_OPS_GRUPO) %>%
      head(2000)
  }, options = list(pageLength = isolate(input$tab_filas),
                    scrollX = TRUE,
                    language = list(url = "//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json")),
     filter = "top", rownames = FALSE)

  # ── IMPORTANCIA DE VARIABLES ───────────────────────────────
  output$plot_importancia <- renderPlotly({
    mod <- modelo_rv()
    req(mod)
    if (input$modelo_tipo == "rf") {
      imp <- importance(mod)
      df  <- data.frame(Variable = rownames(imp),
                        Importancia = imp[, "MeanDecreaseGini"]) %>%
        arrange(desc(Importancia))
      p <- ggplot(df, aes(x = reorder(Variable, Importancia),
                          y = Importancia, fill = Importancia)) +
        geom_col(show.legend = FALSE) +
        coord_flip() +
        scale_fill_gradient(low = "#AED6F1", high = "#1A5276") +
        labs(x = NULL, y = "Mean Decrease Gini") +
        theme_minimal(base_size = 12)
      ggplotly(p)
    } else {
      df <- varImp(mod)$importance %>%
        tibble::rownames_to_column("Variable") %>%
        arrange(desc(Overall))
      p <- ggplot(df, aes(x = reorder(Variable, Overall), y = Overall)) +
        geom_col(fill = "#2ECC71") + coord_flip() +
        labs(x = NULL, y = "Importancia") + theme_minimal()
      ggplotly(p)
    }
  })

  output$train_log <- renderPrint({
    mod <- modelo_rv(); req(mod); print(mod)
  })

  # ── MÉTRICAS ──────────────────────────────────────────────
  output$vb_acc  <- renderValueBox({
    cm <- metricas_rv(); req(cm)
    valueBox(percent(cm$overall["Accuracy"], 0.1), "Exactitud (Accuracy)",
             icon("check-circle"), color = "green")
  })
  output$vb_kap  <- renderValueBox({
    cm <- metricas_rv(); req(cm)
    valueBox(round(cm$overall["Kappa"], 3), "Kappa",
             icon("balance-scale"), color = "blue")
  })
  output$vb_prec <- renderValueBox({
    cm <- metricas_rv(); req(cm)
    v  <- mean(cm$byClass[, "Precision"], na.rm = TRUE)
    valueBox(percent(v, 0.1), "Precisión media",
             icon("crosshairs"), color = "orange")
  })
  output$vb_rec  <- renderValueBox({
    cm <- metricas_rv(); req(cm)
    v  <- mean(cm$byClass[, "Recall"], na.rm = TRUE)
    valueBox(percent(v, 0.1), "Recall medio",
             icon("redo"), color = "red")
  })
  output$metricas_detalle <- renderPrint({
    cm <- metricas_rv(); req(cm); print(cm)
  })

  # ── MATRIZ DE CONFUSIÓN ───────────────────────────────────
  output$plot_confmat <- renderPlotly({
    cm  <- metricas_rv(); req(cm)
    mat <- as.data.frame(cm$table)
    colnames(mat) <- c("Real", "Predicho", "Freq")
    mat$Real     <- substr(mat$Real,     1, 28)
    mat$Predicho <- substr(mat$Predicho, 1, 28)
    p <- ggplot(mat, aes(x = Predicho, y = Real, fill = Freq,
                          text = paste0("Real: ", Real,
                                        "<br>Predicho: ", Predicho,
                                        "<br>N = ", Freq))) +
      geom_tile(color = "white") +
      scale_fill_gradient(low = "#EBF5FB", high = "#1A5276") +
      theme_minimal(base_size = 10) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      labs(x = "Predicho", y = "Real", fill = "N")
    ggplotly(p, tooltip = "text") %>% layout(height = 500)
  })

  # ── PREDICCIÓN ────────────────────────────────────────────
  pred_rv  <- reactiveVal(NULL)
  probs_rv <- reactiveVal(NULL)

  observeEvent(input$btn_predecir, {
    mod <- modelo_rv()
    if (is.null(mod)) {
      output$pred_alerta <- renderUI(
        tags$div(class = "alert alert-danger",
          "⚠ Primero debe entrenar el modelo en la pestaña Entrenamiento."))
      return()
    }

    nuevo <- data.frame(
      SEXO        = factor(input$p_sexo,   levels = levels(datos_modelo$SEXO)),
      EST_CIVIL   = factor(input$p_civil,  levels = levels(datos_modelo$EST_CIVIL)),
      NIVEL_EDU   = factor(input$p_edu,    levels = levels(datos_modelo$NIVEL_EDU)),
      SEG_SOCIAL  = factor(input$p_seg,    levels = levels(datos_modelo$SEG_SOCIAL)),
      ETAREO_QUIN = factor(input$p_etareo, levels = levels(datos_modelo$ETAREO_QUIN)),
      ANO         = as.integer(input$p_ano),
      MES         = as.integer(input$p_mes),
      EDAD_SIMPLE = as.integer(input$p_edad)
    )

    pred  <- predict(mod, nuevo)
    probs <- predict(mod, nuevo, type = "prob")

    pred_rv(as.character(pred))
    probs_rv(as.data.frame(probs))
    output$pred_alerta <- renderUI(
      tags$div(class = "alert alert-success", "✔ Predicción realizada correctamente."))

    updateTabItems(session, "tabs", "pr_res")
  })

  output$pred_resultado <- renderUI({
    p <- pred_rv(); req(p)
    tags$div(
      style = "text-align:center; padding:20px;",
      tags$h3("Grupo de causa predicho:"),
      tags$div(style = "background:#1A5276; color:white; border-radius:10px;
                        padding:15px 20px; font-size:18px; font-weight:bold; margin:10px 0;",
        p),
      tags$p(style = "color:#7F8C8D; font-size:13px;",
        "Resultado basado en las características sociodemográficas ingresadas.")
    )
  })

  output$pred_caso <- renderTable({
    req(pred_rv())
    data.frame(
      Variable = c("Sexo","Edad","Grupo etáreo","Estado civil",
                   "Nivel educativo","Seg. social","Año","Mes"),
      Valor    = c(input$p_sexo, input$p_edad, input$p_etareo,
                   input$p_civil, input$p_edu, input$p_seg,
                   input$p_ano, input$p_mes)
    )
  }, striped = TRUE, hover = TRUE, bordered = TRUE)

  output$plot_prob <- renderPlotly({
    probs <- probs_rv(); req(probs)
    df <- data.frame(
      Grupo = colnames(probs),
      Prob  = as.numeric(probs[1, ])
    ) %>% arrange(desc(Prob)) %>%
      mutate(Grupo = substr(Grupo, 1, 32))

    p <- ggplot(df, aes(x = reorder(Grupo, Prob), y = Prob * 100,
                         fill = Prob,
                         text = paste0(Grupo, "<br>", round(Prob * 100, 1), "%"))) +
      geom_col(show.legend = FALSE) +
      coord_flip() +
      scale_fill_gradient(low = "#AED6F1", high = "#E74C3C") +
      scale_y_continuous(labels = function(x) paste0(x, "%")) +
      labs(x = NULL, y = "Probabilidad (%)") +
      theme_minimal(base_size = 12)
    ggplotly(p, tooltip = "text")
  })

} # /server
