polishCollection = db.polishSentences;
englishCollection = db.englishSentences;

map = function(){
  var split = this.originalText.match(/\b\w/g);
  var result = split.join("");
    emit(result,1);
};

reduce = function(key,values){
  return Array.sum(values);
};

var resultPolish = db.runCommand({
  mapreduce: "polishSentences",
  map: map,
  reduce: reduce,
  out: "resultFast",
  sort: {originalText:1},
  jsMode: true
})
printjson(resultPolish);
var resultEnglish = db.runCommand({
  mapreduce: "englishSentences",
  map: map,
  reduce: reduce,
  out: "resultFast2",
  sort: {originalText:1},
  jsMode: true
})
printjson(resultEnglish);
