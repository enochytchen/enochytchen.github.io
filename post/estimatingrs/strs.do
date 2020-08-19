use  https://enochytchen.com/directory/data/colon.dta if stage==1, clear
stset exit,fail(status==1 2) origin (dx) exit(exit) id(id) scale(365.241) 
strs using  http://enochytchen.com/directory/data/popmort.dta, br(0(1)10) mergeby(_year sex _age) by(sex) 
strs using  http://enochytchen.com/directory/data/popmort.dta, br(0(1)10) mergeby(_year sex _age) by(sex) pohar
