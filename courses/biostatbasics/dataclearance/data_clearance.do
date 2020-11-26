// Created: 20200925 Enoch Chen
// Updated: 20201109 Enoch Chen
*==============================
// Start of Stata codes
// Check where is the working directory now
cd 
pwd

// Change working directory
cd "" //put the route in the ""

// Import and save dataset
// This part is ignored. Please just import the type of the file you need.

// Here comes the example dataset from the Stata default system
sysuse cancer, clear
gen id = _n 
save cancer, replace

// Split the dataset
sysuse cancer, clear
keep if drug ==1 | drug == 2
gen id = _n // give each observation an id by the order of the observation
save cancer_drug12, replace

sysuse cancer, clear
keep if drug ==3
gen id = _n // give each observation an id by the order of the observation
save cancer_drug3, replace

// Merge datasets by id
sysuse cancer, clear
gen id = _n 
keep id
merge 1:1 id using cancer 

// Append datasets
use cancer_drug12, clear // cancer dataset contains patients using drug 1 and 2
append using cancer_drug3.dta // append patients using drug 3

// Get to know the data
sysuse cancer, clear
keep if drug ==1 | drug == 2

summarize      // Know obs, mean, sd, min, max
summarize age  // One variable only (age)

describe       // Know the variable type and its label
describe  age 

codebook       // Know type of the variable, range, missing, mean, sd, percentiles
codebook  age

list           // List the entire data frame
list      age if age < 50

egen tot_st=total(studytime) // generate the sum of studytime

// Manage variables
// Drop/Keep 
sysuse cancer, clear
drop if drug ==1 | drug == 2

sysuse cancer, clear
keep if drug ==1 | drug == 2 // So drug == 3 will be dropped

// Label
sysuse cancer, clear

// Label a dataset
label data "cancerdata" 
// Label variable in the "Variables" window
label variable drug "1=placebo, 2=mild, 3=strong"
// Label define claims the value label
label define drug_label 1 "placebo" 2 "mild" 3 "strong"
// Label value then assigns the label to the variables
label values drug drug_label

// Rename, recode, generate, replace
rename died death
recode drug (3=4) // Make variable drug 3 into 4
generate placebo = 1 if drug == 1 
replace placebo = 0 if drug != 1

// Sort, by, if, in
sort death
by death: summarize
bysort death: summarize // by death, sort: summarize
list age if death == 1

gen id = _n 
list id in 1/10

// End of Stata codes
