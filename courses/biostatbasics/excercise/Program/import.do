clear all

cd "/Users/yitche/My_Website/content/courses/biostatbasics/excercise/Data/"

// import data 2002
import excel "/Users/yitche/My_Website/content/courses/biostatbasics/excercise/Data/sphc2002.xls", sheet("Sheet1") firstrow clear

// save data
save sphc2002, replace

// import data 2006
import excel "/Users/yitche/My_Website/content/courses/biostatbasics/excercise/Data/sphc2006.xls", sheet("Sheet1") firstrow clear

// save data
save sphc2006, replace

// import data 2010
import excel "/Users/yitche/My_Website/content/courses/biostatbasics/excercise/Data/sphc2010.xls", sheet("Sheet1") firstrow clear

// save data
save sphc2010, replace
