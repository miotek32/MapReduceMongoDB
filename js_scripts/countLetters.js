polishCollection = db.polishSentences;
englishCollection = db.englishSentences;

map = function(){
  var split = this.originalText.toLowerCase().match(/\b\w/g);
  split.forEach(function(letter){
    if(letter != "_"){
      emit(letter,1);
    }
  })
};

map2 = function(){
  var split = this.originalText.toLowerCase().match(/\w/g);
  if(split){
    split.forEach(function(letter){
      if(letter != "_"){
        emit(letter,1);
      }
    });
  }
}

reduce = function(key,values){
  return Array.sum(values);
};
