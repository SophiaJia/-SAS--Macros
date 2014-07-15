
%macro surt_cat(data=, var=, sout=);
proc lifetest data=&data ;
time surv_from_ind*scensor(0);
strata &var;
ods output Quartiles=Median(where=(Percent=50));
ods output  CensoredSummary=deathN;
ods output  HomTests=Pv(where=(Test="Log-Rank"));
run;

data deathN;
set deathN;
Stratum1=put(Stratum,1.);
run;

proc sql;
delete *
from deathN
where Stratum1="T"
;

proc sql;
create table sout as
select Median.&var as var1, DeathN.Total as Total, DeathN.Failed as Death, 100-PctCens as Pcent, Median.Estimate as EMtime
from Median, DeathN
where Median.STRATUM=deathN.Stratum
;

data pv;
length factor $20.;
set pv;
Factor="&var";
run;

data Surv_logR;
merge sout Pv;
drop Test ChiSq DF;
run;
*************** actural median survival and range; 
proc means data = D median min max ;
var surv_from_ind ;
class &var; 
ods output Summary = out_actual;
run;

data out_actual;
set out_actual;
Median_range = put(surv_from_ind_Median, 4.2)||"  ("||put(surv_from_ind_Min,4.2)||","||put(surv_from_ind_Max,4.2)||")";
keep d28_lt500 Median_range;
run;

**** HR and p-value;
proc phreg data=&data;
      model surv_from_ind*scensor(0)=&var /risklimits;
	  ods output ParameterEstimates=PE;
run;

data HR_out;
length Parameter $20.;
set PE;
HR=put(HazardRatio, 4.2)||"  ("||put(HRLowerCL,4.2)||","||put(HRUpperCL,4.2)||")";
pvalue=ProbChiSq;
keep Parameter HR pvalue;
run;

data &sout;
merge Surv_logR HR_out out_actual;
run;
%mend;

%surt_cat(data=D, var=d28_lt500, sout=ss1);
