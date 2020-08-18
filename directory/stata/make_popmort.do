//enochytchen.com
/****************************************************************************
The codes available at:
The tutorial available at:
The video instruction available at: 

Purpose: Make population mortality data from life table data 
Note: 

Author: Enoch Yi-Tung Chen 
Created data: 20200421 by Enoch
Updated:
****************************************************************************/

**************************
//---Data Preparation---//
**************************
// Download the data from mortality.org
// The example life table data of Sweden is prepared at enochytchen.com as well
infile _year _age female male total using "death_rates_Sweden_2018_from_mortality_org.txt" ///
if (_year > 1949 & _age <111 ), clear
drop total
rename male rate1 
rename female rate2
reshape long rate, i(_year _age)
rename _j sex
gen prob=exp(-rate)

label data "Swedish death rates from http://www.mortality.org/"
label variable rate "Death rate"
label variable prob "Survival probability"
label variable _year "Year of death"
label variable _age "Age"
label variable sex "Sex"

sort _year sex _age 
compress
save popmort2018, replace
/***************************** FILE ENDS HERE**************************/
