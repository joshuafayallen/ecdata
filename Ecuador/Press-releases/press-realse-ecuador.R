pacman::p_load(polite, rvest, tidyverse)


url = 'https://gobiernodanilomedina.do/noticias'

# #block-presidency-content > div > div > div.view-content.row > div:nth-child(4) > a



test = read_html(url) |> 
  html_elements('.field-content a') |> 
  html_attr('href') |> 
  as_tibble()

#block-presidency-content > div > div > div.view-content.row > div:nth-child(1) > div.field-content.span-date

base_data = tibble(link = url)

simmed_links = tibble(link = paste0(url,"?","page=", seq(1,538, by=1)))

extracting_links = bind_rows(base_data, simmed_links) |> 
  mutate(page_number = str_extract(link, "\\d+"),
         page_number = paste0("page", page_number)) 

bow(url)

link_scrapper = \(links, user_agent = NULL){
  if(is.null(user_agent)){
    stop("Please provide a user agent")
  } else{
    bow(links, user_agent = user_agent)
    
    links_data = read_html(links) |> 
      html_elements('.field-content a') |> 
      html_attr('href') |> 
      as_tibble()
    
    base_data = tibble(links_data, url = links) |> 
      mutate(page_number = str_extract(url, "\\d+"),
             page_number = paste("page", page_number)) 
    
    page_numb = base_data |> 
      distinct(page_number) |>
      pluck('page_number')
    
    cat("Done Scraping", page_numb, "Pausing For 5 + seconds", "\n")
    
    Sys.sleep(sample(5:8,1))
    
    return(base_data)
      }
}

testing_links = extracting_links |> 
  slice_sample(n = 5) |> 
  pluck('link')

testing_fun = map(testing_links, \(x) link_scrapper(x, user_agent = "For questions please contact Ryan Carlin at rcarlin@gsu.edu"))


check_data = testing_fun |> 
  list_rbind()

links_dat = map(extracting_links$link, \(x) link_scrapper(x,
                                  user_agent = "For questions please contact Ryan Carlin at rcarlin@gsu.edu"))


links_scraped = links_dat |> 
  list_rbind()

dir.create("links_data")

write_csv(links_scraped, "links_data/links_scraped.csv")


links_to_scrape = read_csv(here::here("links_data", "links_scraped.csv")) 

fixed_links = links_to_scrape |> 
  mutate(fixed_link = paste0("https://gobiernodanilomedina.do", value))


dates_dat = read_html(fixed_links$fixed_link[1]) |> 
  html_elements('.content-date') |> 
  html_text() |> 
  as_tibble()


header_dat = read_html(fixed_links$fixed_link[1]) |> 
  html_elements('.head-article h2') |> 
  html_text() |> 
  as_tibble()


text_body = read_html(fixed_links$fixed_link[1]) |> 
  html_elements('.main-content-article  p') |> 
  html_text() |> 
  as_tibble()


text_scraper = \(links, user_agent = NULL){
  if(is.null(user_agent)){
    stop("Please provide a user agent")
  } else{
    bow(links, user_agent = user_agent)
    
    dates_dat = read_html(links) |> 
      html_elements('.content-date') |> 
      html_text() |> 
      as_tibble() |> 
      rename(date = value)
    
    header_dat = read_html(links) |> 
      html_elements('.head-article h2') |> 
      html_text() |> 
      as_tibble() |> 
      rename(subject = value)
    
    text_body = read_html(links) |> 
      html_elements('.main-content-article  p') |> 
      html_text() |> 
      as_tibble() |> 
      rename(text = value)
    
    base_data = tibble(dates_dat, header_dat, text_body, url = links)
    

    
    cat("Done Scraping", links, "Pausing For 5 + seconds", "\n")
    
    Sys.sleep(sample(5:8,1))
    
    return(base_data)
  }
}


testing_links = fixed_links |> 
  slice_sample(n = 5) |> 
  pluck('fixed_link')

our_user_agent = "For questions please contact Ryan Carlin at rcarlin@gsu.edu"


testing_fun = map(testing_links, \(x) text_scraper(x, user_agent = our_user_agent))

check_dat = testing_fun |> 
  list_rbind()

pos_text_scrapper = possibly(text_scraper)

text_dat = map(fixed_links$fixed_link, \(x) pos_text_scrapper(x, user_agent = our_user_agent))

bound_text_dat = text_dat |> 
  list_rbind()

fixed_text_dat = bound_text_dat |> 
  mutate(fixed_date = str_remove_all(date, "\\|\\s*\\d+|\\:\\d+"),
         fixed_date = dmy(fixed_date, locale = "es_ES.UTF-8")) |> 
  select(-date) |>
  rename(date = fixed_date)

dir.create("text_data")

write_csv(fixed_text_dat, "text_data/ecuador_statements.csv")


library(tidyverse)
raw_dat = read_csv(here::here("text_data", "ecuador_statements.csv"))

addind = raw_dat |> 
  mutate(type_of_communication = "Press Release") |> 
  rename(url = source, 
         title = subject)


write_csv(addind, "text_data/ecuador_statements.csv")




