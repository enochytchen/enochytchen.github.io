//enochytchen.com
/****************************************************************************
The codes available at: http://enochytchen.com/tutorials/stata/data_prep_extrapolation.do
The tutorial available at: http://enochytchen.com/

Purpose: Make analysis data for extrapolation
Note: The data is from pauldickman.com


Author: Enoch Yi-Tung Chen 
Created data: 20200428 by Enoch
Updated:
****************************************************************************/

**************************
//---Data Preparation---//
**************************

clear all

// This data was downlaoded from Paul Dickman's website
// https://pauldickman.com/survival/colon.dta
// Diagnosis 1975-1985
use https://enochytchen.com/directory/data/colon.dta if yydx>=1975 & yydx<=1985, clear

// Rename variables
rename yydx yeardiag
rename age agediag
gen stime=surv_mm/12
rename status dead

// Smart way to creating age groups
egen agegroup=cut(agediag), at(0 50 60 70 80 200) icodes
label variable agegroup "Age group"
label define agegroup 0 "0-49" 1 "50-59" 2 "60-69" 3 "70-79" 4 "80+" 
label values agegroup agegroup

// Create dummy varaiables for age categories
quietly tab agegroup, gen(agegroup)

save colon1975_1985,replace
