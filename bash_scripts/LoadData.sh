#!/bin/bash

#Load data to MongoDB
echo "Load Polish sentences to test.polishSentences"
Rscript ../r_scripts/PrepareData.R ../data/polish.csv 10000 test.polishSentences
echo "Load English sentences to test.englishSentences"
Rscript ../r_scripts/PrepareData.R ../data/english.csv 10000 test.englishSentences
