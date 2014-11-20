/*------------------------------------------------------------------*
   | MACRO NAME  : surt_multi
   | SHORT DESC  : General survival statistics for multivariable analysis
   |               Table and data format are ready for bind or output by 
   |               calling %survival_macro_multy.sas;
   | VERSION     : 1.0
   *------------------------------------------------------------------*
   | CREATED BY  : Sophia Jia                             (07/13/2014)
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | This macro will calculate the general multivariable survival 
   | statistics and output HR and P value in a format that is good for
   | a rtf table. 
   |
   *------------------------------------------------------------------*
   | MODIFIED BY : Name                                          (Date)
   |
   | Version;  Detail 
   *------------------------------------------------------------------*  
   | MACRO CALL
   |
   | %surt_multi(
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
   | Purpose   : A list of variable that will be used for multivariable
   |             analysis
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
   |       a. 
   |
   |
   |
   *------------------------------------------------------------------*
   | EXAMPLES
   |
   |
   | *%surt(data = D, 
   |        var = Sex stage_con_1 Necrosis_new SarcDiff tumor_size10_1, 
   |        survtime = surdate, scensor = rcensor, sout=s);
   |
   *------------------------------------------------------------------*/
%macro surt_multi(data = _LAST_, var =, survtime = , scensor = , sout =);

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
proc phreg data=&data;
      model &survtime * &scensor(0) = &var/risklimits;
	  ods output ParameterEstimates = out_;
run;

data &sout;
length Parameter $20.;
set out_;
HR_=put(HazardRatio, 4.2)||"  ("||put(HRLowerCL,4.2)||","||put(HRUpperCL,4.2)||")";
pv_=ProbChiSq;
keep Parameter HR_ pv_;
run;
%mend;


