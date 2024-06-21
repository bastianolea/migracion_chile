library(dplyr)
library(ggplot2)

residencias <- read.csv2("datos_procesados/residencias_comuna_año.csv") |> 
  tibble()

residencias |> 
  group_by(pais) |> 
  summarize(n = sum(n)) |> 
  arrange(desc(n))

# residencias temporales y definitivas ----
residencias |> 
  filter(año >= 2010) |> 
  filter(pais %in% c("Venezuela", "Perú", "Colombia", "Bolivia", "Haití")) |> 
  mutate(pais = forcats::fct_relevel(pais, c("Venezuela", "Perú", "Colombia", "Bolivia", "Haití"))) |> 
  group_by(año, pais, residencia) |> 
  summarize(n = sum(n)) |> 
  ggplot(aes(año, n, color = residencia)) +
  geom_line(linewidth = 0.7, alpha = 0.6) +
  geom_point(size = 2, alpha = 0.8) +
  scale_y_continuous(labels = ~scales::comma(.x, big.mark = ".")) +
  scale_x_continuous(breaks = 2010:2024) +
  facet_wrap(~pais, ncol = 1, strip.position = "right", axes = "all", axis.labels = "all") +
  theme_void() +
  theme(strip.text = element_text(size = 11, face = "bold", angle = -90, margin = margin(l = 6, r = 0)),
        axis.text.y = element_text(size = 9, hjust = 1, margin = margin(r = 6)),
        axis.text.x = element_text(size = 8, angle = -90, margin = margin(t = 3, b = 4)),
        panel.grid.major.y = element_line(color = "grey80"),
        panel.grid.major.x = element_line(color = "grey90", linetype = "dotted"),
        plot.subtitle = element_text(margin = margin(t = 4, b = 12))) +
  theme(legend.position = "bottom") +
  theme(plot.margin = unit(rep(0.3, 4), "cm")) +
  labs(title = "Permisos de residencia de extranjeros en Chile",
       subtitle = "Residencias Temporales y Residencias Definitivas otorgadas",
       color = "Tipo de residencia", caption = "Fuente: Servicio Nacional de Migraciones (SERMIG)")

ggsave("graficos/residencias_2010_2023.jpg", 
       width = 5, height = 8)




# —----

# mapa ----
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

