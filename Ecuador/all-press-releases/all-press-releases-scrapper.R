pacman::p_load(rvest, polite, tidyverse)

url = 'https://www.comunicacion.gob.ec/noticias/page/'

url_tib = tibble(url = paste0(url, seq(0, 305,2), "/"))

#contenido-comunica > a:nth-child(1)

get_url = read_html(url_tib$url[2]) |> 
  html_elements('#contenido-comunica a') |> 
  html_attr('href') |>  
  as_tibble()

#contenido-comunica > a:nth-child(1) > span.time

test_xpath = read_html(test_links[5]) |> 
  html_elements(xpath = '//*[@id="contenido-comunica"]/a') |> 
  html_attr('href') |> 
  as_tibble() 
# https://www.comunicacion.gob.ec/noticias/page/2/


get_date  = read_html(test_links[5]) |> 
  html_elements('.time') |> 
  html_text() |> 
  as_tibble() 


bind_cols(test_xpath, get_date) 

get_links = \(links, user_agent = NULL){
  if(is.null(user_agent)){
    stop("user_agent is required")
  }else{
    bow(links, user_agent = user_agent)
    
    get_url = read_html(links) |> 
      html_elements(xpath = '//*[@id="contenido-comunica"]/a') |> 
      html_attr('href') |>  
      as_tibble() |> 
      rename(url = value) 

    get_date  = read_html(url_tib$url[2]) |> 
      html_elements('#contenido-comunica .time') |> 
      html_text() |> 
      as_tibble() |> 
      rename(date = value)
  
    
  full_dat =  bind_cols(get_date, get_url)
    
    cat("Done Scraping", links, "sleeping for 5+ seconds", "\n")
 
    Sys.sleep(sample(5:8, 1))
       
    return(full_dat)
    
 
  }
}





test_links = url_tib |> 
  slice_sample(n = 5) |> 
  pull(url) 

agent = "For questions please contact Ryan Carlin at rcarlin@gsu.edu"

test_fun = map(test_links, \(x) get_links(x, user_agent = agent))

test_dat = test_fun |>
  list_rbind() 

pos_get_links = possibly(get_links)

links_dat = map(url_tib$url, \(x) pos_get_links(x, user_agent = agent)) 

links_bound = links_dat |>
  list_rbind()

links_distinct = links_bound |> 
  distinct(url, .keep_all = TRUE)


## it looks like we can get the date from the actual release  
get_text = links_bound[[1,1]] |> 
  read_html() |> 
  html_elements('#postcontent p') |> 
  html_text() |> 
  as_tibble()  |> 
  mutate(date = dmy(value,  locale = "es_ES.UTF-8")) |> 
  fill(date, .direction = 'downup') |> 
  slice(-c(1:2))


get_text2 = links_bound[[2,1]] |> 
  read_html() |> 
  html_elements('#postcontent p') |> 
  html_text() |> 
  as_tibble()  |> 
  mutate(date = dmy(value,  locale = "es_ES.UTF-8")) |> 
  fill(date, .direction = 'downup') |> 
  slice(-c(1:2))

get_subject = links_bound[[1,1]] |> 
  read_html() |> 
  html_elements('#main h1') |> 
  html_text() |> 
  as_tibble() 


## the original run errored so you had to debug what was going on 
get_text = links_distinct[[538,2 ]] |> 
  read_html() |> 
  html_elements('#postcontent p') |> 
  html_text() |> 
  as_tibble() |> 
  rename(text = value)

get_subject = links_distinct[[538,2 ]] |> 
  read_html() |> 
  html_elements('#main h1') |> 
  html_text() |> 
  as_tibble()  |> 
  rename(subject_of_statement = value) |> 
  slice(1)

full_dat = tibble(get_text, get_subject)


bind_cols(get_text, get_subject)

scrape_text_dat = \(links, user_agent = NULL){
if(is.null(user_agent)){
  stop("user_agent is required")
} else{
  bow(links, user_agent = user_agent)
  
  get_text = links |> 
    read_html() |>
    html_elements('#postcontent p') |> 
    html_text() |> 
    as_tibble() |> 
    rename(text = value)
  
  get_subject = links |> 
    read_html() |> 
    html_elements('#main h1') |> 
    html_text() |> 
    as_tibble()  |> 
    rename(subject_of_statement = value) |> 
    ## sometimes there are other 1st level headings in the articles
    ## so we need to make sure we are only getting the first one
    slice(1)
  
full_dat = tibble(get_text, get_subject, source = links)
  
  cat("Done Scraping", links, "sleeping for 5+ seconds", "\n")

  return(full_dat)
  
  Sys.sleep(sample(5:8, 1))
     
  

}
}
  
test_links = links_bound |> 
  slice_sample(n = 5) |> 
  pull(url)
  

test_data = map(test_links, \(x) scrape_text_dat(x, user_agent = agent))


test_bound = test_data |> 
  list_rbind()

pos_scrape_text_dat = possibly(scrape_text_dat)

## 
scraping_dat = map(links_distinct$url, \(x) pos_scrape_text_dat(x, user_agent = agent))

links_distinct[[538,2 ]]

meses <- c("enero", "febrero", "marzo", "abril", "mayo", 
           "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre")

install.packages("arrow", type = "source")


bound_scraping_dat = scraping_dat |> 
  list_rbind() 

## stashing this just in case 
save(bound_scraping_dat, file = "bound_scraping_dat.rds")


eliminate_dates = bound_scraping_dat  |> 
  filter(!str_detect(text, "Boletín")) |> 
  slice(-1, .by = c(source, subject_of_statement)) 
  

join_dates = eliminate_dates |> 
  left_join(links_distinct, join_by(source == url)) |> 
  mutate(date = str_squish(date),
         date_fix = str_remove(date, "de")) |> 
  separate_wider_delim(date_fix, names = c("day_month", "year", "time"),
                       delim = ",") |> 
  unite(date_unite, c("day_month", "year"), sep = " ")  |> 
  mutate(date_fix = dmy(date_unite, locale = "es_ES.UTF-8")) |> 
  select(-date_unite, -date, -time) |> 
  rename(date = date_fix)



write_csv(join_dates, "all_ecuador_press_statements.csv")

## for whatever reason one statement doesnt have a title 

raw_dat = read_csv('all_ecuador_press_statements.csv') 

fix_title = raw_dat |>
  filter(is.na(subject_of_statement))  |>
  distinct(source) |>
  pull('source')


add_title = raw_dat |>
  mutate(fix_title = ifelse(source == fix_title[1], 'EL PRESIDENTE ENTREGÓ LA REPOTENCIACIÓN DEL CENTRO PARA PERSONAS CON DISCAPACIDAD EN CONOCOTO', NA),
        title = coalesce(subject_of_statement, fix_title)) |>
  rename(url = source) |>
  select(-subject_of_statement, -fix_title)


write_csv(add_title, 'all_ecuador_press_statements.csv')
