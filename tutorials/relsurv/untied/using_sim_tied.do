// Created: 20200827 Enoch Chen
// Lastest update: 20200924  Enoch Chen

// Notes: 
// We want to compare untied data to tied data using -stpp-, -strs-, -stnet-
// simulated dataset of 1 000 people from scenario2_1.dta
// 
// Make tied data by adding ceiling()
/*=================================*/
// Start of Stata code
// stpp

use scenario2_1, clear

// Make tied data
replace t =  ceil(t*365.241)/365.241

// stpp requires survival time in years
stset t, failure(dead) id(id)

// stpp:  step function and changes at each event time
// lifetab.dta: a popmort file 1990-2009
stpp R_pp using "https://enochytchen.com/tutorials/relsurv/untied/lifetab.dta", pmother(sex) ///
agediag(agediag) ///
datediag(diagdate) ///
list(1 5 10) // See 1, 5, 10-year RS 

// Plot the results
twoway (rarea R_pp_lci R_pp_uci _t, color(red%30) connect(stairstep) sort) /// add sort to make it look nice
	   (line R_pp _t, lcolor(red) connect(stairstep) sort)  ///     			   
	   ,legend(off)                                     ///
        xtitle("Years from diagnosis")                  ///
        ytitle(Marginal relative survival)              ///
        name(R_pp, replace)

/*=================================*/
// strs

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

// by months
stnet using lifetab, br(0(`=1/12')10.01) ///
diagdate(diagdate) birthdate(dob) ///
mergeby(_year sex _age) format(%5.3f)


// by year
stnet using lifetab, br(0(1)10) ///
diagdate(diagdate) birthdate(dob) ///
mergeby(_year sex _age) 

// End of Stata code
