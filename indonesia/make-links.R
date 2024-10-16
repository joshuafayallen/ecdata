pacman::p_load(tidyverse, httr, polite, rvest)

base_prefix = "https://setkab.go.id/"

base_suffix = "/?cat=87"

links_tibble = expand_grid(months = seq(1, 12, 1),
                           years = seq(2014, 2023, 1)) |> 
  mutate(links = paste0(base_prefix, years, "/", months, base_suffix)) |> 
  filter(years != 2023, months != 12) 
## looks like the issue is that 
## we had some bad links in there
## 

get_links = read_html(links_tibble[[1,3]]) |> 
  html_elements(".text a") |> 
  html_attr("href") |> 
  as_tibble()

polite::bow(links_tibble[[1,3]])

get_links_to_scrape  = function(links){
  introduction = polite::bow(links, user_agent = "If you have any questions please contact
                                                  Ryan Carlin at rcarlin@gsu.edu")

check = GET(links)

status = status_code(check)

if(status != 200){
  bad_link = links 
  bad_link_tib = tibble(url = bad_link)
  
  return(bad_link_tib)
  
  
} else{
  link_df = read_html(links) |> 
    html_elements(".text a") |> 
    html_attr("href") |> 
    as_tibble() |> 
    rename(urls = value)
  
  subject = read_html(links) |> 
    html_elements(".text") |> 
    html_text() |> 
    as_tibble() |> 
    rename(subject = value)
  
  
  bound_df = bind_cols(link_df, subject, scraping_page = links)
  
  sleepy_time = sample(5:10, 1)
  cat("Done Scraping", links, "going to sleep for", sleepy_time, "seconds", "\n")
  
  Sys.sleep(sleepy_time)
  
  return(bound_df)
  
}
  
}

test_links = links_tibble |> 
  slice_sample(n = 5) |> 
  select(links) |> 
  deframe()

test_fun = map(test_links, get_links_to_scrape)


check_data = test_fun |>  list_rbind()


scrapped_links = map(links_tibble$links, possibly(get_links_to_scrape))

bound_links = list_rbind(scrapped_links)


write_csv(bound_links, "links_data.csv")

## basically we have to manually extract the months and 
## days and years 

bound_links = read_csv("links_data.csv")

get_dates = read_html(bound_links[[234,1]]) |> 
  html_elements('.fl') |> 
  html_text() |> 
  as_tibble() |> 
  mutate(date =dmy(value))

### this is by far the dumbest luck I have ever had working with a string lol
dates_rebex = get_dates |> 
  mutate(date = dmy(text))


get_subject = read_html(bound_links[[234,1]]) |> 
  html_elements('.detail_title') |> 
  html_text() |> 
  str_squish() |> 
  as_tibble()


get_text = read_html(bound_links[[234,1]]) |> 
  html_elements('.reading_text p') |> 
  html_text() |> 
  as_tibble()


scraping_statements = function(links, my_timeout = 10){
  
  introduction = polite::bow(links, user_agent = "If you have any questions please contact
                                                  Ryan Carlin at rcarlin@gsu.edu")
  
  check = GET(links)
  
  status = status_code(check)
  
  sleepy_time = sample(5:10, 1)
  cat("Starting to Scrape", links, "going to sleep for", sleepy_time, "seconds", "\n")
  
  Sys.sleep(sleepy_time)
  
  if(status != 200){
    bad_link = links 
    bad_link_tib = tibble(url = bad_link)
    
    return(bad_link_tib)
    
    
  }else{
    
    
    get_subject =  GET(links, timeout = my_timeout)|> 
      read_html() |> 
      html_elements('.detail_title') |> 
      html_text() |> 
      as_tibble() |> 
      rename(subject = value)
    

    
    
    get_text = GET(links, timeout = my_timeout)|> 
      read_html() |> 
      html_elements('.reading_text p') |> 
      html_text() |> 
      as_tibble() |> 
      rename(text = value)
    
    
    scraped_df = bind_cols(get_subject, get_text, url = links)
    
    return(scraped_df)
    
  }
  
  
  
}



links_scrape = bound_links$urls

scraped_statements = map(links_scrape, scraping_statements)

bound_scraped_statements = scraped_statements |> 
  list_rbind()




## this could be a long shot but
month_names_id <- c(
  "Januari" = "January",
  "Februari" = "February",
  "Maret" = "March",
  "April" = "April",
  "Mei" = "May",
  "Juni" = "June",
  "Juli" = "July",
  "Agustus" = "August",
  "September" = "September",
  "Oktober" = "October",
  "November" = "November",
  "Desember" = "December"
)

month_pattern <- paste(names(month_names_id), collapse = "|")
regex_pattern <- paste0("(\\d{1,2})\\s+(", month_pattern, ")\\s+(\\d{4})")

test_regex = testing_df_bound |> 
  mutate(date = str_extract(subject, regex_pattern))

bound_scraped_statements = bound_scraped_statements |> 
  mutate(date = str_extract(subject, regex_pattern))


write_csv(bound_scraped_statements, "indoneseai-pm-statements.csv")



library(tidyverse)


month_names_id <- c(
  "Januari" = "January",
  "Februari" = "February",
  "Maret" = "March",
  "April" = "April",
  "Mei" = "May",
  "Juni" = "June",
  "Juli" = "July",
  "Agustus" = "August",
  "September" = "September",
  "Oktober" = "October",
  "November" = "November",
  "Desember" = "December"
)


replace_month_names <- function(date_string) {
  for (indonesian_month in names(month_names_id)) {
    date_string <- gsub(indonesian_month, month_names_id[indonesian_month], date_string)
  }
  return(date_string)
}






raw = read.csv("indoneseai-pm-statements.csv")


clean_up_dates = raw |> 
  mutate(date = map_chr(date, replace_month_names),
         date = dmy(date)) 



write_csv(clean_up_dates, "indonesia-pm-statements.csv")



