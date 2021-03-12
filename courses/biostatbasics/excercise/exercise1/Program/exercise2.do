local todaydate: di %tdCYND date(c(current_date),"DMY")
capture log close
// Your Log folder route/ do-file name_todaydate
log using "/Users/yitche/My_Website/content/courses/biostatbasics/excercise/exercise1/Log/exercise2_`todaydate'.log", replace

/*==============================================================================
FILENAME: exercise2.do

PROJECT: Exercise 2, Stockholm Public Health Cohort 	

PURPOSE: Demonstrate exercise2.do to the students
	
AUTHOR: Enoch Chen

CREATED: 20210201 Enoch Chen	
UPDATED: 20210201 Enoch Chen		

INPUT DATA: sphc_all.dta				
OUTPUT: sphc_all_exercise2.dta

STATA VERSION: 16.1
==============================================================================*/
clear all

// See where is my working directory
pwd 

// Redirect my working directory
cd "/Users/yitche/My_Website/content/courses/biostatbasics/excercise/exercise1/Data"

// Use the data, either click or direct type the command
use sphc_all, clear

// Give them id
gen id = _n

/*===============
=====Part 1======
===============*/
// 1.1 Label data
label data "Stockholm Public Health Cohort 2002, 2006, 2010" 

// Use describe to see whether it's successfully labeled or not
describe

// 1.2 Rename variables 
rename kon sex
rename aldkl4 agegrp4
rename f302 srh

// 1.3 Open your codebook and add a new column for the renamed variables

// 1.4 Label variables
label variable sex sex
label variable agegrp4 agegrp4
label variable srh srh

// 1.5 Label value variables
label define sex_lab 1 "man" 2 "woman"
label values sex sex_lab

label define agegrp4_lab 1 "18-29" 2 "30-44" 3 "45-64" 4 "65-84"
label values agegrp4 agegrp4_lab

label define srh_lab 1 "Excellent" 2 "Good" 3 "Average" 4 "Poor" 5 "Very poor"
label values srh srh_lab
// Open up the data viewer and see what is the difference before and after labeling

// 1.6 Generate a new variable female
// Whenever you generate a new variable, check for missing
tab sex // Looks okay

gen female = 1 if sex == 2
replace female = 0 if sex == 1
tab female sex // Check you successfully gen or not

// 1.7 Generate dummy variables for agegrp4
// First take a look at agegrp4
codebook agegrp4

tab agegrp4, gen(agegrp_dum)
list agegrp4 agegrp_dum* if id < 30

// 1.8 Generate a new variable nsrh with reverse order of srh
codebook srh

gen nsrh = 1 if srh == 5
replace nsrh = 2 if srh == 4
replace nsrh = 3 if srh == 3
replace nsrh = 4 if srh == 2
replace nsrh = 5 if srh == 1

/*Bonus: Use forvalues */
capture drop nsrh

forvalues i = 1/5 {
	if `i' == 1{
		gen nsrh = `i'  if srh == 6-`i'
	}
	
	else{
		replace nsrh = `i' if srh == 6-`i'		
	}
}

/*Bonus to me: Use recode (I learned from you guys!)*/
capture drop nsrh
recode srh (5=1) (4=2) (3=3) (2=4) (1=5), gen(nsrh)

// Label again
label define nsrh_lab 1 "Very poor" 2 "Poor" 3 "Average" 4 "Good" 5 "Excellent"
label values nsrh nsrh_lab

// Add numeric values back to the variables
numlabel, add

// Check
tab srh nsrh

save sphc_all_exercise2, replace 

/*===============
=====Part 2======
===============*/
clear all
use sphc_all_exercise2, clear

// 2.1 Describe the data
des

// Summary statistics
tabstat srh, s(count mean sd var median min max range)

// 2.2 Stratification
// f52a02: Living alone 
tab f52a02

// Label the variable 
lab var f52a02 alone

// Separate by agegroup
tab f52a02 agegrp4, col 

// Proportion of females by year?
tab female argang, col

save sphc_all_exercise2, replace 

*==============================================================================
log close
exit

/* Notes: 
- You might consider add Part 1 in to your make_analysis_data
- Go back to the header to update the info (input data and out put data)
- Take a quick look at the Log folder, and the Data folder
*/
