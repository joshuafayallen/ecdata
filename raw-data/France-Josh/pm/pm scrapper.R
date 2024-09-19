## 

pacman::p_load(tidyverse, rvest, polite, httr)

base_url = 'https://www.gouvernement.fr/suivre-l-actualite-du-premier-ministre'

additions = "?page="

links_df = tibble(links = paste0(base_url, additions,seq(1,27,1))) 

links_vec = links_df |> 
  deframe()


bow(base_url)


test_links = read_html(test_links[1]) |> 
  html_elements('.fr-card__link') |> 
  html_attr("href") |> 
  as_tibble() |> 
  rename(links = value) 

subject_links = read_html(test_links[1]) |> 
  html_elements('.fr-card__link') |> 
  html_text()|>
  str_squish() |> 
  as_tibble() |> 
  rename(subject = value)

date = read_html(test_links[1]) |> 
  html_elements('.fr-card__end') |> 
  html_text() |> 
  str_squish() |> 
  as_tibble() |> 
  rename(date = value)

pm_link_scrapper = function(links){
  
  check_status = GET(links)
  
  introduce = bow(links, user_agent = "For any questions please contact Ryan Carlin \n
                   at rcarlin@gsu.edu")
  
  link_status = status_code(check_status)
  
  sleepy_time = sample(10:15, 1)
  
  cat("scraping", links, "going to sleep for", sleepy_time, "before scraping", "\n")
  
  Sys.sleep(sleepy_time)
  
  
  if(link_status != 200){
    
    bad_link = links
    
    error_link_df = tibble(links = NA)
    
    error_link_df = rbind(error_link_df, bad_link)
    
    return(error_link_df)
    
  } else{
    
    urls_scrape = read_html(links) |> 
      html_elements('.fr-card__link') |> 
      html_attr("href") |> 
      as_tibble() |> 
      rename(links = value) 
    
    
    subject = read_html(links) |> 
      html_elements('.fr-card__link') |> 
      html_text()|>
      as_tibble() |> 
      mutate(value = str_squish(value)) |> 
      rename(subject = value)
    
    date = read_html(links) |> 
      html_elements('.fr-card__end') |> 
      html_text() |> 
      str_squish() |> 
      as_tibble() 
    
    
    page_df = bind_cols(urls_scrape, subject, date)
    
    return(page_df)
    
  }
  
  
}

test_links = links_df |> 
  slice_sample(n = 5) |> 
  deframe()

test_dat = map(test_links, \(x) pm_link_scrapper(links = x))


look_at_test = list_rbind(test_dat)  |> 
  mutate(date = str_replace_all(value, "Publié", " "),
         date = str_squish(date),
         date = dmy(date),
         year_statement = year(date))

look_at_test |> 
  filter(links == '/actualite/11724-france-relance-declaration-de-jean-castex-a-l-usine-pavatex-de-golbey-dans-les-vosges')




links_dat = map(links_vec, \(x) pm_link_scrapper(links = x))



full_links_dat = links_dat |> 
  list_rbind() |> 
  mutate(date = str_replace_all(value, "Publié", " "),
                date = str_squish(date),
                date = dmy(date),
                year_statement = year(date)) |> 
  arrange(desc(year_statement))


table(full_links_dat$year_statement)


text_links = full_links_dat |> 
  mutate(links_scrape = paste0("https://www.gouvernement.fr", links))


test_dat = read_html(text_links[[1,6]]) |> 
  html_elements('.fr-modal__content p') |> 
  html_text() |> 
  as_tibble()


write_csv(text_links, "pm-links-scrape.csv")

## okay it looks like some of the links just have videos
## what we should do is deal with what we can scrape 
## than find a way around that later 
## lets scrape the transcription boxes
## then lets just look for partage hrefs 


text_scrapper = function(links){
  
  check_status = GET(links)
  
  introduce = bow(links, user_agent = "For any questions please contact Ryan Carlin \n
                   at rcarlin@gsu.edu")
  
  link_status = status_code(check_status)
  
  sleepy_time = sample(10:15, 1)
  
  cat("scraping", links, "going to sleep for", sleepy_time, "before scraping", "\n")
  
  Sys.sleep(sleepy_time)
  
  
  if(link_status != 200){
    
    bad_link = links
    
    error_link_df = tibble(links = NA)
    
    error_link_df = rbind(error_link_df, bad_link)
    
    return(error_link_df)
    
  } else{
    
    transcription_texts = read_html(links) |> 
      html_elements('.fr-modal__content p') |> 
      html_text() |> 
      as_tibble() |> 
      rename(text = value)
    
   
    
    
   return(transcription_texts)
   

  }
  
}

test_data = text_links |> 
  slice_sample(n = 5) |> 
  select(links_scrape) |> 
  deframe()

text_links_vec = text_links |> 
  select(links_scrape) |> 
  deframe()


poss_text = possibly(text_scrapper)

statements_text = map(text_links_vec, poss_text)

statements_df = statements_text |> 
  list_rbind()


## to avoid recyling warnings lets just go through each link 
## and check for link to statements 
## then scrape thoe 

links_scrape_arts = function(links){
  check_status = GET(links)
  
  introduce = bow(links, user_agent = "For any questions please contact Ryan Carlin \n
                   at rcarlin@gsu.edu")
  
  link_status = status_code(check_status)
  
  sleepy_time = sample(10:15, 1)
  
  cat("scraping", links, "going to sleep for", sleepy_time, "before scraping", "\n")
  
  Sys.sleep(sleepy_time)
  
  
  if(link_status != 200){
    
    bad_link = links
    
    error_link_df = tibble(links = NA)
    
    error_link_df = rbind(error_link_df, bad_link)
    
    return(error_link_df)
    
  }
  else{
    url_links = read_html(links) |> 
           html_elements('.fr-col a') |> 
           html_attr('href') |> 
           as_tibble() |> 
      rename(links = value) |> 
      filter(str_detect(links, "partage"))
    
    return(url_links)
  
  }
}

links_of_statements = map(text_links_vec, links_scrape_arts)


bind_statements_links = list_rbind(links_of_statements) |> 
  mutate(fixed_links = ifelse(str_detect(links, "https", negate = TRUE),
                              paste0("https://www.gouvernement.fr", links),
                              links))


statements_links_vec = bind_statements_links$fixed_links


get_text_one = read_html(statements_links_vec[1]) |> 
  html_elements('.fr-col') |> 
  html_text() |> 
  as_tibble() 

get_date_one = read_html(statements_links_vec[1]) |> 
  html_elements('.fr-text--bold') |> 
  html_text() |> 
  as_tibble()
  
bind_statements_data = bind_cols(get_text_one, get_date_one)

link_two = sample(statements_links_vec[-1], 1)

get_text_two = read_html(link_two) |> 
  html_elements('.fr-col') |> 
  html_text() |> 
  as_tibble() 

get_date_two = read_html(link_two) |> 
  html_elements('.fr-text--bold') |> 
  html_text() |> 
  as_tibble()

bind_statements_data_two = bind_cols(get_text_two, get_date_two)

### Okay it looks like this is fine 

statements_from_pm_two = function(links){
  check_status = GET(links)
  
  introduce = bow(links, user_agent = "For any questions please contact Ryan Carlin \n
                   at rcarlin@gsu.edu")
  
  link_status = status_code(check_status)
  
  sleepy_time = sample(10:15, 1)
  
  cat("scraping", links, "going to sleep for", sleepy_time, "before scraping", "\n")
  
  Sys.sleep(sleepy_time)
  
  
  if(link_status != 200){
    
    bad_link = links
    
    error_link_df = tibble(links = NA)
    
    error_link_df = rbind(error_link_df, bad_link)
    
    return(error_link_df)
    
  } else{
    
    get_text= read_html(links) |> 
      html_elements('.fr-col') |> 
      html_text() |> 
      as_tibble() |> 
      rename(text = value)
    
    get_date = read_html(links) |> 
      html_elements('.fr-text--bold') |> 
      html_text() |> 
      as_tibble() |> 
      rename(date = value)
    
    scraped_states_df = bind_cols(get_text, get_date, url = links)
    
    return(scraped_states_df)
    
  }
  
  
}

bow(statements_links_vec[1])


statements_data_two = map(statements_links_vec, statements_from_pm_two)

bounded_statements_pm = statements_data_two |> 
  list_rbind() |> 
  mutate(date = str_replace_all(date, "Publié", " "),
         date = str_squish(date))


write_csv(bounded_statements_pm, "statments_from_embedding_links.csv")

