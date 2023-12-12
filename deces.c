#include <stdio.h>
#include <malloc.h>
#include <stdbool.h>
#include <stdlib.h>
#include<strings.h>
#include<string.h>

#define min(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a < _b ? _a : _b; })

//Beware of null bytes in C strings...
char *process(char *s_in, int n1,int n2,char *s_out) {
  int j=0;
  for (int i=n1;i<n2;i++) {
    char c = s_in[i];
    if ((c==0x09) || (c==0x0A) || (c==0x0C) || (c==0x0D) || (c==0x22)) s_out[j++]=' ';
    else if ((c>=0x61)&&(c<=0x7A)) s_out[j++]=c-0x20;
    else if ((c>=0x1F) && (c<0x7F)) s_out[j++]=c;
  }
  while ((j>0)&&(s_out[j-1]==' ')) j--;
  s_out [j]=0;
  for (j=0;s_out[j]==' '; j++);
  return s_out+j;
}

int find(char *s,int n1,int n2,char c) {
  int j;
  for (j=n1;(j<n2)&&(s[j]!=c);j++);
  return j;
}

int conv(char *line,int n1,int l) {
  char c = line[n1+l];
  line[n1+l]=0;
  int res = atoi(line+n1);
  line[n1+l]=c;
  return res;
}

int process_utf8(char *s,int n) {
  int j=0,flag=false;
  for (int i=0;i<=n;i++) {
    if ((s[i]>=0) || !flag) s[j++]=s[i];
    if (s[i]>=0) flag=false; else flag=true;
  }
  s[j]=0;
  return j-1;
}

void one(FILE *fp_in,FILE *fp_out) {
  char *line=NULL;
  char buf_nom[512],buf_prenom[512],insee_b[6],buf_commune_b[512],buf_pays_b[512],
    insee_d[6],buf_acte[512];
  char *nom,*prenom,sexe,*commune_b,*pays_b,*num_acte;
  int year_b,month_b,day_b,year_d,month_d,day_d;
  insee_b[5]=0;
  insee_d[5]=0;
  size_t n=0;
  while (true) {
    int nb = getline(&line,&n,fp_in);
    if (nb<0) break;
    nb=process_utf8(line,nb);
    if (nb<167) {fprintf(stderr,"Not enough chars\n");exit(-1);}
    int n1 = find(line,0,80,'*');
    nom = process(line,0,n1,buf_nom);
    int n2 = find(line,n1+1,80,'/');
    prenom=process(line,n1+1,n2,buf_prenom);
    switch (line[80]) {
    case '1' : sexe='H'; break;
    case '2' : sexe='F'; break;
    default : fprintf(stderr,"Sex error\n");exit(-1); 
    }
    year_b = conv(line,81,4);
    month_b = conv(line,85,2);
    day_b = conv(line,87,2);
    bcopy(line+89,insee_b,5);
    commune_b=process(line,94,94+30,buf_commune_b);
    pays_b=process(line,124,124+30,buf_pays_b);
    year_d = conv(line,154,4);
    month_d = conv(line,158,2);
    day_d = conv(line,160,2);
    bcopy(line+162,insee_d,5);
    num_acte=process(line,167,min(167+9,nb+1),buf_acte);
    fprintf(
	    fp_out,
	   "\"%s\",\"%s\",\"%c\",\"%d\",\"%d\",\"%d\",\"%s\",\"%s\",\"%s\",\"%d\",\"%d\",\"%d\",\"%s\",\"%s\"\n",
	   nom,prenom,sexe,year_b,month_b,day_b,insee_b,commune_b,pays_b,
	    year_d,month_d,day_d,insee_d,num_acte);
  }
}

int main(int argc,char **argv) {
  char name_in[512],name_out[512],num[512];
  FILE *fp_in,*fp_out;
  switch (argc) {
  case 2 :
    strcpy(name_out,"./deces-");
    strcat(name_out,argv[1]);
    strcat(name_out,".csv");
    fp_out = fopen(name_out,"w");
    if (fp_out==NULL) {fprintf(stderr,"Can't open out file: %s\n",name_out);exit(-1);}
    strcpy(name_in,"./deces-");
    strcat(name_in,argv[1]);
    strcat(name_in,".txt");
    fp_in = fopen(name_in,"r");
    if (fp_in==NULL) {fprintf(stderr,"Can't open in file: %s\n",name_in);exit(-1);}
    one(fp_in,fp_out);
    fclose(fp_out);
    fclose(fp_in);
    break;
  case 3:
    strcpy(name_out,"./deces-");
    strcat(name_out,argv[1]);
    strcat(name_out,"-");
    strcat(name_out,argv[2]);
    strcat(name_out,".csv");
    fp_out = fopen(name_out,"w");
    if (fp_out==NULL) {fprintf(stderr,"Can't open out file: %s\n",name_out);exit(-1);}
    int n1 = atoi(argv[1]);
    int n2 = atoi(argv[2]);
    for (int i = n1;i<=n2;i++) {
      sprintf(num,"%d",i);
      strcpy(name_in,"./deces-");
      strcat(name_in,num);
      strcat(name_in,".txt");
      fp_in = fopen(name_in,"r");
      if (fp_in==NULL) {fprintf(stderr,"Can't open in file: %s\n",name_in);exit(-1);}
      one(fp_in,fp_out);
      fclose(fp_in);
    }
    fclose(fp_out);
    break;
  default : fprintf(stderr,"Incorrect number of args\n");exit(-1);
  }
  return 0;
}
