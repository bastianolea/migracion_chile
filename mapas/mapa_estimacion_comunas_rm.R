library(dplyr)
library(ggplot2)
library(forcats)
library(stringr)


estimacion_comuna <- read.csv2("datos_procesados/extranjeros_estimacion_comuna_2022.csv")


# obtener mapa urbano de la RM
mapa_urbano <- readRDS("mapas/mapa_urbano_rm.rds")


estimacion_comuna_2 <- estimacion_comuna |> 
  filter(año == 2022,
         region == "METROPOLITANA DE SANTIAGO") |> 
  group_by(comuna) |> 
  summarize(estimacion = sum(estimacion))

# total migrantes en la RM
sum(estimacion_comuna_2$estimacion)

sort(estimacion_comuna_2$comuna) |> unique()
sort(mapa_urbano$nombre_comuna)

estimacion_mapa <- mapa_urbano |> 
  mutate(nombre_comuna = recode(nombre_comuna,
                                "Maipu" = "Maipú",
                                "Conchali" = "Conchalí",
                                "San Joaquin" = "San Joaquín",
                                "Penalolen" = "Peñalolén",
                                "Estacion Central" = "Estación Central",
                                "Nunoa" = "Ñuñoa")) |> 
  mutate(comuna = toupper(nombre_comuna)) |> 
  left_join(estimacion_comuna_2, by = c("comuna" = "comuna"))

sort(estimacion_mapa$nombre_comuna)

# total migrantes en la RM
sum(estimacion_mapa$estimacion, na.rm = T)

estimacion_mapa |>
  ggplot(aes(geometry = geometry)) +
  geom_sf(aes(fill = estimacion), color = "white") +
  scale_fill_gradient(na.value = "grey80") +
  theme_void()