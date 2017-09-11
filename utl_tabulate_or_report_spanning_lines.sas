proc report with arbitrarily placed spanning lines

for output report
see
https://www.dropbox.com/s/4ne81zsbxxbk8ph/lyn.rtf?dl=0

  This is not a tabulate solution. I find report to be more flexible.
  I build a crosstab dataset and then use 'proc report'.
  This is less likely to paint you into an 'excel' corner.

  I created an rtf document. Should work with pdf, althoug inline format may change.

 WORKING CODE
 ===========

     ods output observed   =xpocnt(rename=(label=type sum=rowcnt));
     ods output observedpct=xpopct(rename=(label=type sum=rowpct F=F_pct M=M_pct ));
     proc corresp data=class observed dimens=1 print=both;
      tables year, sex;

     data xpotwo;
       retain grp;
       merge xpocnt xpopct;
       grp=substr(type,1,1);
     run;quit;

     /* almost there at this point

      GRP    TYPE    F     M    ROWCNT     F_PCT      M_PCT      ROWPCT

       2     2014    2     4       6      10.5263    21.0526     31.579
       2     2015    3     4       7      15.7895    21.0526     36.842
       2     2016    4     2       6      21.0526    10.5263     31.579
       S     Sum     9    10      19      47.3684    52.6316    100.000
    */

see
https://goo.gl/Ykyzmi
https://communities.sas.com/t5/ODS-and-Base-Reporting/Tabulate-amp-Template-Issues/m-p/394832

HAVE
====
   Up to 40 obs WORK.CLASS total obs=19

   Obs    SEX    YEAR

     1     M     2015
     2     F     2016
     3     F     2014
     4     F     2015
     5     M     2016
    ....
    16     M     2015
    17     M     2016
    18     M     2014
    19     M     2015

WANT
====
   d:/rtf/lyn.rtf

    (lines are solid in rtf)

   ----------------------------------------------
           Females        Males         Total
          %         #   %         #   %         #
   ----------------------------------------------

   2014   2    10.526   4    21.053   6    31.579
   2015   3    15.789   4    21.053   7    36.842
   2016   4    21.053   2    10.526   6    31.579
   ----------------------------------------------
   Sum    9    47.368  10    52.632  19   100.000
   ----------------------------------------------

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

proc datasets lib=work kill;
run;quit;

data class;
  set sashelp.class(keep=sex);
  year=2014+mod(_n_,3);
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

ods exclude all;
ods output observedpct=xpopct(rename=(label=type sum=rowpct));
ods output observed   =xpocnt(rename=(label=type sum=rowcnt F=F_pct M=M_pct ));
proc corresp data=class observed dimens=1 print=both;
 tables year, sex;
run;quit;
ods select all;

data xpotwo;
  retain grp;
  merge xpocnt xpopct;
  grp=substr(type,1,1);
run;quit;


ods escapechar='^';
ods rtf file="d:/rtf/lyn.rtf" style=HighSchoolRTF;
proc report data=xpotwo nowd split='!' headline headskip
STYLE(report)=[ rules=group]
     style(header)={borderbottomwidth=2pt borderbottomcolor=black};
cols (grp TYPE  ("Females" F F_pct)  ("Males" M M_pct) ("Total" rowcnt rowpct ));
define grp / group noprint;
define type    / group "";
define  F      / group "%";
define  F_pct  / group "#";
define  M      / group "%";
define  M_pct  / group "#";
define  rowcnt / group "%";
define  rowpct / group "#";
compute after grp;
 line '^R/RTF"\brdrt\brdrs\brdrw15"';
endcomp;
endcomp;
run;quit;
ods rtf close;

*_                       _       _
| |_ ___ _ __ ___  _ __ | | __ _| |_ ___
| __/ _ \ '_ ` _ \| '_ \| |/ _` | __/ _ \
| ||  __/ | | | | | |_) | | (_| | ||  __/
 \__\___|_| |_| |_| .__/|_|\__,_|\__\___|
                  |_|
;

PROC TEMPLATE;
      DEFINE STYLE HighSchoolRTF;
      PARENT=styles.rtf;


      replace fonts /
    'TitleFont'     = ("Arial",12pt,Bold) /* TITLE statement */
    'TitleFont2'    = ("Arial",10pt,Bold) /* PROC titles */
    'headingFont'   = ("Arial",10pt) /* Table column/row headings */
    'docFont'       = ("Arial",10pt)      /* data in table cells */
    'footFont'      = ("Arial",8pt)       /* FOOTNOTE statements */
    'StrongFont'    = ("Arial",10pt,Bold)
    'EmphasisFont'  = ("Arial",10pt,Italic)
    'headingEmphasisFont'= ("Arial",10pt,Italic)
    'FixedFont'          = ("Arial",10pt)
    'FixedEmphasisFont'  = ("Arial",10pt,Italic)
    'FixedStrongFont'    = ("Arial",10pt,Bold)
    'FixedHeadingFont'   = ("Arial",10pt)
    'BatchFixedFont'     = ("Arial",10pt) ;

      style table from table /
    background=_UNDEF_ /* REMOVES TABLE BACKGROUND COLOR */
    rules=groups      /* INTERNAL BORDERS: SET TO BOTTOM BORDER ON ROW HEADERS */
    frame=above       /* EXTERNAL BORDERS: SET TO TOP LINE OF TABLE ONLY */
    cellspacing=0      /* SPACE BETWEEN TABLE CELLS */
    cellpadding=1     /* REMOVES PARAGRAPH SPACING BEFORE/AFTER CELL CONTENTS */
    borderwidth=1pt; /* SET WIDTH OF BORDER IN FRAME= */

      style headerrow from data /
            backgroundcolor=grayaa;

      replace HeadersAndFooters from Cell /
    background = _undef_
    font = Fonts('headingFont') ;

       replace SystemFooter from TitlesAndFooters /
     font = Fonts('footFont')
     just = LEFT ;

      replace Body from Document /
    bottommargin = .5in
    topmargin    = .5in
    rightmargin  = .5in
    leftmargin   = .5in ;

      /*replace usertext from usertext /
            font = Fonts('StrongFont')
            just = LEFT;*/

        end ;  /* END OF DEFINE STYLE MyStyleRTF */
run ;    /* END OF PROC TEMPLATE */


