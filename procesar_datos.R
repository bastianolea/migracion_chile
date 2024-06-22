library(dplyr)
library(purrr)
library(janitor)

source("funciones.R")

cut_comunas <- read.csv2("comunas_chile_cut.csv") |> tibble()

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
  mutate(residencia = "Definitiva",
         estado = "Acogidas")

# unir residencias ----
residencias_otorgadas <- bind_rows(otorgadas_temporales, otorgadas_definitivas) |> ungroup()

residencias_acogidas <- bind_rows(acogidas_temporales, acogidas_definitivas) |> ungroup()

residencias <- bind_rows(residencias_otorgadas, residencias_acogidas) |> 
  # agregar cut comunas
  filter(!is.na(comuna),
         comuna != "Sin Información",
         comuna != "Antártica") |> 
  mutate(comuna = recode(comuna, 
                         "Aysén" = "Aisén",
                         "Coyhaique" = "Coihaique",
                         "Los Álamos" = "Los Alamos",
                         "Los Ángeles" = "Los Angeles",
                         "Marchigüe" = "Marchihue",
                         "Paihuano" = "Paiguano",
                         "Ránquil" = "Ranquil")) |> 
  left_join(cut_comunas,
            by = "comuna") |> 
  select(comuna, cut_comuna, region, cut_region, año, pais, everything(), n)

residencias |> filter(año == 2023)


  # filter(is.na(cut_comuna)) |> 
  # distinct(comuna)

# guardar residencias ----
write.csv2(residencias, "datos_procesados/extranjeros_residencias_comuna_año.csv")

write.csv2(residencias |> filter(año == 2023), "datos_procesados/extranjeros_residencias_comuna_2023.csv")

# read.csv2("datos_procesados/residencias_comuna_año.csv") |> 
#   tibble() |> 
#   filter(residencia == "Temporal") |> 
#   filter(estado == "Otorgadas") |> 
#   summarize(n = sum(n), .by = c(comuna))

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
  clean_names() |> 
  rename(año = ano_estimacion) |> 
  mutate(estimacion = as.numeric(estimacion))

# totales por año
estimacion_año <- estimacion |> 
  mutate(pais = str_to_sentence(pais)) |> 
  # mutate(pais = fct_lump_n(pais, w = estimacion, n = 5, other_level = "Otros")) |> 
  summarise(estimacion = sum(estimacion), .by = c(pais, año))

# contar por país, año y comuna
estimacion_comuna <- estimacion |> 
  select(pais, año, region, comuna, estimacion) |> 
  group_by(pais, año, region, comuna) |> 
  summarize(estimacion = sum(estimacion, na.rm = TRUE)) |> 
  # excluir los sin comuna
  filter(comuna != toupper("ignorada"),
         comuna != toupper("otras comunas")) |>
  ungroup() |> 
  # agregar cut comunas
  rename(comuna_join = comuna) |> 
  select(-region) |> 
  left_join(cut_comunas |> 
              mutate(comuna_join = toupper(comuna)), 
            by = c("comuna_join")) |> 
  select(-comuna_join)

estimacion_comuna |> 
  filter(año == 2022) |> 
  summarize(estimacion = sum(estimacion), .by = c(cut_comuna, comuna, año))

# guardar
write.csv2(estimacion_comuna, "datos_procesados/extranjeros_estimacion_comuna_año.csv")

write.csv2(estimacion_comuna |> filter(año == 2022), "datos_procesados/extranjeros_estimacion_comuna_2022.csv")

write.csv2(estimacion_año, "datos_procesados/extranjeros_estimacion_año.csv")