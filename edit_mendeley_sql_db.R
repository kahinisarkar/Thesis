library(RSQLite)
library(tidyverse)

mendeley.path = "C:/Users/Elliot/AppData/Local/Mendeley Ltd/Mendeley Desktop/elliotmartin92@gmail.com@www.mendeley.com.sqlite"
mendeley.connection = dbConnect(RSQLite::SQLite(),mendeley.path)
head(dbListTables(mendeley.connection),n=10)
dbListFields(mendeley.connection,"Documents")

extract.table <- function(con,query){
  
  res <- dbSendQuery(con,query) # Send query
  
  table <- dbFetch(res) # Fetch table
  
  dbClearResult(res) # Free resources
  
  return(table)
  
}

shortTitle <- extract.table(mendeley.connection, "SELECT id, title FROM Documents")

dbGetQuery(mendeley.connection, "select * from Documents") %>%
  as_tibble()

update_query <- "UPDATE Documents SET shortTitle = citationKey"

dbSendQuery(mendeley.connection, update_query)

shortTitle <- extract.table(mendeley.connection, "SELECT id, shortTitle FROM Documents")
dbDisconnect(mendeley.connection)

