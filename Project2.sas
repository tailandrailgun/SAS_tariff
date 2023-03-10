options linesize=78;

libname Project2 "D:\Desktop\SAS Projects\Project2";
* Version 1: Dependent variable is 'growth';
* Version 2: Dependent variable is 'prod_growth';
* Create temporary data set*;

data TRE1;
  set Project2.nunntrefler;
  run;

* Generate summary of the data*;

proc contents data=Project2.nunntrefler;
  title 'Sample Data Contents';
  run;

***************************************************;
*******              Table 2                *******;
***************************************************;

proc means data=Project2.nunntrefler noprint;
 by wbcode;
 output out= cty
 mean (growth avg_tar diffa tskilla tnoskilla
   ln_init_q_skilla ln_init_q_unskilla
   init inv human_cap
   e_africa e_asia e_europe lat_america
   n_afr_me s_c_africa s_e_asia s_w_asia w_africa
   dum80_83 dum85_87)= 

   growth avg_tar diffa tskilla tnoskilla
   ln_init_q_skilla ln_init_q_unskilla
   init inv human_cap
   e_africa e_asia e_europe lat_america
   n_afr_me s_c_africa s_e_asia s_w_asia w_africa
   dum80_83 dum85_87;
    run;

   data cty;
    set cty;
	drop _type_ _freq_;
	run;

  *Table 2, column 1;
 
  proc reg data =cty;
  model growth =avg_tar init inv human_cap dum80_83 dum85_87;
  run;

  *Table 2 column 2;

  proc reg data =cty;
  model growth =avg_tar init inv human_cap dum80_83 dum85_87
    e_africa e_asia e_europe lat_america
    n_afr_me s_c_africa s_e_asia s_w_asia w_africa;
  run;

 *From Table 3, cut off = 248 (248 220 246 150 247 245 243 110 241 are low-skilled);

***************************************************;
*********         Table 4-Version 1      **********;
***************************************************;

 data high low;
     set Project2.nunntrefler;
     if industry=241 or industry=110 or industry=243 or industry=245 or industry=247 or industry=150 or industry=246 
     or industry= 220 or industry=248 then output low;
     else output high;
     run;

proc sort data=low;
	by wbcode;
	run;

proc sort data=high;
	by wbcode;
	run;

proc means data=low noprint;
 by wbcode;
 output out=avg_low mean(init_tar)=init_tarlow;
 run;

proc means data=high noprint;
 by wbcode;
 output out=avg_high mean(init_tar)=init_tarhigh;
 run;

*Merge constructed means to country dataset;
data cty1;
  merge cty avg_low avg_high;
  by wbcode;
  drop _type_ _freq_;
  run;

*Construct a 'difference' variable for difference between init_tarhigh & init_tarlow;
data cty1;
  set cty1;
  diff= init_tarhigh - init_tarlow;
  run;

*Table 4 column 2;
proc reg data=cty1 simple;
model growth = diff
    			avg_tar ln_init_q_skilla ln_init_q_unskilla
    			init inv human_cap dum80_83 dum85_87
   				e_africa e_asia e_europe lat_america
    			n_afr_me s_c_africa s_e_asia s_w_asia w_africa;
    run; 

*Table 4 column 3;
proc reg data=cty1;
 model growth = init_tarhigh init_tarlow 
				ln_init_q_skilla ln_init_q_unskilla
    			init inv human_cap dum80_83 dum85_87 e_africa e_asia e_europe lat_america
    			n_afr_me s_c_africa s_e_asia s_w_asia w_africa;
   run;

***************************************************;
*********         Table 5                **********;
***************************************************;
* Compute means for the base dataset;
proc means data=Project2.nunntrefler noprint;
 output out= Means
 mean (growth avg_tar init inv human_cap
      e_africa e_asia e_europe lat_america
      n_afr_me s_c_africa s_e_asia s_w_asia w_africa
      dum80_83 dum85_87
      ln_init_q_skilla ln_init_q_unskilla)= 
   growth avg_tar init inv human_cap
   e_africa e_asia e_europe lat_america
   n_afr_me s_c_africa s_e_asia s_w_asia w_africa
   dum80_83 dum85_87
   ln_init_q_skilla ln_init_q_unskilla;
   run;

* Repeat procedures used in replicating Table 4 (Version 1);
data high low;
set Project2.Nunntrefler;
if industry=241 or industry=110 or industry=243 or industry=245 or industry=247 or industry=150 or industry=246 
     or industry= 220 or industry=248 then output low;
     else output high;
run;

proc sort data=low;
by wbcode;
run;

proc sort data=high;
by wbcode;
run;

* Take average tariff by country for low and high;
proc means data=low noprint;
 by wbcode;
 output out=avg_low mean(init_tar)=init_tarlow;
 run;

proc means data=high noprint;
 by wbcode;
 output out=avg_high mean(init_tar)=init_tarhigh;
 run;

data cty1;
  if _N_=1 then set Means;
  set cty1;
  drop _type_ _freq_;
  run;

data cty1;
  merge avg_low avg_high;
  by wbcode;
  drop _type_ _freq_;
  run;

data cty1;
  set cty1;
  diff= init_tarhigh - init_tarlow;
  run;

* Sort and merge 'diff' to dataset;
data temp;
set Project2.nunntrefler;
run;

proc sort data=temp;
by wbcode;
run;

data temp1;
merge temp cty1;
by wbcode;
run;

* Table 5, column 2;
proc reg data=temp1 simple;
model growth = diff ln_init_q_skilla ln_init_q_unskilla
    init avg_tar inv human_cap dum80_83 dum85_87
    e_africa e_asia e_europe lat_america
    n_afr_me s_c_africa s_e_asia s_w_asia w_africa;
run; 

* Table 5, column 3;
proc reg data=temp1 simple;
model growth = init_tarhigh init_tarlow 
    ln_init_q_skilla ln_init_q_unskilla
    init avg_tar  
    inv human_cap dum80_83 dum85_87
    e_africa e_asia e_europe lat_america
    n_afr_me s_c_africa s_e_asia s_w_asia w_africa;
run; 


***************************************************;
*********         Table 6                **********;
***************************************************;

data temp2;
    set temp1;

if industry='110' then SL=0.116;
if industry='140' then SL=0.593;
if industry='150' then SL=0.184;
if industry='211' then SL=0.718;
if industry='213' then SL=0.731;
if industry='220' then SL=0.266;
if industry='231' then SL=0.414; 
if industry='232' then SL=0.617;
if industry='233' then SL=0.466;
if industry='241' then SL=0.079;
if industry='242' then SL=0.462;
if industry='243' then SL=0.128;
if industry='244' then SL=0.397;
if industry='245' then SL=0.132;
if industry='246' then SL=0.201;
if industry='247' then SL=0.154;
if industry='248' then SL=0.315;
if industry='249' then SL=0.797;

    int=SL*init_tar;
    run;

*Table 6, column 3;
proc reg data=temp2 simple;
 model growth = diff init_tar
    ln_init_q_skilla ln_init_q_unskilla
    init avg_tar  
    inv human_cap dum80_83 dum85_87
    e_africa e_asia e_europe lat_america
    n_afr_me s_c_africa s_e_asia s_w_asia w_africa;
    run; 

*Table 6, column 4;
proc reg data=temp2 simple;
 model growth = diff init_tar int
    ln_init_q_skilla ln_init_q_unskilla
    init avg_tar  
    inv human_cap dum80_83 dum85_87
    e_africa e_asia e_europe lat_america
    n_afr_me s_c_africa s_e_asia s_w_asia w_africa;
    run; 

*Table 6, column 5;
proc reg data=temp2 simple;
 model growth = init_tarhigh init_tarlow init_tar
    ln_init_q_skilla ln_init_q_unskilla
    init avg_tar  
    inv human_cap dum80_83 dum85_87
    e_africa e_asia e_europe lat_america
    n_afr_me s_c_africa s_e_asia s_w_asia w_africa;
    run; 

*Table 6, column 6;
proc reg data=temp2;
 model growth = init_tarhigh init_tarlow init_tar int
     avg_tar ln_init_q_skilla ln_init_q_unskilla
    init inv human_cap dum80_83 dum85_87
    e_africa e_asia e_europe lat_america
    n_afr_me s_c_africa s_e_asia s_w_asia w_africa;
   run;

***************************************************;
*********         Table 4-Version 2      **********;
***************************************************;
 data high low;
     set Project2.nunntrefler;
     if industry=241 or industry=110 or industry=243 or industry=245 or industry=247 or industry=150 or industry=246 
     or industry= 220 or industry=248 then output low;
     else output high;
     run;

proc sort data=low;
	by wbcode;
	run;

proc sort data=high;
	by wbcode;
	run;

proc means data=low noprint;
 by wbcode;
 output out=avg_low mean(init_tar)=init_tarlow;
 run;

proc means data=high noprint;
 by wbcode;
 output out=avg_high mean(init_tar)=init_tarhigh;
 run;

data cty2;
  merge cty avg_low avg_high;
  by wbcode;
  drop _type_ _freq_;
  run;

data cty3;
  set cty2;
  diff= init_tarhigh -  init_tarlow;
  run;

  data temp;
    set Project2.nunntrefler;
    run;

  proc sort data=temp;
    by wbcode;
    run;

  data temp1;
    merge temp cty3;
	by wbcode;
    run;

*add dummies;

data temp1;
  set temp1;
  if industry=241 then ind_1=1; else ind_1=0;
  if industry=110 then ind_2=1; else ind_2=0;
  if industry=243 then ind_3=1; else ind_3=0;
  if industry=245 then ind_4=1; else ind_4=0;
  if industry=247 then ind_5=1; else ind_5=0;
  if industry=150 then ind_6=1; else ind_6=0;
  if industry=246 then ind_7=1; else ind_7=0;
  if industry=220 then ind_8=1; else ind_8=0;
  if industry=248 then ind_9=1; else ind_9=0;
  if industry=244 then ind_10=1; else ind_10=0;
  if industry=231 then ind_11=1; else ind_11=0;
  if industry=242 then ind_12=1; else ind_12=0;
  if industry=233 then ind_13=1; else ind_13=0;
  if industry=140 then ind_14=1; else ind_14=0;
  if industry=232 then ind_15=1; else ind_15=0;
  if industry=211 then ind_16=1; else ind_16=0;
  if industry=213 then ind_17=1; else ind_17=0;
  if industry=249 then ind_18=1; else ind_18=0;
  run;

*Table 4 (Version 2), column 2;  
proc reg data=temp1 simple;
 model growth = diff ind_1-ind_18
    avg_tar ln_init_q_skilla ln_init_q_unskilla
    init inv human_cap dum80_83 dum85_87
    e_africa e_asia e_europe lat_america
    n_afr_me s_c_africa s_e_asia s_w_asia w_africa;
    run; 

*Table 4 (Version 2), column 3;
proc reg data=temp1;
 model growth = init_tarhigh init_tarlow ln_init_q_skilla ln_init_q_unskilla
    init inv human_cap dum80_83 dum85_87 e_africa e_asia e_europe lat_america
    n_afr_me s_c_africa s_e_asia s_w_asia w_africa;
   run;

