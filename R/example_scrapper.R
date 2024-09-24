#' This is a helper function to help you the scrape the web
#' 
#' opens and example webscraper in your texteditor 
#' 
#' @param scrapper_type calls the example scrapper scripts. Should be one of static or dynamic which matches the kind of scrapper you want to use
#' 
#' @export
#' 


example_scrapper = \(scrapper_type = c('static', 'dynamic')){
 

arg = match.arg(scrapper_type)
  
  if(arg == 'static'){

   file_path = file.path("inst", 'static-scrapper.R')

    script_path = system.file(file_path, package = 'ecdata', mustWork = TRUE)

  
  }

  if(arg == 'dynamic'){
   
    file_path = file.path("inst", 'dynamic-scrapper.py')

    script_path = system.file(file_path, package = 'ecdata', mustWork = TRUE)

    

  }

 
  

  usethis::edit_file(script_path, open = TRUE)

  invisible()

}
