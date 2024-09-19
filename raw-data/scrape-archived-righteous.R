pacman:::p_load(tidyverse, httr2, rvest)

raw_resecue = read_csv(here::here("data", "raw_places_of_rescues.csv")) 

raw_righteous = read_csv(here::here("data", "righteous_among_nations_names_ajpn.csv")) 

## this solution comes from
## https://stackoverflow.com/questions/76596578/r-webscraping-wayback-machine


archive_links = request("https://web.archive.org/cdx/search/cdx")

test = archive_links |> 
  req_url_query(url = raw_righteous[[158,2]],
                filter = "statuscode:200",
                collapse = "timestamp:8") |> 
  req_perform() |> 
  resp_body_string() |> 
  read_table(col_names = c("urlkey","timestamp","original","mimetype","statuscode","digest","length"),
             col_types = cols_only(timestamp = "c",
                                   original  = "c",
                                   mimetype  = "c",
                                   length    = "i")) |> 
  mutate(link = paste("https://web.archive.org/web", timestamp, original, sep = "/") |> tibble::char(shorten = "front"),
         timestamp = lubridate::ymd_hms(timestamp)) |> 
  select(timestamp, link, length)


get_archived_righteous = function(links, request_link = "https://web.archive.org/cdx/search/cdx"){
  
  Sys.sleep(sample(5:10, 1))
  cat("Retrieving info for", links, "\n")
  
  archive_links = request(request_link)
  
  
  archived_df = archive_links |> 
  req_url_query(url = links,
                filter = "statuscode:200",
                collapse = "timestamp:8") |> 
    req_perform() |> 
    resp_body_string() |> 
    read_table(col_names = c("urlkey","timestamp","original","mimetype","statuscode","digest","length"),
               col_types = cols_only(timestamp = "c",
                                     original  = "c",
                                     mimetype  = "c",
                                     length    = "i")) |> 
    mutate(link = paste("https://web.archive.org/web", timestamp, original, sep = "/") |> tibble::char(shorten = "front"),
           timestamp = lubridate::ymd_hms(timestamp)) |> 
    select(timestamp, link, length) 
  
  return(archived_df)
  
}

links_archive = raw_righteous$links

archived_scrapper = map(links_archive, possibly(get_archived_righteous))


bind_archive = archived_scrapper |> 
  list_rbind() |> 
  filter(str_detect(link, "juste")) 


## the problem is that we do not want to rescrape the same link 





write_csv(bind_archive, here::here("data", "archived-righteous.csv"))

archived_links_df = read_csv(here::here("data", "archived-righteous.csv"))


clean_archived_links_df = archived_links_df |> 
  mutate(last_bit = gsub(".*/([^/]+)$", "\\1", link)
) |> 
  distinct(last_bit, .keep_all = TRUE)
  
  



## okay it looks like we have the archived pages 
## now its time to scrapey 

name = read_html(clean_archived_links_df[[1,2]]) |> 
  html_elements(".titrepageitalbold") |> 
  html_text() |> 
  as_tibble()

## okay! so it looks like I can also get the name of the prefects if I eally 
## wanted but I am not all together not all that interested in that
## but could be useful 

commune_name = read_html(clean_archived_links_df[[1,2]]) |> 
  html_elements(".body11boldleft") |> 
  html_text() |> 
  as_tibble()



get_name_and_commune = function(link){
  name = read_html(link) |> 
    html_elements(".titrepageitalbold") |> 
    html_text() |> 
    as_tibble() |> 
    rename(name_of_the_righteous = value )
  
  
  commune_name = read_html(link) |> 
    html_elements(".body11boldleft") |> 
    html_text() |> 
    as_tibble() |> 
    rename(commune_name = value)
  
bound_data = bind_cols(name, commune_name, url = link)
  


sleepy_time = sample(8:10,1)

cat("Finished scraping", link, "going to sleep for", sleepy_time, "\n")

Sys.sleep(sleepy_time)

return(bound_data)
}


test = clean_archived_links_df |> 
  slice_sample(n = 5) |> 
  select(link) |> 
  deframe()


testing_data = map(test, get_name_and_commune )

## okay it looks like we have some changes in the structure of how things were recorded
## so slicing and dicing in the function is going to be wrought with problems 
check = testing_data |> 
  pluck(2)

righteous_links = clean_archived_links_df$link



see_what_is_happening = righteous_links[10:15]

testing_issues = map(see_what_is_happening, get_name_and_commune)

## so it looks like these work it may just have been a connection issue?
## okay lets check to see if we can 


see_what_is_happening = righteous_links[1:15]


testing_issues2 = map(see_what_is_happening, get_name_and_commune)


## so the issue is less that there is no content but the timeout 
## issue timeout after 78ms 
## https://stackoverflow.com/questions/36043172/package-rvest-for-web-scraping-https-site-with-proxy/38463559#38463559
see_what_is_happening[1] |> 
 httr::GET(, timeout = 10) |> 
  read_html() |> 
  html_elements(".titrepageitalbold") |> 
  html_text() 


get_name_and_commune = function(link, my_timeout = 10){
  
  
  name = httr::GET(link, timeout = my_timeout) |> 
    read_html() |> 
    html_elements(".titrepageitalbold") |> 
    html_text() |>  
    as_tibble() |> 
    rename(name_of_the_righteous = value )
  
  
  commune_name = httr::GET(link, timeout = my_timeout) |> 
    read_html() |> 
    html_elements(".body11boldleft") |> 
    html_text() |> 
    as_tibble() |> 
    rename(commune_name = value)
  
  bound_data = bind_cols(name, commune_name, url = link)
  
  
  
  sleepy_time = sample(8:10,1)
  
  cat("Finished scraping", link, "going to sleep for", sleepy_time, "\n")
  
  Sys.sleep(sleepy_time)
  
  return(bound_data)
}

testing_links = righteous_links[1:20]

testing_this = map(testing_links, get_name_and_commune)

## this seems to work 
## lets add a custom user agent 


get_name_and_commune = function(link, my_timeout = 10){
  introduce = polite::bow(link, user_agent = "For questions and Concerns please contact 
                                      Josh Allen at jallen108@gsu.edu")
  
  name = httr::GET(link, timeout = my_timeout) |> 
    read_html() |> 
    html_elements(".titrepageitalbold") |> 
    html_text() |>  
    as_tibble() |> 
    rename(name_of_the_righteous = value )
  
  
  commune_name = httr::GET(link, timeout = my_timeout) |> 
    read_html() |> 
    html_elements(".body11boldleft") |> 
    html_text() |> 
    as_tibble() |> 
    rename(commune_name = value)
  
  bound_data = bind_cols(name, commune_name, url = link)
  
  
  
  sleepy_time = sample(8:10,1)
  
  cat("Finished scraping", link, "going to sleep for", sleepy_time, "\n")
  
  Sys.sleep(sleepy_time)
  
  return(bound_data)
}


get_righteous = map(righteous_links, get_name_and_commune)


righteous_data = get_righteous |> 
  list_rbind()

write_csv(righteous_data, here::here("data", "ajpn-archived-righteous-data.csv"))




