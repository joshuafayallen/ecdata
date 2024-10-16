pacman::p_load("tidyverse", "rvest", "polite")



robotstxt::get_robotstxt("https://www.presidency.ucsb.edu/documents/app-categories/presidential")

base_link = "https://www.presidency.ucsb.edu/documents/app-categories/presidential"

add_first_page = "https://www.presidency.ucsb.edu/documents/app-categories/presidential?items_per_page=60&field_docs_start_date_time_value%5Bvalue%5D%5Bdate%5D="

first_page_df = tibble(links = paste0(add_first_page, seq(1963,2022,1)))


links_tibble = tibble(links = paste0(base_link,"?","items_per_page=60","&field_docs_start_date_time_value%5Bvalue%5D%5Bdate%5D=",
                                     seq(1963,2023),"&","page=",seq(1,20,1))) |> 
  bind_rows(first_page_df)


sample(1:121, 5)


fake_link = "https://joshuafayallen.github.io/blog/asdf"

httr::GET(fake_link)


random_links = links_tibble |> 
  slice(c(1,2,18,50)) |> 
  add_row(links = fake_link) |> 
  deframe()


bow(random_links[1])

test_this = httr:::GET(random_links[1])

test_this$status_code

# It is best to go and test what div returns what we want 
# in this case if you click on the link it redirects to # documents/name-of-statement
# instead of fiddling with trying to figure out how to click then scrape the clicked link
# I can grab the hrefs 
testing_this = read_html("https://www.presidency.ucsb.edu/documents/app-categories/presidential?items_per_page=60&field_docs_start_date_time_value%5Bvalue%5D%5Bdate%5D=2022") |> 
  html_elements('div.col-sm-8 > div > p > a') |>
  html_attr("href") |>
  as_tibble()



test_this 

is.atomic(fake_link)

scraping_links = function(links_to_scrape){
  
  check_link = httr::GET(links_to_scrape) # this checks to see if the links are can be foun
  
  if(check_link$status_code >= 400){ ## if any of the links return a status code greater than 400
  
  ## just making a blank data.frame so it does not interrupt anything 
  bad_link = links_to_scrape
    
   error_link_df = tibble(links = NA)
   
   error_link_df = rbind(error_link_df, bad_link)
   
   return(error_link_df)
    
  } else{
    ## Just so I know what is going on and if something fails not due to status code
    cat("Starting to Scrape", links_to_scrape, "\n")
    
    # this sets a user agent 
    session = bow(url = links_to_scrape, user_agent = "Please Contact Ryan Carlin at rcarlin@gsu.edu with questions or concerns",
                  force = TRUE)
    
    raw_links = scrape(session, content = "text/html; charset=UTF8") |> 
      html_elements('div.col-sm-8 > div > p > a') |>
      html_attr("href") |>
      as_tibble()
    
    return(raw_links)
    
    Sys.sleep(sample(10:15, 1))
    
  }
}

links_scrape = links_tibble |> 
  deframe()

presidency_links = map(links_scrape,\(x) scraping_links(links_to_scrape = x),
                       .progress = TRUE)


compacted_presidency = presidency_links |> 
  compact() |> 
  list_rbind() |> 
  mutate(links = paste0("https://www.presidency.ucsb.edu/", value)) 


dir.create("data")


## lets just save myself the trouble of having to rescrape everythingg
write_csv(compacted_presidency, here::here("data", "document_links.csv"))

## looks like I acciendly put an extraneous / so lets just redo the links 
links_df = read_csv(here::here("data", "document_links.csv")) |> 
  mutate(links = paste0("https://www.presidency.ucsb.edu", value))



link = links_df[[1,2]]

## looks good 
check = httr::GET(links_df[[1,2]])


selector = 'div class="field-docs-content"'

date_selector = '/html/body/div[2]/div[4]/div/section/div/section/div/div/div[1]/div[2]'


### lets get the content of this one 


test = read_html(link) |> 
  html_elements('p') |> 
  html_text() |>
  as_tibble() |> 
  rename(text = value)

date_test = read_html(link) |> 
  html_elements('.field-docs-start-date-time') |> 
  html_text() |> 
  as_tibble() |> 
  rename(date = value)

bound_cols = bind_cols(test, date_test)

clean_the_text = bound_cols |> 
  filter(str_detect(text, 'About|Twitter|Copyright', negate = TRUE), nchar(text) > 1) 


## lets see if we can get name of the president easily 
## so that works
president = '/html/body/div[2]/div[4]/div/section/div/section/div/div/div[1]/div[1]/div/div[2]/h3/a'

## now lets see if we can get the subject of the message 

check = read_html(link) |> 
  html_elements('h1') |> 
  html_text() |> 
  as_tibble()




## Lets get a little function going 

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
     
    output_data = bind_cols(raw_date, raw_pres_name , subject_of_message, raw_text) |> 
      filter(str_detect(text, 'About|Twitter|Copyright', negate = TRUE), nchar(text) > 1)
    
  return(output_data)
    
    
   Sys.sleep(sample(10:15, 1))
    
  }
  
}




test = links_df |> 
  select(links) |> 
  slice_sample(n = 5) |> 
  deframe()


test_scraping_function = map(test, get_statements)

check_data = test_scraping_function |> 
  pluck(1)


scrape_links = links_df |> 
  select(links) |> 
  deframe()


statement_data = map(scrape_links, get_statements, .progress = TRUE)


combined_statement_data = statement_data |> 
  list_rbind()



write_csv(combined_statement_data, here::here("data", "us_president_statements.csv"))





