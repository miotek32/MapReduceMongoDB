load("countLetters.js");
print("Compute distribution for first letters")
var firstLettersEnglish = englishCollection.mapReduce(map, reduce, {out: "firstLettersEng"});
printjson(firstLettersEnglish);
print("Compute distribution for all letters");
var allLettersEng = englishCollection.mapReduce(map2,reduce,{out: "allLettersEng"});
printjson(allLettersEng);
