// Created: 20201124 Enoch Chen
// Updated: 20201125 Enoch Chen
*==============================
// Start of Stata codes

// Data preparation
sysuse cancer, clear
keep if drug ==1 | drug == 2
replace drug = 0 if drug == 2
// Generate a new variable just for the sake of demonstrating stratification. 
* There is no sex variable in this dataset, so I generated a random binary variable.
set seed 1234
gen sex = runiform() < 0.5 
//==============================
// Table

// table
// One-way table of frequencies with mean and sd of age
table died, contents(freq mean age sd age)

// tabulate
// One-way table of frequencies
tabulate died

// tab1
// One-way tables of frequencies each variable specified
tab1 died drug

// tabulate 2 by 2
// 2 by 2 table for drug and died with relative frequency by column or row
tabulate died drug, col row

// tabulate 2 by 2 with chi-square test and fisher's exact test
tabulate died drug, col row chi2 exact

// bysort tabulate
// 2 by 2 tables straitified by sex
bysort sex: tab died drug, col row chi2

//==============================
// Risk and Odd
// Using Statistics - Epidemiology and related - Tables for epidemiologists

// Risk ratio
// cs variable_case variable_exposed 
cs died drug

// Odds ratio 
cs died drug, or

// Incidence rate ratio
ir died drug studytime

// End of Stata code
