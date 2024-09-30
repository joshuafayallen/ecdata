#' Build our links 
#' 
#' @keywords internal
#' 
#' @export
#' 


link_builder = \(country = NULL, language = NULL, ecd_version){

  if(!isTRUE(is.null(country)) && isTRUE(is.null(language))){
  
    country_names = country_dictionary()
  
    country_names = country_names[country_names$name_in_dataset %in% country,]
  
    country_names = country_names |>
      within({
        file_names = glue::glue('https://github.com/joshuafayallen/executivestatements/releases/download/{ecd_version}/{file_name}.parquet')
      })
      country_names = country_names$file_names
  
  }
    
  if(isTRUE(is.null(country)) && !isTRUE(is.null(language))){
  
    country_names = country_dictionary()
  
    country_names = country_names[country_names$language %in% language,]
  
    country_names = country_names |>
      within({
        file_names = glue::glue('https://github.com/joshuafayallen/executivestatements/releases/download/{ecd_version}/{file_name}.parquet')
      })
      country_names = country_names$file_names
  
  }
    
    if(!isTRUE(is.null(country)) && !isTRUE(is.null(language))){
  
      country_names = country_dictionary()
  
      country_names = country_names[country_names$language %in% language | country_names$name_in_dataset %in% country,]
  
      country_names = country_names |>
        within({
          file_names = glue::glue('https://github.com/joshuafayallen/executivestatements/releases/download/{ecd_version}/{file_name}.parquet')
        })
        country_names = country_names$file_names
  
    }
    
   
  
    return(country_names)
  
  }