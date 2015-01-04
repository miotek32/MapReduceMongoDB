polishCollection = db.polishSentences;
englishCollection = db.englishSentences;

map = function(){
  var split = this.originalText.match(/\b\w/g);
  var temp = split.sort();
  var result = split.join("");
    emit(result,1);
};

reduce = function(key,values){
  return Array.sum(values);
};

var resultPolish = polishCollection.mapReduce(map, reduce, {out: "resultPol"});
printjson(resultPolish);
var resultEnglish = englishCollection.mapReduce(map, reduce, {out: "resultEng"});
printjson(resultEnglish);
