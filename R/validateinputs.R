#' Get latest release 
#' 
#' keywords @internal 




get_ecd_release = \(){
  
 ecd_versions = piggyback::pb_releases(repo = 'joshuafayallen/executivestatements')
  
 versions = ecd_versions$release_name 
 

return(versions)
}

get_ecd_release()


#' Validate input parameters
#'
#' keywords @internal 

validate_inputs = \(country = NULL, full_ecd = FALSE, version = '1.0.0'){
 
  ## first lets validate the first two inputs 

  if(isTRUE(is.null(country)) && full_ecd == FALSE){

   cli::cli_abort('Please provide a country name or set full_ecd to TRUE')

  }

  if(!isTRUE(is.character(country)) && full_ecd == FALSE){

    country_type = typeof(country)

    cli::cli_abort('Country should be a character vector but is {country_type}')


  }

  if(!version %in% get_ecd_release()){

  releases = get_ecd_release()

   cli::cli_abort('Stop version is {version} please set it to one of {releases}')


  }



}




