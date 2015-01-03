#!/usr/bin/awk -f
($2 == "pol") {
  out=$3;
  for(n=4;n<=NF;n++){
    out=out " " $n;
  }
  if(n >=8 && n <= 14){
    printf("%s\n",out);
  }
}
