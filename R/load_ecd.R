#' Reading Executive Communications Dataset
#'  
#' This function imports data from the ECD 
#'  
#' @param country a character vector  with a country or countries in our dataset to download. For a list of valid names, call "ecd_country_dictionary"
#' @param language a character vector with a lanaguage or languages in our dataset to download. For a list of valid languages call "ecd_country_dictionary"
#' @param full_ecd to download the full Executive Communications Dataset set full_ecd to TRUE and don't provide an argument to the country argument
#' @param ecd_version a character of ecd versions. 
#' @importFrom vctrs list_unchop
#' @importFrom arrow read_parquet
#' @export
#' @examples
#' \dontrun{
#' library(ecdata)
#' 
#' ## load one country 
#' 
#' load_ecd(country = 'United States of America')
#' 
#' ## displays data from the USA
#' 
#' 
#' ## load multiple countries 
#' 
#' load_ecd(country = c('Turkey', 'Republic of South Korea', 'India'))
#'
#' ## displays data from Turkey, South Korea, and India
#' 
#' # load full ecd 
#' 
#' 
#' load_ecd(full_ecd = TRUE)
#' }
#' 
#' @export
#' 


load_ecd = \(country = NULL, language = NULL , full_ecd = FALSE, ecd_version = '1.0.0'){

  validate_inputs(country, full_ecd, version = ecd_version)

  if(full_ecd == TRUE && isTRUE(is.null(country)) && isTRUE(is.null(language))){

  
  url = glue::glue('https://github.com/joshuafayallen/executivestatements/releases/download/{ecd_version}/full_ecd.parquet')
  
  ecd_data = read_parquet(url)
    
  if(nrow(ecd_data) > 0){
    cli::cli_alert_success('Successfully downloaded the full ECD')

  }
  else{

    cli::cli_alert_danger('Download of ECD  failed')
  }
    
  }
  
  
  if(full_ecd == FALSE && length(country) == 1 && isTRUE(is.null(language))){
  
    link_to_read = link_builder(country =  country, ecd_version = ecd_version)

    
    ecd_data = read_parquet(link_to_read)

    if (nrow(ecd_data) > 1) {

      cli::cli_alert_success('Successfully downloaded {country} data')
      
    }
  
  }
<<<<<<< HEAD

=======
>>>>>>> origin/main
    if(full_ecd == FALSE && length(country) > 1 && isTRUE(is.null(language))){

      links_to_read = link_builder(country = country, ecd_version = ecd_version)

      ecd_data = lapply(link_to_read, \(x) read_parquet(x))

      ecd_data = ecd_data |>
        list_unchop()


      if(nrow(ecd_data) != 0){
        cli::cli_alert_success('Successfully downloaded data for {country}')
      }
   

    }

  if(full_ecd == FALSE && isTRUE(is.null(country)) && length(language) == 1){
     
    if(language == 'English'){
      cli::cli_alert_info('Language is set to English. Note due to data availability Azerbaijan and Russian will be included in this data')
    }

<<<<<<< HEAD
    link_to_read = link_builder(language = language, ecd_version = ecd_version)
=======
    link_to_read = link_builder(country =  country, ecd_version = ecd_version)
>>>>>>> origin/main

    
    ecd_data = arrow::read_parquet(link_to_read)

    if(nrow(ecd_data) > 0){

      cli::cli_alert_success('Successfully downloaded data for {language}')
    }


  }

<<<<<<< HEAD
=======
  }

>>>>>>> origin/main
  if(full_ecd == FALSE && isTRUE(is.null(country)) && length(language) > 1){
     
    if(language == 'English'){
      cli::cli_alert_info('Language is set to English. Note due to data availability Azerbaijan and Russian will be included in this data')
    }

<<<<<<< HEAD
    links_to_read = link_builder(language = language, ecd_version = ecd_version)
=======
    links_to_read = link_builder(country =  country, ecd_version = ecd_version){
>>>>>>> origin/main



    
    ecd_data = lapply(links_to_read, \(x) read_parquet(x)) |>
      list_unchop()

    if(nrow(ecd_data) > 0){

      cli::cli_alert_success('Successfully downloaded data for {language}')
    }


  }
    
  if(full_ecd == FALSE && length(language) >= 1 && length(country) >= 1){

     links_to_read = link_builder(country = country, language = language)
    
    ecd_data = lapply(links_to_read, \(x) read_parquet(x)) |>
      list_unchop()

    if(nrow(ecd_data) > 0){

      cli::cli_alert_success("Successfully downloaded {country} and {language}")
    }
    

  }

    
  return(ecd_data)

  }