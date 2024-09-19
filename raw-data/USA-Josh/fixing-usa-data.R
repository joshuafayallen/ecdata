library(polite)
library(fuzzyjoin)
library(rvest)
library(tidyverse)


raw_dat = read_csv('data/us_president_statements.csv')

## you should have added the links you dolt 
raw_links = read_csv('data/document_links.csv') 

## lets try the hacky way since we really don't have to deal with special characters 

add_subjects = raw_links |>
  mutate(joining_file_name = basename(value),
          joining_file_name = str_replace_all(joining_file_name, '-', ' '))


cleaning_dat = raw_dat |>
  mutate(joining_file_name = str_to_lower(subject_of_statement),
         ## this loooks like it only removes trailing punction
         joining_file_name = gsub('[[:punct:]]', '', joining_file_name))

## lets do something kind of conservative 

add_what_we_can = cleaning_dat |>
  inner_join(add_subjects)

add_what_we_can |>
  distinct(links) -> check

## this definitively did not work 
## we can going to try fuzzyjoining 


make_links = raw_links |>
  mutate(links = paste0('https://www.presidency.ucsb.edu', value))


get_statements = function(links_to_scrape){
 
    cat(links_to_scrape, "is being scraped", "\n")
    session = bow(url = links_to_scrape, user_agent = "Please Contact Ryan Carlin at rcarlin@gsu.edu with questions or concerns",
                  force = TRUE)
    
    
    subject_of_message = read_html(links_to_scrape) |> 
      html_elements('h1') |> 
      html_text() |> 
      as_tibble() |> 
      rename(title = value)
     
    output_data = bind_cols(subject_of_message, url = links_to_scrape) 
    Sys.sleep(10)
  
  return(output_data)
    
    
    
}
  


pos_scrapper = possibly(get_statements)


rescrape = map(make_links$links, \(x) pos_scrapper(x))


bound_rescrape = rescrape |>
  list_rbind() 


rescrape_these = which(lengths(rescrape) == 0)

add_ids = make_links |>
  mutate(id = row_number()) |>
  filter(id %in% rescrape_these)


write_csv(bound_rescrape, 'rescraped_data.csv')

write_csv(add_ids, 'links_that_are_being_rescraped.csv')

rescrape_again = map(add_ids$links, \(x) get_statements(x))

# umm interesting there were some 404 errors 

add_ids = add_ids |>
  mutate(status = map_dbl(links, \(x) httr::status_code(httr::GET(x)))) 

get_working_links = add_ids |>
  filter(status == 200)

rescrape_again = map(get_working_links$links, \(x) get_statements(x))

bound_rescrapes = rescrape_again |>
  list_rbind() |>
  bind_rows(bound_rescrape)

add_to_data = raw_dat |>
  left_join(bound_rescrapes, join_by(subject_of_statement == title))

write_csv(add_to_data, 'temp_usa_statements.csv')


get_problem_kids = add_ids |>
  filter(status != 200) |>
  mutate(title = basename(links),
title = str_replace_all(title, '-', ' '),
        title = str_to_title(title))

look_these_up = pull(get_problem_kids, links)

look_up = get_problem_kids |>
  mutate(title = str_replace_all(title, '-', ' '),
        title = str_to_title(title)) |>
  pull('title')

look_up

smaller = add_to_data |>
   ## it looks like the annex one is the only one where we are gonna have some probs 
  filter(str_detect(subject_of_statement, 'Annex', negate = TRUE))




fixed_links  = get_problem_kids |>
  mutate(
        fixed_url = case_match(title,
                             look_up[1] ~ 'https://www.presidency.ucsb.edu/documents/statement-the-flooding-libya',
                              look_up[2] ~ 'https://www.presidency.ucsb.edu/documents/statement-the-return-united-states-citizens-released-from-detention-iran',
                             look_up[3] ~ 'https://www.presidency.ucsb.edu/documents/proclamation-10627-national-voter-registration-day-2023',
                             look_up[4] ~ 'https://www.presidency.ucsb.edu/documents/statement-the-10th-anniversary-the-shooting-the-washington-navy-yard',
                             look_up[5] ~ 'https://www.presidency.ucsb.edu/documents/remarks-the-contract-negotiations-between-the-united-auto-workers-and-the-big-three',
                            look_up[6] ~ 'https://www.presidency.ucsb.edu/documents/statement-the-anniversary-the-death-mahsa-amini-and-political-demonstrations-iran',
                          look_up[7] ~ 'https://www.presidency.ucsb.edu/documents/statement-the-observance-rosh-hashanah-2',
                        look_up[8] ~ 'https://www.presidency.ucsb.edu/documents/memorandum-delegation-authority-under-section-404c-the-child-soldiers-prevention-act-1',
                      look_up[9] ~ 'https://www.presidency.ucsb.edu/documents/proclamation-10625-constitution-day-and-citizenship-day-and-constitution-week-2023',
                        look_up[10] ~ 'https://www.presidency.ucsb.edu/documents/proclamation-10626-national-farm-safety-and-health-week-2023',
                      look_up[11] ~ 'https://www.presidency.ucsb.edu/documents/joint-statement-president-biden-prime-minister-anthony-albanese-australia-and-prime-3',
                     look_up[12] ~ 'https://www.presidency.ucsb.edu/documents/statement-international-day-democracy',
                      look_up[13] ~ 'https://www.presidency.ucsb.edu/documents/remarks-teleconference-call-with-faith-leaders-the-jewish-high-holidays',
                     look_up[14] ~ 'https://www.presidency.ucsb.edu/documents/remarks-prince-georges-community-college-largo-maryland-1',
                     look_up[15] ~ 'https://www.presidency.ucsb.edu/documents/statement-the-death-eugene-buzzy-peltola-jr',
                     look_up[16] ~ 'https://www.presidency.ucsb.edu/documents/statement-the-appointment-penny-s-pritzker-united-states-special-representative-for',
                     look_up[17] ~ 'https://www.presidency.ucsb.edu/documents/proclamation-10624-national-powmia-recognition-day-2023',
                    look_up[18] ~ 'https://www.presidency.ucsb.edu/documents/proclamation-10623-national-hispanic-heritage-month-2023',
                   look_up[19] ~ 'https://www.presidency.ucsb.edu/documents/the-presidents-news-conference-before-foreign-correspondents',
                   look_up[20] ~ 'https://www.presidency.ucsb.edu/documents/executive-order-13757-taking-additional-steps-address-the-national-emergency-with-respect')) 







president = '/html/body/div[2]/div[4]/div/section/div/section/div/div/div[1]/div[1]/div/div[2]/h3/a'


get_statements = function(links_to_scrape){
  check = httr::GET(links_to_scrape)
  
  if(check$status_code >= 400){
    bad_link = links_to_scrape
    
    error_link_df = tibble(links = NA)
    
    error_link_df = rbind(error_link_df, bad_link)
    
    return(error_link_df)
  } else{
    cat(links_to_scrape, "is being scraped", "\n")
    session = bow(url = links_to_scrape, user_agent = "Please Contact Ryan Carlin at rcarlin@gsu.edu with questions or concerns",
                  force = TRUE)
    
    raw_text = scrape(session, content = "text/html; charset=UTF8") |> 
      html_elements('p') |> 
      html_text() |>
      as_tibble() |> 
      rename(text = value)
    
    raw_date = scrape(session, content = "text/html; charset=UTF8") |> 
      html_elements('.field-docs-start-date-time') |> 
      html_text() |> 
      as_tibble() |> 
      rename(date = value)
    
    raw_pres_name = scrape(session, content = "text/html; charset=UTF8") |> 
      html_elements(xpath = president) |> 
      html_text() |> 
      as_tibble() |> 
      rename(president = value)
    
    subject_of_message = scrape(session, content = "text/html; charset=UTF8") |> 
      html_elements('h1') |> 
      html_text() |> 
      as_tibble() |> 
      rename(subject_of_statement = value)
     
    output_data = bind_cols(raw_date, raw_pres_name , subject_of_message, raw_text, url = links_to_scrape) 
    


    Sys.sleep(sample(10, 1))
    return(output_data)
    
    

    
  }
  
}
rescraped_obama_exec_statements = get_statements(full_rescrape$fixed_url) 

fix_dates = rescraped_obama_exec_statements |>
  mutate(date = str_squish(date),
         date = mdy(date))

add_obabma_rescrape = bind_rows(smaller, fix_dates)



links_that_did_not_join = fixed_links |>
  anti_join(smaller, join_by(title == subject_of_statement))



check = smaller |>
  anti_join(fixed_links, join_by(subject_of_statement == title)) |>
  distinct(subject_of_statement, .keep_all = TRUE)

## okay those are roughly equivalent 

## lets just go ahead and rescrape this 

full_rescrapes = map(links_that_did_not_join$fixed_url, \(x) get_statements(x))




bound_full_rescrapes = full_rescrapes |>
  list_rbind() |>
  mutate(date = str_squish(date), 
         date = mdy(date))


get_rid_missing_urls = add_obabma_rescrape |>
  filter(!is.na(url)) |>
  bind_rows(bound_full_rescrapes) |>
  rename(title = subject_of_statement)

## this is not really working so I am just going to rescrape 
