library(tidyverse)
library(rvest)

first_page = tibble(url = 'http://www.presidencia.gob.ve/Site/Web/Principal/paginas/classListaEvento1.php')


links = read_html(first_page) |>
  html_elements('.tabla a') |>
  html_attr('href')

url = 'http://www.presidencia.gob.ve/Site/Web/Principal/paginas/classListaEvento1.php'

links_tib = tibble(url = paste0(url, '?', 'pagina=',
seq(1,2756,1),'&fecha_busqueda=&mes_busqueda=&anio_busqueda='))

links_test = read_html(links_tib[[1,1]]) |>
  html_elements('.tabla a') |>
  html_attr('href')


write_csv(links_tib,'links.csv')
