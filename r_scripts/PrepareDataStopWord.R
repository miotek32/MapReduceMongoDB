library(rmongodb)
library(stringr)
library(plyr)
library(parallel)
library(Hmisc)

PrepareLine <- function(readLine,data){
  splitLine <- str_split(readLine,"\\s+")
  splitLine <- unlist(splitLine)
  splitLine <- tolower(splitLine)
  stopWords <- match(splitLine,data)
  splitLine <- splitLine[is.na(stopWords) == TRUE] 
  splitLine[1] <- capitalize(splitLine[1])
  n <- length(splitLine)
  if(n >= 6 && n <= 12){
    return (splitLine)
  }
  return (NULL)
}

MakeListBson <- function(object){
  msg <- paste(c(object),collapse = ' ')
  buffer <- mongo.bson.buffer.create()
  i <<- i+1
  mongo.bson.buffer.append(buffer,"originalText",msg)
  mongo.bson.buffer.append(buffer,"_id",i)
  mongo.bson.buffer.append(buffer,"howWords",length(object))
  newobject <- mongo.bson.from.buffer(buffer)
  return(newobject)
}

CheckAndRemoveCollection <- function(mongo,nameDatabase){
  coll <- mongo.get.database.collections(mongo,"test")
  coll <- coll[coll == nameDatabase]
  if(length(coll) != 0){
    mongo.drop(mongo,coll)
  }
}

PrepareData <- function(line,stopList){
  numberCores <- detectCores()
  list <- mclapply(line,PrepareLine,data=stopList,mc.cores = numberCores)
  nullElements <- mclapply(list,is.null,mc.cores = numberCores)
  list <- list[nullElements == FALSE]
  return (list)
}

LoadStopWords <- function(language){
  if(language == "eng"){
    data <- scan("../data/stop-words-english1.txt",what=as.character())
  }
  else if(language == "pol"){
    data <- scan("../data/stop-words-polish2.txt",what=as.character())
  }
  else{
    stop("Language invalid. Correct languages are eng,pol")
  }
  return (data)
}

LoadData <- function(filename,howMuch,nameDatabase,language){
  stopList <- LoadStopWords(language)
  numberSteps <- 0
  i <<- 0
  numberCores <- detectCores()
  fileOpen <- file(filename,open ="r")
  mongo <- mongo.create()
  if(mongo.is.connected(mongo)){
    CheckAndRemoveCollection(mongo,nameDatabase)
    while(length(readLine <- readLines(fileOpen,n=howMuch,warn=FALSE)) > 0){
      numberSteps <- numberSteps + 1
      list <- PrepareData(readLine,stopList)
      bsonList <- lapply(list,MakeListBson)
      mongo.insert.batch(mongo,nameDatabase,bsonList)
      msg <- paste("Add",howMuch,"records per",numberSteps,sep=" ")
      print(msg)
    }
  }
  close(fileOpen)
}

main <- function(filename,howMuch,nameDatabase,language){
  LoadData(filename,howMuch,nameDatabase,language)
}

args = commandArgs(trailingOnly = TRUE)
if(length(args) < 4 ){
  stop("Correct usage: Rscript PrepareData.R <filename> <how lines load> <name collections> <language>")
}

main(as.character(args[1]),as.numeric(args[2]),as.character(args[3]),as.character(args[4]))
