# Map reduce on MongoDB
Mateusz Miotk  
04.01.2015  

```
Sprzęt: 
Laptop ACER ASPIRE ONE 5820TG
Procesor: Intel core I5-430M
Ilość pamięci RAM: 8 GB
Dysk twardy: SSD SanDisk 128 GB
System Operacyjny: Linux Mint 17 x64
Wersja MongoDB: 2.6.5 oraz 2.8.0.rc0
```
## Tytuł: Użycie Map Reduce w MongoDB do sprawdzenia rozkładów liter w sentencjach polskich i angielskich

### Motywacja

Coraz częściej słyszymy o atakach na różne serwisy www oraz o nieodpowiedzialności administratorów, którzy mają bardzo słabe hasła. 
Jak stworzyć silne hasło: jest opinia, która mówi że należy wymyśleć sobie jakieś zdanie i za hasło wziąść pierwsze litery wyrazów w tym zdaniu. Eksperyment, który przeprowadziłem sprawdził czy ta metoda ma sens poprzez sprawdzenie czy hasła są unikalne to znaczy czy są zdania które posiadają ten sam rozkład liter.
Poza tym zastanowić się można jak można ulepszyć tą metodę. 
Nasuwają się następujące pytania: 
- Czy usunięciu ```stop-słów``` zwiększa unikalność haseł.
- Czy posortowanie liter w rozkładzie zwiększy nieunikalność haseł.

### Przygotowanie danych

Do przeprowadzenia eksperymentu użyłem pliku ```sentences.tar.bz2``` ze strony [tatoeba.org](http://downloads.tatoeba.org/exports/sentences.tar.bz2) która zawiera plik z popularnymi sentencjami w różnych językach świata. Nas będzie interesował język **angielski** oraz **polski**.

#### Przetworzenie danych ze strony tatoeba.org

Ponieważ plik ze strony **tatoeba.org** zawiera sentencje w wielu językach świata musimy przerobić i wydzielić do innych plików sentencje polskie i angielskie.
Następnie dane musimy załadować do MongoDB.
Do przetworzenia danych należy uruchomić skrypt **PrepareData.sh**, ktory:
- Pobiera plik ze strony **tatoeba.org**
- Rozpakowuje plik do folderu **data**
- Wywołuje skrypt napisany w **awk** który eksportuje sentencje w danym języku
- Usuwa znak "," z sentencji oraz usuwa powtarzające się linie.
Kod skryptu przetwarzającego dane: 
```bash
#!/bin/bash

#Prepare data and load to MongoDB
wget -O ../data/sentences.tar.bz2 http://downloads.tatoeba.org/exports/sentences.tar.bz2
tar xvf ../data/sentences.tar.bz2 -C ../data/

./convert.awk "eng" ../data/sentences.csv > ../data/english1.csv
./convert.awk "pol" ../data/sentences.csv > ../data/polish1.csv

#Remove comma from files
tr -d "," < ../data/english1.csv > ../data/english2.csv
tr -d "," < ../data/polish1.csv > ../data/polish2.csv

#Remove duplicate lines in file
awk '!x[$0]++' ../data/english2.csv > ../data/english.csv
awk '!x[$0]++' ../data/polish2.csv > ../data/polish.csv

#Remove temporary files
rm ../data/english1.csv
rm ../data/english2.csv
rm ../data/polish1.csv
rm ../data/polish2.csv
rm ../data/sentences.tar.bz2
```
#### convert.awk
Plik ze strony **tatoeba.org** jeśli chodzi o język angielski zawiera błędy, które polegają na tym że językowi temu przydzielone zostały sentencje napisane w języku arabskim. Dlatego też w skrypcie są zawarte numery 3670301 itd., które zawierają te nieprawidłowe linie. 
Poza tym eksportuje tylko te sentencje, które zawierają od 6 do 12 słów.

Kod skryptu napisanego w **awk**:
```awk
#!/usr/bin/awk -f
BEGIN{
  if (ARGC<3) exit(1);
    arg=ARGV[1];
    ARGV[1]="";
}
($2 == arg && $1 != 3670301 && $1 != 3712889 && $1 != 3712890) {
  out=$3;
  for(n=4;n<=NF;n++){
    out=out " " $n;
  }
  if(NF >= 8 && NF <= 14){
    printf("%s\n",out);
  }
}
```

#### Załadowanie danych do MongoDB.

Do załadowania danych należy użyć skryptu **LoadData.sh** z folderu **bash_scripts**. Skrypt ten używa innego skryptu napisanego w języku R, o nazwie **PrepareData.R** dzięki któremu ładowane są dane do **MongoDB**. 

```bash
#!/bin/bash

#Load data to MongoDB
echo "Load Polish sentences to test.polishSentences"
Rscript ../r_scripts/PrepareData.R ../data/polish.csv 10000 test.polishSentences
echo "Load English sentences to test.englishSentences"
Rscript ../r_scripts/PrepareData.R ../data/english.csv 10000 test.englishSentences

```

Dane zostały zapisane odpowiednio w kolekcjach: **polishSentences** oraz **englishSentences**.

### MapReduce w sentencjach polskich i angielskich.

#### Zapisanie rozkładów liter do kolekcji - split.js

Kod pliku:
```js
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

var resultPolish = polishCollection.mapReduce(map, reduce, {out: "resultPol"});
printjson(resultPolish);
var resultEnglish = englishCollection.mapReduce(map, reduce, {out: "resultEng"});
printjson(resultEnglish);
```
Wynik:
```js
{
  "result" : "resultPol",
	"timeMillis" : 1566,
	"counts" : {
		"input" : 27934,
		"emit" : 27934,
		"reduce" : 162,
		"output" : 27771
	},
	"ok" : 1
}
{
	"result" : "resultEng",
	"timeMillis" : 16371,
	"counts" : {
		"input" : 301120,
		"emit" : 301120,
		"reduce" : 7696,
		"output" : 292684
	},
	"ok" : 1
}
```
Podgląd do bazy, który otrzymaliśmy: 
```js
{
  "_id": "11111111112",
  "value": 1
}
{
  "_id": "1dwTcnw",
  "value": 1
}
{
  "_id": "Amepjdkdw",
  "value": 2
}
{
  "_id": "BdmotpzT",
  "value": 2
}
```

#### Obliczenie unikalnych i nieunikalnych rozkładów - distributions.js.

Jak już widać niektóre rozkłady występują więcej niż 1 raz. Policzmy ile jest takich rozkładów w obu przypadkach.

Kod pliku:
```js
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
```
Otrzymany wynik: 
```js
Statistic for Polish sentences:
{
  "results" : [
		{
			"_id" : "answer",
			"value" : {
				"unique" : 27613,
				"notUnique" : 321
			}
		}
	],
	"timeMillis" : 616,
	"counts" : {
		"input" : 27771,
		"emit" : 27771,
		"reduce" : 278,
		"output" : 1
	},
	"ok" : 1
}
Statistic for English sentences:
{
	"results" : [
		{
			"_id" : "answer",
			"value" : {
				"unique" : 285367,
				"notUnique" : 15753
			}
		}
	],
	"timeMillis" : 6348,
	"counts" : {
		"input" : 292684,
		"emit" : 292684,
		"reduce" : 2927,
		"output" : 1
	},
	"ok" : 1
}
```
