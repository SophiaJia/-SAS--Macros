proc format;
   picture Pvaluef (round)
           0.985   -   high    = "0.99"    (NoEdit)
           0.10    -<  0.985   = "9.99"
           0.001   -<  0.10    = "9.999"
           0       -<  0.001   = "<0.001"  (NoEdit)
		    . = " ";
run;
ods rtf file="&basedir.\Table6_Survival_additional.doc" style=journal bodytitle;
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
            column Parameter var1 Total Dp  Median_range EMtime   HR pvalue;
            

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
            define Death/"N0.Death" 
                               style(header) = {just = center}
                               style(column) = {cellwidth = 0.8in just = center};

            define Median_range/"Actual survival time (Months)"
                               style(header) = {just = center}
                               style(column) = {cellwidth = 0.8in just = center};

            define EMtime/"Estimated Median Survival(Months)"
                               style(header) = {just = center}
                               style(column) = {cellwidth = 0.8in just = center};

            define HR/"Hazard Ratio (95%CI)"
                               style(header) = {just = left}
                               style(column) = {cellwidth = 1.5in just = left};

            define pvalue/"P-value" format=Pvaluef.
                               style(header) = {just = center}
                               style(column) = {cellwidth = 0.6in just = center};
run;
ods rtf close;
       ***** END MY PROC REPORT *****;
