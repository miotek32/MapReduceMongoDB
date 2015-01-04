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
  printf("%s\n",out);
}
