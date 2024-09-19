pacman::p_load(rvest, tidyverse)

links_dat = read_csv("links.csv")


table(links_dat$speaker)

clean_links_dat = links_dat |> 
  mutate(speaker = str_squish(speaker)) |> 
  filter(speaker %in% c("Presidenza", "Presidente CdM"))


scrapper = \(links, agent = 'please contact Ryan Carlin at rcarlin@gsu.edu'){
  session = polite::bow(links, user_agent = paste(agent))

 cat("scrapping", links, '\n')
  subject = read_html_live(links) |> 
    html_elements('body > center > table:nth-child(5) > tbody > tr > td > span') |> 
    html_text() |> 
    as_tibble() |> 
    rename(subject = value)
  
  
  date = read_html_live(links) |> 
    html_elements('body > center > table:nth-child(2) > tbody > tr:nth-child(3) > td:nth-child(2) > span') |> 
    html_text() |> 
      as_tibble() |> 
        rename(date = value)
  
  text = read_html_live(links) |> 
    html_elements('body > center > table:nth-child(7) > tbody > tr > td > span') |>
    html_text() |> 
    as_tibble() |> 
      as_tibble() |> 
        rename(text = value)
  

  tryCatch({

    bound_dat = bind_cols(date, subject,  text, url = links)
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



alema_list = map(clean_links_dat$links, \(x) scrapper(x))

bound_alema = list_rbind(alema_list)  |> 
  mutate(date = dmy(date))

write_csv(bound_alema, "data/almea_amato_statements.csv")
