
# descargar ----
download.file("https://serviciomigraciones.cl/wp-content/uploads/2024/06/RT-Acogidas-2000-al-2023.zip", 
              destfile = "datos_originales/RT-Acogidas-2000-al-2023.zip")

download.file("https://serviciomigraciones.cl/wp-content/uploads/2024/03/RT-otorgadas-2000-al-2023.zip", 
              destfile = "datos_originales/RT-otorgadas-2000-al-2023.zip")

download.file("https://serviciomigraciones.cl/wp-content/uploads/2024/03/RD-acogidas-2000-al-2023.zip", 
              destfile = "datos_originales/RD-acogidas-2000-al-2023.zip")

download.file("https://serviciomigraciones.cl/wp-content/uploads/2024/06/RD-Otorgadas-2000-al-2023.zip", 
              destfile = "datos_originales/RD-Otorgadas-2000-al-2023.zip")


download.file("https://serviciomigraciones.cl/wp-content/uploads/2023/12/Estimacion-2022.zip", 
              destfile = "datos_originales/Estimacion-2022.zip")

# descomprimir ----
unzip(zipfile = "datos_originales/RT-Acogidas-2000-al-2023.zip", exdir = "datos_originales/RT-Acogidas-2000-al-2023")

unzip(zipfile = "datos_originales/RT-otorgadas-2000-al-2023.zip", exdir = "datos_originales/RT-otorgadas-2000-al-2023")

unzip(zipfile = "datos_originales/RD-acogidas-2000-al-2023.zip", exdir = "datos_originales/RD-acogidas-2000-al-2023")

unzip(zipfile = "datos_originales/RD-Otorgadas-2000-al-2023.zip", exdir = "datos_originales/RD-Otorgadas-2000-al-2023")

unzip(zipfile = "datos_originales/Estimacion-2022.zip", exdir = "datos_originales/Estimacion-2022")