%macro surt(data=, var=, survtime = , scensor = , sout=);
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
*%surt(data = D, var = Sex stage_con_1 Necrosis_new SarcDiff tumor_size10_1 rn_invasion_1Y PerinephFat_m mononuc_cell_infiltrate_m1 MicroVascInv  , survtime = surdate, scensor = rcensor, sout=s);


