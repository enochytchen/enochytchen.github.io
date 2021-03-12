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
	   
// Most frequently used: twoway
// Type -help twoway- to see the functions of twoway
twoway (line /*plotype*/ le_male/*y-axis*/ year/*x-axis*/, ///
			lcolor(blue)/*line color*/ lpattern(shortdash) /*line pattern*/) /// 
	   (line le_female year, lcolor(red) lpattern(solid)), ///
			///
	   legend (order(1 "LE of male" 2 "LE of female")) ///
			/// legend order by the same order above. 
			/// Make sure you get all the space, quotation marks right!	
			///
	   xline(1920, lpattern(dash) lwidth(thin) lcolor(black))        ///
			/// Add vertical line x=1920
	   xscale(range(1900(10)2020)) ///
		    /// xscale's main function is to change the scale of the axis
	   xlabel(1900 1920(10)2000) ///
			/// xlabel would label the appointed values
	   xtitle("Time (year)") ///
			/// Put name + unit
	        ///
	   yline(50,lpattern(dash) lwidth(thin) lcolor(red)) ///
		    /// Add horizontal line y = 50
	   yscale(range(0(10)100)) ///
			/// Set the scale from 0 to 100
	   ylabel(0(10)100, nogrid) ///	
		    /// You don't need to put range in label()
			/// Take away grid line by adding -nogrid-
	   ytitle("Life expectancy at birth (year)") ////
			/// Put name + unit
			///
	   name("usale", replace) ///
			/// Give the name for furtheruse
	   title("Life expectancy at birth by year, USA") ///
		    /// Main title
	   saving( ,replace)
			/// Save as gph, but for other file types: -graph export -
	   
	   
	   
	   
	   
	   
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
