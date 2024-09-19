library(rvest)
library(tidyverse)


links_data = read_csv('current_hungarian_links.csv')

test = links_data$links[1]


text = read_html(test) |>
  html_elements('.MsoNormal') |>
  html_text()

scrapper = \(links){

text = read_html(links) |>
  html_elements('.MsoNormal') |>
  html_text() |>
  as_tibble() |>
  rename(text = value) |>
  mutate(url = links)
  
  cat('Done Scraping:', links, '\n')

  Sys.sleep(5)
  
  return(text)


}


pos_scrapper = possibly(scrapper)

hungarian_statements = map(links_data$links, \(x) pos_scrapper(x))

which_rescrape = which(lengths(hungarian_statements) == 0)

links_to_scrape = links_data |>
  mutate(id = row_number()) |>
  filter(id %in% which_rescrape)

rescraped_data = map_dfr(links_to_scrape$links, \(x) scrapper(x))

## this link 404ed https://kormany.hu/hirek/orban-viktor-zsido-ujevi-uzenete-most-meg-nagyobb-szuksegunk-van-a-hagyomanyainkra
links_to_scrape$links[1]


bound_hungary = hungarian_statements |>
  list_rbind()

add_in_rest = bound_hungary |>
  left_join(links_data, join_by(url == links)) |>
  separate_wider_delim(date, delim = ',', names_sep = '_') |>
  mutate(date = ymd(date_1)) |>
  select(-c(date_1, date_2))

glimpse(add_in_rest)

write_csv(add_in_rest, 'current_hungary_statements.csv')
