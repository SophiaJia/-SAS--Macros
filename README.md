-SAS--Macros
============

 - Survival Analysis : 
   - Univariable Survival Analysis [9.4] 
     - Name       : surv_uni
     - Function   : Number of Total, Number of Death, Median estimated Survival HR and P_value 
     - Procedures : lifetest ; phreg
     - Usage      : %include   "C:\Users\jiax\Documents\GitHub\-SAS--Macros\survival_macro_uni.sas";
     - Usage      : %surv_uni(data=D, var=d28_lt500, survtime = rfs, scensor = rcensor, sout=rs1);
     - Output     : survival_macro_output_uni.sas
     - Furture    : multiply variables input
  
  - Multvariable Survival Analysis [9.4]
     - Name       : surt()
     - Function   : HR (95% CI) and P_value 
     - Procedures : phreg
     - Usage      : %include   "C:\Users\jiax\Documents\GitHub\-SAS--Macros\survival_macro_multy.sas" ;
     - Usage      : %surt(data=D, var = V1 V2 V3 V4 V5, survtime = rfs, scensor = rcensor, sout=rs1);
     - Output     : survival_macro_output_multy.sas
     - Furture    : This macro is only good for binary varaibles 
