library(rvest)
library(tidyverse)

base = 'https://www.stjornarradid.is/efst-a-baugi/frettir/$LisasticSearch/Search/?SearchQuery=&ContentTypes=&Themes=&Ministries=Fors%C3%A6tisr%C3%A1%C3%B0uneyti%C3%B0&Year=&PageIndex='

links = tibble(url = paste0(base, seq(0,5,1), '&SortByDate=True'))



get_links = \(links){

  session = read_html_live(links)
  
 links = session |>
  html_elements('#main .news-overview__search-table.top.container a') |>
  html_attr('href') |>
  as_tibble() |>
  mutate(fixed_links = paste0('https://www.stjornarradid.is', value)) |>
  select(links = fixed_links)
  

  Sys.sleep(5)

  return(links)
  
  
  
}

all_links = map(links$url, \(x) get_links(x))

all_links |>
  list_rbind() |>
    filter(!links %in% c("https://www.stjornarradid.is/askriftir/", 'https://www.stjornarradid.is/efst-a-baugi/eldri-frettir/')) |>
  write_csv('icelandic_links.csv')

bound_links = list_rbind(all_links) |>
  ## get rid of subscription links
  filter(!links %in% c("https://www.stjornarradid.is/askriftir/", 'https://www.stjornarradid.is/efst-a-baugi/eldri-frettir/'))




get_text = \(links){
  
  date = read_html(links) |>
  html_element('.news-startdate') |>
  html_text() |>
  as_tibble() |>
    rename(date = value)


subject = read_html(links) |>
  html_element('.big-heading') |>
  html_text() |>
  as_tibble() |>
  rename(subject = value)

text = read_html(links) |>
  html_elements('.single-news__content p') |>
  html_text() |>
  as_tibble() |>
  rename(text = value)
  
 bound_dat = bind_cols(date, subject, text, url = links)
 
  
 Sys.sleep(5)
  
cat('Done Scraping:', links, '\n')
  
return(bound_dat)
  
}

links = read_csv('icelandic_links.csv')



poss_get_text = possibly(get_text)


full_statements = map(links$links, \(x) poss_get_text(x))

rescrape = links |>
  mutate(id = row_number())

errors = which(lengths(full_statements) == 0)

links_dat = rescrape |>
  filter(id == 315)

rescraped = get_text(links_dat$links)

bound_data = full_statements |>
  list_rbind() |>
  bind_rows(rescraped)

parse_dates = bound_data |>
  mutate(date = dmy(date, locale = 'is_IS'))


write_csv(parse_dates, 'iceland_statements_in_icelandic.csv')


