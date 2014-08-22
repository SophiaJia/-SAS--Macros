proc format;
   picture Pvaluef (round)
           0.985   -   high    = "0.99"    (NoEdit)
           0.10    -<  0.985   = "9.99"
           0.001   -<  0.10    = "9.999"
           0       -<  0.001   = "<0.001"  (NoEdit)
		    . = " ";
run;
ods rtf file="&basedir.\Table7_Survival_multy_add.doc" style=journal bodytitle;
proc report data=  Sout_all_r nowd
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
            column Parameter HR_ pv_;
            

            ***** Title *****;
            compute before _PAGE_ /style = {font_size=11pt font_face=Times
                                  FONTSTYLE=ROMAN font_weight=bold
                                  just=left borderbottomwidth=3
                                  borderbottomcolor=black bordertopcolor=white};
                line "Table 7: survival compasion";
            endcomp;

            ***** Variable name column *****;
            
            define Parameter /"Factor"
                               style(header) = {just = left}
                               style(column) = {cellwidth = 1.5in font_weight=bold just = left};

            define HR_/"Hazard Ratio (95%CI)"
                               style(header) = {just = left}
                               style(column) = {cellwidth = 1.5in just = left};

            define pv_/"P-value" format=Pvaluef.
                               style(header) = {just = center}
                               style(column) = {cellwidth = 0.6in just = center};
run;
ods rtf close;
       ***** END MY PROC REPORT *****;
