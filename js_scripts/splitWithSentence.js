polishCollection = db.polishSentences;
englishCollection = db.englishSentences;

map = function(){
  var split = this.originalText.match(/\b\w/g);
  var result = split.join("");
    emit(result,{list: [this.originalText],count: 1});
};

reduce = function(key,values){
  var list =  [];
  var count = 0;
  values.forEach(function(item){
    list = item.list.concat(list);
    count += item.count;
  });
  return ({list: list,count: count});
};

var resultPolish = polishCollection.mapReduce(map, reduce, {out: "result2Pol"});
printjson(resultPolish);
var resultEnglish = englishCollection.mapReduce(map, reduce, {out: "result2Eng"});
printjson(resultEnglish);
