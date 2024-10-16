pacman::p_load(tidyverse, tidypolars, rvest, polite, httr2)



## so the links differ in two places year and number 

base_url = "https://www.kantei.go.jp/jp/"

after_pm = "/statement/"

after_year = "/index.html"


links_df = tibble(pms = c("101_kishida","100_kishida", "99_suga", "98_abe"))



kishida = tibble(links = paste0(base_url, "101_kishida", after_pm, seq(2022,2023,1),
                                after_year)) |> 
  add_row(links = paste0(base_url, "100_kishida", after_pm, "2021", after_year))


suga = tibble(links = paste0(base_url, "99_suga", after_pm, seq(2020, 2021,1), after_year))


abe = tibble(links = paste0(base_url, "98_abe", after_pm, seq(2017, 2020, 1)))

all_pms = bind_rows(kishida,suga, abe)

httr::GET("https://www.kantei.go.jp/jp/98_abe/statement/2021/index.html")

get_status_code = function(url) {
  response = httr::GET(url)
  
  status_code_df = tibble(status = httr::status_code(response),
                          url = url)
  return(status_code_df)
  
  Sys.sleep(5)
}

links_vec_check = all_pms$links

check_to_see_if_works =  map(links_vec_check, get_status_code)

## okay these work

## ... 

#top > main > div > div.l-main > article > div > div.section > ul > li:nth-child(1) > div.news-list-data > div.news-list-title

get_urls = read_html(links_vec_check[1]) |> 
  html_elements(".news-list-title a") |> 
  html_attr("href") |> 
  as_tibble()

## the dates are a little weird and it seems like whenever anything gets 
## https://www.kantei.go.jp/jp/101_kishida/statement/2023/index.html 
## seems to have an updated on a date that is not actually 2023

bow(links_vec_check[1])

get_refs_scrape = function(links){
  
  check_status = httr::GET(links)
  
  sleepy_time = sample(5:10,1)
  
  cat("scraping", links, "going to sleep for", sleepy_time)
  
  Sys.sleep(sleepy_time)
  
 ## We are doing a bit of a no no. I know that all these links work
 ## and there is only 4 of them so we can just do away with any 
 ## control flow 
links_df = read_html(links) |> 
    html_elements(".news-list-title a") |> 
    html_attr("href") |> 
    as_tibble() 
  
return(links_df)
}

scraped_links = map(links_vec_check, get_refs_scrape)

fixing_links = links_scraped_df |> 
  mutate(fix_links = paste0("https://www.kantei.go.jp", value))


links_vec = fixing_links$fix_links







scraping_text = function(links){
  status = httr::GET(links) 
  
  introduce = bow(links, user_agent = "For any questions contact Ryan Carlin at rcarlin@gsu.edu")
  
  sleepy_time = sample(5:10,1)
  
  cat("Starting to Scrape", links, "going to sleep for", sleepy_time, "\n")
  
  Sys.sleep(sleepy_time)
  
  stat_links = httr::status_code(status)
  
  if(stat_links != 200){
    bad_links = links
    error_link_df = tibble(links = NA) 
    
    error_link_df = rbind(error_link_df, bad_links)
    
    return(error_link_df)
    
    
    
  } else {
    
    text_df = read_html(links) |>
      html_elements("p") |>
      html_text() |>
      as_tibble() |>
      rename(text = value)
    
    title = read_html(links) |> 
      html_elements("h1") |> 
      html_text() |> 
      as_tibble() |> 
      rename(subject = value)
    
    bound_data = bind_cols(text_df, title, url = links)
    
    return(bound_data)
    
  }
}

testing_links = sample(links_vec, 5)



testing_function = map(testing_links, scraping_text)


look_at_dat = testing_function |> 
  list_rbind()

japanese_statements = map(links_vec, scraping_text)


bound_statements = japanese_statements |> 
  list_rbind()

write_csv(bound_statements, "japanese-pm-statements.csv")


pacman::p_load(tidyverse, rvest)

base_url = "https://www.kantei.go.jp/jp/"

after_pm = "/statement/"

after_year = "/index.html"


japan_raw = read_csv("japanese-pm-statements.csv")

kishida = tibble(links = paste0(base_url, "101_kishida", after_pm, seq(2022,2023,1),
                                after_year)) |> 
  add_row(links = paste0(base_url, "100_kishida", after_pm, "2021", after_year))


suga = tibble(links = paste0(base_url, "99_suga", after_pm, seq(2020, 2021,1), after_year))


abe = tibble(links = paste0(base_url, "98_abe", after_pm, seq(2017, 2020, 1)))

add_leaders = japan_raw |> 
  mutate(exec_one = str_extract(url, "kishida|suga|abe"),
         exec_one = case_when(exec_one == "kishida" ~ "Fumio Kishida",
                              exec_one == "suga" ~ "Yoshihide Suga",
                              exec_one == "abe" ~ "Shinzo Abe"))

## we need the dates 

links = add_leaders$url[1]

date = read_html(links) |>
  html_elements('.date') |>
  html_text()

scrappers = \(links){
  
  date = read_html(links) |>
    html_elements('.date') |>
    html_text() |>
    as_tibble() |>
    rename(date = value) |>
    mutate(url = links)

   cat('Done Scraping', links, '\n')
  
  Sys.sleep(5)

  return(date)

}

pos_scrappers = possibly(scrappers)

distinct_urls = add_leaders |>
  distinct(url, .keep_all = TRUE)



add_dates = map(distinct_urls$url, \(x) pos_scrappers(x))

bound_dates = add_dates |>
  list_rbind()

joined_dates  = add_leaders |>
  left_join(bound_dates, join_by(url))

test = joined_dates |>
  slice_sample(n = 5) |>
  select(date, exec_one, url) 

library(zipangu)

### hopefully this works 

parsed_some_dates = joined_dates |>
  mutate(fix_dates = convert_jdate(date))


## this is not the most accurate but far prefered to the hand doing 300 or so dates
## I just got this from chat gpt

converter = \(date_str){
  year <- as.numeric(str_extract(date_str, "(?<=令和)\\d+"))
  month <- as.numeric(str_extract(date_str, "(?<=年)\\d+(?=月)"))
  day <- as.numeric(str_extract(date_str, "(?<=月)\\d+(?=日)"))
  
 
  gregorian_year <- 2018 + year  
  
  # Create a date string
  date_string <- sprintf("%04d-%02d-%02d", gregorian_year, month, day)
  
  # Parse the date using lubridate
  parsed_date <- ymd(date_string)
  
  return(parsed_date)

}


fix_dates = parsed_some_dates |>
  mutate(fix_dates_two = ifelse( is.na(fix_dates), converter(date), NA),
         fix_dates_two = as_date(fix_dates_two),
          date = coalesce(fix_dates, fix_dates_two)) |>
select(subject, text, date, url, exec_one)


write_csv(fix_dates, 'japan_statements.csv')






