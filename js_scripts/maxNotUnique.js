polishCollection = db.resultPol;
englishCollection = db.resultEng;

map = function () {
    var x = { count : this.value , _id : this._id };
    emit("maximum", { max : x } )
}

reduce = function(key,values){
  var res = values[0];
    for ( var i=1; i<values.length; i++ ) {
      if ( values[i].max.count > res.max.count )
         res.max = values[i].max;
    }
    return res;
}

var result = polishCollection.mapReduce(map, reduce, {out: {inline: 1}});
printjson(result);
var result2 = englishCollection.mapReduce(map, reduce, {out: {inline: 1}});
printjson(result2);
