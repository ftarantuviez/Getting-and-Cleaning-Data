answer_one <- function(){
  URL <- "https://api.github.com/users/jtleek/repos"
  r <- GET(URL)
  parsed_json <- content(r, "parsed")
  for(i in parsed_json){
    if(i$name == "datasharing"){
      print(i$created_at)
    }
  }
}

