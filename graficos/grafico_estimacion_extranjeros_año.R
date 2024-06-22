library(dplyr)
library(ggplot2)
library(forcats)
library(stringr)

extranjeros <- read.csv2("datos_procesados/extranjeros_estimacion_año.csv") |> 
  tibble()

extranjeros_año <- extranjeros |> 
  mutate(pais = fct_lump_n(pais, w = estimacion, n = 5, other_level = "Otros")) |> 
  summarise(estimacion = sum(estimacion), .by = c(pais, año))

extranjeros_año |> 
  ggplot(aes(año, estimacion, fill = pais)) +
  geom_col(width = .5, color = "white", linewidth = .6) +
  geom_point(aes(color = pais), alpha = 0) +
  geom_text(aes(label = if_else(pais %in% c("Venezuela", "Perú", "Otros"),
                                scales::comma(estimacion, big.mark = ".", trim = T), "")),
            position = position_stack(vjust = .5), 
            size = 3, angle = 90, color = "white") +
  geom_text(data = ~summarize(.x, estimacion = sum(estimacion), .by = año),
            aes(x = año, y = estimacion, 
                label = scales::comma(estimacion, big.mark = ".", trim = T)),
            size = 3.2, vjust = 0, nudge_y = 20000, inherit.aes = F) +
  scale_y_continuous(labels = ~scales::comma(.x, big.mark = ".", trim = F), 
                     expand = expansion(c(0.02, 0.05))) +
  theme_void() +
  # scale_fill_brewer(palette = 2, type = "qual", aesthetics = c("colour", "fill")) +
  scale_fill_manual(values = c("#1b9e77", "#d95f02", "#7570b3", "#e6ab02", "#e7298a" |> shades::brightness(.88), 
                               "grey70"),
                    aesthetics = c("colour", "fill")) +
  theme(axis.text = element_text(),
        axis.text.x = element_text(face = "bold"),
        plot.caption.position = "plot",
        plot.title.position = "plot",
        plot.title = element_text(face = "bold", margin = margin(b = 6)),
        plot.subtitle = element_text(margin = margin(b = 4)),
        plot.caption = element_text(margin = margin(t = 8)),
        legend.box.margin = margin(l = 0, r = 6),
        plot.margin = unit(rep(0.3, 4), "cm")) +
  guides(fill = guide_none(),
         color = guide_legend(title = "Nacionalidad", override.aes = c(alpha = 1, size = 5))) +
  labs(title = "Estimación de personas extranjeras residentes habituales en Chile",
       subtitle = "Servicio Nacional de Migraciones junto al INE, en colaboración con PDI, el Ministerio de Relaciones Exteriores y el Servicio de Registro Civil e Identificación" |> str_wrap(100),
       caption = "Fuente: Servicio Nacional de Migraciones (SERMIG). Elaboración: Bastián Olea Herrera")


ggsave("graficos/estimacion_extranjeros_2018_2022.jpg", 
       width = 5, height = 4, scale = 1.4)
