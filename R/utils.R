#' Build our links 
#' 
#' @keywords internal
#' 
#' @export
#' 


link_builder = \(country, ecd_version){


  country_names = country_dictionary()

  country_names = country_names[country_names$name_in_dataset %in% country,]

  country_names = country_names |>
    within({
      file_names = glue::glue('https://github.com/joshuafayallen/executivestatements/releases/download/{ecd_version}/{file_name}.parquet')
    })
    country_names = country_names$file_names

  
  
 

  return(country_names)

}
