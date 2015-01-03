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
