# ============================================================
#  server.R
#  Modelo de Clasificación - Causas de Defunción (Medellín)
# ============================================================

server <- function(input, output, session) {

  # ── Reactive values ──────────────────────────────────────
  modelo_rv    <- reactiveVal(NULL)   # mejor modelo (para predicción)
  metricas_rv  <- reactiveVal(NULL)
  test_rv      <- reactiveVal(NULL)
  mod_rf_rv    <- reactiveVal(NULL)
  mod_rpart_rv <- reactiveVal(NULL)
  cm_rf_rv     <- reactiveVal(NULL)
  cm_rpart_rv  <- reactiveVal(NULL)

  # ── Inicializar desde modelos guardados si existen ───────
  # Se ejecuta directo (sin observe) para compatibilidad con versiones antiguas de Shiny
  if (!is.null(MODELOS_GUARDADOS)) {
    modelo_rv(MODELOS_GUARDADOS$mejor_modelo)
    metricas_rv(MODELOS_GUARDADOS$cm_mejor)
    mod_rf_rv(MODELOS_GUARDADOS$mod_rf)
    mod_rpart_rv(MODELOS_GUARDADOS$mod_rpart)
    cm_rf_rv(MODELOS_GUARDADOS$cm_rf)
    cm_rpart_rv(MODELOS_GUARDADOS$cm_rpart)
  }

  # ── ENTRENAR MODELOS (según selección del usuario) ───────
  observeEvent(input$btn_entrenar, {

    sel <- input$sel_modelo   # "rf", "rpart" o "ambos"

    withProgress(message = "Entrenando...", value = 0, {

      set.seed(123)
      idx   <- createDataPartition(datos_modelo$NOM_667_OPS_GRUPO,
                                   p = input$tr_split / 100, list = FALSE)
      train <- datos_modelo[idx, ]
      test  <- datos_modelo[-idx, ]
      test_rv(test)

      # ── Random Forest ──────────────────────────────────
      if (sel %in% c("rf", "ambos")) {
        incProgress(0.1, detail = "Entrenando Random Forest...")
        pesos     <- table(train$NOM_667_OPS_GRUPO)
        pesos_inv <- 1 / sqrt(pesos)
        pesos_inv <- pesos_inv / sum(pesos_inv)

        mod_rf <- randomForest(NOM_667_OPS_GRUPO ~ ., data = train,
                               ntree      = max(input$rf_trees, 300),
                               classwt    = pesos_inv,
                               importance = TRUE)
        cm_rf  <- confusionMatrix(predict(mod_rf, test), test$NOM_667_OPS_GRUPO)
        mod_rf_rv(mod_rf)
        cm_rf_rv(cm_rf)
        incProgress(0.55, detail = "Random Forest listo.")
      }

      # ── Árbol de decisión ──────────────────────────────
      if (sel %in% c("rpart", "ambos")) {
        incProgress(if (sel == "ambos") 0.65 else 0.15,
                    detail = "Entrenando Árbol de decisión...")
        mod_rpart <- caret::train(NOM_667_OPS_GRUPO ~ ., data = train,
                                  method    = "rpart",
                                  trControl = trainControl(method = "cv", number = 5))
        cm_rpart  <- confusionMatrix(predict(mod_rpart, test), test$NOM_667_OPS_GRUPO)
        mod_rpart_rv(mod_rpart)
        cm_rpart_rv(cm_rpart)
        incProgress(0.95, detail = "Árbol listo.")
      }

      # ── Seleccionar mejor modelo para predicción ───────
      if (sel == "ambos") {
        if (cm_rf_rv()$overall["Accuracy"] >= cm_rpart_rv()$overall["Accuracy"]) {
          modelo_rv(mod_rf_rv()); metricas_rv(cm_rf_rv())
        } else {
          modelo_rv(mod_rpart_rv()); metricas_rv(cm_rpart_rv())
        }
      } else if (sel == "rf") {
        modelo_rv(mod_rf_rv()); metricas_rv(cm_rf_rv())
      } else {
        modelo_rv(mod_rpart_rv()); metricas_rv(cm_rpart_rv())
      }
    })

    showNotification(
      paste0("Entrenamiento completado — ",
             switch(sel, rf = "Random Forest", rpart = "Árbol de decisión", ambos = "ambos modelos")),
      type = "message", duration = 5)
  })

  # ── GUARDAR MODELOS ───────────────────────────────────────
  observeEvent(input$btn_guardar, {
    if (is.null(mod_rf_rv()) && is.null(mod_rpart_rv())) {
      showNotification("Primero entrene al menos un modelo.", type = "warning", duration = 4)
      return()
    }
    if (!dir.exists("models")) dir.create("models")
    saveRDS(list(
      mejor_modelo   = modelo_rv(),
      cm_mejor       = metricas_rv(),
      mod_rf         = mod_rf_rv(),
      mod_rpart      = mod_rpart_rv(),
      cm_rf          = cm_rf_rv(),
      cm_rpart       = cm_rpart_rv(),
      fecha_guardado = Sys.time()
    ), file = file.path("models", "modelos_entrenados.rds"))
    showNotification("Modelos guardados en models/modelos_entrenados.rds",
                     type = "message", duration = 5)
  })

  # ── ESTADO DEL GUARDADO ───────────────────────────────────
  output$ui_estado_guardado <- renderUI({
    if (!is.null(MODELOS_GUARDADOS)) {
      tags$p(style = "font-size:11px; color:#27ae60; text-align:center;",
        icon("check-circle"),
        paste0(" Modelos cargados (",
               format(MODELOS_GUARDADOS$fecha_guardado, "%d/%m/%Y %H:%M"), ")"))
    } else if (!is.null(modelo_rv())) {
      tags$p(style = "font-size:11px; color:#e67e22; text-align:center;",
        icon("exclamation-circle"), " Modelos entrenados — presione Guardar.")
    } else {
      tags$p(style = "font-size:11px; color:#999; text-align:center;",
        icon("clock-o"), " Sin modelos entrenados.")
    }
  })

  # ── ALERTA EN PESTAÑA MÉTRICAS ────────────────────────────
  output$met_entrenamiento_alerta <- renderUI({
    if (is.null(mod_rf_rv()) && is.null(mod_rpart_rv())) {
      tags$div(class = "alert alert-warning",
        icon("exclamation-triangle"), " Ningún modelo está cargado aún.",
        " Vaya a ", tags$strong("Modelado → Configuración"),
        " para entrenar, o guarde modelos para que se carguen automáticamente al iniciar.")
    }
  })

  # ── BANNERS DE ESTADO POR MODELO ─────────────────────────
  output$met_rf_estado <- renderUI({
    if (!is.null(mod_rf_rv())) {
      origen <- if (!is.null(MODELOS_GUARDADOS) && !is.null(MODELOS_GUARDADOS$mod_rf))
        "cargado desde archivo guardado" else "entrenado en esta sesión"
      tags$div(class = "alert alert-success",
        icon("check-circle"), " Random Forest disponible — ", origen, ".")
    } else {
      tags$div(class = "alert alert-info",
        icon("info-circle"),
        " Random Forest no ha sido entrenado.",
        " Vaya a ", tags$strong("Configuración"), " y seleccione RF o Ambos modelos.")
    }
  })

  output$met_rpart_estado <- renderUI({
    if (!is.null(mod_rpart_rv())) {
      origen <- if (!is.null(MODELOS_GUARDADOS) && !is.null(MODELOS_GUARDADOS$mod_rpart))
        "cargado desde archivo guardado" else "entrenado en esta sesión"
      tags$div(class = "alert alert-success",
        icon("check-circle"), " Árbol de decisión disponible — ", origen, ".")
    } else {
      tags$div(class = "alert alert-info",
        icon("info-circle"),
        " Árbol de decisión no ha sido entrenado.",
        " Vaya a ", tags$strong("Configuración"), " y seleccione Árbol o Ambos modelos.")
    }
  })

  # ── IMPORTANCIA DE VARIABLES (RF) — envuelta en uiOutput ─
  output$ui_importancia_wrap <- renderUI({
    if (!is.null(mod_rf_rv())) {
      plotlyOutput("plot_importancia", height = 320)
    } else {
      tags$div(class = "alert alert-info", style = "margin:20px;",
        icon("info-circle"),
        " Disponible después de entrenar Random Forest.")
    }
  })

  output$plot_importancia <- renderPlotly({
    mod <- mod_rf_rv(); req(mod)
    imp <- importance(mod)
    df  <- data.frame(Variable    = rownames(imp),
                      Importancia = imp[, "MeanDecreaseGini"]) %>%
      arrange(desc(Importancia))
    p <- ggplot(df, aes(x = reorder(Variable, Importancia),
                        y = Importancia, fill = Importancia)) +
      geom_col(show.legend = FALSE) + coord_flip() +
      scale_fill_gradient(low = "#AED6F1", high = "#1A5276") +
      labs(x = NULL, y = "Mean Decrease Gini") +
      theme_minimal(base_size = 12)
    ggplotly(p)
  })

  output$train_log <- renderPrint({
    mod <- mod_rf_rv()
    if (!is.null(mod)) { print(mod); return(invisible()) }
    mod2 <- mod_rpart_rv()
    if (!is.null(mod2)) { print(mod2); return(invisible()) }
    cat("Sin modelos entrenados aún.\n")
  })

  # ── GRAFICO VARIABLE OBJETIVO ─────────────────────────────
  output$plot_target_preview <- renderPlotly({
    df <- datos %>%
      count(NOM_667_OPS_GRUPO) %>%
      mutate(pct = round(n / sum(n) * 100, 1),
             G   = substr(NOM_667_OPS_GRUPO, 1, 30)) %>%
      arrange(desc(n))
    p <- ggplot(df, aes(x = reorder(G, n), y = n, fill = G,
                        text = paste0(G, "<br>n = ", format(n, big.mark=","),
                                      " (", pct, "%)"))) +
      geom_col(show.legend = FALSE) + coord_flip() +
      scale_fill_manual(values = rep(PAL, length.out = nrow(df))) +
      labs(x = NULL, y = "Numero de defunciones") +
      theme_minimal(base_size = 11)
    ggplotly(p, tooltip = "text")
  })

  # ── HELPER: datos filtrados ───────────────────────────────
  datos_filt <- reactive({
    df <- datos
    if (!is.null(input$filt_grupo) && input$filt_grupo != "Todos")
      df <- df %>% filter(NOM_667_OPS_GRUPO == input$filt_grupo)
    if (!is.null(input$filt_sexo) && input$filt_sexo != "Todos")
      df <- df %>% filter(SEXO == input$filt_sexo)
    if (!is.null(input$filt_ano))
      df <- df %>% filter(ANO >= input$filt_ano[1], ANO <= input$filt_ano[2])
    if (!is.null(input$filt_edad))
      df <- df %>% filter(EDAD_SIMPLE >= input$filt_edad[1], EDAD_SIMPLE <= input$filt_edad[2])
    df
  })

  # ── VALUE BOXES EDA ───────────────────────────────────────
  output$vb_total  <- renderValueBox(
    valueBox(format(nrow(datos), big.mark = ","), "Registros totales",
             icon("database"), color = "blue"))
  output$vb_grupos <- renderValueBox(
    valueBox(nlevels(datos$NOM_667_OPS_GRUPO), "Grupos de causa",
             icon("tags"), color = "green"))
  output$vb_anio   <- renderValueBox(
    valueBox(paste(range(datos$ANO, na.rm=TRUE), collapse = " - "), "Periodo",
             icon("calendar"), color = "orange"))
  output$vb_edad_med <- renderValueBox({
    med <- round(median(datos$EDAD_SIMPLE, na.rm = TRUE), 0)
    valueBox(paste0(med, " anos"), "Edad mediana", icon("user"), color = "purple")
  })
  output$vb_masculino <- renderValueBox({
    n <- sum(datos$SEXO == "1", na.rm = TRUE)
    pct <- round(n / nrow(datos) * 100, 1)
    valueBox(paste0(pct, "%"), "Masculino", icon("male"), color = "blue")
  })
  output$vb_femenino <- renderValueBox({
    n <- sum(datos$SEXO == "2", na.rm = TRUE)
    pct <- round(n / nrow(datos) * 100, 1)
    valueBox(paste0(pct, "%"), "Femenino", icon("female"), color = "fuchsia")
  })
  output$vb_top_causa <- renderValueBox({
    top <- datos %>% count(NOM_667_OPS_GRUPO) %>%
      arrange(desc(n)) %>% slice(1) %>% pull(NOM_667_OPS_GRUPO)
    valueBox(substr(top, 1, 28), "Causa mas frecuente", icon("heartbeat"), color = "red")
  })
  output$vb_miss <- renderValueBox({
    pct <- round(mean(is.na(datos)) * 100, 1)
    valueBox(paste0(pct, "%"), "Datos faltantes", icon("exclamation"), color = "yellow")
  })

  # ── EDA RESUMEN: graficos ─────────────────────────────────
  output$plot_top_causas <- renderPlotly({
    df <- datos %>% count(NOM_667_OPS_GRUPO) %>%
      mutate(pct = round(n / sum(n) * 100, 1),
             G   = substr(NOM_667_OPS_GRUPO, 1, 32)) %>%
      arrange(desc(n)) %>% head(10)
    p <- ggplot(df, aes(x = reorder(G, n), y = n, fill = G,
                        text = paste0(G, "<br>n = ", format(n, big.mark=","), " (", pct, "%)"))) +
      geom_col(show.legend = FALSE) + coord_flip() +
      scale_fill_manual(values = rep(PAL, length.out = nrow(df))) +
      labs(x = NULL, y = "Defunciones") + theme_minimal(base_size = 11)
    ggplotly(p, tooltip = "text")
  })

  output$plot_hist_edad <- renderPlotly({
    df <- datos %>% filter(!is.na(EDAD_SIMPLE))
    p <- ggplot(df, aes(x = EDAD_SIMPLE)) +
      geom_histogram(binwidth = 5, fill = "#6366f1", color = "white", alpha = .85) +
      labs(x = "Edad (años)", y = "Frecuencia") +
      theme_minimal(base_size = 11)
    ggplotly(p)
  })

  output$plot_missing <- renderPlotly({
    req(!is.null(INFO_NA_CRUDO))
    df <- INFO_NA_CRUDO %>% filter(Faltantes > 0)
    p <- ggplot(df, aes(x = reorder(Variable, Pct), y = Pct, fill = Pct,
                        text = paste0(Variable, "<br>", Faltantes, " faltantes (", Pct, "%)"))) +
      geom_col(show.legend = FALSE) + coord_flip() +
      scale_fill_gradient(low = "#FDE68A", high = "#EF4444") +
      labs(x = NULL, y = "% faltantes (dato crudo)") +
      theme_minimal(base_size = 11)
    ggplotly(p, tooltip = "text")
  })

  output$plot_sexo_pie <- renderPlotly({
    df <- datos %>%
      mutate(Sexo = case_when(SEXO == "1" ~ "Masculino",
                              SEXO == "2" ~ "Femenino",
                              TRUE ~ "Otro")) %>%
      count(Sexo)
    plot_ly(df, labels = ~Sexo, values = ~n, type = "pie",
            marker = list(colors = c("#6366f1", "#ec4899", "#94a3b8")),
            textinfo = "label+percent") %>%
      layout(showlegend = FALSE, margin = list(t=0,b=0,l=0,r=0))
  })

  output$plot_mes_bar <- renderPlotly({
    df <- datos %>% count(MES) %>%
      mutate(Mes = factor(MES, labels = c("Ene","Feb","Mar","Abr","May","Jun",
                                          "Jul","Ago","Sep","Oct","Nov","Dic")))
    p <- ggplot(df, aes(x = Mes, y = n, fill = n,
                        text = paste0(Mes, ": ", format(n, big.mark=",")))) +
      geom_col(show.legend = FALSE) +
      scale_fill_gradient(low = "#BFDBFE", high = "#1D4ED8") +
      labs(x = NULL, y = NULL) + theme_minimal(base_size = 10)
    ggplotly(p, tooltip = "text")
  })

  # ── EDA VIZ ───────────────────────────────────────────────
  output$plot_eda <- renderPlotly({
    df <- datos_filt()
    var <- input$eda_var
    tipo <- input$eda_tipo

    df2 <- df %>%
      mutate(X = as.character(.data[[var]])) %>%
      count(X) %>%
      mutate(pct = round(n / sum(n) * 100, 1)) %>%
      arrange(desc(n))

    if (tipo == "pie") {
      plot_ly(df2, labels = ~X, values = ~n, type = "pie",
              textinfo = "label+percent") %>%
        layout(showlegend = TRUE)
    } else {
      y_val <- if (input$eda_pct) "pct" else "n"
      y_lab <- if (input$eda_pct) "%" else "N"
      p <- ggplot(df2 %>% head(20),
                  aes(x = reorder(X, .data[[y_val]]),
                      y = .data[[y_val]], fill = .data[[y_val]],
                      text = paste0(X, "<br>n=", n, " (", pct, "%)"))) +
        geom_col(show.legend = FALSE) + coord_flip() +
        scale_fill_gradient(low = "#C7D2FE", high = "#4F46E5") +
        labs(x = NULL, y = y_lab) + theme_minimal(base_size = 11)
      ggplotly(p, tooltip = "text")
    }
  })

  output$plot_edad_grupo <- renderPlotly({
    df <- datos_filt() %>%
      filter(!is.na(EDAD_SIMPLE)) %>%
      mutate(G = substr(NOM_667_OPS_GRUPO, 1, 28))
    p <- ggplot(df, aes(x = reorder(G, EDAD_SIMPLE, median), y = EDAD_SIMPLE, fill = G)) +
      geom_boxplot(show.legend = FALSE, outlier.size = .5) +
      coord_flip() +
      scale_fill_manual(values = rep(PAL, length.out = nlevels(factor(df$G)))) +
      labs(x = NULL, y = "Edad (años)") + theme_minimal(base_size = 10)
    ggplotly(p)
  })

  output$plot_causa_sexo <- renderPlotly({
    df <- datos_filt() %>%
      mutate(Sexo = ifelse(SEXO == "1", "Masculino", "Femenino"),
             G    = substr(NOM_667_OPS_GRUPO, 1, 28)) %>%
      count(G, Sexo) %>%
      group_by(G) %>%
      mutate(pct = round(n / sum(n) * 100, 1)) %>%
      ungroup()
    p <- ggplot(df, aes(x = reorder(G, n), y = pct, fill = Sexo,
                        text = paste0(G, "<br>", Sexo, ": ", pct, "%"))) +
      geom_col(position = "fill") + coord_flip() +
      scale_fill_manual(values = c("Masculino" = "#6366f1", "Femenino" = "#ec4899")) +
      scale_y_continuous(labels = scales::percent) +
      labs(x = NULL, y = "Proporción", fill = NULL) + theme_minimal(base_size = 10)
    ggplotly(p, tooltip = "text")
  })

  output$plot_trend <- renderPlotly({
    df <- datos_filt() %>%
      count(ANO, NOM_667_OPS_GRUPO) %>%
      mutate(G = substr(NOM_667_OPS_GRUPO, 1, 25))
    p <- ggplot(df, aes(x = ANO, y = n, color = G, group = G,
                        text = paste0(G, "<br>Año: ", ANO, "<br>n=", n))) +
      geom_line(size = .8) + geom_point(size = 1.5) +
      scale_color_manual(values = rep(PAL, length.out = nlevels(factor(df$G)))) +
      labs(x = "Año", y = "Defunciones", color = NULL) +
      theme_minimal(base_size = 11) +
      theme(legend.position = "bottom", legend.text = element_text(size = 8))
    ggplotly(p, tooltip = "text")
  })

  output$plot_heatmap_mes_ano <- renderPlotly({
    df <- datos_filt() %>% count(ANO, MES)
    p <- ggplot(df, aes(x = factor(MES), y = factor(ANO), fill = n,
                        text = paste0("Año:", ANO, " Mes:", MES, " N=", n))) +
      geom_tile(color = "white") +
      scale_fill_gradient(low = "#EFF6FF", high = "#1D4ED8") +
      labs(x = "Mes", y = "Año", fill = "N") +
      theme_minimal(base_size = 10)
    ggplotly(p, tooltip = "text")
  })

  output$plot_edu_causa <- renderPlotly({
    df <- datos_filt() %>%
      mutate(G = substr(NOM_667_OPS_GRUPO, 1, 25)) %>%
      count(NIVEL_EDU, G) %>%
      group_by(NIVEL_EDU) %>%
      mutate(pct = round(n / sum(n) * 100, 1)) %>%
      ungroup()
    p <- ggplot(df, aes(x = factor(NIVEL_EDU), y = pct, fill = G,
                        text = paste0(G, "<br>Edu: ", NIVEL_EDU, "<br>", pct, "%"))) +
      geom_col(position = "stack") +
      scale_fill_manual(values = rep(PAL, length.out = nlevels(factor(df$G)))) +
      labs(x = "Nivel educativo", y = "%", fill = NULL) +
      theme_minimal(base_size = 10) +
      theme(legend.position = "bottom", legend.text = element_text(size = 7))
    ggplotly(p, tooltip = "text")
  })

  output$plot_seg_causa <- renderPlotly({
    df <- datos_filt() %>%
      mutate(G = substr(NOM_667_OPS_GRUPO, 1, 25)) %>%
      count(SEG_SOCIAL, G) %>%
      group_by(SEG_SOCIAL) %>%
      mutate(pct = round(n / sum(n) * 100, 1)) %>%
      ungroup()
    p <- ggplot(df, aes(x = factor(SEG_SOCIAL), y = pct, fill = G,
                        text = paste0(G, "<br>Seg:", SEG_SOCIAL, "<br>", pct, "%"))) +
      geom_col(position = "stack") +
      scale_fill_manual(values = rep(PAL, length.out = nlevels(factor(df$G)))) +
      labs(x = "Régimen de salud", y = "%", fill = NULL) +
      theme_minimal(base_size = 10) +
      theme(legend.position = "bottom", legend.text = element_text(size = 7))
    ggplotly(p, tooltip = "text")
  })

  # ── TABLA DATOS ───────────────────────────────────────────
  datos_tabla <- reactive({
    df <- datos
    if (!is.null(input$tab_grupo) && input$tab_grupo != "Todos")
      df <- df %>% filter(NOM_667_OPS_GRUPO == input$tab_grupo)
    if (!is.null(input$tab_sexo) && input$tab_sexo != "Todos")
      df <- df %>% filter(SEXO == input$tab_sexo)
    if (!is.null(input$tab_ano))
      df <- df %>% filter(ANO >= input$tab_ano[1], ANO <= input$tab_ano[2])
    if (!is.null(input$tab_edad))
      df <- df %>% filter(EDAD_SIMPLE >= input$tab_edad[1], EDAD_SIMPLE <= input$tab_edad[2])
    df
  })

  observeEvent(input$tab_reset, {
    updateSelectInput(session, "tab_grupo", selected = "Todos")
    updateSelectInput(session, "tab_sexo",  selected = "Todos")
    updateSliderInput(session, "tab_ano",   value = c(2012, 2023))
    updateSliderInput(session, "tab_edad",  value = c(0, 99))
  })

  output$tab_conteo <- renderUI({
    n <- nrow(datos_tabla())
    tags$div(
      style = "background:#eaf4fb; border-radius:8px; padding:14px; text-align:center;",
      tags$h4(style = "color:#1a5276; margin:0;", format(n, big.mark=",")),
      tags$p(style = "color:#555; margin:0; font-size:12px;", "registros filtrados"),
      tags$hr(),
      tags$p(style = "font-size:11px; color:#888; margin:0;",
             round(n / nrow(datos) * 100, 1), "% del total")
    )
  })

  output$tabla_datos <- renderDT({
    datos_tabla()
  }, options = list(
    pageLength = 15,
    scrollX    = TRUE,
    language   = list(url = "//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json")
  ), filter = "top", rownames = FALSE)

  # ── MÉTRICAS RANDOM FOREST ────────────────────────────────
  output$vb_acc_rf <- renderValueBox({
    cm <- cm_rf_rv(); req(cm)
    valueBox(percent(cm$overall["Accuracy"], 0.1), "Accuracy RF",
             icon("check-circle"), color = "green")
  })
  output$vb_kap_rf <- renderValueBox({
    cm <- cm_rf_rv(); req(cm)
    valueBox(round(cm$overall["Kappa"], 3), "Kappa RF",
             icon("balance-scale"), color = "blue")
  })
  output$vb_prec_rf <- renderValueBox({
    cm <- cm_rf_rv(); req(cm)
    valueBox(percent(mean(cm$byClass[, "Precision"], na.rm = TRUE), 0.1), "Precision RF",
             icon("crosshairs"), color = "orange")
  })
  output$vb_rec_rf <- renderValueBox({
    cm <- cm_rf_rv(); req(cm)
    valueBox(percent(mean(cm$byClass[, "Recall"], na.rm = TRUE), 0.1), "Recall RF",
             icon("redo"), color = "red")
  })
  output$metricas_detalle_rf <- renderPrint({
    cm <- cm_rf_rv(); req(cm); print(cm)
  })

  # ── MÉTRICAS ÁRBOL DE DECISIÓN ────────────────────────────
  output$vb_acc_rpart <- renderValueBox({
    cm <- cm_rpart_rv(); req(cm)
    valueBox(percent(cm$overall["Accuracy"], 0.1), "Accuracy Arbol",
             icon("check-circle"), color = "green")
  })
  output$vb_kap_rpart <- renderValueBox({
    cm <- cm_rpart_rv(); req(cm)
    valueBox(round(cm$overall["Kappa"], 3), "Kappa Arbol",
             icon("balance-scale"), color = "blue")
  })
  output$vb_prec_rpart <- renderValueBox({
    cm <- cm_rpart_rv(); req(cm)
    valueBox(percent(mean(cm$byClass[, "Precision"], na.rm = TRUE), 0.1), "Precision Arbol",
             icon("crosshairs"), color = "orange")
  })
  output$vb_rec_rpart <- renderValueBox({
    cm <- cm_rpart_rv(); req(cm)
    valueBox(percent(mean(cm$byClass[, "Recall"], na.rm = TRUE), 0.1), "Recall Arbol",
             icon("redo"), color = "red")
  })
  output$metricas_detalle_rpart <- renderPrint({
    cm <- cm_rpart_rv(); req(cm); print(cm)
  })

  # ── MATRICES DE CONFUSIÓN ─────────────────────────────────
  conf_plot <- function(cm) {
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
    ggplotly(p, tooltip = "text") %>% layout(height = 420)
  }

  output$plot_confmat_rf    <- renderPlotly({ cm <- cm_rf_rv();    req(cm); conf_plot(cm) })
  output$plot_confmat_rpart <- renderPlotly({ cm <- cm_rpart_rv(); req(cm); conf_plot(cm) })

  # ── PREDICCIÓN (tab Predicción clásica) ───────────────────
  pred_rv  <- reactiveVal(NULL)
  probs_rv <- reactiveVal(NULL)

  observeEvent(input$btn_predecir, {
    mod <- modelo_rv()
    if (is.null(mod)) {
      output$pred_alerta <- renderUI(
        tags$div(class = "alert alert-danger",
                 "Primero debe entrenar el modelo en la sección Entrenamiento."))
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
      tags$div(class = "alert alert-success", "Prediccion realizada correctamente."))
    updateTabItems(session, "tabs", "pr_res")
  })

  output$pred_resultado <- renderUI({
    p <- pred_rv(); req(p)
    tags$div(
      style = "text-align:center; padding:20px;",
      tags$h3("Grupo de causa predicho:"),
      tags$div(style = "background:#1A5276; color:white; border-radius:10px;
                        padding:15px 20px; font-size:18px; font-weight:bold; margin:10px 0;", p),
      tags$p(style = "color:#7F8C8D; font-size:13px;",
             "Resultado basado en las caracteristicas sociodemograficas ingresadas.")
    )
  })

  output$pred_caso <- renderTable({
    req(pred_rv())
    data.frame(
      Variable = c("Sexo","Edad","Grupo etareo","Estado civil",
                   "Nivel educativo","Seg. social","Ano","Mes"),
      Valor    = c(input$p_sexo, input$p_edad, input$p_etareo,
                   input$p_civil, input$p_edu, input$p_seg,
                   input$p_ano, input$p_mes)
    )
  }, striped = TRUE, hover = TRUE, bordered = TRUE)

  output$plot_prob <- renderPlotly({
    probs <- probs_rv(); req(probs)
    df <- data.frame(Grupo = colnames(probs),
                     Prob  = as.numeric(probs[1, ])) %>%
      arrange(desc(Prob)) %>%
      mutate(Grupo = substr(Grupo, 1, 32))
    p <- ggplot(df, aes(x = reorder(Grupo, Prob), y = Prob * 100,
                        fill = Prob,
                        text = paste0(Grupo, "<br>", round(Prob * 100, 1), "%"))) +
      geom_col(show.legend = FALSE) + coord_flip() +
      scale_fill_gradient(low = "#AED6F1", high = "#E74C3C") +
      scale_y_continuous(labels = function(x) paste0(x, "%")) +
      labs(x = NULL, y = "Probabilidad (%)") +
      theme_minimal(base_size = 12)
    ggplotly(p, tooltip = "text")
  })

  # ── MÉTRICAS CONSOLIDADAS (met_full) ─────────────────────
  output$met_alerta <- renderUI({
    if (is.null(modelo_rv()))
      tags$div(class = "alert alert-warning",
        icon("exclamation-triangle"),
        " No hay modelos cargados. Vaya a Modelado → Configuración para entrenar.")
  })

  output$met_modelo_info <- renderUI({
    mod <- modelo_rv(); req(mod)
    tipo <- if (inherits(mod, "randomForest")) "Random Forest" else "Árbol de decisión"
    cm   <- metricas_rv()
    acc  <- if (!is.null(cm)) paste0(round(cm$overall["Accuracy"] * 100, 1), "%") else "—"
    tags$div(
      style = "background:linear-gradient(135deg,#0f172a,#1e293b); border-radius:12px;
               padding:20px 24px; margin-bottom:20px; color:#f1f5f9;
               display:flex; align-items:center; gap:20px;",
      icon("robot", style = "font-size:28px; color:#818cf8;"),
      tags$div(
        tags$div(style = "font-size:13px; color:#64748b; text-transform:uppercase; letter-spacing:.06em;",
                 "Mejor modelo seleccionado"),
        tags$div(style = "font-family:'Sora',sans-serif; font-size:20px; font-weight:800; color:#f1f5f9;",
                 tipo),
        tags$div(style = "font-size:13px; color:#94a3b8;",
                 paste0("Accuracy: ", acc))
      )
    )
  })

  output$met_vb_acc  <- renderValueBox({
    cm <- metricas_rv(); req(cm)
    valueBox(percent(cm$overall["Accuracy"],  0.1), "Accuracy",  icon("check"), color = "green")
  })
  output$met_vb_kap  <- renderValueBox({
    cm <- metricas_rv(); req(cm)
    valueBox(round(cm$overall["Kappa"], 3), "Kappa", icon("balance-scale"), color = "blue")
  })
  output$met_vb_prec <- renderValueBox({
    cm <- metricas_rv(); req(cm)
    valueBox(percent(mean(cm$byClass[,"Precision"], na.rm=TRUE), 0.1), "Precision",
             icon("crosshairs"), color = "orange")
  })
  output$met_vb_rec  <- renderValueBox({
    cm <- metricas_rv(); req(cm)
    valueBox(percent(mean(cm$byClass[,"Recall"], na.rm=TRUE), 0.1), "Recall",
             icon("redo"), color = "red")
  })
  output$met_vb_f1   <- renderValueBox({
    cm <- metricas_rv(); req(cm)
    prec <- cm$byClass[,"Precision"]; rec <- cm$byClass[,"Recall"]
    f1   <- mean(2 * prec * rec / (prec + rec), na.rm = TRUE)
    valueBox(percent(f1, 0.1), "F1-Score", icon("star"), color = "purple")
  })
  output$met_vb_bacc <- renderValueBox({
    cm <- metricas_rv(); req(cm)
    bacc <- mean(cm$byClass[,"Balanced Accuracy"], na.rm = TRUE)
    valueBox(percent(bacc, 0.1), "Balanced Acc.", icon("arrows-alt"), color = "teal")
  })

  output$met_tabla_clase <- DT::renderDT({
    cm <- metricas_rv(); req(cm)
    df <- as.data.frame(round(cm$byClass, 3))
    df$Clase <- rownames(df)
    df <- df %>% select(Clase, everything()) %>%
      arrange(desc(Balanced.Accuracy))
    DT::datatable(df, options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
  })

  output$met_confmat <- renderPlotly({
    cm <- metricas_rv(); req(cm); conf_plot(cm)
  })

  output$met_importancia <- renderPlotly({
    mod <- mod_rf_rv(); req(mod)
    imp <- importance(mod)
    df  <- data.frame(Variable    = rownames(imp),
                      Importancia = imp[, "MeanDecreaseGini"]) %>%
      arrange(desc(Importancia))
    p <- ggplot(df, aes(x = reorder(Variable, Importancia),
                        y = Importancia, fill = Importancia)) +
      geom_col(show.legend = FALSE) + coord_flip() +
      scale_fill_gradient(low = "#AED6F1", high = "#1A5276") +
      labs(x = NULL, y = "Mean Decrease Gini") + theme_minimal(base_size = 12)
    ggplotly(p)
  })

  # ── PREDICCIÓN MEJOR MODELO ───────────────────────────────
  pm_pred_rv  <- reactiveVal(NULL)
  pm_probs_rv <- reactiveVal(NULL)

  output$pm_modelo_info <- renderUI({
    mod <- modelo_rv()
    if (is.null(mod)) {
      tags$div(class = "alert alert-warning",
        icon("exclamation-triangle"), " Sin modelo cargado aún.")
    } else {
      tipo <- if (inherits(mod, "randomForest")) "Random Forest" else "Árbol de decisión"
      cm   <- metricas_rv()
      acc  <- if (!is.null(cm)) paste0(round(cm$overall["Accuracy"] * 100, 1), "%") else "—"
      tags$div(
        style = "background:linear-gradient(135deg,#0f172a,#1e293b); border-radius:10px;
                 padding:16px 20px; color:#f1f5f9; display:flex; align-items:center; gap:14px;",
        icon("robot", style = "font-size:22px; color:#818cf8;"),
        tags$div(
          tags$div(style = "font-size:11px; color:#64748b; text-transform:uppercase;",
                   "Mejor modelo activo"),
          tags$div(style = "font-weight:800; font-size:15px;", tipo),
          tags$div(style = "font-size:12px; color:#94a3b8;", paste0("Accuracy: ", acc))
        )
      )
    }
  })

  observeEvent(input$btn_predecir2, {
    mod <- modelo_rv()
    if (is.null(mod)) {
      output$pm_alerta <- renderUI(
        tags$div(class = "alert alert-danger",
                 "Primero entrene o cargue un modelo."))
      return()
    }
    nuevo <- data.frame(
      SEXO        = factor(input$pm_sexo,   levels = levels(datos_modelo$SEXO)),
      EST_CIVIL   = factor(input$pm_civil,  levels = levels(datos_modelo$EST_CIVIL)),
      NIVEL_EDU   = factor(input$pm_edu,    levels = levels(datos_modelo$NIVEL_EDU)),
      SEG_SOCIAL  = factor(input$pm_seg,    levels = levels(datos_modelo$SEG_SOCIAL)),
      ETAREO_QUIN = factor(input$pm_etareo, levels = levels(datos_modelo$ETAREO_QUIN)),
      ANO         = as.integer(input$pm_ano),
      MES         = as.integer(input$pm_mes),
      EDAD_SIMPLE = as.integer(input$pm_edad)
    )
    pred  <- predict(mod, nuevo)
    probs <- predict(mod, nuevo, type = "prob")
    pm_pred_rv(as.character(pred))
    pm_probs_rv(as.data.frame(probs))
    output$pm_alerta <- renderUI(
      tags$div(class = "alert alert-success", "Predicción realizada correctamente."))
  })

  output$pm_resultado <- renderUI({
    p <- pm_pred_rv(); req(p)
    tags$div(class = "pred-result-card",
      tags$div(class = "pred-label", "Grupo de causa predicho"),
      tags$div(class = "pred-value", p)
    )
  })

  output$pm_prob_plot <- renderPlotly({
    probs <- pm_probs_rv(); req(probs)
    df <- data.frame(Grupo = colnames(probs),
                     Prob  = as.numeric(probs[1, ])) %>%
      arrange(desc(Prob)) %>% head(10) %>%
      mutate(Grupo = substr(Grupo, 1, 32))
    p <- ggplot(df, aes(x = reorder(Grupo, Prob), y = Prob * 100,
                        fill = Prob,
                        text = paste0(Grupo, "<br>", round(Prob * 100, 1), "%"))) +
      geom_col(show.legend = FALSE) + coord_flip() +
      scale_fill_gradient(low = "#AED6F1", high = "#E74C3C") +
      scale_y_continuous(labels = function(x) paste0(x, "%")) +
      labs(x = NULL, y = "%") + theme_minimal(base_size = 11)
    ggplotly(p, tooltip = "text")
  })

  output$pm_top5 <- DT::renderDT({
    probs <- pm_probs_rv(); req(probs)
    df <- data.frame(
      Grupo        = colnames(probs),
      Probabilidad = paste0(round(as.numeric(probs[1, ]) * 100, 2), "%")
    ) %>% arrange(desc(as.numeric(sub("%", "", Probabilidad)))) %>% head(5)
    DT::datatable(df, options = list(dom = "t", pageLength = 5), rownames = FALSE)
  })

} # /server
