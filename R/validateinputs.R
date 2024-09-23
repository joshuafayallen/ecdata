#' Get latest release 
#' keywords @internal 
#' @noRd




get_ecd_release = \(){
  
 ecd_versions = piggyback::pb_releases(repo = 'joshuafayallen/executivestatements')
  
 versions = ecd_versions$release_name 
 

return(versions)
}



#' Validate input parameters
#' keywords @internal 
#' @noRd

validate_inputs = \(country = NULL, full_ecd = FALSE, version = '1.0.0'){
 
  versions = get_ecd_release()

  countries = country_dictionary()$name_in_dataset

  if(isTRUE(is.null(country)) && full_ecd == FALSE){

   cli::cli_abort('Please provide a country name or set full_ecd to TRUE')

  }

  if(!isTRUE(is.character(country)) && full_ecd == FALSE){

    country_type = typeof(country)

    cli::cli_abort('Country should be a character vector but is {country_type}')


  }

  if(!version %in% versions){


   cli::cli_abort('Stop version is {version} please set it to one of {versions}')


  }
  if(!country %in% countries){
    
    cli::cli_abort('Stop {country} is not in our dataset. Call country_names() for a list of valid country names')



  }



}




