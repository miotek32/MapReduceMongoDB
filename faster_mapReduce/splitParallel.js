polishCollection = db.polishSentences;
englishCollection = db.englishSentences;

load("parallelTester.js");

var res = db.runCommand({
  splitVector: "test.englishSentences",
  keyPattern: {_id: 1},
  maxChunkSizeBytes: 4*1024*1024
});
var keys = res.splitKeys;

var command = function(min,max){
  return db.runCommand({
  mapreduce: "englishSentences",
  map: function(){
    var split = this.originalText.match(/\b\w/g);
    var result = split.join("");
    emit(result,1);
  },
  reduce: function(key,values){ return Array.sum(values)},
  out: "resultParallel" + min,
  sort: {_id:1},
  query: {_id: {$gte: min, $lt: max}},
})};

var numberCores = 4
var inc = (Math.floor(keys.length) / numberCores) + 1;
threads = [];
for (var i = 0; i < numberCores; ++i) {
   var min = (i == 0) ? 0 : keys[i * inc]._id;
   var max = (i * inc + inc >= keys.length) ? MaxKey : keys[i * inc + inc]._id ;
   print("min:" + min + " max:" + max);
   var t = new ScopedThread(command, min, max);
   threads.push(t);
   t.start()
}

for (var i in threads){
  var t = threads[i];
  t.join();
  printjson(t.returnData());
}
