pacman::p_load(rvest, tidyverse)


berlusconi_links = read_csv("links.csv")




scrapper = \(links, agent = 'For questions please contact Ryan Carlin at rcarlin@gsu.edu'){
 if(!is.character(agent) || nchar(agent) == 0){
   stop(print("Set a user agent"))
 } else{
   
   ag = rlang::englue('agent')

   session = polite::bow(links, user_agent = ag)
   
   text = read_html_live(links) |>
   html_element('#tdtesto .dvtesto p') |> 
   html_text() |> 
   as_tibble() |> 
   rename(text = value) 
   
   subject = read_html_live(links) |> 
    html_element('#tdtesto .dvtesto p') |> 
    html_text() |> 
    as_tibble() |> 
    rename(subject = value)

   bound_data = bind_cols(subject, text, url = links)

   if(nrow(bound_data) != 0){
     cat(links, 'Was Scraped sleeping for a lil', '\n')
     Sys.sleep(runif(1, min = 5, max = 8))

     
     
   }else{
    
     links_that_failed <<- tibble(url = links)
     cat("Oh no", links, "didn't work sleeping", "\n")

     Sys.sleep(runif(1, min = 5, max = 8))

   }

  return(bound_data)
 }

  
  

}


test_links = slice_sample(berlusconi_links, n = 10) |> 
  pull('url')




dedup = berlusconi_links |> 
  distinct(url, .keep_all = TRUE)


berlusconi_text = map(dedup$url, \(x) scrapper(x))


berlusconi_full = berlusconi_text |> 
  list_rbind()


add_dates = berlusconi_full |> 
  left_join(dedup, join_by(url)) |> 
  mutate(date = dmy(date, locale =  "it_IT.UTF-8"))




if(dir.exists("statements")){
  write_csv(add_dates, "statements/berlusconi_two_statements.csv")
}else{
  dir.create('statements')
  write_csv(add_dates, "statements/berlusconi_two_statements.csv")
}
