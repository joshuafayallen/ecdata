
## this is being redone 
pacman::p_load(rvest, tidyverse, polite)


base_url = 'https://www.bundesregierung.de/breg-de/service/archive?page='


links_df = tibble(my_urls = paste0(base_url, seq(0,134,1)))

links_vec = links_df$my_urls


get_date = read_html_live(links_vec[1]) |>
  html_elements('.bpa-time') |>
  html_text()

length(get_date) == length(hrefs_tib)

no_date_tib = tibble()

get_links_germany = function(links){
  
  hrefs_tib = read_html_live(links) |> 
      html_elements('.bpa-teaser-text-wrapper a') |> 
      html_attr('href')  |>
    as_tibble() |>
    rename(url = value) 

  cat('Done scraping', links, '\n')

  Sys.sleep(5)
  
  return(hrefs_tib)
}





links_to_scape = map(links_vec, get_links_germany)

links_dat = list_rbind(links_to_scape)

write_csv(links_dat, 'german_links.csv')



failed_links = tibble(url = NA)

get_germany_statements = function(links){
  
  get_date = read_html_live(links) |> 
  html_elements("#main .bpa-time time") |> 
  html_text() |> 
  as_tibble() |>
    rename(date = value)


get_subject = read_html_live(links) |> 
  html_elements(".bpa-teaser-title-text-inner") |> 
  html_text() |> 
  as_tibble() |>
  rename(subject = value)

get_text = read_html_live(links) |> 
  html_elements("#main .bpa-container p") |> 
  html_text() |> 
  as_tibble() |>
  rename(text = value)
     
  tryCatch({
    bound_data = bind_cols(get_date, get_subject, get_text, url = links)
    cat('Done Scraping', links, '\n')
    Sys.sleep(5)
    return(bound_data)
  }, error = \(e){
    error_message = errorCondition(e)
    if(grepl('recyled', error_message, ignore.case = TRUE)){
      cat('recyling error', links, '\n')

     bound_data = bind_cols(get_date,get_subject, get_text, url = links)
     Sys.sleep(5)  
    return(bound_data)

    }else{
      links_fail = tibble(url = links)
      failed_links <<- bind_rows(failed_links, links_fail)
    }
  } 

  )

  
  
  cat('Done Scraping', links, '\n')  
  
}
  
pos_get_statements = possibly(get_germany_statements)


statements_germany = map(links_dat$url,\(x) pos_get_statements(x))

statements_germany_df = statements_germany |> 
  list_rbind()

fix_dates = statements_germany_df |>
  mutate(date = dmy(date, locale = 'de_DE'))

write_csv(statements_germany_df, 'raw_germany_statements.csv')


contemp_link = "https://www.bundesregierung.de/breg-de/aktuelles?f=992752%3ABPAPressConference--992752%3ABPAPressRelease--992752%3ABPASpeech&page="


current_statements = tibble(url = paste0(contemp_link, seq(0,199,1)))

current_statements_vec = current_statements |> 
  deframe()


get_links_germany(current_statements_vec[1])



get_current_links = map(current_statements_vec, get_links_germany)


current_links = get_current_links |>
  list_rbind()



get_current_statements = function(links){
  cat("Starting to scrape", links, "\n")
  
  check_links = httr::GET(links)
  
  session = bow(links, user_agent = "If you have any question please contact Ryan Carlin \n
                                                       at rcarlin@gsu.edu")
  
  
    

    get_date = read_html(links) |> 
      html_element('#main .bpa-container li:nth-child(2)') |>
      html_text() |> 
      as_tibble() |>
      rename(date = value)
    
    
    
    get_subject = read_html(links) |>
      html_elements('.bpa-article-header') |> 
      html_text() |> 
      as_tibble() |> 
      rename(subject = value)
    
    get_text = read_html(links) |>
      html_elements('.bpa-richtext p') |> 
      html_text() |> 
      as_tibble() |> 
      filter(nchar(value) > 1 & !grepl("\\nPhoto:", value)) |> 
      slice(-c(1:5)) |> 
      rename(text = value) 
    
    statements_df = bind_cols(get_date, get_subject, get_text, url = links)
    

return(statements_df)

sleepy_time = sample(5:8,1)

cat("sleeping for", sleepy_time, "seconds", "\n")

Sys.sleep(sleepy_time)
    
    
} 


test_vec = current_links |>
  slice_sample(n = 5)


test = map(test_vec$url, \(x) get_current_statements(x)) 

pos_statements = possibly(get_current_statements)

current_statements = map(current_links$url, \(x) pos_statements(x))

bound_current_statements = current_statements |>
  list_rbind()


these = which(lengths(current_statements) == 0)

rescrape_these = current_links |>
  mutate(id = row_number()) |>
  filter(id %in% these)

scrapped_again = map(rescrape_these$url, \(x) get_current_statements(x))

bound_scrapped_again = scrapped_again |>
  list_rbind() |>
  bind_rows(bound_current_statements)



parse_dates_current = bound_scrapped_again |>
  mutate(date = str_squish(date),
        date_fix = dmy(date, locale = 'de_DE'))

parse_dates_current |>
  filter(is.na(url))


## okay it looks like we don't have missing dates 
check_missing = parse_dates_current |>
  filter(is.na(date_fix)) |>
  distinct(url, .keep_all = TRUE)

## lets randomly sample deez 


#main > div > div.bpa-module.bpa-module-supplement.bpa-white.bpa-humming-bird > div > div > header > ul > li:nth-child(2) > span
## it looks like the issue is that  its at a different nth child 

scrappers = \(links){
  get_date = read_html(links) |> 
    html_element('#main .bpa-time') |>
    html_text() |> 
    as_tibble() |>
    rename(date = value)

 bound_date = bind_cols(get_date, url = links)
  cat('Done scrapping', links, '\n')
  Sys.sleep(4)

  return(bound_date)
}

na_dates |>
  slice_sample(n = 5) -> check

poss_scrapper= possibly(scrappers)
  
  
fix_dates = map(check_missing$url, \(x) poss_scrapper(x))

bound_fixes = list_rbind(fix_dates) |>
  mutate(date_fix = str_extract(url, '\\b\\d{1,2}-(\\w+)-\\d{4}\\b'),
         date = coalesce(date, date_fix))


na_dates = bound_fixes |>
  filter(is.na(date)) |>
  distinct(url)

scrapper_two = \(links){
  date = read_html(links) |>
    html_elements('.bpa-government-declaration-place-date') |>
    html_text() |>
    as_tibble() |>
    mutate(url = links)


 Sys.sleep(5)

  return(date)
}

rest_of_them = map(na_dates$url, \(x) scrapper_two(x))

bound_rest = list_rbind(rest_of_them)

joined_data = bound_fixes |>
  left_join(bound_rest, join_by(url)) |>
  mutate(fix_date = dmy(date, locale = 'de_DE'),
         date_fix_two = dmy(value, locale = 'de_DE'),
         date = coalesce(fix_date, date_fix_two))

joined_data |>
  filter(is.na(date))


 check = joined_data |>
  filter(is.na(date)) |>
  filter(is.na(date_fix)) |>
  distinct(url) |>
   pull('url')

check_two =  joined_data |> filter(is.na(date)) 

fix_manuals = joined_data |>
  mutate(date_fix = ifelse(url == check[1], ymd('2024-07-05'), date_fix), 
         date_fix = str_replace(date_fix, 'summit', 'Mai'),
         date_fix_three = dmy(date_fix, locale = 'de_DE'),
         date_fix = ifelse(date_fix == '19909', ('05-07-2024'), date_fix),
         date_fix = dmy(date_fix, locale = 'de_DE'),
         date = coalesce(date, date_fix_three, date_fix)
  ) 


fix_manuals |>
  filter(is.na(date))

further_fixes = fix_manuals |>
  mutate(date_fix = str_extract(url, '\\b\\d{1,2}-(\\w+)-\\d{4}\\b'),
          ## its getting tripped up becasuse there are no umlats
         date_fix = str_replace(date_fix, 'maerz', 'März'),
         date_fix_three = dmy(date_fix, locale = 'de_DE'),
        date = coalesce(date, date_fix_three),
      year = year(date)) |>
  select(url, date, year)
  ## these are dates where they are commemorating thing 

impossible_dates = further_fixes |>
  filter(year < 2000) |>
  distinct(url, .keep_all = TRUE) |>
  pull('url') 

impossible_dates_two = further_fixes |>
  filter(year < 2000) |>
  distinct(url, .keep_all = TRUE) |>
  pull('year')

manual_fix = further_fixes |>
  mutate(date_fix = case_when(url == impossible_dates[1] ~ '2024-07-20',
                              url == impossible_dates[2] ~ '2024-09-01',
                             url == impossible_dates[3] ~  '2023-06-17'),
         date = ifelse(year %in% impossible_dates_two, NA, date),
         date = as_date(date),
         date_fix = ymd(date_fix), 
        date = coalesce(date, date_fix)) |>
  select(url, fix_date = date)

manual_fix |>
  filter(is.na(date))


add_in = parse_dates_current |>
  left_join(manual_fix, join_by(url)) |>
  mutate(date = dmy(date), 
         date = coalesce(date, date_fix, fix_date))


last_fixes = add_in |>
  mutate(date_fix_three = ifelse(url == last_check[1], '2023-10-04', NA),
        date_fix_three = ymd(date_fix_three),
        date = coalesce(date, date_fix_three),
        subject = str_squish(subject)) 


write_csv(last_fixes, 'raw_current_statements.csv')



past_statements = read_csv('raw_germany_statements.csv') 


glimpse(parse_dates)


parse_dates = past_statements |>
  mutate(date = dmy(date, locale = 'de_DE')) |>
  bind_rows(last_fixes) |>
  select(title = subject, date, text, url) |>
  mutate(title = str_squish(title))


parse_dates |>
  filter(is.na(title))

parse_dates |>
  filter(is.na(url))

parse_dates |>
  filter(is.na(date))


write_csv(parse_dates, 'germany_statements.csv')



raw_dat = read_csv('germany_statements.csv')

na_date = raw_dat |>
  filter(is.na(date)) |>
  pull('url')

fix_this = raw_dat |>
  mutate(date = ifelse(url == 'https://www.bundesregierung.de/breg-de/aktuelles/bundesregierung-gedenkt-der-opfer-des-volksaufstandes-vom-17-juni-1953-2050900',  ymd('2022-06-10'), date),
      date = as_date(date) )

glimpse(fix_this)


fix_this |>
  filter(is.na(date))


write_csv(fix_this, 'cleaned_germany_statements.csv')



