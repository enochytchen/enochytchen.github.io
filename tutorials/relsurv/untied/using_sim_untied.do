// Created: 20200827 Enoch Chen
// Lastest update: 20200924 Enoch Chen

// Notes: 
// We want to compare untied data to tied data using -stpp-, -strs-, -stnet-
// simulated dataset of 1 000 people from scenario2_1.dta
// 
/*=================================*/
// Start of Stata code
// stpp

// Note dataset is from a simulation
use http://enochytchen.com/tutorials/relsurv/untied/scenario2_1.dta, clear

// continuous time t in years
// no ties
tab t 	   // no tied data

// stpp requires survival time in years; time is already in years
stset t, failure(dead) id(id) 

// stpp:  step function and changes at each event time
// lifetab.dta: a popmort file 1990-2009
stpp R_pp using "https://enochytchen.com/tutorials/relsurv/untied/lifetab.dta", pmother(sex) ///
agediag(agediag) ///
datediag(diagdate) ///
list(1 5 10) // See 1, 5, 10-year RS 

// The results were saved to a matrix
matrix list r(PP)

// Plot the results
twoway (rarea R_pp_lci R_pp_uci _t, color(red%30) connect(stairstep) sort) /// add sort to make it look nice
	   (line R_pp _t, lcolor(red) connect(stairstep) sort)  ///     			   
	   ,legend(off)                                     ///
        xtitle("Years from diagnosis")                  ///
        ytitle(Marginal relative survival)              ///
        name(R_pp, replace)
/*===============================================*/
// strs
use scenario2_1, clear

stset t, failure(dead) id(id) 

// by month
strs using lifetab, br(0(`=1/12')10) ///
	 diagage(agediag) diagyear(yeardiag) ///
	 mergeby(_year sex _age) pohar ht format(%5.3f)


// by year
strs using lifetab, br(0(1)10) ///
	 diagage(agediag) diagyear(yeardiag) ///
	 mergeby(_year sex _age) pohar ht format(%5.3f)
	 

/*=================================*/
// stnet
use scenario2_1, clear

stset t, failure(dead) id(id) 

// by months
stnet using "https://enochytchen.com/tutorials/relsurv/untied/lifetab.dta", br(0(`=1/12')10.01) ///
diagdate(diagdate) birthdate(dob) ///
mergeby(_year sex _age) format(%5.3f)

// by year
stnet using "https://enochytchen.com/tutorials/relsurv/untied/lifetab.dta", br(0(1)10) ///
diagdate(diagdate) birthdate(dob) ///
mergeby(_year sex _age) format(%5.3f)

// End of Stata code
