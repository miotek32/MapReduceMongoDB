load("countLetters.js");
print("Compute distribution for first letters")
var firstLettersPolish = polishCollection.mapReduce(map, reduce, {out: "firstLettersPol"});
printjson(firstLettersPolish);
print("Compute distribution for all letters");
var allLettersPolish = polishCollection.mapReduce(map2,reduce,{out: "allLettersPol"});
printjson(allLettersPolish);
