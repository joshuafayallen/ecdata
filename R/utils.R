#' Build our links 
#' 
#' @keywords internal
#' 
#' 
#' 


link_builder = \(country = NULL, ecd_version){

  country_names = dictionary()

  country_names$file_names = glue::glue('https://github.com/joshuafayallen/executivestatements/releases/download/{ecd_version}/{country_names$file_name}.parquet')

  country_names = country_names[country_names$name_in_dataset %in% country,]
  
  country_names = country_names$file_names
  


}
