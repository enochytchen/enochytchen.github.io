// Created: 20200903 Enoch Chen
// Lastest update: 20200923 Enoch Chen

// Notes: 
// We want to compare using tied/untied data while estimating net survival-time
// using stpp, strs, stnet
// colon.dta, where surv_mm was untied by using generate surv_mm2 = surv_mm + rnormal()

/*===============================================*/
// Start of Stata code
// stpp

// Use colon.dta
use "http://enochytchen.com/directory/data/colon.dta", clear

// Break ties by adding a random variance into stime
set seed 1234 
generate stime = (exit-dx)/365.241 + rnormal(0, 0.01) // with mean=0, s.d.=0.01

// stset
stset stime, failure(status == 1 2) id(id)

// stpp
stpp R_pp2 using "http://enochytchen.com/directory/data/popmort.dta", pmother(sex) ///
agediag(age) ///
datediag(dx) ///
list(1 5 10) // See 1, 5, 10-year RS 

/*===============================================*/
// strs pohar
// strs allows decimal values for year of diagnosis
// Please refer to: http://www.pauldickman.com/software/stnet/comparestrs/

replace yydx = 1960 + dx/365.241

// by months
strs using  "popmort", br(0(`=1/12')10) ///
	 diagage(age) diagyear(yydx) ///
	 mergeby(_year sex _age) ht pohar format(%5.3f)

// by year
strs using "~/cansurv/data/popmort", br(0(1)10) ///
	 diagage(age) diagyear(yydx) ///
	 mergeby(_year sex _age) ht pohar format(%5.3f)

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
