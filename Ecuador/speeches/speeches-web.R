pacman::p_load(rvest, polite, tidyverse)


base_url = 'https://gobiernodanilomedina.do/discursos'



bow(base_url)

get_urls_page_one = read_html(base_url) |> 
  html_elements('.field-content a') |> 
  html_attr('href') |> 
  as_tibble() |> 
  rename(url = value)

get_dates_page_one = read_html(base_url) |> 
  html_elements('div.field-content.span-date') |> 
  html_text() |> 
  as_tibble() |> 
  rename(date = value)

full_page_one = cbind(get_dates_page_one, get_urls_page_one)



get_urls_page_two = read_html('https://gobiernodanilomedina.do/discursos?page=1') |> 
  html_elements('.field-content a') |> 
  html_attr('href') |> 
  as_tibble() |> 
  rename(url = value)

get_dates_page_two = read_html('https://gobiernodanilomedina.do/discursos?page=1') |> 
  html_elements('div.field-content.span-date') |> 
  html_text() |> 
  as_tibble() |> 
  rename(date = value)

full_page_two = cbind(get_dates_page_two, get_urls_page_two)

full_dat = bind_rows(full_page_one, full_page_two)




make_links = full_dat |> 
  mutate(fixed_url = paste0('https://gobiernodanilomedina.do', url))



#block-presidency-content > div > article > div > div.article-content > h2.h2 > span
get_subject = read_html(make_links[[1,3]]) |> 
  html_elements('div.article-content') |> 
  html_text()  |> 
  as_tibble()
  

get_text = read_html(make_links[[1,3]]) |> 
  html_elements('.main-content-article p') |> 
  html_text() |> 
  as_tibble() 

## lets not screw around with making paragraphs 


text_scrapper = \(links, user_agent = NULL){
  if(is.null(user_agent)){
    stop('Please provide a user agent')
  } else{
    
    bow(links, user_agent = user_agent)
    
    get_subject = read_html(links) |> 
      html_elements('div.article-content') |> 
      html_text()  |> 
      as_tibble() |> 
      rename(subject = value)
    
    get_text = read_html(links) |>
      html_elements('.main-content-article p') |> 
      html_text() |> 
      as_tibble() |> 
      rename(text = value)
    
    full_text = tibble(get_subject, get_text,
                       url = links)
    
    cat("Done Scraping", links, 'pausing for 5+ seconds', "\n")
    
    
    Sys.sleep(sample(5:8, 1))
    
    return(full_text)
    
  }
}


test_links = make_links |> 
  slice_sample(n = 5) |> 
  pull('fixed_url')

user_agent = 'For questions please contact Ryan Carlin at rcarlin@gsu.edu'

test_fun = map(test_links, \(x) text_scrapper(x, user_agent = user_agent)) 


check= test_fun |> 
  list_rbind()


glimpse(check)

speech_list = map(make_links$fixed_url, \(x) text_scrapper(x, user_agent = user_agent)) 

speech_dat = speech_list |> 
  list_rbind()

just_date = make_links |> 
  select(date, fixed_url)


joined_data = speech_dat |> 
  left_join(just_date, join_by(url == fixed_url)) |> 
  mutate(fixed_date = dmy(date, locale = "es_ES.UTF-8"),
         type_of_communication = 'speech') |> 
  select(-date) |>
  rename(date = fixed_date)

write_csv(joined_data, here::here("text_data", "speech_data.csv"))





