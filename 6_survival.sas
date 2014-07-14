
*continous;
%macro surt(data=, var=, sout=);
proc phreg data=&data;
      model surv_new*scensor_new(0)=&var/risklimits;
	  ods output ParameterEstimates=&sout;
run;
%mend;
%surt(data=D, var=vCTC, sout=ss1);
%surt(data=D, var=mCTC_new, sout=ss2);
%surt(data=D, var=t1, sout=ss3);
%surt(data=D, var=t2, sout=ss4);
%surt(data=D, var=t3, sout=ss5);
data Sout_con;
length Parameter $20.;
set ss1-ss5;
HR=put(HazardRatio, 4.2)||"  ("||put(HRLowerCL,4.2)||","||put(HRUpperCL,4.2)||")";
pvalue=ProbChiSq;
keep Parameter HR pvalue;
run;
*************binory;
%macro surt_cat(data=, var=, sout=);

proc lifetest data=&data ;
time surv_new*scensor_new(0);
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

proc phreg data=&data;
      model surv_new*scensor_new(0)=&var /risklimits;
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
merge Surv_logR HR_out;
run;
%mend;

%surt_cat(data=D, var=vCTC_0, sout=sv1);
%surt_cat(data=D, var=mCTC_0, sout=sv2);
%surt_cat(data=D, var=vCTC_1, sout=sv3);
%surt_cat(data=D, var=mCTC_1, sout=sv4);
%surt_cat(data=D, var=any_t1, sout=sv5);
%surt_cat(data=D, var=any_t2, sout=sv6);
%surt_cat(data=D, var=any_t3, sout=sv7);

%surt_cat(data=D, var=age_c, sout=s1);
%surt_cat(data=D, var=hist1, sout=s2);
%surt_cat(data=D, var=lung, sout=s3);
%surt_cat(data=D, var=liver, sout=s4);
%surt_cat(data=D, var=ln, sout=s5);
%surt_cat(data=D, var=bone, sout=s6);
%surt_cat(data=D, var=brain, sout=s7);
%surt_cat(data=D, var=plef, sout=s8);
%surt_cat(data=D, var=other, sout=s9);
%surt_cat(data=D, var=nsites, sout=s10);
%surt_cat(data=D, var=nsites1, sout=s11);
Data D_1;set D;run;
proc sql;
delete *
from D_1
where Metl = 0;

%surt_cat(data=D_1, var=MetL, sout=s12);
%surt_cat(data=D, var=vm, sout=s13);

data Sout_cat;
set sv1-sv7 s1-s13 ;
run;

data Sout_all;
set Sout_con Sout_cat;
Dp=put(Death,4.)  || "("||put(Pcent,4.1)||"%)";
run;


proc format;
   picture Pvaluef (round)
           0.985   -   high    = "0.99"    (NoEdit)
           0.10    -<  0.985   = "9.99"
           0.001   -<  0.10    = "9.999"
           0       -<  0.001   = "<0.001"  (NoEdit)
		    . = " ";
run;
ods rtf file="&basedir.\Table6_Survival.doc" style=journal bodytitle;
proc report data=  Sout_all nowd
            style(report)={borderwidth=3 bordercolor=black cellpadding=3
                           font_size=11pt font_face=Times  FONTSTYLE= ROMAN}

            style(lines)={background=white foreground=black
                          font_size=9pt font_face=Times FONTSTYLE= ROMAN
                          protectspecialchars=off}

            style(column)={background=white foreground=black
                          font_size=11pt font_face=Times FONTSTYLE= ROMAN
                          font_weight=medium}

            style(header)={background=white foreground=black borderbottomstyle=double
                          font_weight=bold FONTSTYLE= ROMAN
                          font_size=11pt font_face=Times};
            column Parameter var1 Total Dp EMtime  ProbChiSq HR pvalue;
            

            ***** Title *****;
            compute before _PAGE_ /style = {font_size=11pt font_face=Times
                                  FONTSTYLE=ROMAN font_weight=bold
                                  just=left borderbottomwidth=3
                                  borderbottomcolor=black bordertopcolor=white};
                line "Table 6: survival compasion";
            endcomp;

            ***** Variable name column *****;
            
            define Parameter /"Factor"
                               style(header) = {just = left}
                               style(column) = {cellwidth = 1.5in font_weight=bold just = left};

            define var1/""
                               style(header) = {just = left}
                               style(column) = {cellwidth = 0.3in just = left};

            define Total/"N0.Total" 
                               style(header) = {just = center}
                               style(column) = {cellwidth = 0.3in just = center};
            define Dp/"N0.Death" 
                               style(header) = {just = center}
                               style(column) = {cellwidth = 0.8in just = center};
            define EMtime/"Estimated Median Survival(Months)"
                               style(header) = {just = center}
                               style(column) = {cellwidth = 0.8in just = center};
            define ProbChiSq/"P-value" format=Pvaluef.
                               style(header) = {just = center}
                               style(column) = {cellwidth = 0.6in just = center};
            define HR/"Hazard Ratio (95%CI)"
                               style(header) = {just = left}
                               style(column) = {cellwidth = 1.5in just = left};

            define pvalue/"P-value" format=Pvaluef.
                               style(header) = {just = center}
                               style(column) = {cellwidth = 0.6in just = center};
run;
ods rtf close;
       ***** END MY PROC REPORT *****;
