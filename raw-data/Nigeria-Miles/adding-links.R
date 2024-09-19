library(tidyverse)
library(rvest)

raw_dat = read_csv('nigeria_statements.csv')

links  = read_csv('nigeria_links.csv')

test = links$links[1]


title = read_html(test) |>
  html_element('.article__title.text-center .h2') |>
  html_text()

subject_scrapper = \(links){
  title = read_html(links) |>
  html_element('.article__title.text-center .h2') |>
  html_text() |>
  as_tibble() |>
    mutate(url = links) |>
    rename(title = value)

  cat('Done Scraping:', links, '\n')

  Sys.sleep(5)

  return(title)
}

subjects = map(links$links, \(x) subject_scrapper(x))

bound = subjects |>
  list_rbind()


add_links = raw_dat |>
  left_join(bound, join_by(title)) |>
  mutate(date = mdy(date))


write_csv(add_links, 'nigeria_statements.csv')
