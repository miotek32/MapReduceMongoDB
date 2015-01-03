//How many sentences has distribution greater than one
resultPol = db.resultPol;
resultEng = db.resultEng;

map = function(){
    emit("answer",{value: this.value, sum: this.value,notUnique: 0});
};

reduce = function(key,values){
  var a = values[0];
  for(var i=1; i < values.length;i++){
    var b = values[i];
    if(b.value > 1){
      a.notUnique += b.value;
    }
    a.sum += b.value;
  }
  return a;
};

final = function(key,reducedValue){
  var result = {unique: 0,notUnique: 0};
  result.unique = reducedValue.sum - reducedValue.notUnique;
  result.notUnique = reducedValue.notUnique;
  return result;
}
print("Statistic for Polish sentences\n");
var result = resultPol.mapReduce(map, reduce, {out: {inline: 1}, finalize: final});
printjson(result);
print("Statistic for English sentences\n");
var result2 = resultEng.mapReduce(map, reduce, {out: {inline: 1}, finalize: final});
printjson(result2);
