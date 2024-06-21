cargar_datos_residencias <- function(archivos) {
  map(archivos, \(archivo) {
    message("cargando ", archivo)
    
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
}