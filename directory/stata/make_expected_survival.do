//enochytchen.com
/****************************************************************************
The codes available at:
The tutorial available at:
The video instruction available at: 

Purpose:  Use -strs- to estimate expected survival within each age group
Note: For further details of using  -strs- to estimate and model relative/net survival
Please refer to http://pauldickman.com/software/strs/strs/

Author: Enoch Yi-Tung Chen 
Created data: 20200420 by Enoch
Updated:
****************************************************************************/

**************************
//---Data Preparation---//
**************************
// Specify which group of people you want to estimate for their expected survival
clear all

// This data was downlaoded from Paul Dickman's website
// https://pauldickman.com/survival/colon.dta
// Diagnosis 1975-1985
use https://enochytchen.com/directory/data/colon.dta if yydx>=1975 & yydx<=1985, clear

// Rename variables
rename yydx yeardiag
rename age agediag
gen stime=surv_mm/12
rename status dead

// Smart way to creating age groups
egen agegroup=cut(agediag), at(0 50 60 70 80 200) icodes
label variable agegroup "Age group"
label define agegroup 0 "0-49" 1 "50-59" 2 "60-69" 3 "70-79" 4 "80+" 
label values agegroup agegroup

// Create dummy varaiables for age categories
quietly tab agegroup, gen(agegroup)

save colon1975_1985,replace

******************
//---Modeling---//
******************
//Read the data
use colon1975_1985, clear

// We want every individual to be alive for eternity
replace stime=100
replace dead=0

// stset the data
// All-cause death as outcome
stset stime, failure(dead==1) id(id)  exit(time 21)

strs using "popmort_projection", ///
	breaks(0(`=1/12')21) ///
	diagage(agediag) diagyear(yeardiag) ///
	mergeby(_year sex _age) by(agegroup) ///
	savgroup(colon_expected_survival, replace)

// Add observations for time 0
use colon_expected_survival, clear
expand 2 if start==0, generate(expandflag)
replace end=0 if expandflag==1
replace cp_e2=1 if expandflag==1

// Change variable name so we can merge with model-based predictions
rename end _t 
keep cp_e2 agegroup _t
sort agegroup _t
compress
save, replace

**************
//---Plot---//
**************
// The corresponding expected survival of the patient cohort.
twoway (line cp_e2 _t if agegroup==0, sort lcolor(brown)) ///
	   (line cp_e2 _t if agegroup==1, sort lcolor(blue)) ///
       (line cp_e2 _t if agegroup==2, sort lcolor(black)) ///
       (line cp_e2 _t if agegroup==3, sort lcolor(red)) ///
       (line cp_e2 _t if agegroup==4, sort lcolor(green)) ///
	   , ylabel(0(0.2)1, format(%5.1f)) name(cp_e2, replace) ///
	    legend(order(1 "Age<50" 2 "Age 50-59" 3 "Age 60-69" 4 "Age 70-79" 5 "Age 80+")  ring(0) pos(1) col(1)) ///
	   ytitle("Expected survival (Ederer II)", size(*1.0)) ///
	   xtitle("Time since diagnosis (years)", size(*1.0)) 

/***************************** FILE ENDS HERE**************************/
