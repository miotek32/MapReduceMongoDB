polishCollection = db.polishSentences;
englishCollection = db.englishSentences;

map2 = function(){
  var split = this.originalText.toLowerCase().match(/[\w\u00C0-\u017F]+/g);
  split.forEach(function(letter){
    var result = letter.split("");
    result.forEach(function (character){
      if(character != "_"){
        emit(character,1);
      }
    });
  });
};

map = function(){
  var split = this.originalText.toLowerCase().match(/[\w\u00C0-\u017F]+/g);
  if(split){
    split.forEach(function(letter){
      var result = letter.charAt(0);
      if(result != "_"){
        emit(result,1);
      }
    });
  }
}

reduce = function(key,values){
  return Array.sum(values);
};
