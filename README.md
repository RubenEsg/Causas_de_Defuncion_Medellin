# Causas de Defunción — Medellín

# Análisis y clasificación de causas de muerte en Medellín (2012–2023) usando Machine Learning en R Shiny.

El estudio de la mortalidad constituye uno de los indicadores más relevantes en salud pública. Este proyecto integra técnicas de **análisis exploratorio de datos (EDA)** y **aprendizaje automático (Machine Learning)** para examinar y predecir las causas de defunción registradas en Medellín entre 2012 y 2023, a partir de variables demográficas, temporales y socioeconómicas.

Los datos provienen del **Registro de Defunciones de Medellín**, publicado en el portal de datos abiertos [MeData (medata.gov.co)](https://medata.gov.co/node/16570), con aproximadamente **145.000 registros** y variables como sexo, edad, estado civil, nivel educativo, régimen de salud y causa básica de defunción codificada según la nomenclatura **OPS 667**.

## Problema

La magnitud y diversidad del dataset de defunciones de Medellín dificulta identificar patrones sin un proceso sistemático de exploración y modelado. La pregunta central del proyecto es:

> *¿Es posible predecir el grupo de causa de muerte de una persona a partir de sus características sociodemográficas (sexo, edad, estado civil, nivel educativo, régimen de salud) y temporales (año, mes)?*

## Impacto

Al construir un modelo de clasificación sobre este dataset, se provee a investigadores y tomadores de decisiones en salud pública una herramienta para:

- Identificar grupos de riesgo y comportamientos diferenciales de mortalidad.
- Detectar tendencias temporales y territoriales en las causas de muerte.
- Explorar el poder predictivo de variables sociodemográficas sobre la causa de defunción.
- Apoyar la formulación de políticas públicas basadas en evidencia.

## Correr la aplicación

Todos los archivos necesarios para ejecutar la app localmente se encuentran en la carpeta `app/`. La aplicación fue desarrollada en **R** usando la librería **Shiny** (es necesario tener R instalado).

### 1. Clonar el repositorio

```bash
git clone https://github.com/RubenEsg/Causas_de_Defuncion_Medellin.git
cd Causas_de_Defuncion_Medellin
```

### 2. Instalar los paquetes requeridos

Abre R o RStudio y ejecuta:

```r
install.packages(c(
  "shiny", "shinydashboard", "shinyWidgets",
  "dplyr", "tidyr", "ggplot2", "plotly",
  "DT", "randomForest", "caret", "reshape2", "scales"
))
```

### 3. Correr la aplicación

Desde R o RStudio, con la carpeta `app/` como directorio de trabajo:

```r
shiny::runApp("app")
```

O también puedes abrir cualquiera de los archivos `app/ui.R`, `app/server.R` o `app/global.R` en RStudio y hacer clic en el botón **Run App**.

### 4. Acceder a la aplicación

La app se abrirá automáticamente en tu navegador. Si no, accede en:

```
http://127.0.0.1:PUERTO
```

> El puerto es asignado automáticamente por Shiny y se muestra en la consola de R al iniciar la app.

> **Nota:** Los datos se descargan automáticamente desde este repositorio al iniciar la app. Si no hay conexión a internet, se usará el archivo local `data/defunciones.csv` si está disponible.


## Equipo

Este proyecto fue desarrollado por:

- **Rubén Esguerra** — [GitHub](https://github.com/RubenEsg)
- **Camilo Gonzales** — [GitHub](https://github.com/spidermil0)
