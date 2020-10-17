// Created: 20200925 Enoch Chen
// Updated: 20201017 Enoch Chen
*==============================
// Start of Stata codes
sysuse cancer, clear
keep if drug ==1 | drug == 2
gen id = _n // give each observation an id by the order of the observation
save cancer_drug12, replace

sysuse cancer, clear
keep if drug ==3
gen id = _n // give each observation an id by the order of the observation
save cancer_drug3, replace

** One numeric variable
use cancer_drug12, clear
// Get to know the data
summarize      // Know obs, mean, sd, min, max
summarize age  // One variable only (age)

describe       // Know the variable type and its label
describe  age 

codebook       // Know type of the variable, range, missing, mean, sd, percentiles
codebook  age

list           // List the entire data frame
list      age if age < 50

egen tot_st=total(studytime) // generate the sum of studytime

// Managing datasets
// Split the dataset
keep studytime id
save cancer_st, replace

// Merge datasets
use cancer_st, clear // cancer dataset contains only studytime and id
merge 1:1 id using cancer_drug12.dta

// Append datasets
use cancer_drug12, clear // cancer dataset contains patients using drug 1 and 2
append using cancer_drug3.dta // append patients using drug 3

// Managing variables
// Label
sysuse cancer, clear
label variable drug "1=placebo, 2=mild, 3=strong"
label define drug 1 "placebo" 2 "mild" 3 "strong"
label values drug drug

// Rename, recode, generate, replace
rename died death
recode drug (3=4) // Make variable drug 3 into 4
generate placebo = 1 if drug == 1 
replace placebo = 0 if drug != 1

// End of Stata codes
