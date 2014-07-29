
%macro surt_cat(data =, var=, survtime = , scensor = , sout = );
proc lifetest data=&data ;
time &survtime * &scensor(0);
strata &var;
ods output Quartiles =_Median(where=(Percent=50));
ods output CensoredSummary =_deathN;
ods output HomTests =_Pv(where=(Test="Log-Rank"));
run;

data _deathN;
set _deathN;
Stratum1=put(Stratum,1.);
run;

proc sql;
delete *
from _deathN
where Stratum1="T"
;

proc sql;
create table _sout as
select _Median.&var as var1, _DeathN.Total as Total, _DeathN.Failed as Death, 100-PctCens as Pcent, _Median.Estimate as EMtime
from _Median, _DeathN
where _Median.STRATUM=_deathN.Stratum
;

data _pv;
length factor $20.;
set _pv;
Factor="&var";
run;

data _Surv_logR;
merge _sout _Pv;
drop Test ChiSq DF;
run;
*************** actural median survival and range; 
proc means data = &data median min max ;
var &survtime ;
class &var; 
ods output Summary = _out_actual;
run;

data _out_actual;
set _out_actual;
Median_range = put(&survtime._Median, 4.2)||"  ("||put(&survtime._Min,4.2)||", "||put(&survtime._Max,4.2)||")";
keep d28_lt500 Median_range;
run;

**** HR and p-value;
proc phreg data=&data ;
      model &survtime * &scensor(0)=&var /risklimits;
	  ods output ParameterEstimates=_PE;
run;

data _HR_out;
length Parameter $20.;
set _PE;
HR=put(HazardRatio, 4.2)||"  ("||put(HRLowerCL,4.2)||","||put(HRUpperCL,4.2)||")";
pvalue=ProbChiSq;
keep Parameter HR pvalue;
run;

data &sout;
merge _Surv_logR _HR_out _out_actual;
run;

proc datasets library=work;
delete  _hr_out _median _out_actual _pe _pv _surv_logr _sout _deathn;
run;
quit;
%mend;

*%surt_cat(data = D, var = d28_lt500, survtime = surv_from_ind, scensor = scensor, sout = ss3);
