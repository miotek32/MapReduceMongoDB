#!/bin/bash

./convert2.awk "eng" ../data/sentences.csv > ../data/english1.csv
./convert2.awk "pol" ../data/sentences.csv > ../data/polish1.csv

#Remove comma from files
tr -d "," < ../data/english1.csv > ../data/english2.csv
tr -d "," < ../data/polish1.csv > ../data/polish2.csv

#Remove duplicate lines in file
awk '!x[$0]++' ../data/english2.csv > ../data/englishStop.csv
awk '!x[$0]++' ../data/polish2.csv > ../data/polishStop.csv

#Remove temporary files
rm ../data/english1.csv
rm ../data/english2.csv
rm ../data/polish1.csv
rm ../data/polish2.csv

#Load data to MongoDB
echo "Load Polish sentences to test.polishSentences"
Rscript ../r_scripts/PrepareDataStopWord.R ../data/polishStop.csv 10000 test.polishSentences pol
echo "Load English sentences to test.englishSentences"
Rscript ../r_scripts/PrepareDataStopWord.R ../data/englishStop.csv 10000 test.englishSentences eng
