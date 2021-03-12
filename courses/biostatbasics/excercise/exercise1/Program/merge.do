local todaydate: di %tdCYND date(c(current_date),"DMY")
capture log close
// Your Log folder route/ do-file name_todaydate
log using "/Users/yitche/My_Website/content/courses/biostatbasics/excercise/exercise1/Log/merge_`todaydate'.log", replace

/*==============================================================================
FILENAME: merge.do


PURPOSE: Demonstrate merge.do to the students
	
AUTHOR: Enoch Chen

CREATED: 20210201 Enoch Chen	
UPDATED: 20210201 Enoch Chen		

INPUT DATA: 		
OUTPUT:

STATA VERSION: 16.1
==============================================================================*/

clear all

// See where is my working directory
pwd 

// Redirect my working directory
cd "/Users/yitche/My_Website/content/courses/biostatbasics/excercise/exercise1/Data"

// Dataset A
input id  a
	   1 50
	   1 49
	   2 38
	   4 78
	   5 55
end

sort id
save A, replace

// Dataset B
clear all
input id   b
	   1 0.5
       2 0.2
	   3 0.4
end

sort id
save B, replace

// 
clear all
use A, clear


// What happens if id is not unique?
merge 1:1 id using B

// Then you have to use multiple to 1
merge m:1 id using B
list

// What if you wrongly consider 1 to multiple?
// That's alright. Stata will tell you it's an error.
clear all
use A, clear

merge 1:m id using B

// What if you wrongly consider multiple to multiple?
// That's alright. 1 is a kind of type of "mu;ltiple". 
// Then you're basically still using 1:m in this case.
clear all
use A, clear

merge m:m id using B

// End of Stata Code
log close
exit
