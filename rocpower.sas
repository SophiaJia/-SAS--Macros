%macro rocpower (t0, t1, t2, percent, r,na, nn,n, alpha, tails, ordinal, I=2,
   J=1);

 %macro VAR(num);
    if ordinal=1 then do;
       A&num=probit(t&num)*sqrt(2);
     V&num=na*((.0099)*exp(-A&num**2/2))*((5*A&num**2+8)/na+(A&num**2+8)/nn);
       end;
    else do;
       Q1&num=t&num/(2-t&num);
       Q2&num=2*(T&num**2)/(1+T&num);
       v&num=Q1&num/ratio+Q2&num-T&num**2*(1/ratio+1);
       end;
  %mend;



data zepp1;
error=0;
pi=3.141592654;
I=&i+0; if i le 0 then i=1;
j=&j+0; if j le 0 then j=1;

t0=&t0+0; if t0 le 0 then do;
           put "ERROR: t1 needs to be specified";
           error=1;
           end;
          if t0 ge 1 then do;
            put "ERROR: t0 specified as &t0.  It should be less than 1.0";
           error=1;
           end;

t1=&t1+0; if t1 le 0 then do;
           put "ERROR: t1 needs to be specified";
           error=1;
           end;
          if t1 ge 1 then do;
            put "ERROR: t1 specified as &t1.  It should be less than 1.0";
           error=1;
           end;

t2=&t2+0; if i ge 2 and t2 le 0 then do;
           put "ERROR:  &i modalities indicated, but T2 not specified or set to zero";
           error=1;
           end;
          if t2 ge 1 then do;
            put "ERROR: t2 specified as &t2.  It should be less than 1.0";
           error=1;
           end;
n=&n+0; no=n;
nn=&nn+0; nno=nn;
na=&na+0; nao=na;
percent=&percent+0; percento=percent;
if percent>1 and percent le 100 then percent=percent/100;
if percent gt 100 then do;
  put "ERROR: A percentage greater than 100% has been entered";
  error=1;
  end;
if percent lt 0 then do;
  put "ERROR: A percentage less than 0 has been entered";
  error=1;
  end;
if nn gt 0 then percent=na/(nn+na);
if na le 0 and nn le 0 then do;
   if n le 0 then do;
    put "ERROR: na, nn, n, and percent input incorrectly or not at all";
    put "you must specify nn and na or percent and n";
    error=1;
    end;
   else do;
    na=percent*n;
    nn=n-na;
   end;
end;

alpha=&alpha+0; if alpha le 0 then do;
                  alpha=.05;
                  %let alpha=.05;
                  end;
tails=&tails+0; if tails le 0 then do;
                  tails=2;
                  %let tails=2;
                  end;
r=&r+0;
ordinal=&ordinal+0;
ratio=nn/na;

*Single Reader;
if J=1 and error=0 then do;

if t2 eq 0 and tails eq 1 then do;
   diff=abs(t1-t0);
   %do zz=0 %to 1;
     %var(&zz);
   %end;
   zbeta=(diff*sqrt(na)-probit(1-alpha)*sqrt(v0))/sqrt(v1);
   Power=probnorm(ZBeta);
end;

if t2 eq 0 and tails eq 2 then do;
   diff=abs(t1-t0);
   %do zz=0 %to 1;
     %var(&zz);
   %end;
   zbeta=(diff*sqrt(na)-probit(1-alpha/2)*sqrt(v0))/sqrt(v1);
   zbeta2=(-diff*sqrt(na)-probit(1-alpha/2)*sqrt(v0))/sqrt(v1);
   Power=probnorm(ZBeta) + probnorm(Zbeta2);
end;

if t2 gt 0 and tails eq 1 then do;
   d1=abs(t1-t0);
   d2=abs(t2-t0);
   d3=abs(t1-t2);
   diff=max(of d1 d2 d3);
   %do zz=0 %to 2;
     %var(&zz);
   %end;    ZBeta=(diff*sqrt(na)-probit(1-alpha)*sqrt(2*v0-2*r*V0))/sqrt(v1+v2-2*r*sqrt(v1)*sqrt(v2));
    Power=probnorm(ZBeta);
end;

if t2 gt 0 and tails eq 2 then do;
   d1=abs(t1-t0);
   d2=abs(t2-t0);
   d3=abs(t1-t2);
   diff=max(of d1 d2 d3);
%do zz=0 %to 2;
  %var(&zz);
%end;   ZBeta=(diff*sqrt(na)-probit(1-alpha/2)*sqrt(2*v0-2*r*V0))/sqrt(v1+v2-2*r*sqrt(v1)*sqrt(v2));
   ZBeta2=(-diff*sqrt(na)-probit(1-alpha/2)*sqrt(2*v0-2*r*V0))/sqrt(v1+v2-2*r*sqrt(v1)*sqrt(v2));
   Power=probnorm(ZBeta) + probnorm(Zbeta2);
end;




file print;
*paired or unpaired;

if i eq 2 then do;
  if r eq 0 then Put 'Unpaired Cases';
   else  Put 'Paired Cases';
end;

put;
put;

*hypotheses;
 Put "Hypothesis tested:";
if i eq 2 then do;
  Put "HO:  T1 = T2 = &T0";
  if tails eq 2 then put "HA:  T1 < T2 or T1 > T2";
  else if t1<t2 then put "HA:  T1 < T2";
  else put "HA:  T1 > T2";
  end;
else if i eq 1 then do;
  Put "HO:  T1 = &T0";
  if tails eq 2 then put "HA:  T1 < &T0 or T1 > &T0";
  else if t1<t0 then put "HA:  T1 < &T0";
  else put "HA:  T1 > &T0";
  end;



put;
put;
put "With:";
put "T1 hypothesized at &t1";
if t2 gt 0 then put "T2 hypothesized at &t2";
put "Alpha = &alpha";

if na>10 and nn> 10 and nao gt 0 then do;
   put "Number of Abnormal Cases = &na";
   put "Number of Normal Cases = &nn";
   end;
else if na>10 and nn> 10 and percent gt 0 then do;
   put "Percent of abnormal patients = &percent";
   put " Total Sample Size = &n";
   end;


else if na<10 and nao gt 0 then do;
  put "WARNING:  The number of Abnormal Cases (&na) is small.";
  put "          Assymptotic Theory may not apply!";
  end;
else if na<10 and nao eq 0 then do;
  put "WARNING:  The percent (&percent) and total sample size (&n) yield a small number of abnormal patients.";
  put "          Assymptotic Theory may not apply!";
  end;

if nn<10 and nno gt 0 then do;
  put "WARNING:  The number of Normal Cases (&nn) is small.";
  put "          Assymptotic Theory may not apply!";
  end;
else if nn<10 and nno eq 0 then do;
  put "WARNING:  The percent (&percent) and total sample size (&n) yield a small number of abnormal patients.";
  put "          Assymptotic Theory may not apply!";
  end;


if r ne 0 then put "Correlation between T1 and T2 = &r";
if ordinal=0 then put "Standard Errors estimated using the Hanley-McNeil method";
 else put "Standard Errors estimated using the Obuchowski method";
put;
put "The estimated Power of the test is " power 5.3;

end;

if error=1 then do;
file print;
put  #8 "An error has occurred, please check the SAS:LOG";
end;
run;
%mend;
