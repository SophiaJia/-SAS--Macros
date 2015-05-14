%include "H:\File\SD_Survival\cure rate model\PSPMCM\pspmcm_v1.sas";

%macro crm(D =, var = , scens = , stime = ,out=);
*call macro;
%pspmcm(DATA = &D,ID=,CENSCOD=&scens,TIME=&stime,
				  VAR=&var(IS, 0) ,
				  INCPART=logit,
				  SURVPART=cox, 
				  TAIL=zero , SU0MET=pl,
				  FAST=Y,BOOTSTRAP=Y,
				  NSAMPLE=2000, STRATA=,
				  MAXITER=200,CONVCRIT=1e-5, ALPHA=0.05, 
				  BASELINE=Y, 
				  BOOTMET=ALL,
				  JACKDATA=,
				  GESTIMATE=Y,
                  SPLOT=Y,
                  PLOTFIT=Y);				  
run;
proc sql ;
create table cox as
select Fast_or.*, Fast_inci.ProbChiSq as or1,   Fast_surv.HazardRatio,  Fast_surv.HRLowerCL,  Fast_surv.HRUpperCL, Fast_surv.ProbChiSq as hrp
from Fast_or, Fast_inci, Fast_surv
where Fast_surv.Parameter = Fast_inci.Variable and Fast_inci.Variable = Fast_or.Effect;

data cox; set cox;
coxOR = put(OddsRatioEst,4.2)||"("||put(LowerCL,4.2)||","||put(UpperCL,4.2)||")";
coxORp = or1;
coxHR = put(HazardRatio,4.2)||"("||put(HRLowerCL,4.2)||","||put(HRUpperCL,4.2)||")";
coxHRp = hrp;
drop OddsRatioEst LowerCL UpperCL HazardRatio HRLowerCL HRUpperC or1 hrp HRUpperCL;
run;

proc datasets library=work;
	delete Fast_or Fast_inci Fast_surv;
run;

%pspmcm(DATA = &D ,ID=,CENSCOD=&scens,TIME=&stime,
				  VAR= &var(IS, 0) ,
				  INCPART=logit,
				  SURVPART=WEIB, 
				  TAIL=zero , SU0MET=pl,
				  FAST=Y,BOOTSTRAP=Y,
				  NSAMPLE=2000, STRATA=,
				  MAXITER=200,CONVCRIT=1e-5, ALPHA=0.05, 
				  BASELINE=Y, 
				  BOOTMET=ALL,
				  JACKDATA=,
				  GESTIMATE=Y,
                  SPLOT=Y,
                  PLOTFIT=Y);				  
run;

proc sql ;
create table weibull as
select Fast_or.*, Fast_inci.ProbChiSq as or1,   Fast_surv.HazardRatio,  Fast_surv.HRLowerCL,  Fast_surv.HRUpperCL, Fast_surv.ProbChiSq as hrp
from Fast_or, Fast_inci, Fast_surv
where Fast_surv.Parameter = Fast_inci.Variable and Fast_inci.Variable = Fast_or.Effect;

data weibull; set weibull;
weibullOR = put(OddsRatioEst,4.2)||"("||put(LowerCL,4.2)||","||put(UpperCL,4.2)||")";
weibullORp = or1;
weibullHR = put(HazardRatio,4.2)||"("||put(HRLowerCL,4.2)||","||put(HRUpperCL,4.2)||")";
weibullHRp = hrp;
drop OddsRatioEst LowerCL UpperCL HazardRatio HRLowerCL HRUpperC or1 hrp HRUpperCL;
run;

proc sql;
create table &out as
select cox.* , weibull.* 
from cox, weibull
where cox.Effect = weibull.Effect;
%mend;
