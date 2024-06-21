library(dplyr)
library(purrr)
library(janitor)

source("funciones.R")

# residencias otorgadas ----

##  definitivas ----
archivos_otorgadas_definitivas <- dir("datos_originales/RD-Otorgadas-2000-al-2023", full.names = T)

# cargar y limpiar todos los datos
otorgadas_definitivas <- archivos_otorgadas_definitivas |> 
  cargar_datos_residencias() |> 
  list_rbind() |> 
  mutate(residencia = "Definitiva",
         estado = "Otorgadas")


## temporales ----
archivos_otorgadas_temporales <- dir("datos_originales/RT-otorgadas-2000-al-2023", full.names = T)

otorgadas_temporales <- archivos_otorgadas_temporales |> 
  cargar_datos_residencias() |> 
  list_rbind() |> 
  mutate(residencia = "Temporal",
         estado = "Otorgadas")


# residencias acogidas ----

## temporales ----
archivos_acogidas_temporales <- dir("datos_originales/RT-Acogidas-2000-al-2023", full.names = T)

acogidas_temporales <- archivos_acogidas_temporales |> 
  cargar_datos_residencias() |> 
  list_rbind() |> 
  mutate(residencia = "Temporal",
         estado = "Acogidas")

## definitivas ----
archivos_acogidas_definitivas <- dir("datos_originales/RD-acogidas-2000-al-2023", full.names = T)

acogidas_definitivas <- archivos_acogidas_definitivas |> 
  cargar_datos_residencias() |> 
  list_rbind() |> 
  mutate(residencia = "Temporal",
         estado = "Acogidas")

# unir residencias ----
residencias_otorgadas <- bind_rows(otorgadas_temporales, otorgadas_definitivas) |> ungroup()

residencias_acogidas <- bind_rows(acogidas_temporales, acogidas_definitivas) |> ungroup()

residencias <- bind_rows(residencias_otorgadas, residencias_acogidas)

residencias |> filter(año == 2023)



# guardar residencias ----
write.csv2(residencias, "datos_procesados/residencias_comuna_año.csv")

write.csv2(residencias |> filter(año == 2023), "datos_procesados/residencias_comuna_2023.csv")

# -—----



# refugiados ----
# no tienen comuna

refugiados <- readxl::read_xlsx("datos_originales/Refugio/Refugiados_WEB.xlsx")

# extraer comuna, pais y año
refugiados_2 <- refugiados |>
  janitor::clean_names() |>
  select(pais = pais_de_nacionalidad, año = ano) |>
  group_by(pais, año) |>
  count()



# estimación ----
# no están todas las comunas del país

estimacion <- read.csv("datos_originales/Estimacion-2022/basecomunas.csv", header=FALSE, stringsAsFactors=FALSE, fileEncoding="latin1") |> 
  tibble() |> 
  row_to_names(1) |> 
  clean_names()

# contar por país, año y comuna
estimacion_comuna <- estimacion |> 
  select(pais, año = ano_estimacion, region, comuna, estimacion) |> 
  group_by(pais, año, region, comuna) |> 
  summarize(estimacion = sum(as.numeric(estimacion), na.rm = TRUE)) |> 
  filter(comuna != toupper("ignorada"),
         comuna != toupper("otras comunas")) |> 
  ungroup()

estimacion_comuna |> filter(año == 2022)

# guardar
write.csv2(estimacion_comuna, "procesados/estimacion_comuna_año.csv")
