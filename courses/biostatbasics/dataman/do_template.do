local todaydate: di %tdCYND date(c(current_date),"DMY")
capture log close
log using "your log folder route\do file name_`todaydate'.log", replace

/*=====================================================================
Filename: make_analysis_data.do
Study:    Colon cancer patient survival, Sweden, 2010-2015

Created:  20201015 Name
Updated:  20201017 Name 

Purpose:  Conduct data clearance for the project
Note:     Well, this is just an example.
=====================================================================*/ 
// Start of Stata code






// End of Stata code

log close


