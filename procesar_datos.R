library(dplyr)
library(purrr)

carpetas <- dir("datos")

# residencias definitivas ----
archivos_definitivas <- dir(paste0("datos/", carpetas[1]), full.names = T)

# cargar y limpiar todos los datos
definitivas_otorgadas <- map(archivos_definitivas, \(archivo) {
  message(archivo)
  
  # cargar
  dato <- readxl::read_xlsx(archivo)
  # dato <- readxl::read_excel(archivos[2])
  
  # extraer comuna, pais y año
  dato_2 <- dato |> 
    janitor::clean_names() |> 
    select(comuna, pais, año = ano) |> 
    group_by(comuna, pais, año) |> 
    count()
  
  return(dato_2)
})

definitivas_otorgadas_2 <- definitivas_otorgadas |> 
  list_rbind() |> 
  mutate(residencia = "Definitiva")


# residencias temporales ----
archivos_temporales <- dir(paste0("datos/", carpetas[3]), full.names = T)

# cargar y limpiar todos los datos
temporales_otorgadas <- map(archivos_temporales, \(archivo) {
  message(archivo)
  
  # cargar
  dato <- readxl::read_xlsx(archivo)
  # dato <- readxl::read_excel(archivos[2])
  
  # extraer comuna, pais y año
  dato_2 <- dato |> 
    janitor::clean_names() |> 
    select(comuna, pais, año = ano) |> 
    group_by(comuna, pais, año) |> 
    count()
  
  return(dato_2)
})


temporales_otorgadas_2 <- temporales_otorgadas |> 
  list_rbind() |> 
  mutate(residencia = "Temporal")




# refugiados ----
# no tienen comuna

refugiados <- readxl::read_xlsx("datos/Refugio/Refugiados_WEB.xlsx")

# extraer comuna, pais y año
refugiados_2 <- refugiados |>
  janitor::clean_names() |>
  select(pais = pais_de_nacionalidad, año = ano) |>
  group_by(pais, año) |>
  count()


# unir residencias ----
residencias <- bind_rows(temporales_otorgadas_2, definitivas_otorgadas_2) |> 
  ungroup()



