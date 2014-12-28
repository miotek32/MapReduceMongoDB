library(rmongodb)
library(stringr)
library(plyr)
library(parallel)

PrepareLine <- function(readLine){
  readLine <- gsub('[[:punct:]]',"",readLine)
  splitLine <- str_split(readLine,"\\s+")
  splitLine <- unlist(splitLine)
  if(splitLine[1] == ""){
    splitLine <- splitLine[-1]
  }
  if(length(splitLine) >= 8 && length(splitLine) <= 14){
    return (splitLine[-length(splitLine)])
  }
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

PrepareData <- function(line){
  numberCores <- detectCores()
  list <- mclapply(line,PrepareLine,mc.cores = numberCores)
  nullElements <- mclapply(list,is.null,mc.cores = numberCores)
  list <- list[nullElements == FALSE]
  return (list)
}

LoadData <- function(filename,howMuch,nameDatabase){
  numberSteps <- 0
  i <<- 0
  numberCores <- detectCores()
  fileOpen <- file(filename,open ="r")
  mongo <- mongo.create()

  if(mongo.is.connected(mongo)){
    CheckAndRemoveCollection(mongo,nameDatabase)
    while(length(readLine <- readLines(fileOpen,n=howMuch,warn=FALSE)) > 0){
      numberSteps <- numberSteps + 1
      list <- PrepareData(readLine)
      bsonList <- lapply(list,MakeListBson)
      mongo.insert.batch(mongo,nameDatabase,bsonList)
      msg <- paste("Add",howMuch,"records per",numberSteps,sep=" ")
      print(msg)
    }
  }
  close(fileOpen)
}

main <- function(filename,howMuch,nameDatabase){
  LoadData(filename,howMuch,nameDatabase)
}

main("data/sample.txt",10000,"test.marta2")
