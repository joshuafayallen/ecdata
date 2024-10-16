pacman::p_load(rvest, polite, tidyverse)

base_data = tibble(url = c("https://presidencia.gob.bo/index.php/prensa")) 

base_url = "https://presidencia.gob.bo/index.php/prensa"

added_links = tibble(url = paste0(base_url, "?start=", seq(5, 65, 5)))

links = bind_rows(base_data, added_links)

bow(links[[1,1]])


test = read_html(links[[1,1]]) |> 
  html_elements('div.entry-header.has-post-format > h2 > a') |> 
  html_attr('href') 


scraping_fun = \(links,
                 user_agent = "For questions please contact Ryan Carlin at rcarlin@gsu.edu"){
  agent = rlang::englue('{{user_agent}}')
  
  bow(links, user_agent =  agent)
  
  links_data = read_html(links) |> 
    html_elements('div.entry-header.has-post-format > h2 > a') |> 
    html_attr('href') |> 
    as_tibble() |> 
    rename(url = value )
  
  cat("Done Scraping", links, "\n")
  
  
  
  Sys.sleep(runif(1, min = 5, max = 8)) 
  
  return(links_data)
}


bolivia_links = map(links$url, scraping_fun)

combinded_links = bolivia_links |> 
  list_rbind()

write_csv(combinded_links, "data/bolivia_links.csv")

bolivia_links = read_csv(here::here("data", "bolivia_links.csv")) |> 
  mutate(url = paste0("https://presidencia.gob.bo", url))




text = bolivia_links$url[1] |> 
  read_html() |> 
  html_elements('p') |> 
  html_text2() |>
  as_tibble() |> 
  separate_longer_delim(cols = value, delim  = "\n") |> 
  filter(nchar(value) > 0)
  
  
test_two = bolivia_links$url[2] |> 
  read_html() |> 
  html_elements('p') |> 
  html_text2() |>
  as_tibble() |> 
  separate_longer_delim(cols = value, delim  = "\n") |> 
  filter(nchar(value) > 0)

## cool this works 

date = bolivia_links$url[1] |> 
  read_html() |> 
  html_elements('#sp-component dd.published > time') |> 
  html_text()

subject = bolivia_links$url[1] |> 
  read_html() |> 
  html_elements('div.entry-header.has-post-format > h1') |> 
  html_text()

test_one = test |> 
  mutate(date = date, subject = subject)


grab_texts =\(links,
              user_agent = "For questions please contact Ryan Carlin at rcarlin@gsu.edu",
              timeout = 10) {
  
  agent = rlang::englue('{{user_agent}}')
  
  bow(links, user_agent =  agent)
  
  
  text = links |>
    httr::GET(timout = timeout) |>
    read_html() |> 
    html_elements('p') |> 
    html_text2() |>
    as_tibble() |> 
    separate_longer_delim(cols = value, delim  = "\n") |> 
    filter(nchar(value) > 0) |> 
    rename(text = value)
  
  ## cool this works 
  
  date = links |>
    httr::GET(timout = timeout) |> 
    read_html() |> 
    html_elements('#sp-component dd.published > time') |> 
    html_text()
  
  subject = links |>
    httr::GET(timout = timeout) |> 
    read_html() |> 
    html_elements('div.entry-header.has-post-format > h1') |> 
    html_text()
  
  full_dat = text |> 
    mutate(date = date,
           subject = subject,
           url = links)
  
  cat("Done Scraping", links, "\n")
  Sys.sleep(runif(1, min = 5, max = 8))
  
  return(full_dat)
  
}

test_vec = bolivia_links |> 
  slice_sample(n = 3) |> 
  pull(url)  |> 
  map(grab_texts)


test_data = list_rbind(test_vec)


bolivia_data = bolivia_links |> 
  pull(url) |> 
  map(grab_texts) 

bound_bolivia = list_rbind(bolivia_data)


clean_up = bound_bolivia |> 
  mutate(date = dmy(date, locale = 'es_ES')) 

write_csv(clean_up, "data/bolivia_statements.csv")


