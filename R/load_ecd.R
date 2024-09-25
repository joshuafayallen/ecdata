#' Reading Executive Communications Dataset
#'  
#' This function imports data from the ECD 
#'  
#' @param country a character vector of country or countries in our dataset to download. For a list of valid names, call `country_dictionary` 
#' @param full_ecd to download the full Executive Communications Dataset set full_ecd to TRUE and don't provide an argument to the country argument
#' @param ecd_version a character of ecd versions. 
#' @importFrom vctrs list_unchop
#' 
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


load_ecd = \(country = NULL, full_ecd = FALSE, ecd_version = '1.0.0'){

  validate_inputs(country, full_ecd, version = ecd_version)

  if(full_ecd == TRUE && isTRUE(is.null(country))){

  
  url = glue::glue('https://github.com/joshuafayallen/executivestatements/releases/download/{ecd_version}/full_ecd.parquet')
  
  ecd_data = arrow::read_parquet(url)
    
  if(nrow(ecd_data) > 0){
    cli::cli_alert_success('Successfully downloaded the full ECD')

  }
  else{

    cli::cli_alert_danger('Download of ECD  failed')
  }
    
  }
  
  
  if(full_ecd == FALSE && length(country) == 1){
  
    link_to_read = link_builder(country =  country, ecd_version = ecd_version)

    
    ecd_data = arrow::read_parquet(link_to_read)

  
  }
    if(full_ecd == FALSE && length(country) > 1){

      links_to_read = link_builder(country = country, ecd_version = ecd_version)

      ecd_data = lapply(link_to_read, \(x) arrow::read_parquet(x))

      ecd_data = ecd_data |>
        list_unchop()

      if(nrow(ecd_data) != 0){
        cli::cli_alert_success('Successfully downloaded data for {country}')
      }
   

    }

    
  return(ecd_data)

  }