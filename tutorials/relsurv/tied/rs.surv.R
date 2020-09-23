#' rs.surv.R
#'
#' Latest Update: 20200923 Enoch Chen
#' Purpose: compare using tied/untied data while estimating net survival
#'==============================================================================
#' Start of R file =============================================================
#' 1 Preparation

#' Clear all
#' Use it if you need to clear all
#' rm(list = ls()) 

#' Load required packages
x<-c(  "haven",       # read.dta()
       "tidyverse",   # dplyr::mutate
       "relsurv")     # transrate(), joinrate(), rs.surv()

lapply(x, require, character.only = TRUE)

#' Read the data from web
colon <- read_dta("http://enochytchen.com/directory/data/colon.dta")
str(colon)

#' 
colon2 <- colon %>%
          mutate(sex     = as_factor(sex),      
                 status  = as.numeric(status),
                 stime   = as.numeric(exit-dx),  # survival time in days
                 )%>%
          select(id, sex, status, dx, age, stime)

str(colon2)
summary(colon2)

#'===============================================================================
#' 2 Make popmort file into ratetable for further use in rs.surv()
popmort <- read_dta("http://enochytchen.com/directory/data/popmort.dta")
colnames(popmort)[2] <- "year"
colnames(popmort)[3] <- "age"

popmort <- popmort %>% 
           mutate (sex  = as_factor(sex),
                   prob = as.numeric(prob),
                  )%>%
           select(sex, age, year, prob)

#' Make the dataset wider instead of longer
popmort <- popmort %>% spread(year, prob)

#' Split the popmort file by sex (1 = m; 2 = f)
popmort_m <- subset(popmort, sex == 1);
popmort_m <-as.matrix(popmort_m[-c(1:2)])
popmort_f <- subset(popmort, sex == 2);
popmort_f <-as.matrix(popmort_f[-c(1:2)])

popmort_rt<- transrate(popmort_m,popmort_f, yearlim=c(1951,2000), int.length=1)

#' Examine whether it is ratetable
is.ratetable(popmort_rt)

#===============================================================================
#' 3  Use rs.surv() to estimate non-parametric relative survival by time since diagnosis
#' 3.1 rs.surv(), the follow-up time must be specified in days.
#' Vital status (status) is coded as follows
#' 1 [Dead: cancer]
#' 2 [Dead: other]
#' 0 [Alive]
#' 4 [Lost to follow-up]

rssurv <- rs.surv(Surv(time  =  stime, 
                     event = status == 1 | status == 2 ) ~ 1,
                rmap = list(age = age*365.241, year = dx),
                ratetable = popmort_rt,
                data = colon2,
                method = "pohar-perme")

summary(rssurv, time = c(0:10) * 365.241, scale = 365.241)
#' time survival  
#'    1    0.676  
#'    5    0.473  
#'   10    0.433  
#'=============================================================================
#'4.Break ties by adding a small random variance into surv_mm
colon2$stime2 <- colon2$stime + rnorm(nrow(colon2), mean = 0, sd = 0.01)

rssurv2 <- rs.surv(Surv(time  =  stime2 ,
                        event = status == 1 | status == 2 ) ~ 1,
                   rmap = list(age = age*365.241, year = dx),
                   ratetable = popmort_rt,
                   data = colon2,
                   method = "pohar-perme")

summary(rssurv2, time = c(0:10) * 365.241, scale = 365.241)

#' time survival  
#'    1    0.676  
#'    5    0.472  
#'   10    0.431  
#' End of R file ===============================================================


