pacman::p_load(rvest, tesseract, tabulizer, pdftools, tidyverse)



base_url = 'https://www.presidencia.gob.ec/discursos/#'


#collapse123 > div > ul > li:nth-child(1) > a
#collapse123 > div > ul > li:nth-child(1) > a

get_pdf_links = read_html(base_url) |> 
  html_elements('a') |>
  html_attr('href') |> 
  as_tibble() 


just_pdfs = get_pdf_links |> 
  filter(str_detect(value, 'pdf')) |> 
  ## lets just use a lookbehind
  mutate(text_after = sub(".*/[^-]+-[^-]+-(.*)\\.pdf$", "\\1", value),
         name_nice = paste0("pdfs/",str_to_lower(text_after),".pdf")) 


download.file(just_pdfs$value, just_pdfs$name_nice,
              mode = "wb", method = "auto")


map2(just_pdfs$value, just_pdfs$name_nice, \(url, name) download.file(url, name,
                                                                      mode = 'wb',
                                                                      method = 'auto'))



pdf_files = list.files('pdfs', full.names = TRUE, recursive = TRUE)

get_pdf_txt = function(pdfs_in){
  raw_dat = tibble(raw_text = pdf_text(pdfs_in),
                   file_name = pdfs_in)
  
  return(raw_dat)
  
}


pdf_dat = map_df(pdf_files, get_pdf_txt)


## this is a little bit to aggressive 
get_paragraphs = pdf_dat |> 
  separate_longer_delim(raw_text, delim = "\n\n") |> 
  mutate(raw_text = str_squish(raw_text))  |> 
  filter(nchar(raw_text) > 1) |> 
  mutate(date = dmy(raw_text, locale = 'es_ES.UTF-8'))

get_dates = get_paragraphs |> 
  group_by(file_name) |>
  slice(2) |> 
  ungroup() |> 
  mutate(date = dmy(raw_text, locale = 'es_ES.UTF-8'),
         date = as.character(date),
         date = case_when(file_name == "pdfs/con-dignidad.pdf" ~ "2023-12-22",
                          file_name == "pdfs/convenios-mies-gad.pdf" ~ "2024-02-09",
                          file_name == "pdfs/de-seguridad-salinas.pdf" ~ "2024-02-23",
                          file_name == "pdfs/para-aprender-y-emprender.pdf" ~ "2024-01-04",
                          file_name == "pdfs/alto-mando-militar.pdf" ~ "2023-11-30",
                          .default = date),
         year = year(date)) |> 
  select(date, file_name)

add_dates = get_paragraphs |> 
  left_join(get_dates, join_by(file_name)) |> 
  mutate(type_of_communication = 'speech' )

write_csv(add_dates, here::here("text_data", "ecuador_speeches.csv"))

combo_links = list.files(path = "text_data", pattern = "*.csv", full.names = TRUE)


all_dat = map(combo_links, read_csv) |> 
  list_rbind() |> 
  mutate(pdf_ind = ifelse(!is.na(file_name), "From a Pdf", "From a Webpage"),
         url = ifelse(pdf_ind == "From a Pdf", 'https://www.presidencia.gob.ec/discursos/', url)) 


write_csv(all_dat, here::here("text_data", "ecuador_speeches_combined.csv"))






