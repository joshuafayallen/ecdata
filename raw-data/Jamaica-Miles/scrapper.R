library(tidyverse)
library(rvest)

links = read_csv('jamaica_links.csv')




scrapper = \(links, agent = 'for questions please contact rcarlin@gsu.edu'){

  intro = polite::bow(links, paste(agent))

  subject = read_html(links) |>
  html_element('div.col-xs-12.col-sm-12.col-md-8.col-lg-8 > div > header > h1') |>
  html_text() |>
  as_tibble() |>
  rename(subject = value)

date = read_html(links) |>
  html_element('.posted-on a time') |>
  html_text() |>
  as_tibble() |>
  rename(date = value)



text = read_html(links) |>
  html_elements('.container p') |>
  html_text() |>
  as_tibble() |>
  rename(text = value)
  
  bound_dat = bind_cols(subject, text, date, url = links)

  cat('Done scraping:', links, '\n')

  Sys.sleep(5)


return(bound_dat)
}

pos_scrapper = possibly(scrapper)

jamaica_statements = map(links$links, \(x) pos_scrapper(x))

rescrapes = which(lengths(jamaica_statements) == 0)

bound = jamaica_statements |>
  list_rbind()



parse_dates = bound |>
  mutate(date = mdy(date))

write_csv(parse_dates, 'jamaica_statements.csv')
