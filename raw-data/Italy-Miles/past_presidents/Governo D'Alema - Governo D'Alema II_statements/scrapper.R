pacman::p_load(rvest, tidyverse)


links_data = read_csv("links.csv")



scrapper = \(links, agent = "Ryan Carlin rcarlin@gsu.edu"){
  agent = paste(agent)

  session = polite::bow(links, user_agent = agent)

  cat("Scraping", links, "\n")

  date_speak = read_html(links) |> 
    html_element('body > center > table:nth-child(2)') |> 
    html_table(trim = TRUE, header = TRUE) 

  colnames(date_speak) = c('speaker', 'date', 'ora') 

 cleaned_speaker = date_speak |> 
  filter(if_any(everything(), \(x) nchar(x) > 0)) |> 
   select(-ora)
  
text = read_html_live(links) |> 
  html_elements('body > center > table:nth-child(3) > tbody > tr > td > font:nth-child(3) > p') |>
  html_text() |> 
  as_tibble() |>
  rename(text = value) |> 
  mutate(text = str_squish(text)) |> 
  filter(nchar(text) > 0)

  
  
  tryCatch({

    bound_dat = bind_cols(cleaned_speaker, text, url = links)
    Sys.sleep(runif(1, 5, 8))
    return(bound_dat)
  }, error = \(e){
    error_message = errorCondition(e)

    if(grepl("recyled", e, ignore.case = TRUE)){
      
      recyling_error <<- tibble(url = links)
      Sys.sleep(runif(1, 5, 8))

    }else{
      
      rescrape_links  <<- tibble(url = links)
      Sys.sleep(runif(1, 5, 8))
    }


  })
    
  




}





clean_links = links_data |> 
  filter(str_detect(links, "&pg=[[0-9]]", negate = TRUE)) 

## so this should get rid of the pages links 
test_vec = clean_links |> 
  slice_sample(n = 5) |> 
  pull('links')




alema_list = map(clean_links$links, \(x) scrapper(x))

bound_alema = alema_list |> 
  list_rbind() |> 
  mutate(date = dmy(date))


table(bound_alema$speaker)

bound_alema |> 
  filter(speaker %in% c("Presidente CdM", "Presidenza")) |> 
write_csv('data/almemaiiandii_statements.csv')
