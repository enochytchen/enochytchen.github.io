// Created: 20200925 Enoch Chen
// Updated: 20201110 Enoch Chen
*==============================

// Start of Stata codes
sysuse cancer, clear
keep if drug ==1 | drug == 2

// give each observation an id by the order of the observation
gen id = _n


** One numeric variable
// Get to know the data
summarize      // Know obs, mean, sd, min, max
summarize age  // One variable only (age)

describe       // Know the variable type and its label
describe  age 

codebook       // Know type of the variable, range, missing, mean, sd, percentiles
codebook  age

list           // List the entire data frame
list      age

egen tot_st=total(studytime) // generate the sum of studytime

// Measures of Central Tendency
// Mean and median
tabstat age // will only give you mean
tabstat age, s(count mean median) // s stands for statistics

// Measures of Dispersion
// Range, IQR, variance, standard deviation
tabstat age, s(count range min max iqr var sd)

// End of Stata codes
