-SAS--Macros
============

 - Some SAS Macros: 
   - Survival Analysis [9.3] 
     - Name       : surv_cat()
     - Function   : Number of Total, Number of Death, Median estimated Survival HR and P_value 
     - Procedures : lifetest ; phreg
     - Usage      : %include   "C:\Users\jiax\Documents\GitHub\-SAS--Macros\survival_macro_tmp.sas" ;
     - Usage      : %surt_cat(data=D, var=d28_lt500, survtime = rfs, scensor = rcensor, sout=rs1);
     - Other      : including output
     - Furture    : multiply variables input
