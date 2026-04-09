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
  
  # ── GRÁFICO VARIABLE OBJETIVO (pestaña Problema) ─────────
  output$plot_target_preview <- renderPlotly({
    df <- datos %>%
      count(NOM_667_OPS_GRUPO) %>%
      mutate(pct = round(n / sum(n) * 100, 1),
             G   = substr(NOM_667_OPS_GRUPO, 1, 30)) %>%
      arrange(desc(n))
    
    p <- ggplot(df, aes(x = reorder(G, n), y = n, fill = G,
                        text = paste0(G, "<br>n = ", format(n, big.mark=","),
                                      " (", pct, "%)"))) +
      geom_col(show.legend = FALSE) +
      coord_flip() +
      scale_fill_manual(values = rep(PAL, length.out = nrow(df))) +
      labs(x = NULL, y = "Número de defunciones") +
      theme_minimal(base_size = 11)
    ggplotly(p, tooltip = "text")
  })
  
  # ── HELPER: datos filtrados (eda_viz) ────────────────────
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
  
  # ── VALUE BOXES EDA ──────────────────────────────────────
  output$vb_total  <- renderValueBox(
    valueBox(format(nrow(datos), big.mark = ","), "Registros totales",
             icon("database"), color = "blue"))
  output$vb_grupos <- renderValueBox(
    valueBox(nlevels(datos$NOM_667_OPS_GRUPO), "Grupos de causa",
             icon("tags"), color = "green"))
  output$vb_anio   <- renderValueBox(
    valueBox(paste(range(datos$ANO, na.rm=TRUE), collapse = " – "), "Período",
             icon("calendar"), color = "orange"))
  output$vb_edad_med <- renderValueBox({
    med <- round(median(datos$EDAD_SIMPLE, na.rm = TRUE), 0)
    valueBox(paste0(med, " años"), "Edad mediana", icon("user"), color = "purple")
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
    valueBox(substr(top, 1, 28), "Causa más frecuente", icon("heartbeat"), color = "red")
  })
  output$vb_miss <- renderValueBox({
    pct <- round(mean(is.na(datos)) * 100, 1)
    valueBox(paste0(pct, "%"), "Datos faltantes", icon("exclamation"), color = "yellow")
  })
  
  # ── EDA RESUMEN: gráficos ────────────────────────────────
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
      geom_histogram(binwidth = 5, fill = "#3498DB", color = "white", alpha = 0.85) +
      labs(x = "Edad (años)", y = "Frecuencia") +
      theme_minimal(base_size = 11)
    ggplotly(p)
  })
  
  output$plot_missing <- renderPlotly({
    df <- if (exists("INFO_NA_CRUDO") && !is.null(INFO_NA_CRUDO)) {
      INFO_NA_CRUDO
    } else {
      datos %>%
        summarise(across(everything(), ~ sum(is.na(.)))) %>%
        tidyr::pivot_longer(everything(), names_to = "Variable", values_to = "Faltantes") %>%
        mutate(Pct = round(Faltantes / nrow(datos) * 100, 1)) %>%
        arrange(desc(Faltantes))
    }
    
    df_plot <- df %>% filter(Faltantes > 0) %>% arrange(Pct)
    
    if (nrow(df_plot) == 0) {
      return(
        plotly_empty(type = "bar") %>%
          layout(title = list(
            text = "No se detectaron valores faltantes en el dato crudo",
            font = list(size = 13, color = "#7f8c8d")
          ))
      )
    }
    
    # Colores interpolados de azul a rojo según porcentaje
    pct_norm  <- (df_plot$Pct - min(df_plot$Pct)) /
      max(1, max(df_plot$Pct) - min(df_plot$Pct))
    r <- round(174 + (231 - 174) * pct_norm)
    g <- round(214 + ( 76 - 214) * pct_norm)
    b <- round(241 + ( 60 - 241) * pct_norm)
    colores <- paste0("rgb(", r, ",", g, ",", b, ")")
    
    plot_ly(
      data        = df_plot,
      x           = ~Pct,
      y           = ~reorder(Variable, Pct),
      type        = "bar",
      orientation = "h",
      marker      = list(color = colores),
      text        = ~paste0(Pct, "% — ", format(Faltantes, big.mark = ",")),
      textposition = "outside",
      hovertemplate = paste0(
        "<b>%{y}</b><br>",
        "Faltantes: %{text}<extra></extra>"
      )
    ) %>%
      layout(
        xaxis  = list(title = "% faltantes / sin información (dato crudo)",
                      ticksuffix = "%", range = c(0, max(df_plot$Pct) * 1.25)),
        yaxis  = list(title = "", tickfont = list(size = 12)),
        margin = list(l = 20, r = 80, t = 10, b = 40),
        font   = list(size = 12)
      )
  })
  
  output$plot_sexo_pie <- renderPlotly({
    df <- datos %>%
      mutate(Sexo = ifelse(SEXO == "1", "Masculino", "Femenino")) %>%
      count(Sexo)
    plot_ly(df, labels = ~Sexo, values = ~n, type = "pie",
            textinfo = "label+percent",
            marker = list(colors = c("#3498DB","#E74C3C")))
  })
  
  output$plot_mes_bar <- renderPlotly({
    meses <- c("Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic")
    df <- datos %>% count(MES) %>%
      mutate(Mes = factor(meses[MES], levels = meses))
    p <- ggplot(df, aes(x = Mes, y = n, fill = n,
                        text = paste0(Mes, ": ", format(n, big.mark=",")))) +
      geom_col(show.legend = FALSE) +
      scale_fill_gradient(low = "#AED6F1", high = "#1A5276") +
      labs(x = NULL, y = NULL) + theme_minimal(base_size = 10) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    ggplotly(p, tooltip = "text")
  })
  
  # ── EDA VIZ: gráficos con filtros ────────────────────────
  output$plot_eda <- renderPlotly({
    df  <- datos_filt()
    var <- input$eda_var
    
    # Convertir a carácter para contar sin problemas de factor con niveles vacíos
    dfc <- df %>%
      mutate(VAR_PLOT = as.character(.data[[var]])) %>%
      count(VAR_PLOT) %>%
      mutate(pct = n / sum(n) * 100) %>%
      arrange(desc(n)) %>%
      head(12) %>%
      mutate(VAR_PLOT = factor(VAR_PLOT, levels = rev(VAR_PLOT)))  # orden para coord_flip
    
    if (nrow(dfc) == 0) {
      return(plotly_empty() %>% layout(title = "Sin datos para los filtros seleccionados"))
    }
    
    texto_hover <- if (input$eda_pct)
      paste0(dfc$VAR_PLOT, "<br>n = ", format(dfc$n, big.mark = ","),
             " (", round(dfc$pct, 1), "%)")
    else
      paste0(dfc$VAR_PLOT, "<br>n = ", format(dfc$n, big.mark = ","))
    
    if (input$eda_tipo == "bar") {
      p <- ggplot(dfc, aes(x = VAR_PLOT, y = n, fill = VAR_PLOT, text = texto_hover)) +
        geom_col(show.legend = FALSE) +
        coord_flip() +
        scale_fill_manual(values = rep(PAL, length.out = nrow(dfc))) +
        labs(x = NULL, y = "Frecuencia") +
        theme_minimal(base_size = 12) +
        theme(axis.text.y = element_text(size = 11))
      ggplotly(p, tooltip = "text")
    } else {
      # plotly no entiende ~.data[[var]]: usar columna intermedia VAR_PLOT
      plot_ly(dfc,
              labels  = ~VAR_PLOT,
              values  = ~n,
              type    = "pie",
              text    = ~paste0(round(pct, 1), "%"),
              textinfo = if (input$eda_pct) "label+percent" else "label",
              hovertemplate = paste0("%{label}<br>n = %{value:,}<br>%{percent}<extra></extra>"),
              marker  = list(colors = rep(PAL, length.out = nrow(dfc))))
    }
  })
  
  output$plot_edad_grupo <- renderPlotly({
    df <- datos_filt() %>% filter(!is.na(EDAD_SIMPLE)) %>%
      group_by(NOM_667_OPS_GRUPO) %>% filter(n() >= 10) %>% ungroup() %>%
      mutate(G = substr(NOM_667_OPS_GRUPO, 1, 25))
    p <- ggplot(df, aes(x = G, y = EDAD_SIMPLE, fill = G)) +
      geom_boxplot(show.legend = FALSE, outlier.size = 0.4, outlier.alpha = 0.3) +
      scale_fill_manual(values = rep(PAL, length.out = n_distinct(df$G))) +
      coord_flip() + labs(x = NULL, y = "Edad") + theme_minimal(base_size = 11)
    ggplotly(p)
  })
  
  output$plot_causa_sexo <- renderPlotly({
    df <- datos_filt() %>%
      filter(!is.na(SEXO), !is.na(NOM_667_OPS_GRUPO)) %>%
      mutate(Sexo = ifelse(SEXO == "1", "Masculino", "Femenino"),
             G    = substr(NOM_667_OPS_GRUPO, 1, 25)) %>%
      count(G, Sexo)
    p <- ggplot(df, aes(x = reorder(G, n), y = n, fill = Sexo,
                        text = paste0(G, "<br>", Sexo, ": ", format(n, big.mark=",")))) +
      geom_col(position = "dodge") + coord_flip() +
      scale_fill_manual(values = c("Masculino" = "#3498DB", "Femenino" = "#E74C3C")) +
      labs(x = NULL, y = "Defunciones", fill = NULL) + theme_minimal(base_size = 11)
    ggplotly(p, tooltip = "text")
  })
  
  output$plot_trend <- renderPlotly({
    df <- datos_filt() %>% count(ANO, NOM_667_OPS_GRUPO) %>%
      group_by(NOM_667_OPS_GRUPO) %>% filter(sum(n) >= 20) %>% ungroup() %>%
      mutate(G = substr(NOM_667_OPS_GRUPO, 1, 22))
    p <- ggplot(df, aes(x = ANO, y = n, color = G, group = G)) +
      geom_line(size = 1) + geom_point(size = 2) +
      scale_color_manual(values = rep(PAL, length.out = n_distinct(df$G))) +
      labs(x = "Año", y = "Defunciones", color = NULL) + theme_minimal(base_size = 11)
    ggplotly(p)
  })
  
  output$plot_heatmap_mes_ano <- renderPlotly({
    meses <- c("Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic")
    df <- datos_filt() %>% count(ANO, MES) %>%
      mutate(Mes = factor(meses[MES], levels = meses))
    p <- ggplot(df, aes(x = Mes, y = factor(ANO), fill = n,
                        text = paste0(Mes, " ", ANO, "<br>n = ", format(n, big.mark=",")))) +
      geom_tile(color = "white", size = 0.3) +
      scale_fill_gradient(low = "#EBF5FB", high = "#1A5276") +
      labs(x = NULL, y = NULL, fill = "N") +
      theme_minimal(base_size = 10) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    ggplotly(p, tooltip = "text")
  })
  
  output$plot_edu_causa <- renderPlotly({
    edu_labels <- c("0"="Sin escolaridad","1"="Primaria","2"="Secundaria",
                    "3"="Técnico","4"="Universitario","99"="Sin info")
    df <- datos_filt() %>%
      filter(!is.na(NIVEL_EDU), !is.na(NOM_667_OPS_GRUPO)) %>%
      mutate(Edu = recode(as.character(NIVEL_EDU), !!!edu_labels),
             G   = substr(NOM_667_OPS_GRUPO, 1, 22)) %>%
      count(G, Edu)
    p <- ggplot(df, aes(x = G, y = n, fill = Edu,
                        text = paste0(G, "<br>", Edu, ": ", format(n, big.mark=",")))) +
      geom_col(position = "fill") + coord_flip() +
      scale_fill_manual(values = rep(PAL, length.out = n_distinct(df$Edu))) +
      scale_y_continuous(labels = scales::percent) +
      labs(x = NULL, y = "Proporción", fill = "Nivel edu.") + theme_minimal(base_size = 11)
    ggplotly(p, tooltip = "text")
  })
  
  output$plot_seg_causa <- renderPlotly({
    seg_labels <- c("1"="Contributivo","2"="Subsidiado","3"="Vinculado",
                    "4"="Especial","9"="Sin info")
    df <- datos_filt() %>%
      filter(!is.na(SEG_SOCIAL), !is.na(NOM_667_OPS_GRUPO)) %>%
      mutate(Seg = recode(as.character(SEG_SOCIAL), !!!seg_labels),
             G   = substr(NOM_667_OPS_GRUPO, 1, 22)) %>%
      count(G, Seg)
    p <- ggplot(df, aes(x = G, y = n, fill = Seg,
                        text = paste0(G, "<br>", Seg, ": ", format(n, big.mark=",")))) +
      geom_col(position = "fill") + coord_flip() +
      scale_fill_manual(values = rep(PAL, length.out = n_distinct(df$Seg))) +
      scale_y_continuous(labels = scales::percent) +
      labs(x = NULL, y = "Proporción", fill = "Régimen") + theme_minimal(base_size = 11)
    ggplotly(p, tooltip = "text")
  })
  
  # ── TABLA NAVEGABLE ───────────────────────────────────────
  observeEvent(input$tab_reset, {
    updateSelectInput(session, "tab_grupo", selected = "Todos")
    updateSelectInput(session, "tab_sexo",  selected = "Todos")
    updateSliderInput(session, "tab_ano",   value = c(2012, 2023))
    updateSliderInput(session, "tab_edad",  value = c(0, 99))
  })
  
  datos_tabla <- reactive({
    df <- datos
    if (input$tab_grupo != "Todos")
      df <- df %>% filter(NOM_667_OPS_GRUPO == input$tab_grupo)
    if (input$tab_sexo != "Todos")
      df <- df %>% filter(SEXO == input$tab_sexo)
    df <- df %>%
      filter(ANO >= input$tab_ano[1], ANO <= input$tab_ano[2]) %>%
      filter(EDAD_SIMPLE >= input$tab_edad[1], EDAD_SIMPLE <= input$tab_edad[2])
    df %>% select(ANO, MES, SEXO, EDAD_SIMPLE, ETAREO_QUIN,
                  EST_CIVIL, NIVEL_EDU, SEG_SOCIAL, NOM_667_OPS_GRUPO)
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
    datos_tabla() %>% head(3000)
  }, options = list(
    pageLength = 15, scrollX = TRUE,
    language = list(url = "//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json")
  ), filter = "top", rownames = FALSE)
  
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