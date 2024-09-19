library(rvest)
library(polite)
library(tidyverse)

## lets be absolutely sure about this 
## I don't entirely trust this 

links = read_csv('manual_fix_to_links.csv') |>
  mutate(url = coalesce(url, fixed_url)) |>
  select(-title)

president = '/html/body/div[2]/div[4]/div/section/div/section/div/div/div[1]/div[1]/div/div[2]/h3/a'

dir.create('temp-dat')


get_statements = function(links_to_scrape){

    cat(links_to_scrape, "is being scraped", "\n")
    session = bow(url = links_to_scrape, user_agent = "Please Contact Ryan Carlin at rcarlin@gsu.edu with questions or concerns")
    
    raw_text = read_html(links_to_scrape) |> 
      html_elements('.field-docs-content p') |> 
      html_text() |>
      as_tibble() |> 
      rename(text = value)
    
    raw_date = read_html(links_to_scrape) |> 
      html_elements('.field-docs-start-date-time') |> 
      html_text() |> 
      as_tibble() |> 
      rename(date = value)
    
    raw_pres_name = read_html(links_to_scrape) |> 
      html_elements(xpath = president) |> 
      html_text() |> 
      as_tibble() |> 
      rename(president = value)
    
    subject_of_message = read_html(links_to_scrape) |>
      html_elements('h1') |> 
      html_text() |> 
      as_tibble() |> 
      rename(title = value)
     
    output_data = bind_cols(raw_date, raw_pres_name , subject_of_message, raw_text, url = links_to_scrape) 
    write_csv(output_data, 'temp-dat/data_during_scrape.csv', append = TRUE)

    Sys.sleep(10)
    return(output_data)
    
      
}


pos_scrap = possibly(get_statements)
check = pos_scrap(links$fixed_url[1])

## i just commented and un commented the line that rewrites the csv
write_csv(check, 'temp-dat/data_during_scrape.csv')


test_dat = links_dat |>
  slice_sample(n = 5) |>
  pull('url')

check = map(test_dat, \(x) pos_scrap(x))

bound = list_rbind(check)

import_data = read_csv('temp-dat/data_during_scrape.csv') |>
  distinct(url) |>
  pull('url')

scraping_links = links_dat |>
  filter(!url %in% import_data) |>
  pull(url)

rescraped_statements = map(scraping_links, \(x) pos_scrap(x))

needs_rescrape = which(lengths(rescraped_statements) == 0)

make_links_dat = scraping_links = links_dat |>
  filter(!url %in% import_data) 

needs_rescrapes = make_links_dat |>
  mutate(id = row_number()) |>
  filter(id %in% needs_rescrape)

rescrapes = map(needs_rescrapes$url, \(x) get_statements(x))

## so the data is a littl
## but since we did the rescrape it binded that data to the data frame 

read_in = read_csv('temp-dat/data_during_scrape.csv')

parse_dates = read_in |>
  mutate(date = str_squish(date),
        date = mdy(date))


write_csv(parse_dates, 'fixed_usa_statements.csv')









