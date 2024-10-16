pacman::p_load(rvest, tidyverse)

berlusc_iv = read_csv("links.csv")


head(berlusc_iv)

rel_links = berlusc_iv |> 
  filter(speaker %in% c('Presidente CdM', 'Presidenza')) |> 
  distinct(url, .keep_all = TRUE)



subject = rel_links[[6,3]] |> 
  read_html_live() |> 
  html_elements('#tdTestaPagina') |> 
  html_text2()


text = rel_links[[6,3]] |> 
  read_html_live() |>
  html_elements('#tdTesto > div > p') |> 
  html_text() |> 
  as_tibble()


scrapper = \(links, agent = 'For questions please contact Ryan Carlin at rcarlin@gsu.edu'){
  ag = rlang::englue('{agent}')

  session = polite::bow(links, user_agent = ag)


  subject = links |> 
  read_html_live() |> 
  html_elements('#tdTestaPagina') |> 
  html_text2() |> 
    as_tibble() |> 
    rename(subject = value)


text = links |> 
  read_html_live() |>
  html_elements('#tdTesto > div > p') |> 
  html_text() |> 
  as_tibble() |> 
  rename(text = value)

tryCatch({
   bound_dat = bind_cols(text, subject, url = links)},
  error = \(e){
       
    errmessage = conditionMessage(e)

    if(grepl('recyled', errmessage, ignore.case = TRUE)){
       cat(links, "Failed to make a dataframe", '\n')

      bad_data <<- data.frame(url = links)

    }else{
      cat('SOmething went wrong that was not a recyling error')
       
      bad_data <<- data.frame(url = links)
    }
 


  })
 
  cat("Done Scraping", links, "\n")

  Sys.sleep(runif(1, 5, 8))

  return(bound_dat)

}


test_link = rel_links |> 
  slice_sample(n = 5) |> 
  pull('url')



check = map(test_link, \(x) scrapper(x))



berlus_links = map(rel_links$url, \(x) scrapper(x))


bound_data = berlus_links |> 
  list_rbind() |> 
  left_join(rel_links, join_by(url)) |> 
  mutate(date = dmy(date)) |> 
  slice(-1, .by = url) |> 
  filter(nchar(text) > 0)

head(bound_data)

if(dir.exists('data')){
  write_csv(bound_data, "data/berlusconi_iv_statements.csv")
}else{
  dir.create('data')
  write_csv(bound_data, "data/berlusconi_iv_statements.csv")
}
