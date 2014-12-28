coll = db.marta;

map = function(){
  var split = this.originalText.match(/\b\S/g);
  var result = split.join("");
    emit(result,1);
};

reduce = function(key,values){
  return Array.sum(values);
};

var res = coll.mapReduce(map, reduce, {out: "result"});
printjson(res);
