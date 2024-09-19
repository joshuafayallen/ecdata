library(rvest)
library(tidyverse)

raw_dat = read_csv('portugal_pm_release.csv')

parse_dates = raw_dat |>
  mutate(date = str_squish(date), 
        date = str_extract_all(date, '\\d{4}-\\d{2}-\\d{2}')) |>
  unnest_longer(date) |>
  mutate(date = ymd(date))


links_dat = read_csv('portugal_pm_links.csv')

polite::bow(test)


scrapper = \(links){

  subject = read_html(links) |>
    html_element('.title') |>
    html_text() |>
    as_tibble() |>
    mutate(url = links) |>
    rename(title = value)

cat('Done Scraping:', links, '\n')
  
  Sys.sleep(5)

  return(subject)


}

links_dat |>
  slice_sample(n=5) |>
  pull('links') %>%
  map(. ,.f = scrapper) -> test


test |>
  list_rbind()

parse_dates |>
  select(title) |>
  head()

### okay these look mostly the same 

pos_scrapper = possibly(scrapper)

links_dat = map(links_dat$links, \(x) pos_scrapper(x))

## you accidently overwrote the names space 
links_scrape = read_csv('portugal_pm_links.csv')

bound_portugal = links_dat |>
  list_rbind()

rescrapes = which(lengths(links_dat) == 0)

rescrape_these = links_scrape |>
  mutate(id = row_number()) |>
  filter(id %in% rescrapes)

rescraped = map(rescrape_these$links, \(x) scrapper(x))

bound_rescraped = list_rbind(rescraped) |>
  bind_rows(bound_portugal)



raw_dat$title[1]

joined_data = raw_dat |>
  left_join(bound_rescraped, join_by(title), multiple = 'first')


write_csv(joined_data, 'portugal_statements_add_urls.csv')
