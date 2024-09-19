pacman::p_load("tidyverse", "rvest", "polite")



robotstxt::get_robotstxt("https://www.regjeringen.no")

base_link = "https://www.regjeringen.no"

add_first_page = "https://www.beehive.govt.nz/minister/rt-hon-chris-hipkins?page=0"

first_page_df = tibble(links = paste0(add_first_page, seq(0,3,1))) 

first_page_df$links <- str_remove(first_page_df$links,"^0+$")

links_tibble = tibble(links = paste0(base_link,seq(1,4,1)))

sample(1:121, 5)


fake_link = "https://joshuafayallen.github.io/blog/asdf"

httr::GET(fake_link)


random_links = links_tibble |> 
  slice(c(1,2,18,50)) |> 
  add_row(links = fake_link) |> 
  deframe()


bow(random_links[1])

test_this = httr:::GET(add_first_page)

test_this$status_code

# It is best to go and test what div returns what we want 
# in this case if you click on the link it redirects to # documents/name-of-statement
# instead of fiddling with trying to figure out how to click then scrape the clicked link
# I can grab the hrefs 
key_release_links0 = read_html("https://www.beehive.govt.nz/search?query=&f%5B0%5D=content_type_facet%3Aarticle&f%5B1%5D=government_facet%3A6064&f%5B2%5D=ministers%3A6066&f%5B0%5D=content_type_facet%3Aarticle&f%5B1%5D=government_facet%3A6064&f%5B2%5D=ministers%3A6066&page=") |> 
  html_elements(".field-content a") |>
  html_attr('href') |>
  as_tibble() |>
  rename(links = value)

key_release_links1 = read_html("https://www.beehive.govt.nz/search?query=&f%5B0%5D=content_type_facet%3Aarticle&f%5B1%5D=government_facet%3A6064&f%5B2%5D=ministers%3A6066&f%5B0%5D=content_type_facet%3Aarticle&f%5B1%5D=government_facet%3A6064&f%5B2%5D=ministers%3A6066&page=1") |> 
  html_elements(".field-content a") |>
  html_attr('href') |>
  as_tibble() |>
  rename(links = value)
  
#put all data frames into list
df_list <- list(key_release_links0, key_release_links1)

#merge all data frames in list
key_release_links <- df_list %>% reduce(full_join, by='links') %>%
  rename(value = links)


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
      html_elements('.title a') |>
      html_attr("href") |>
      as_tibble()
    
    return(raw_links)
    
    Sys.sleep(sample(10:15, 1))
    
  }
}

links_scrape = links_tibble |> 
  deframe()

norway_links = map(links_scrape,\(x) scraping_links(links_to_scrape = x),
                       .progress = TRUE)


compacted_links = norway_links |> 
  compact() |> 
  list_rbind() |>
  mutate(links = paste0(base_link, value))


## lets just save myself the trouble of having to rescrape everythingg
write_csv(compacted_links, here::here("data", "norway_links.csv"))

## looks like I acciendly put an extraneous / so lets just redo the links 
links_df = read_csv(here::here("data", "norway_links.csv")) |> 
  mutate(links = paste0(base_link, value))

links_df = read_csv("data/norway_links.csv")


### lets get the content of this one 


text_test = read_html("https://www.regjeringen.no/en/aktuelt/human-rights-75-pledges-pledging-event/id3016250/") |> 
  html_elements('.article-body') |> 
  html_text() |>
  as_tibble() |> 
  rename(text = value)

date_test = read_html("https://www.regjeringen.no/en/aktuelt/human-rights-75-pledges-pledging-event/id3016250/") |> 
  html_elements('.date') |> 
  html_text() |> 
  as_tibble() |> 
  rename(date = value)

title_test = read_html("https://www.regjeringen.no/en/aktuelt/human-rights-75-pledges-pledging-event/id3016250/") |>
  html_elements('h1') |>
  html_text() |>
  as_tibble() |>
  rename(title = value)

test_df = bind_cols(text_test, date_test, title_test)


# Lets get a little function going 

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
      html_elements('.article-body p') |> 
      html_text() |>
      as_tibble() |>
      rename(text = value)
    
    raw_date = scrape(session, content = "text/html; charset=UTF8") |> 
      html_elements('.date') |> 
      html_text() |> 
      as_tibble() |>
      rename(date = value)
    
    raw_title = scrape(session, content = "text/html; charset=UTF8") |> 
      html_elements('h1') |> 
      html_text() |> 
      as_tibble() |>
      rename(title = value)
    
  #  raw_from = scrape(session, content = "text/html; charset=UTF8") |> 
  #    html_elements('.gem-c-metadata__definition:nth-child(2)') |> 
  #    html_text() |> 
  #    as_tibble() |>
  #    rename(from = value)
    
    output_data = bind_cols(raw_date, raw_title, raw_text)
    
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
  list_rbind() |>
  distinct()

  
write_csv(combined_statement_data, here::here("data", "norway_statements.csv"))


