pacman::p_load(tidyverse, polite, rvest, httr)

base_link = "https://www.pm.gov.au/media?page="

links_df = tibble(links = paste0(base_link, seq(0,106, 1)))


get_links = read_html(links_df[[1,1]]) |> 
  html_elements('.card-title a') |> 
  html_attr("href") |> 
  as_tibble()
  
get_date = read_html(links_df[[1,1]]) |> 
  html_elements('.date') |> 
  html_text() |> 
  as_tibble()

get_subject = read_html(links_df[[1,1]]) |> 
  html_elements('.card-title') |> 
  html_text() |> 
  as_tibble()

australian_link_scrapper = function(links){

  
  introduce = bow(links, user_agent = "For questions please contact Ryan Carlin at 
                  rcarlin@gsu.edu")
  
  get_links = read_html(links) |> 
    html_elements('.card-title a') |> 
    html_attr("href") |> 
    as_tibble() |> 
    rename(url = value)
  
  get_date = read_html(links) |> 
    html_elements('.date') |> 
    html_text() |> 
    as_tibble() |> 
    rename(date = value)
  
  get_subject = read_html(links) |> 
    html_elements('.card-title') |> 
    html_text() |> 
    as_tibble() |> 
    rename(subject = value)
  
  links_df = bind_cols(get_links, get_subject, get_date)
  
sleepy_time = sample(5:8,1)

cat("done scraping", links, "going to sleep for", sleepy_time, "seconds")

Sys.sleep(sleepy_time)

return(links_df)
  
}

test_links = links_df |> 
  slice_sample(n = 5) |> 
  deframe()


test = map(test_links, australian_link_scrapper)

links_to_scrape = links_df$links


links_from_web = map(links_to_scrape, australian_link_scrapper)


bound_links_from_web = links_from_web |> 
  list_rbind() |> 
  mutate(url_fix = paste0("https://www.pm.gov.au", url)) |> 
  select(-url)

write_csv(bound_links_from_web, "links-to-scrape.csv")



get_text = read_html('https://www.pm.gov.au/media/national-apology-thalidomide-survivors-and-their-families') |> 
  html_elements('.content p') |> 
  html_text() |> 
  as_tibble() |> 
  filter(str_detect(value, "PM&C", negate = TRUE), nchar(value) > 1)


get_date = read_html('https://www.pm.gov.au/media/national-apology-thalidomide-survivors-and-their-families') |> 
  html_elements('.datetime') |> 
  html_text() |> 
  as_tibble()


get_subject = read_html('https://www.pm.gov.au/media/national-apology-thalidomide-survivors-and-their-families') |> 
  html_elements('#block-pearly-page-title--2 .content') |> 
  html_text() |> 
  as_tibble()


test = bind_cols(get_subject, get_date, get_text)

scrape_texts = function(links){
  introduce = bow(links, user_agent = "For questions please contact Ryan Carlin at 
                  rcarlin@gsu.edu")
  
  get_text = read_html(links) |> 
    html_elements('.content p') |> 
    html_text() |> 
    as_tibble() |> 
    filter(str_detect(value, "PM&C", negate = TRUE), nchar(value) > 1) |> 
    rename(text = value)
  
  
  get_date = read_html(links) |> 
    html_elements('.datetime') |> 
    html_text() |> 
    as_tibble() |> 
    rename(date = value)
  
  
  get_subject = read_html(links) |> 
    html_elements('#block-pearly-page-title--2 .content') |> 
    html_text() |> 
    as_tibble() |> 
    rename(subject = value)
  
  
text_df = bind_cols(get_subject, get_date, get_text, url = links)
  
sleepy_time = sample(5:8,1)
  
cat("done scraping", links, "going to sleep for", sleepy_time, "seconds")
  
Sys.sleep(sleepy_time)
  
  return(text_df)
}

test_links = bound_links_from_web |> 
  select(url_fix) |> 
  slice_sample(n = 5) |> 
  deframe()

test = map(test_links, scrape_texts)

##


statements_data = map(bound_links_from_web$url_fix, scrape_texts)

bind_statements_data = statements_data |> 
  list_rbind()



write_csv(bind_statements_data, "australian-statements-sans-links.csv")


raw_dat = read_csv('australian-statements-sans-links.csv')



fix_dates = raw_dat |>
  mutate(date = dmy(date), 
         subject = str_squish(subject))


links_dat = read_csv('links-to-scrape.csv') |>
  mutate(date = dmy(date),
         subject = str_squish(subject))


add_links = fix_dates |>
  left_join(links_dat, join_by(date, subject)) |>
  rename(url = url_fix)



links_dat |>
  filter(str_detect(subject, "Press Conference - Beijing - People's Republic of China")) -> check

add_links |>
  filter(is.na(url_fix))

write_csv(add_links, 'australian_statements.csv')




