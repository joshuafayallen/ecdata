#' Reading Executive Communications Dataset
#'  
#' This function imports data from the ECD 
#'  
#' 
#' 
#' 



load_ecd = \(country = NULL, full_ecd = FALSE, ecd_version = '1.0.0'){

  validate_inputs(country = country, full_ecd, version = ecd_version)

  if(full_ecd == TRUE){
  
  url = glue::glue('https://github.com/joshuafayallen/executivestatements/releases/download/{ecd_version}/full_ecd.parquet')
  
  ecd_data = arrow::read_parquet(url)
  
  
  
  }
  if(full_ecd != TRUE && !isTRUE(is.null(country))){

  link_builder(country = country, ecd_version = ecd_version)


  }
  
    
    return(ecd_data)
  
  }

