library(rvest)
library(tidyverse)


raw_dat = read_csv('azerbaijan_statements.csv')

links_dat = read_csv('azerbaijan_links.csv')




subject = read_html(links_dat$links[1]) |>
  html_elements('.news_heading') |>
  html_text()

text = read_html(links_dat$links[1]) |>
  html_elements('.news_paragraph-block p') |>
  html_text()



scrapper = \(links){

  subject = read_html(links) |>
    html_element('.news_heading') |>
    html_text() |>
    as_tibble() |>
    rename(title = value )

  date = read_html(links) |>
    html_elements('.news_date') |>
    html_text() |>
    as_tibble() |>
    rename(date = value)

  text = read_html(links) |>
    html_elements('.news_paragraph-block p') |>
    html_text() |>
    as_tibble() |>
    rename(text = value)

  all_together = bind_cols(date, subject, text, url = links) 

  cat('Done Scrapping', links, '\n')

  Sys.sleep(5)

  return(all_together)

}

poss_scrape = possibly(scrapper)

statement_data = map(links_dat$links, \(x) poss_scrape(x))

bound_dat = statement_data |>
  list_rbind() 

scrape_again = which(lengths(statement_data) == 0)

get_links = links_dat |>
  mutate(id = row_number()) |>
  filter(id %in% scrape_again)

rescraped = map(get_links$links, rescrape)

rs_dat = rescraped |>
  list_rbind() |>
    separate_wider_delim(date, delim = ',', names = c('date', 'time')) |>
      mutate(date = dmy(date)) |>
      select(-time)

fix_date = bound_dat |>
  separate_wider_delim(date, delim = ',', names = c('date', 'time')) |>
  mutate(date = dmy(date)) |>
  select(-time) |>
  bind_rows(rs_dat)



write_csv(fix_date, 'azerbaijain_statements_rescraped_use_this.csv')
