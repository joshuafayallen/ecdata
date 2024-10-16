pacman::p_load(rvest, tidyverse)


links = read_csv('links.csv')



links[[1,1]]


subject = links[[1,1]] |> 
  read_html_live() |> 
  html_elements('.title_large') |> 
  html_text()


date = links[[1,1]] |> 
  read_html_live() |> 
  html_elements('#articolo-12687 > div > div > div.col-md-6.col-sm-8 > div > div.post_content_title.clearfix > p') |> 
  html_text() 


text = links[[1,1]] |> 
  read_html_live() |> 
  html_elements('#articolo-12687 > div > div > div.col-md-6.col-sm-8 > div > div.field.field-name-body.field-type-text-with-summary.field-label-hidden > div > div') |> 
  html_text()


scrapper = \(links, agent = 'Ryan Carlin rcarlin@gsu.edu'){

   session = polite::bow(links, user_agent = paste(agent))

  
   subject = 
    read_html_live(links) |> 
    html_elements('#articolo-10258 > div > div > div.col-md-6.col-sm-8 > div > div.post_content_title.clearfix > h1') |> 
    html_text() |> 
     as_tibble() |> 
     rename(subject = value)
  
  
  date = 
    read_html_live(links) |> 
    html_elements('#articolo-10258 > div > div > div.col-md-6.col-sm-8 > div > div.post_content_title.clearfix > p') |> 
    html_text()  |> 
    as_tibble() |> 
    rename(date = value )
  
  
  text = 
    read_html_live(links) |> 
    html_elements('#articolo-10258 > div > div > div.col-md-6.col-sm-8 > div > div.field.field-name-body.field-type-text-with-summary.field-label-hidden') |> 
    html_text() |> 
    as_tibble() |> 
    rename(text = value)
  
   
   bound_dat = bind_cols(date, subject, text, url = links)
   
  
  if(nrow(bound_dat) == 0){
    print("This Didn't work")
    check_links <<- tibble(links)
  }
  {
    else{

      print("This didn't work")
  }
                      
   
  cat("Done scrapping:", links, '\n')

  Sys.sleep(runif(1, 5, 8))
  
  return(bound_dat)
  
  
}
}

test_vec = links |> 
  slice_sample(n = 5) 


test_list = map(test_vec$links, \(x) scrapper(x))



