local todaydate: di %tdCYND date(c(current_date),"DMY")
capture log close
// Your Log folder route/ do-file name_todaydate

/*Bonus: global*/

global route "/Users/yitche/My_Website/content/courses/biostatbasics/excercise/exercise1"

log using $route/Log/exercise3_`todaydate'.log, replace

/*==============================================================================
FILENAME: exercise3.do

PROJECT: Exercise 3, Stockholm Public Health Cohort 	

PURPOSE: Demonstrate exercise3.do to the students
	
AUTHOR: Enoch Chen

CREATED: 20210203 Enoch Chen	
UPDATED: 20210204 Enoch Chen		

INPUT DATA: sphc_all.dta				
OUTPUT: N/A

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
// 1.3 Two by two tables
// f52a02=living alone
tab f52a02 sex, row 

// 1.4 Chi-square test 
tab f52a02 sex, row chi2 
// Interpretation: Sex has association with living alone or not.

// 1.5 Employment(Exposure) and Living alone(Outcome), stratified by sex_lab 
bysort sex: tab f52a02 f7502, chi
// Interpretation: Employment has association with living alone or not, in both sex.

// 1.6 Calculate risk ratio/difference
// Sex(Exposure) vs. Diabetes(Outcome)
// Caution: be aware of the order of the var in cs.

cs f6a02 sex 
// Sex was coded as 1/2, so cs cannot recognise which one is unexposed.
// The default is unexposed=0

// Instead
cs f6a02 female
// Interpretation: 
// a.  Risk difference: Females had 22 less cases of having diabetes per 100 subjects than males.
// b. Risk ratio: The risk of females with diabetes is 0.63 (95% CI 0.60-0.67) than males.
tab f6a02 female, col chi

// 1.7 Caculate odds ratio
cs f6a02 female, or
// Interpretation: Females had a 38% lower odds of diabetes(OR: 62, 95% CI 0.58-0.66)  than males.

*==============================================================================
log close
exit

/* Notes: 
- Go back to the header to update the info (input data and out put data)
*/
