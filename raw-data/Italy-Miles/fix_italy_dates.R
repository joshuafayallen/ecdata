pacman::p_load(polite, rvest, tidyverse)

raw_links = read_csv(here::here("Italy-Miles", "meloni_links_it.csv"))


raw_links[[1,1]] |> 
  bow()


test = read_html(raw_links[[1,1]]) |> 
  html_elements('#primo-piano > div > div > div.col-md-6.col-sm-8 > div > p') |> 
  html_text() |> 
  as_tibble()


get_dates = \(links){
  
  introduce = bow(links, user_agent = "For questions please contact Ryan Carlin at
                  rcarlin@gsu.edu")
  
  
  dates_dat = read_html(links) |> 
    html_elements('#primo-piano > div > div > div.col-md-6.col-sm-8 > div > p') |> 
    html_text() |> 
    as_tibble() |> 
    rename(date = value)
  
  
  title_dat = read_html(links) |> 
    html_elements('.title_large') |> 
    html_text() |> 
    as_tibble() |> 
    rename(title = value)
  
  
  combined = bind_cols(dates_dat, title_dat, url = links)
  
  cat("done scraping", links, "going to sleep for", " 10 seconds")
  
  Sys.sleep(10)
  
  return(combined)
  
  
  
  
}

test_vec = raw_links |> 
  slice_sample(n = 5) |> 
  pull('links') 



it_dates = map(test_vec, \(x) get_dates(x))

it_df = it_dates |> 
  list_rbind() |> 
  mutate(date = dmy(date, locale = "it_IT.UTF-8"))





italian_statements = read_csv(here::here("Italy-Miles", "meloni_statements_it.csv")) 


test_join = italian_statements |> 
  left_join(it_df, join_by(title))

test_join |> 
  filter(!is.na(date))


pos_get_dates = possibly(get_dates)


full_it_dates = map(raw_links$links, \(x) pos_get_dates(x))



full_it_df = full_it_dates |> 
  list_rbind() |> 
  mutate(date = dmy(date, locale = "it_IT.UTF-8"))


joined_data = italian_statements |> 
  left_join(full_it_df, join_by(title))

write_csv(joined_data, here::here("Italy-Miles", "italian_statements.csv"))


