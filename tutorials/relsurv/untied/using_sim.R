#' using_sim.R
#'
#' Latest Update: 20200928 Enoch Chen
#' Purpose: compare using tied/untied data while estimating net survival-time
#' Use scenario2_1.dta
#'===============================================================================
#'Start of R file ===============================================================

#' 1 Preparation

#' Clear all
#' Use it if you need to clear all
#' rm(list = ls()) 

#' Load required packages
x<-c(  "haven",       # read.dta()
       "tidyverse",   # dplyr::mutate
       "relsurv")     # transrate(), joinrate(), rs.sruv()


lapply(x, require, character.only = TRUE)

#' Read the data from web
sc <- read_dta( "http://enochytchen.com/tutorials/relsurv/untied/scenario2_1.dta")
str(sc)

#' 
sc2 <- sc %>%
       mutate(sex  = ifelse(sex == 1, "Male", "Female"),      
         dead = as.numeric(dead),
         t    = as.numeric(t),
       ) %>%
       select(id, sex, dead, t, agediag, yeardiag)
str(sc2)
summary(sc2)

#'===============================================================================
#' 2 Make popmort file into ratetable
popmort <- read_dta( "http://enochytchen.com/tutorials/relsurv/untied/lifetab.dta" )
colnames(popmort)[2] <- "year"
colnames(popmort)[3] <- "age"

popmort <- popmort %>% 
  mutate (sex  = as_factor(sex),
          prob = as.numeric(prob),
  )%>%
  select(sex, age, year, prob)

popmort <- popmort %>% spread(year, prob)

#' Split our popmort file by sex (1 = m; 2 = f)
popmort_m <- subset(popmort, sex == 1);
popmort_m <-as.matrix(popmort_m[-c(1:2)])
popmort_f <- subset(popmort, sex == 2);
popmort_f <-as.matrix(popmort_f[-c(1:2)])

popmort_rt<- transrate(popmort_m,popmort_f, yearlim=c(1990,2009), int.length=1)
is.ratetable(popmort_rt)

#===============================================================================
#' 3  Use rs.surv() to estimate non-parametric relative survival by time since diagnosis
#' 3.1 rs.surv(), the follow-up time must be specified in days.

rssurv<-rs.surv(Surv(time  =  t*365.241, 
                     event = dead == 1 | dead == 2 ) ~ 1,
                rmap = list(age = agediag*365.241, year = yeardiag, sex = sex),
                ratetable = popmort_rt,
                data = sc2,
                method = "pohar-perme")

summary(rssurv, time = c(0:10) * 365.241, scale = 365.241)

#'=============================================================================
#'4. Add floor to create ties
sc2 <- sc2 %>%
       mutate(
         tt1 = t,                        # original time in days
         tt2 = floor(t*365.241)/365.241, # Add some ties in days
         tt3 = floor(t*52.177)/52.177,   # weeks
         tt4 = floor(t*12)/12,           # months
         tt5 = floor(t*4)/4,             # quarters
         tt6 = floor(t),                 # years
          )%>%
       select(id, sex, dead, t, agediag, yeardiag, tt1, tt2, tt3, tt4, tt5, tt6)
str(sc2)

sc2$tt2 <- ifelse(sc2$tt2 == 0, 0.5/365.241, sc2$tt2)
sc2$tt3 <- ifelse(sc2$tt3 == 0, 0.5/52.177,  sc2$tt3)
sc2$tt4 <- ifelse(sc2$tt4 == 0, 0.5/12,      sc2$tt4)
sc2$tt5 <- ifelse(sc2$tt5 == 0, 0.5/4,       sc2$tt5)
sc2$tt6 <- ifelse(sc2$tt6 == 0, 0.5,         sc2$tt6)

# Regression models
regmodels <- lapply(1:6, function(i){
  
  #' select ttn
  select_var <- paste0("tt", i)
  
  #' prepare ttn for rs.surv
  time_n <- sc2[, select_var] %>% 
    unlist()
  
  rssurv <- rs.surv(Surv(time  =  time_n *365.241, 
                         event = dead == 1 | dead == 2 ) ~ 1,
                    rmap = list(age = agediag*365.241, year = yeardiag, sex = sex),
                    ratetable = popmort_rt,
                    data = sc2,
                    method = "pohar-perme")
  
  summary(rssurv, time = c(0:10) * 365.241, scale = 365.241)
  
})

regmodels

# End of R file ===============================================================
