local todaydate: di %tdCYND date(c(current_date),"DMY")
capture log close
// Your Log folder route/ do-file name_todaydate
log using "/Users/yitche/My_Website/content/courses/biostatbasics/excercise/exercise1/Log/make_analysis_data_`todaydate'.log", replace

/*==============================================================================
FILENAME: make_analysis_data.do

PROJECT: Exercise 1, Stockholm Public Health Cohort 	

PURPOSE: Demonstrate make_analysis_data.do to the students
	
AUTHOR: Enoch Chen

CREATED: 20210127 Enoch Chen	
UPDATED: 20210128 Enoch Chen		

INPUT DATA: sphc2002.xls, sphc2006.xls, sphc2010.xls				
OUTPUT: sphc2002.dta, sphc2006.dta, sphc2010.dta, sphc_all.dta

STATA VERSION: 16.1
==============================================================================*/
clear all

// See where is my working directory
// Different command in Windows/Mac 
// If you are not sure, you can type help pwd
pwd 

// Redirect my working directory
cd "/Users/yitche/My_Website/content/courses/biostatbasics/excercise/Data/"

// Import the data, either click or direct type the command
// If you use click function, please remember to cope and paste the command back to do-file.
// Import data 2002
import excel "/Users/yitche/My_Website/content/courses/biostatbasics/excercise/Data/sphc2002.xls", sheet("Sheet1") firstrow clear

// Save data (at the working directory)
save sphc2002, replace

// Import data 2006
import excel "/Users/yitche/My_Website/content/courses/biostatbasics/excercise/Data/sphc2006.xls", sheet("Sheet1") firstrow clear

// Save data
save sphc2006, replace

// Import data 2010
import excel "/Users/yitche/My_Website/content/courses/biostatbasics/excercise/Data/sphc2010.xls", sheet("Sheet1") firstrow clear

// Save data
save sphc2010, replace

/*
Bonus: use the loop function to save your work
	   Use -foreach-
*/
foreach i in 2002 2006 2010{
	import excel "/Users/yitche/My_Website/content/courses/biostatbasics/excercise/Data/sphc`i'.xls", sheet("Sheet1") firstrow clear
save sphc`i', replace
}

// Read sphc2002.dta only and append the two others
clear 
use sphc2002, clear 

append using sphc2006
append using sphc2010

// Quick check 
tab argang

// Save the appeneded data in one file
save sphc_all, replace

*==============================================================================
log close
exit

/* Notes: 
- Go back to the header to update the info (input data and out put data)
- Take a quick look at the Log folder, and the Data folder
*/
