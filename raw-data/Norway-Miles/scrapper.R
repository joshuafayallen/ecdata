library(tidyverse)
library(rvest)

links = 'https://www.regjeringen.no/no/aktuelt/nyheter/id2006120/?ownerid=875&term=&page='

links_dat = tibble(urls = paste0(links, seq(1,41,1)))


scrapper = \(links){

link = read_html(links) |>
  html_elements('.title a') |>
  html_attr('href') |>
  as_tibble() |>
  rename(link = value) 
  
 subject = read_html(links) |>
  html_elements('.title a') |>
  html_text() |>
  as_tibble() |>
  rename(title = value)
  
type = read_html(links) |>
  html_elements('.info .type') |>
  html_text() |>
  as_tibble() |>
  rename(type = value)
  
bound = bind_cols(link, type, subject)

cat('Done scraping:', links, '\n')
  
Sys.sleep(5) 
  
  

return(bound)

}


scrapper(links_dat$urls[1])

links_to_scrape = map(links_dat$urls, \(x) scrapper(x))

links_bound = links_to_scrape |>
  list_rbind()

links_bound$link[1]

#mainContent > div > div.content-row.article > div > header

fix_links = links_bound |>
  mutate(link = paste0('https://www.regjeringen.no', link))


text = read_html(fix_links$link[1]) |>
  html_elements('.article-body p') |>
  html_text()


date = read_html(fix_links$link[1]) |>
  html_element('.article-info .date') |>
  html_text()

get_text = \(links){

  text = read_html(links) |>
  html_elements('.article-body p') |>
  html_text() |>
  as_tibble() |>
    rename(text = value)


date = read_html(links) |>
  html_element('.article-info .date') |>
  html_text() |>
  as_tibble() |>
  rename(date = value)
  
 bound = bind_cols(text, date, url = links) 
  
 cat('Done scraping:', links, '\n')
  
  Sys.sleep(5)
  
  return(bound)
  


}

get_text(fix_links$link[1])

pos_scrapper = possibly(get_text)

pos_scrapper(fix_links$link[1])


statements = map(fix_links$link, \(x) pos_scrapper(x))

rescrape = which(lengths(statements) == 0)

rescrape_these = fix_links |>
  mutate(id = row_number()) |>
  filter(id %in% rescrape)

rescraped_data = map(rescrape_these$link, \(x) pos_scrapper(x))

which(lengths(rescraped_data) == 0)

rescraped_bound = list_rbind(rescraped_data)

bound_statements = statements |>
  list_rbind()  |>
  bind_rows(rescraped_data)



joined_with_subject = bound_statements |>
  left_join(fix_links, join_by(url == link)) |>
  mutate(title = str_squish(title),
        date = dmy(date))



write_csv(joined_with_subject, 'norewegian_statements.csv')








