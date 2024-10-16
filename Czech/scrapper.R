library(rvest)
library(tidyverse)

raw_dat = read_csv('czech_statements.csv')

raw_links = read_csv('czech_links.csv')


czech_links_czech = tibble(links = paste0('https://vlada.gov.cz/scripts/detail.php?pgid=215&conn=1317&pg=', seq(1,208,1)))




links_scrapper = \(links, user_agent = 'For questions please contact Ryan Carlin at rcarlin@gsu.edu'){
  ag = rlang::englue('{user_agent}')
  
  intro = polite::bow(links, user_agent = ag)

  links_dat = read_html(links) |>
  html_elements('#content .nomargin a') |>
  html_attr('href') |>
  as_tibble() |>
  mutate(links = paste0('https://vlada.gov.cz', value)) |>
  select(links)

date_dat = read_html(links) |>
  html_elements('#content .info') |>
  html_text() |>
  as_tibble() |>
  rename(date = value)
  
  bound_dat = bind_cols(links_dat, date_dat)

  cat('Done Scraping:', links, '\n')

  Sys.sleep(5)


  return(bound_dat)

}



poss_links = possibly(links_scrapper)

links_to_scrape = map(czech_links_czech$links, \(x) links_scrapper(x))

links_scraped = links_to_scrape |>
  list_rbind()



write_csv(links_scraped, 'czech_links_czech.csv')


scrapping_fun = \(links, user_agent = 'For questions please contact Ryan Carlin at rcarlin@gsu.edu'){
  ag = rlang::englue('{user_agent}')
  intro = polite::bow(links, ag)

  subject = read_html(links) |>
    html_elements('#content > div.content-main > h1' ) |>
    html_text()
  
    text = read_html(links) |>
      html_elements('#content .detail p') |>
      html_text()
     
  
 
  
  
  
  text_dat = tibble(subject = subject,
                    text = text,
                    url = links )
  
  cat('Done Scraping:', links, '\n')

  Sys.sleep(5)

  return(text_dat)


}


poss_scraping = possibly(scrapping_fun)

czech_data = map(links_scraped$links, \(x) poss_scraping(x))


needs_rescrape = which(lengths(czech_data) == 0)

rescrape_links = all_together |>
  mutate(id = row_number()) |>
  filter(id %in% needs_rescrape)

rescraped = map(rescrape_links$links, \(x) scrapping_fun(x))

bound_czech = czech_data |>
  list_rbind()

rescraped_dat = rescraped |>
  list_rbind() |>
  bind_rows(bound_czech) 

joined_data = rescraped_dat |>
  left_join(all_together, join_by(url == links), multiple = 'first') |>
  mutate(date = dmy(date)) 


fix_date_fun = \(links) {

text  = httr::GET(links, timeout = 30) |>
read_html() |>
html_elements(xpath = '//*[@id="content"]/div[1]/p/text()') |>
html_text()
  
return(text)
Sys.sleep(5)
}




write_csv(joined_data, 'czech_statements_scraped.csv')


fixing_dates = joined_data |>
  mutate(id = row_number(), .by = url) |>
  mutate(flag = ifelse(id == 1, url, NA))

fixed_dates = fixing_dates |>
  filter(!is.na(flag)) |>
  distinct(url) |>
  mutate(fix_dates = map_chr(url, \(x) fix_date_fun(x)))

add_missing = joined_data |>
  left_join(fixed_dates, join_by(url), multiple  = 'first') |>
  mutate(fix_dates = dmy(fix_dates),
         date = coalesce(date, fix_dates)) |>
  select(-fix_dates) |>
  separate_longer_delim(text, delim = '\n')




write_csv(add_missing, "czech_statements_czech.csv")


raw_data = read_csv('czech_statements_czech.csv')



