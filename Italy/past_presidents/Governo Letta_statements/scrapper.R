pacman::p_load(rvest, tidyverse)

links_dat = read_csv('links.csv') |> 
  filter(speaker %in% c('Presidenza', "Presidente CdM"))

scrapper = \(links){

  cat('Scraping', links, '\n')
   



  text = read_html_live(links) |> 
  html_elements('#tdTesto > div > p') |> 
  html_text() |> 
  as_tibble() |> 
  rename(text = value)
  
  
  subject = read_html_live(links) |> 
    html_elements('#dvTestaPagina') |> 
    html_text() |> 
    as_tibble() |> 
    rename(subject = value)


  tryCatch({
    
    bound_data = bind_cols(text, subject,  url = links)
     
    Sys.sleep(runif(1, 5, 8))

    return(bound_data)

  }, error = function(e){
     
    error_message = errorCondition(e)

    if(grepl('recyled', error_message, ignore.case = TRUE)){

      cat('recyling error', links, '\n')

      links_fail = tibble(url = links, rows = nrow(e))

    failed_links <<- bind_rows(failed_links, links_fail )}
    

    else{

    

      links_fail = tibble(url = links)

      failed_links <<- bind_rows(failed_links, links_fail )

      cat('Something wonky happened', '\n')

      


    }
  })


}




letta_dat = map(links_dat$links, \(x) scrapper(x))

bound_letta_dat  = letta_dat |> 
  list_rbind()




joined_data = links_dat |> 
  select(date, links) |> 
  left_join(bound_letta_dat, join_by(links == url))


### one annoying thin is that we have the dates in there so we need to just extract those 


italian_months <- c("Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno", "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre")



cleaned_data = joined_data |> 
  filter(str_detect(text, paste(italian_months, collapse = '|'), negate = TRUE)) |> 
  filter(nchar(text) > 0) |> 
  mutate(date = dmy(date),
         subject = str_squish(subject)) |> 
  relocate(links, .after = subject)

## looks like the failed links object in your environment is a holdover from testing 
cleaned_data |> 
  filter(links %in% failed_links$url)


head(cleaned_data)

dir.create('data')
write_csv(cleaned_data,'data/letta_statements.csv')
