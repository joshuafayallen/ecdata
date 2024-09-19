library(tidyverse)
library(rvest)

## ugh no links 
raw_dat = read_csv('hungary_statements_hu.csv')


links = read_csv('hungary_links.csv')

## we need a scrapper anyway 

text = read_html(links$links[1]) |>
  html_elements('.article-content p') |>
  html_text2()

## okay roughly what we are looking for
make_pars = text |>
  as_tibble() |>
  separate_longer_delim(value, delim = '\n\n')


date = read_html(links$links[1]) |>
  html_elements('#Content > div.article-head.clr > h4') |>
  html_text()

subject = read_html(links$links[1]) |>
  html_elements('#Content > div.article-head.clr > h1') |>
  html_text()


scrapper = \(links, user_agent = 'For questions please contact rcarlin@gsu.edu'){
   intro = polite::bow(links, paste(user_agent))
  
   text = read_html(links) |>
    html_elements('.article-content p') |>
    html_text2() |>
    as_tibble() |>
    separate_longer_delim(value, delim = '\n\n') |>
     rename(text = value)
  
  
  date = read_html(links) |>
    html_elements('#Content > div.article-head.clr > h4') |>
    html_text() |>
    as_tibble() |>
    rename(date = value)
  
  subject = read_html(links) |>
    html_elements('#Content > div.article-head.clr > h1') |>
    html_text() |>
    as_tibble() |>
    rename(subject = value)

  bound_dat = bind_cols(date, subject, text, urls = links)

  cat('Done Scraping:', links, '\n')

  Sys.sleep(sample(5:8,1))

  return(bound_dat)

}

test = links |>
  slice_sample(n = 5)

test_two = map(test$links, \(x) scrapper(links = x))

test_two |>
  list_rbind() -> check


statement_data = map(links$links, \(x) scrapper(x))

bound_statements = statement_data |>
  list_rbind()

parse_dates = bound_statements |>
  mutate(date_fix = parse_date_time(date, "Y. B d. H:M" ,locale =  "hu_HU"),
         date = as_date(date_fix)) |>
  select(-date_fix)

write_csv(parse_dates, 'hungarian_statements.csv')

## this is the 2015-2019 data 

base = 'https://2015-2019.kormany.hu/hu/a-miniszterelnok/hirek?page='


make_links = tibble(links = paste0(base, seq(1, 193,1)))

#ListArticles > div:nth-child(1) > h2 > a
test = read_html_live(make_links$links[1]) |>
  html_elements('#ListArticles .article h2 a') |>
  html_attr('href')


get_links = \(links){

  links_dat = read_html_live(links) |>
    html_elements('#ListArticles .article h2 a') |>
    html_attr('href') |>
    as_tibble() |>
    rename(link = value)

  cat('Done Scraping:', links, '\n')

  Sys.sleep(5)


  return(links_dat)
}


pos_scrapper = possibly(get_links)

get_links(make_links$links[2])

pos_scrapper(make_links$links[1])

links_2015 = map(make_links$links, \(x) pos_scrapper(x))

bound = list_rbind(links_2015) |>
  mutate(fixed_links = paste0('https://2015-2019.kormany.hu/', link))

bound |>
  write_csv('2015_hungary_links.csv')


test = bound$fixed_links[1]


pos_scrapper = possibly(scrapper)

twnty_fifteen_statements = map(bound$fixed_links, \(x) pos_scrapper(x))

these_need_rescrapes = which(lengths(twnty_fifteen_statements) == 0)

add_ids = bound |>
  mutate(id = row_number()) |>
  filter(id %in% these_need_rescrapes)

rescrape_deez = map(add_ids$fixed_links, \(x) scrapper(x))

bind_all = list_rbind(twnty_fifteen_statements)

bind_small = list_rbind(rescrape_deez)

all_togther = bind_rows(bind_all, bind_small) |>
  mutate(
  date_fix = parse_date_time(date, "Y. B d. H:M" ,locale =  "hu_HU"),
  date = as_date(date_fix)) |>
  select(-date_fix) |>
  rename(title = subject,
         url = urls)

write_csv(all_togther, '2015-2019-statements.csv')




