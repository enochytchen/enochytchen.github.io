// Created: 20200902 Enoch Chen
// Lastest update: 20200923Enoch Chen

// Notes: 
// We want to compare using tied/untied data while estimating net survival-time
// using stpp, strs, stnet
// colon.dta, which has "tied" survival time data
/*===============================================*/ 
// stpp
// This part is the same as https://pclambert.net/software/stpp/using_stpp/
 
// Use colon.dta
use "http://enochytchen.com/directory/data/colon.dta", clear

// Calculate stime in days, then convert into years
generate stime = (exit-dx)/365.241

// Declare survival-time data
// stpp requires survival time in years,
stset stime, failure(status == 1 2) id(id) 

// stpp:  step function and changes at each event time
// popmort.dta: a popmort file 1951 - 2000
stpp R_pp using "http://enochytchen.com/directory/data/popmort.dta", pmother(sex) ///
agediag(age) ///
datediag(dx) ///
list(1 5 10) // See 1, 5, 10-year RS 

/*===============================================*/
// strs pohar
// Refer to: http://www.pauldickman.com/software/stnet/comparestrs/

// strs allows decimal values for year of diagnosis
replace yydx = 1960 + dx/365.241

// by months
// -ht- option specifies that the hazard transformation approach 
// to estimation (rather than the actuarial) is used.
// Download popmort from: https://enochytchen.com/directory/data/popmort.dta 

strs using "popmort", ///
	 br(0(`=1/12')10) ///
	 diagage(age) diagyear(yydx) ///
	 mergeby(_year sex _age) ht pohar format(%5.3f)

// by year
strs using "~/cansurv/data/popmort", br(0(1)10) ///
	 diagage(age) diagyear(yydx) ///
	 mergeby(_year sex _age) pohar format(%5.3f)

/*===============================================*/
// stnet pohar (the default is pohar) 

// Create a variable for dob
gen dob=dx-age*365.241

// by months
stnet using "~/cansurv/data/popmort", br(0(`=1/12')10.1) ///
diagdate(dx) birthdate(dob) ///
mergeby(_year sex _age) ///
listyearly format(%5.3f)

// by year
stnet using "~/cansurv/data/popmort", br(0(1)10) ///
diagdate(dx) birthdate(dob) ///
mergeby(_year sex _age) format(%5.3f)

// End of Stata code
