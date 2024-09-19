library(tidyverse)

files = c('conferencias_all.csv', 'discursos_all.csv')

raw_dat = read_csv(files) |>
  rename(url = summary_url)




removal_pat = c("Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo",
                "de")
english_months <- c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")

spanish_months <- c("enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre")

clean_up_date = raw_dat |> 
  mutate(date_fix = str_remove_all(date, paste(removal_pat, collapse = "|")),
         date_fix = dmy(date_fix, locale = "es_ES.UTF-8"),
         date_fix_two = ymd(date),
        ## these date have associated articles with them so we are just going to add them manually
        fix_dates_three = case_when(
          url == "https://www.casarosada.gob.ar/informacion/discursos/36233-palabras-del-presidente-mauricio-macri-anunciando-medidas-de-apoyo-a-las-pymes" ~ ymd('2016-05-10'),
          url == "https://www.casarosada.gob.ar/informacion/discursos/36232-palabras-del-presidente-mauricio-macri-luego-de-la-firma-del-acuerdo-de-estabilidad-laboral" ~ ymd('2016-05-09'),
          url ==  "https://www.casarosada.gob.ar/informacion/discursos/35563-el-presidente-mauricio-macri-anuncio-modificaciones-en-el-impuesto-a-las-ganancias-y-asignaciones-familiares" ~ ymd('2016-02-18'),
          url == 'https://www.casarosada.gob.ar/informacion/discursos/36233-palabras-del-presidente-mauricio-macri-anunciando-medidas-de-apoyo-a-las-pymes' ~ ymd('2022-11-30'),
         ),
          
        date = coalesce(date_fix, date_fix_two, fix_dates_three)) |>
  select(-contains('fix')) 





problems = check |>
  filter(is.na(date)) |>
  pull('url')



clean_up_date = raw_dat |> 
  mutate(date_fix = str_remove_all(date, paste(removal_pat, collapse = "|")),
         date_fix = dmy(date_fix, locale = "es_ES"),
         date_fix_two = ymd(date),
        ## these date have associated articles with them so we are just going to add them manually
        fix_dates_three = case_when(
          url == "https://www.casarosada.gob.ar/informacion/discursos/36233-palabras-del-presidente-mauricio-macri-anunciando-medidas-de-apoyo-a-las-pymes" ~ ymd('2016-05-10'),
          url == "https://www.casarosada.gob.ar/informacion/discursos/36232-palabras-del-presidente-mauricio-macri-luego-de-la-firma-del-acuerdo-de-estabilidad-laboral" ~ ymd('2016-05-09'),
          url ==  "https://www.casarosada.gob.ar/informacion/discursos/35563-el-presidente-mauricio-macri-anuncio-modificaciones-en-el-impuesto-a-las-ganancias-y-asignaciones-familiares" ~ ymd('2016-02-18'),
          url == 'https://www.casarosada.gob.ar/informacion/discursos/36233-palabras-del-presidente-mauricio-macri-anunciando-medidas-de-apoyo-a-las-pymes' ~ ymd('2022-11-30'),
         ),
          
        date = coalesce(date_fix, date_fix_two, fix_dates_three)) |>
  select(-contains('fix'))

clean_up_date |>
  filter(is.na(date))


write_csv(clean_up_date, 'argentina_statements.csv')
