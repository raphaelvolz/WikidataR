#Generic queryin' function for direct Wikidata calls. Wraps around WikipediR::page_content.
wd_query <- function(title, ...){
  result <- WikipediR::page_content(domain = "wikidata.org", page_name = title, as_wikitext = TRUE,
                                    httr::user_agent("WikidataR - https://github.com/Ironholds/WikidataR"),
                                    ...)
  output <- jsonlite::fromJSON(result$parse$wikitext[[1]])
  class(output) <- "wikidata"
  return(output)
}

#Query for a random item in "namespace" (ns). Essentially a wrapper around WikipediR::random_page.
wd_rand_query <- function(ns, limit, ...){
  result <- WikipediR::random_page(domain = "wikidata.org", as_wikitext = TRUE, namespaces = ns,
                                   httr::user_agent("WikidataR - https://github.com/Ironholds/WikidataR"),
                                   limit = limit, ...)
  output <- lapply(result, function(x){jsonlite::fromJSON(x$wikitext[[1]])})
  class(output) <- "wikidata"
  return(output)
  
}

#Generic input checker. Needs additional stuff for property-based querying
#because namespaces are weird, yo.
check_input <- function(input, substitution){
  in_fit <- grepl("^\\d+$",input)
  if(any(in_fit)){
    input[in_fit] <- paste0(substitution, input[in_fit])
  }
  return(input)
}

#Generic, direct access to Wikidata's search functionality.
searcher <- function(search_term, language, limit, type, ...){
  url <- paste0("wikidata.org/w/api.php?action=wbsearchentities&format=json&type=",type)
  url <- paste0(url, "&language=", language, "&limit=", limit, "&search=", search_term)
  result <- WikipediR::query(url = url, out_class = "list", clean_response = FALSE, ...)
  result <- result$search
  return(result)
}

#'@importFrom utils URLencode
sparql_query <- function(params, ...){
  url <- paste0("https://query.wikidata.org/bigdata/namespace/wdq/sparql?query=", params)
  result <- httr::GET(utils::URLencode(url), httr::user_agent("WikidataR - https://github.com/Ironholds/WikidataR"),
                      ...)
  httr::stop_for_status(result)
  return(httr::content(result, as = "parsed", type = "application/json"))
}

