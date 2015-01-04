polishCollection = db.polishSentences;
englishCollection = db.englishSentences;

map = function(){
  var sam = 0;
  var spol = 0;
  var split = this.originalText.toLowerCase().match(/\b\w/g);
  var result = split.join("");
  var r = result.match(/[aeiou]/g);
  var s = result.match(/[^aeiou0-9]/g);
  if(r){
    sam = r.length;
  }
  if(s){
    spol = s.length;
  }
  emit("answer",{samo: sam,spol: spol});
};

reduce = function(key,values){
  var a = values[0];
  for(var i=1; i < values.length;i++){
    var b = values[i];
     a.samo += b.samo;
     a.spol += b.spol;
  }
  return a;
};

var a = polishCollection.mapReduce(map, reduce, {out: {inline: 1}});
var b = englishCollection.mapReduce(map, reduce, {out: {inline: 1}});
print ("Polish sentences:\n");
printjson(a);
print ("English sentences:\n");
printjson(b);
