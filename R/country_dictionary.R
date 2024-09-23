#' internal function to print our country names
#' 
#' @noRd
#' 


dictionary = \(){
  
  country_names = 'name_in_dataset, file_name,
        Argentina,  argentina,
        Australia,  australia,
        Austria,  austria,
        Azerbaijan,  azerbaijan,
        Bolivia,  bolivia,
        Brazil, brazil,
        Canada,  canada,
        Chile,  chile,
        Colombia,  colombia,
        Costa Rica,  costa_rica,
        Czechia,  czechia,
        Denmark,  denmark,
        Ecuador,  ecuador,
        France,  france,
        Georgia,  georgia,
        Germany,  germany,
        Greece,  greece,
        Hong Kong,  hong_kong,
        Hungary,  hungary,
        Iceland,  iceland,
        India,  india,
        Indonesia,  indonesia,
        Israel,  israel,
        Italy,  italy,
        Jamaica,  jamaica,
        Japan,  japan,
        Mexico,  mexico,
        New Zealand,  new_zealand,
        Nigeria,  nigeria,
        Norway,  norway,
        Philippines,  philippines,
        Poland,  poland,
        Portugal,  portugal,
        Republic of South Korea,  republic_of_south_korea,
        Russia,  russia,
        Spain,  spain,
        Turkey,  turkey,
        United Kingdom,  united_kingdom,
        United States of America,  united_states_of_america,
        Uruguay,  uruguay,
        Venzuela,  venzuela'

out = utils::read.csv(
  text = country_names,
  colClasses = c('character', 'character')
) 
  
out = out[, c(1:2)]

for (i in 1:2) {

  out[[i]] = trimws(out[[i]])
  
}

return(out)

}


#' Data.frame of the names of the countries in our dataset 
#' This is a simple helper function for the user to pass valid names 
#' to read_communications 
#' 
#' @docType data
#' @keywords datasets
#' @name get_dictionary
#' @format data.frame with 2 columns of character data: name_in_dataset, file_name
#' @examples
#' if(identical(Sys.getenv('pkgdown'), "true")){
#'   
#'    country_names = country_dictionary()
#' 
#'     head(country_names)
#' 
#'    #>   name_in_dataset  file_name
#> 1       Argentina  argentina
#> 2       Australia  australia
#> 3         Austria    austria
#> 4      Azerbaijan azerbaijan
#> 5         Bolivia    bolivia
#> 6          Canada     canada  
#' 
#' }
#' @export
#

country_dictionary = dictionary()


