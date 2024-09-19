#' Reading Executive Communications Dataset
#'  
#' This function imports data from the ECD 
#'  
#' 
#' 
#' 



load_ecd = \(country, full_ecd = FALSE, ecd_version = '1.0.0'){

  validate_inputs(coutnry, full_ecd, version = ecd_version)

  if(full_ecd == TRUE){
  
  url = glue::glue('https://github.com/joshuafayallen/executivestatements/releases/download/{ecd_version}/full_ecd.parquet')
  
  ecd_data = arrow::read_parquet(url)
  
  
  
  }
  
    
    return(ecd_data)
  
  }


devtools::