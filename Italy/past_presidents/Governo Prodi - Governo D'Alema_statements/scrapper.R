library(rvest)
library(tidyverse)

links_data = read_csv('links.csv')



scrapper = \(links){
  subject = read_html_live(links) |> 
  html_elements('body > blockquote > h1') |> 
  html_text() |> 
  as_tibble()  |> 
  mutate(value = str_squish(value)) |> 
  separate_wider_delim(cols = value, names = c('subject', 'date'), delim = '- ')

text = read_html_live(links) |> 
  html_elements('p') |> 
  html_text() |> 
  as_tibble() |> 
  rename(text = value)
  
  bound_data = bind_cols(subject, text)

  cat('Done Scrapping:', links, '\n')

  Sys.sleep(runif(1, 5, 8))

  return(bound_data)
  

}


prodi_alema = map(links_data$url, \(x) scrapper(x))

bound_data = prodi_alema |> 
  list_rbind() |> 
  mutate(date = dmy(date))

dir.create('data')


write_csv(bound_data, 'prodi_alema_statements.csv')
