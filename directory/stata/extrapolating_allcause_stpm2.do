//enochytchen.com
/****************************************************************************
The codes available at:
The tutorial available at:

Purpose: Extrapolating survival of colon cancer patients, diagnosed in 1975-1985,
		 in all-cause survival framework
Note: We restricted follow-up data to 10 years to extrapolate to 20 years,
	  and compare the extrapolation results with empirical Kaplan-Meier's curve

Author: Enoch Yi-Tung Chen 
Created data: 20200420 by Enoch
Updated:
****************************************************************************/

**************************
//---Data Preparation---//
**************************

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
use colon1975_1985,clear

// stset the data (prepare data for survival analysis)
// All-cause death as outcome, make everyone censored after 10 years since diagnosis
stset stime, failure(dead==1,2) id(id) exit(time 10) 

// stpm2 model
stpm2 agegroup2-agegroup5, /// agegroup0 is reference group
scale(hazard) df(5) eform /// hazard: propotional hazard
tvc(agegroup2-agegroup5) dftvc(2) // tvc allows non-proportional hazard


********************
//---Prediction---//
********************
// Create a new dataset for prediction
clear
range agegroup 0 4 5 
range _t 0 20 241 // (12*20)+1=241
fillin agegroup _t
drop if missing(agegroup,_t)

quietly tab agegroup, gen(agegroup)
 
predict s, survival timevar(_t) 
sort agegroup _t

save colon1975_1985_10yr_extrap, replace


**************
//---Plot---//
**************
twoway (line s _t if agegroup==0, sort lcolor(brown)) ///
       (line s _t if agegroup==1, sort lcolor(blue)) ///
       (line s _t if agegroup==2, sort lcolor(black)) ///
       (line s _t if agegroup==3, sort lcolor(red)) ///
       (line s _t if agegroup==4, sort lcolor(green)) ///
	   ,xline(10,lpattern(dash) lwidth(thin) lcolor(black)) ///
	   legend(order( 1 "Age<50" 2 "Age 50-59" 3 "Age 60-69" 4 "Age 70-79" 5 "Age 80+") ring(0) pos(1) col(1)) ///
	   xlabel(0 10 20) ///
	   ytitle("Survival proportion", size(*1.0)) ///
	   xtitle("Time since diagnosis (years)", size(*1.0)) 

	   
*******************************************************
//---Compare with empirical K-M curve by age group---//
*******************************************************
	   
// Use the whole follow-up period (until 1995) of the data
use colon1975_1985, clear
stset stime, failure(dead==1,2) id(id)

// generate K-M and  95% CI
sts generate km=s, by(agegroup)
sts gen ub=ub(s), by(agegroup)
sts gen lb=lb(s), by(agegroup)

keep agegroup _t km ub lb
sort agegroup _t

// Compared with the extrapolation curve
append using colon1975_1985_10yr_extrap

//Age <50
twoway 	 (rarea ub lb _t if agegroup==0, sort color(gs12)) ///
		 (line km _t if agegroup==0, sort lcolor(black)) ///
		 (line s _t if agegroup==0, lpattern(shortdash) sort lcolor(blue)) ///
	   ,xline(10,lpattern(dash) lwidth(thin) lcolor(black)) ///
	   ytitle("")  ylabel(0(.2)1, format(%3.1f))  yscale(noextend) ///
	   xtitle("") xlabel(none) xtick(0 10 20)  xscale(noextend) subtitle(Age<50) ///
	   plotregion(margin(0 0 0 0)) ///
	   legend(order(2 "K-M curve" 1 "95% CI for K-M curve" 3 "Extrapolation, all-cause") ring(0) pos(4) col(1) row(3) size(small) symxsize(huge) bmargin(0 0 15 0)) name(agegroup0, replace) 

// Age 50-59
twoway 	 (rarea ub lb _t if agegroup==1, sort color(gs12)) ///
		 (line km _t if agegroup==1, sort lcolor(black)) ///
		 (line s _t if agegroup==1, lpattern(shortdash) sort lcolor(blue)) ///
	   ,xline(10,lpattern(dash) lwidth(thin) lcolor(black)) ///
	   subtitle(Age 50-59) ///
	  ytitle("") ylabel(none) ytick(0(.2)1, grid)  yscale(noextend) ///
			xtitle("") xlabel(none) xtick(0 10 20)  xscale(noextend)  ///
			plotregion(margin(0 0 0 0)) ///
			title("") legend(off) name(agegroup1, replace)
	   
// Age 60-69
twoway 	 (rarea ub lb _t if agegroup==2, sort color(gs12)) ///
		 (line km _t if agegroup==2, sort lcolor(black)) ///
		 (line s _t if agegroup==2, lpattern(shortdash) sort lcolor(blue)) ///
	   ,xline(10,lpattern(dash) lwidth(thin) lcolor(black)) ///
	    subtitle(Age 60-69) ///
	   ytitle("") ylabel(none) ytick(0(.2)1, grid)  yscale(noextend) ///
			xtitle("") xlabel(none) xtick(0 10 20)  xscale(noextend)  ///
			plotregion(margin(0 0 0 0)) ///
			title("") legend(off) name(agegroup2, replace)
	   
// Age 70-79
twoway 	 (rarea ub lb _t if agegroup==3, sort color(gs12)) ///
		 (line km _t if agegroup==3,  sort lcolor(black)) ///
		 (line s _t if agegroup==3, sort lpattern(shortdash)  lcolor(blue)) ///
	   ,xline(10,lpattern(dash) lwidth(thin) lcolor(black)) ///
	   subtitle(Age 70-79) ///
	   ytitle("") ylabel(0(.2)1, format(%3.1f))  yscale(noextend) ///
			xtitle("") xlabel(0 5 10 20)  xscale(noextend) ///
			plotregion(margin(0 0 0 0)) ///
			title("") legend(off) name(agegroup3, replace)

// Age 80+
twoway 	 (rarea ub lb _t if agegroup==4, sort color(gs12)) ///
		 (line km _t if agegroup==4,  sort lcolor(black)) ///
		 (line s _t if agegroup==4, lpattern(shortdash) sort lcolor(blue)) ///
		  ,xline(10,lpattern(dash) lwidth(thin) lcolor(black)) ///
	   subtitle(Age ≥80) ///
	ytitle("") ylabel(none) ytick(0(.2)1, grid)  yscale(noextend)  ///
			xtitle("") xlabel(0 5 10 20)  xscale(noextend) ///
			plotregion(margin(0 0 0 0)) ///
			title("") legend(off) name(agegroup4, replace)

// Put 5 graph together by using grc1leg2
grc1leg2 agegroup0 agegroup1 agegroup2 agegroup3 agegroup4, /// 
	col(3) row(2) imargin(medsmall) iscale(0.8) ///
	l1title(Survival probability) b2title(Time since diagnosis (years)) title(Colon 1975-1985) ///
	legendfrom(agegroup0) position(4) ring(0) 
	
/***************************** FILE ENDS HERE**************************/
