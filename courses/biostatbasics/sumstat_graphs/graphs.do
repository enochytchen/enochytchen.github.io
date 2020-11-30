// Created: 20200925 Enoch Chen
// Updated: 20201120 Enoch Chen
*==============================
// Start of Stata codes
sysuse lifeexp, clear

** Basic grpahs
// Histograms
hist lexp, title("Histogram of Life Expectancy") ///
		   xtitle(Age (years)) width(1) /// By each age
		   graphregion(color(white)) //

// Bar charts
graph bar (count), over(region) ///
		  title("Bar chart of Regions") ///
		  graphregion(color(white)) //

// Scatter plots
twoway scatter lexp gnppc, ///
			   graphregion(color(white)) 

// Box plots
graph box lexp, over (region) ///
	  graphregion(color(white)) 

// Line graphs
sysuse uslifeexp, clear
twoway line le year, title("Life expectancy at birth by year, USA") ///
       graphregion(color(white)) 

** Customisation
// Use -help two way- to obtain more insight
sysuse uslifeexp, clear

// Using life graphs as an example
// Overall LE over years
twoway line le year

// LE stratified by sex
twoway (line le_male year) ///
	   (line le_female year, lpattern(dash))
	   
// LE stratified by sex
// More customisation 
twoway (line le_male year,    lcolor(blue) lpattern(shortdash)) /// Add line color blue
	   (line le_female year,  lcolor(red) lpattern(dot)), /// Add line color red
	   legend (order(1 "LE of male" 2 "LE of female")) ///
	   xline(1918,lpattern(dash) lwidth(thin) lcolor(black)) /// Add vertical line x=1918
	   xlabel(1900 1918 1990) /// Change the labels
	   name(overll,replace) ///
	   subtitle("Overall") xtitle("") // I don't want title
	   
twoway (line le_wmale year,    lcolor(blue)) ///
	   (line le_wfemale year,  lcolor(red)), ///
	   legend (order(1 "LE of white male" 2 "LE of white  female")) ///
	   xline(1918,lpattern(dash) lwidth(thin) lcolor(black)) /// Add vertical line x=1918
	   xlabel(1900 1918 1990) /// Change the labels
	   name(white, replace) ///
	   subtitle("White") xtitle("") // I don't want title
	   
// Put two graphs together
grc1leg2 overll white, /// 
	col(1) row(2) imargin(medsmall) iscale(1) ///
	l1title(Life expectancy) b2title(Calendar year) ///
	title(Life expectancy at birth by sex and year) ///
	legendfrom(overll)  position(6) ring(3) ///
	name(comparison, replace)

** Export graph
graph export "location" /// assign the location
	         , as(pdf) name("")

// End of Stata codes
