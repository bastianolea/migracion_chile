library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)
library(ggtext)

censo <- read.csv2("datos_originales/censo_proyecciones_año.csv") |> tibble()


poblacion <- censo |> 
  summarize(poblacion = sum(población), .by = año)


poblacion |> 
  filter(año <= 2024) |> 
  ggplot(aes(año, poblacion)) +
  geom_area()



extranjeros <- read.csv2("datos_procesados/extranjeros_estimacion_año.csv") |> 
  tibble()

extranjeros_ven <- extranjeros |> 
  filter(pais == "Venezuela") |> 
  summarise(estimacion = sum(estimacion), .by = año)

extranjeros_año <- extranjeros |> 
  summarise(estimacion = sum(estimacion),
            .by = año)

extranjeros_año |> 
  filter(año <= 2024) |> 
  ggplot(aes(año, estimacion)) +
  geom_area()


ggplot() +
  geom_area(data = poblacion |> filter(año >= 2018, año <= 2024),
            aes(año, poblacion), fill = color_poblacion) +
  geom_area(data = extranjeros_año |> filter(año <= 2024),
            aes(año, estimacion), fill = color_extranjeros) +
  theme_minimal()


# extrapolar estimación de extranjeros ----

## visualizar datos originales
p1 <- ggplot(extranjeros_año, aes(x = año, y=estimacion)) +
  geom_line() +
  geom_point() +
  geom_hline(aes(yintercept=0))

print(p1)

# crear modelo lineal
# model <- lm(estimacion ~ poly(año, 2), data = extranjeros_año)
model <- lm(estimacion ~ año, data = extranjeros_año)

# crear predicción
extranjeros_año$pred1 <- predict(model)

# visualizar modelo
p1 +
  geom_line(aes(y = pred1), color="red")

# extrapolar datos en base al modelo
pred <- data.frame(año=2018:2050)
pred$estimacion <- predict(model, newdata = pred)

# visualizar extrapolación
p1 +
  geom_line(color="red", data = pred) +
  geom_point(color="red", data = pred) +
  xlim(c(2019, 2028))


prediccion <- pred |> 
  tibble() |> 
  rename(prediccion = estimacion)

prediccion_porcentaje <- prediccion |> 
  left_join(poblacion, by = "año") |> 
  mutate(porcentaje = prediccion/poblacion)

extranjeros_año_porcentaje <- extranjeros_año |> 
  left_join(poblacion, by = "año") |> 
  mutate(porcentaje = estimacion/poblacion)



# graficar ----
color_poblacion = "#7570b3"
color_extranjeros = "#e7298a"
año_maximo = 2026

grafico_base <- ggplot() +
  geom_area(data = poblacion |> filter(año >= 2018, año <= año_maximo),
            aes(año, poblacion, fill = "Población proyectada")) +
  geom_line(data = poblacion |> filter(año >= 2018, año <= 2024),
            aes(año, poblacion), 
            color = color_poblacion |> shades::brightness(0.5), linewidth = 1.2) +
  geom_area(data = extranjeros_año,
            aes(año, estimacion, fill = "Estimación migrantes")) +
  geom_line(data = extranjeros_año |> filter(año >= 2018, año <= 2022),
            aes(año, estimacion), 
            color = color_extranjeros |> shades::brightness(0.65), linewidth = 1.2) +
  geom_line(data = prediccion |> filter(año > 2021, año <= 2024),
            aes(año, prediccion, linetype = "Predicción migrantes"),
            color = "white") +
  geom_line(data = prediccion |> filter(año >= 2024, año <= año_maximo),
            aes(año, prediccion, linetype = "Predicción migrantes"),
            color = "white", alpha = .5) +
  scale_fill_manual(values = c("Población proyectada" = color_poblacion, 
                               "Estimación migrantes" = color_extranjeros)) +
  scale_linetype_manual(values = c("Predicción migrantes" = "dashed")) +
  # leyenda
  theme_minimal() +
  theme(legend.position = "bottom",
        legend.title = element_blank()) +
  guides(fill = guide_legend(order = 1, keywidth = 1, keyheight = 1, reverse = T),
         linetype = guide_legend(order = 3, keywidth = 2.2,
                                 override.aes = list(color = "black"))) +
  # escalas
  scale_y_continuous(expand = expansion(c(0, 0.03)),
                     labels = ~comma(.x, big.mark = ".", decimal.mark = ",")) +
  scale_x_continuous(breaks = 2018:año_maximo,
                     expand = expansion(c(0, 0.1))) +
  theme(axis.text.x = element_text(angle = -90, vjust = .5, size = 9, face = "bold"),
        panel.grid = element_blank(), 
        axis.title = element_blank())

grafico_base

# cifras para anotaciones
estimacion_p_2018 <- extranjeros_año_porcentaje |> filter(año == 2018) |> pull(porcentaje)
estimacion_n <- extranjeros_año_porcentaje |> filter(año == 2022) |> pull(estimacion)
estimacion_p <- extranjeros_año_porcentaje |> filter(año == 2022) |> pull(porcentaje)
prediccion_n = prediccion_porcentaje |> filter(año == 2024) |> pull(prediccion)
prediccion_p = prediccion_porcentaje |> filter(año == 2024) |> pull(porcentaje)
poblacion_n = poblacion |> filter(año == 2024) |> pull(poblacion)

# anotaciones
grafico_base_anotaciones <- grafico_base +
  # cuadro blanco post 2024
  annotate("rect", xmin = 2024, xmax = año_maximo, ymin = 0, ymax = Inf, 
           fill = "white", alpha = 0.2) +
  # puntos población
  annotate("point", x = 2024, y = poblacion_n,
           color = "white", size = 3.5, alpha = .7) +
  annotate("point", x = 2024, y = poblacion_n,
           color = color_poblacion, size = 2.5, alpha = .9) +
  # textos poblacion
  annotate("text", label = poblacion |> filter(año == 2024) |> pull(poblacion) |> comma(big.mark = "."),
           x = 2024, y = poblacion_n*1.045, 
           color = "black", size = 3.3, angle = 3) +
  # puntos estimación
  annotate("point", x = 2022, y = estimacion_n,
           color = "white", size = 3.5, alpha = .7) +
  annotate("point", x = 2022, y = estimacion_n,
           color = color_extranjeros, size = 2.5, alpha = 1) +
  # textos estimación
  annotate("text", label = estimacion_p_2018 |> percent(accuracy = 0.1),
           x = 2018.3, y = estimacion_n/2.4, 
           label.size = NA, size = 3.1, color = "white") +
  annotate("text", label = estimacion_p |> percent(accuracy = 0.1),
           x = 2022.4, y = estimacion_n/2, 
           label.size = NA, size = 3.4, color = "white") +
  annotate("text", label = estimacion_n |> comma(big.mark = "."),
           x = 2022, y = estimacion_n*1.6, angle = 2,
           color = "white", size = 3.4) +
  # puntos predicción
  annotate("point", x = 2024, y = prediccion_n,
           color = "white", size = 3.5, alpha = .7) +
  annotate("point", x = 2024, y = prediccion_n,
           color = color_extranjeros, size = 2.5, alpha = .9) +
  #textos prediccion
  annotate("text", label = prediccion_n |> comma(big.mark = "."),
           x = 2024.1, y = prediccion_n*1.5, 
            size = 3.4, angle = 2, hjust = 0, color = "white", alpha = 0.6) +
  annotate("text", label = prediccion_p |> percent(accuracy = 0.1),
         x = 2024.1, y = prediccion_n/2, 
         size = 3.4, hjust = 0, color = "white", alpha = 0.6) +
  # lineas verticales
  geom_vline(xintercept = 2018:año_maximo, color = "white", alpha= .07); plot(grafico_base_anotaciones)


# shades::brightness(color_poblacion, .7) |> 
#   shades::saturation(.5) #|>
#   # shades::swatch() 

# agregar textos
grafico_base_anotaciones +
  labs(title = "Estimación de extranjeros residentes en Chile versus población nacional",
  subtitle = "<span style = 'color:#6059B3;'>Proyección de población nacional</span> 
  (INE), <span style = 'color:#e7298a;'>estimación de extranjeros con residencia habitual</span> (Servicio de Migraciones),
  y <span style = 'color:#808080;'>extrapolación lineal de la estimación de extranjeros<span>",
  caption = "Fuentes: Proyecciones de población, Instituto Nacional de Estadísticas,\n
  Estimación de extranjeros residentes habituales en Chile, Servicio Nacional de Migraciones,\n
  Predicción, elaboración propia; visualización: Bastián Olea Herrera") +
  theme(
    plot.title = element_textbox_simple(size = 12, face = "bold", 
                                        padding = margin(0, 0, 8, 0)),
    plot.subtitle = element_textbox_simple(
      size = 11, lineheight = 1.2, padding = margin(0, 0, 8, 0)),
    plot.caption = element_text(lineheight = 0.5),
    plot.title.position = "plot")
      

ggsave("graficos/poblacion_estimacion_prediccion_extranjeros.jpg", 
       width = 5, height = 4, scale = 1.4)

