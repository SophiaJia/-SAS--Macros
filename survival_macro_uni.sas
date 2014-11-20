 /*------------------------------------------------------------------*
   | MACRO NAME  : surv_uni
   | SHORT DESC  : General survival statistics for univariable analysis
   |               Table and data format are ready for bind or output by 
   |               calling %survival_macro_uni.sas;
   | VERSION     : 1.0
   *------------------------------------------------------------------*
   | CREATED BY  : Sophia Jia                             (07/13/2014)
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | This macro will calculate the general survival statistics (Total 
   | number of patients by group, Number of deaths, Median estimated 
   | survival time, HR, and p(t)
   |
   *------------------------------------------------------------------*
   | MODIFIED BY : Name                                          (Date)
   |
   | Version;  Detail 
   *------------------------------------------------------------------*  
   | MACRO CALL
   |
   | %surv_uni(
   |            data = ,
   |            var = ,
   |            survtime = ,
   |            scensor = ,
   |            sout = ,
   |          );
   *------------------------------------------------------------------*
   | REQUIRED PARAMETERS
   |
   | Name      : var
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : Group variable which are using for the analysis 
   |
   | Name      : survtime
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : Variable containing time to event or last follow-up
   |             in any units
   |
   | Name      : scensor
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : Event variable as a numeric two-valued variable (0,1). 
   |             The event value is coded as 1 and the censoring value 
   |             is coded as 0
   |
   | Name      : sout
   | Default   :
   | Type      : Dataset Name
   | Purpose   : Output dataset name
   |
   *------------------------------------------------------------------*
   | OPTIONAL PARAMETERS
   |
   | Name      : data
   | Default   : _LAST_
   | Type      : Dataset Name
   | Purpose   : Input dataset name (Default is the last dataset created)
   |
   *------------------------------------------------------------------*
 | ADDITIONAL NOTES
   |
   |
   |  1.  Under developing 
   |       a. multiply variables input
   |
   |
   |
   *------------------------------------------------------------------*
   | EXAMPLES
   |
   |
   | %surv_uni(data = D, var = d28_lt500, survtime = surv_from_ind, 
   |           scensor = scensor, sout = ss3);
   *------------------------------------------------------------------*/

%macro surv_uni(data = _LAST_, var=, survtime = , scensor = , sout = );

*Variables Checking;
%if &survtime =  %then %do;
   %put  ERROR: Variable <survtime> not defined;
   %LET  errorflg = 1;
   %end;

%if &scensor =  %then %do;
   %put  ERROR: Variable <scensor> not defined;
   %LET  errorflg = 1;
   %end;

*survival;
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
	select _Median.&var as var1, _DeathN.Total as Total, _DeathN.Failed as Death, 100-_DeathN.PctCens as Pcent, _Median.Estimate as EMtime
	from _Median, _DeathN
	where _Median.STRATUM = _deathN.Stratum
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


**** HR and p-value;
proc phreg data=&data;
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
	merge _Surv_logR _HR_out;
run;

data &sout;
	set &sout;
	EMtime_2 = put(EMtime, 4.2);
	ND = put(Death,4.0)||"( "||put(Pcent, 4.2)||"% )";
run;

proc datasets library=work;
	delete _deathn _hr_out _median  _pe _pv _surv_logr _sout;
run;

%mend;
