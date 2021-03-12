local todaydate: di %tdCYND date(c(current_date),"DMY")
capture log close
// Your Log folder route/ do-file name_todaydate

/*Bonus: global*/

global route "your route"

log using $route/Log/exercise4_`todaydate'.log, replace

/*==============================================================================
FILENAME: exercise4.do

PROJECT: Exercise 4, Stockholm Public Health Cohort 	

PURPOSE: Demonstrate exercise4.do to the students
	
AUTHOR: Enoch Chen

CREATED: 20210208 Enoch Chen	
UPDATED: 20210208 Enoch Chen		

INPUT DATA: sphc_all.dta				
OUTPUT: mean_srh.pdf

STATA VERSION: 16.1
==============================================================================*/
clear all

// See where is my working directory
pwd 

// Redirect my working directory
cd "$route/Data"

// Use the data from exercise 2
// Or your make_analysis data (if you've already intergrated.)
clear all
use sphc_all_exercise2, clear

/*===============
=====Part 1======
===============*/
// 1.1 Bar chart showing no. of participants by year
graph bar (count), over (argang) ///
      title("Number of participants in 2002, 2006, 2010")

// 1.2 Box plot for self-rated health by year
graph box srh, over(argang)

// 1.3 Statistics behind box plots
tabstat srh, s(p25 p50 p75) by(argang) 

// 1.4 Mean of self-rate health
ci mean nsrh if argang == 2002
ci mean nsrh if argang == 2006
ci mean nsrh if argang == 2010

// I would choose demonstrate mean with sd./95% CI rather than median/box plot

// Also use ANOVA to test the difference over year
anova srh argang

/*===============
=====Part 2======
===============*/
gen nsrh_mean = .

// Generate mean of self-rated health by agegroup and year
// 2002
tabstat nsrh if argang == 2002, by(agegrp4) s(mean) save

replace nsrh_mean = r(Stat1)[1,1]  if agegrp4 == 1 & argang == 2002
replace nsrh_mean = r(Stat2)[1,1]  if agegrp4 == 2 & argang == 2002
replace nsrh_mean = r(Stat3)[1,1]  if agegrp4 == 3 & argang == 2002
replace nsrh_mean = r(Stat4)[1,1]  if agegrp4 == 4 & argang == 2002

// 2006
tabstat nsrh if argang == 2006, by(agegrp4) s(mean) save

replace nsrh_mean = r(Stat1)[1,1]  if agegrp4 == 1 & argang == 2006
replace nsrh_mean = r(Stat2)[1,1]  if agegrp4 == 2 & argang == 2006
replace nsrh_mean = r(Stat3)[1,1]  if agegrp4 == 3 & argang == 2006
replace nsrh_mean = r(Stat4)[1,1]  if agegrp4 == 4 & argang == 2006

// 2010
tabstat nsrh if argang == 2010, by(agegrp4) s(mean) save
replace nsrh_mean = r(Stat1)[1,1]  if agegrp4 == 1 & argang == 2010
replace nsrh_mean = r(Stat2)[1,1]  if agegrp4 == 2 & argang == 2010
replace nsrh_mean = r(Stat3)[1,1]  if agegrp4 == 3 & argang == 2010
replace nsrh_mean = r(Stat4)[1,1]  if agegrp4 == 4 & argang == 2010

/* Bonus: use foreach/forvalues to save your work*/
capture drop nsrh_mean 
capture gen nsrh_mean = .

foreach i in 2002 2006 2010 {
	forvalues j = 1/4{
	tabstat nsrh if argang == `i', by(agegrp4) s(mean) save
	replace nsrh_mean = r(Stat`j')[1,1]  if agegrp4 == `j' & argang == `i'
	}
}

// Plot mean self-rated health by age group and by year
twoway(scatter nsrh_mean argang if agegrp4 == 1, color(blue)) ///
	  (scatter nsrh_mean argang if agegrp4 == 2, color(green)) ///
	  (scatter nsrh_mean argang if agegrp4 == 3, color(red)) ///
	  (scatter nsrh_mean argang if agegrp4 == 4, color(gray)), ///
	  ///
	  legend(order(1 "18-29" 2 "30-44" 3 "45-64" 4 "65-84")) ///
	  ///
	  xscale(range(2000 2012)) ///
	  xlabel(2002 2006 2010) ///
	  xtitle("Survey year") ///
	  ///
	  yscale(range(3 5)) ///
	  ylabel(3(0.5)5) ///
	  ytitle("Mean self-rated health") ///
	  ///
	  name("mean_srh", replace) ///
	  title("Mean self-rated health by age group and by year") ///
	  saving(, replace) 

	  graph export "$route/Output/mean_srh.pdf", as(pdf) replace
	  
*==============================================================================
log close
exit

/* Notes: 
- Go back to the header to update the info (input data and out put data)
*/
