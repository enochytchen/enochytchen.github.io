//enochytchen.com
/****************************************************************************
The codes available at:
The tutorial available at:
The video instruction available at: 

Purpose: Make population mortality projection file
Note: 
1. Import the raw data dowloaded from 
http://www.statistikdatabasen.scb.se/pxweb/en/ssd/START__BE__BE0401__BE0401F/BefProgDodstal19/
2. Append using empirical popmort~2018
Author: Enoch Yi-Tung Chen
 
Created data: 20200420 by Enoch
Updated:
****************************************************************************/

// Downlaod the data from Statistics Sweden (SCB)
import delimited https://enochytchen.com/directory/data/popmort_projection_2019_2120.csv, varnames(1) delimiter(comma) encoding(utf8) clear

// Relabel sex
gen nsex=1 if sex=="men"
replace nsex=2 if sex=="women"
drop sex
rename nsex sex 
label variable sex "Sex"
label define sex 1 "male" 2 "female" /*Define Sex*/
lab values sex sex

// Get rid of "years" in the variable age
program define extrnum
version 7
syntax varlist(max=1) , gen(str)
local maxlen: type `varlist'
local maxlen=substr("`maxlen'",4,.)
tempvar work
qui gen str1 `work'=""
forvalues i=1/`maxlen' {
 qui replace `work'=`work'+substr(`varlist',`i',1) if real(substr(`varlist',`i',1))<.
}
gen `gen'=real(`work')
end

extrnum age, gen(nage)
drop age
rename nage _age
label variable _age "Age"

// Put column v3(2019)-v104(2120) into one column
gen hhid = _n 
reshape long v, i(hhid) j(pid)

// Rename the variable names
gen _year=pid+2016
rename v rate
gen prob=exp(-rate)
drop hhid pid

order _year _age sex rate prob
sort _year sex _age 
compress

// Append popmort2018 (life tables 1950-2018)
// Only keep age<=105
append using popmort2018, gen(source)
sort _year sex _age
drop source
drop if _age>105

save popmort_projection, replace
/***************************** FILE ENDS HERE**************************/
