library(rvest)
library(tidyverse)

links = read_csv('georgia_links_georgian.csv')

test = links$links[1]

text = read_html(test) |>
  html_elements('.article-single-content p') |>
  html_text()

scrapper = \(links){
  text = read_html(links) |>
    html_elements('.article-single-content p') |>
    html_text() |>
    as_tibble() |>
    mutate(url = links) |>
    rename(text = value)


  cat('Done scraping:', links, '\n')
  Sys.sleep(5)

  return(text)
  
}

test_vec = links |>
  slice_sample(n =5)


datas = map_dfr(test_vec$links, \(x)  scrapper(x))

polite::bow(links$links[1])

pos_scrapper = possibly(scrapper)

georgian_dat = map(links$links, \(x) pos_scrapper(x))

which_rescrapes = which(lengths(georgian_dat) == 0)

rescrape_these = links |>
  mutate(id = row_number()) |>
  filter(id %in% which_rescrapes)

rescraped_dat = map(rescrape_these$links, \(x) scrapper(x))




bind_georgia = georgian_dat |>
  list_rbind()


bind_rescrape = rescraped_dat |>
  list_rbind() |>
  bind_rows(bind_georgia)


parse_dates = bind_rescrape |>
  left_join(links, join_by(url == links)) |>
  select(text, date = dates, title = subject, url) |>
  mutate(title = str_squish(title),
         date = dmy(date))

write_csv(parse_dates, 'georgia_statements_georgia.csv')


parse_dates |>
  filter(is.na(date))
