// Created: 20200827 Enoch Chen
// Lastest update: 20200928  Enoch Chen

// Notes: 
// We want to compare untied data to tied data using -stpp-, -strs-, -stnet-
// simulated dataset of 1 000 people from scenario2_1.dta
// 
// Make tied data by adding ceiling()/floor() in days, weeks, months, quarters
/*=================================*/
// Start of Stata code
// Make tied data
use "https://enochytchen.com/tutorials/relsurv/untied/scenario2_1", clear

gen tt1 = t                        // original time in days

// Floor
// if survival time is 0, Stata will exclude that individual from the analysis
// Make sure those 0 due to floor(), still have half of the minimum (e.g. 0.5 weeks)
gen tt2 = floor(tt1*365.241)/365.241 // Add some ties in days
	replace tt2 = 0.5/365.241  if tt2 == 0
	
gen tt3 = floor(tt1*52.177)/52.177   // weeks
	replace tt3 = 0.5/52.177   if tt3 == 0

gen tt4 = floor(tt1*12)/12           // months
    replace tt4 = 0.5/12       if tt4 == 0
	
gen tt5 = floor(tt1*4)/4             // quarters
	replace tt5 = 0.5/4        if tt5 == 0
	
gen tt6 = floor(tt1)                 // years
	replace tt6 = 0.5	       if tt6 == 0

save sc_new, replace

// Read the data
use sc_new, clear

// See how many distinct values there are
distinct tt*
/*=================================*/
// stns
ssc install stns, replace // get the latest stpp 

use sc_new, clear

forvalues i = 1/6{
stset tt`i', failure(dead==1 2) id(id)
stns list using "https://enochytchen.com/tutorials/relsurv/untied/lifetab.dta", ///
age(agediag=_age) period(diagdate=_year) ///
rate(rate) strata(sex) ///
survival at (1 5 10) // See 1, 5, 10-year Net surv 
}

/*=================================*/
// stpp
ssc install stpp, replace // get the latest stpp 

use sc_new, clear

forvalues i = 1/6{
stset tt`i', failure(dead==1 2) id(id)

// stpp:  step function and changes at each event time
// lifetab.dta: a popmort file 1990-2009
stpp R_pp`i' using "https://enochytchen.com/tutorials/relsurv/untied/lifetab.dta", pmother(sex) ///
agediag(agediag) ///
datediag(diagdate) ///
list(1 5 10) // See 1, 5, 10-year RS 
}
/*=================================*/
// strs
use sc_new, clear

forvalues i = 1/6{
stset tt`i', failure(dead==1 2) id(id)

strs using "https://enochytchen.com/tutorials/relsurv/untied/lifetab.dta", br(0(`=1/12')10) ///
	 diagage(agediag) diagyear(yeardiag) ///
	 mergeby(_year sex _age) pohar ht format(%5.3f) ///
	 notable savgroup(grouped`i', replace) 
}

forvalues i = 1/6{
use grouped`i', clear
list end cns_pp lo_cns_pp hi_cns_pp if end == 1 | end == 5 | end == 10
}

/*=================================*/
// stnet
use sc_new, clear

forvalues i = 1/6{
stset tt`i', failure(dead==1 2) id(id)

stnet using "https://enochytchen.com/tutorials/relsurv/untied/lifetab.dta", br(0(`=1/12')10.01) ///
diagdate(diagdate) birthdate(dob) ///
mergeby(_year sex _age) format(%5.3f) ///
notab saving(grouped`i', replace)
}
 
forvalues i = 1/6{
use grouped`i', clear
list end cns locns upcns if end == 1 | end == 5 | end == 10
}

// End of Stata code
