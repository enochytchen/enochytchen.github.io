#' reproduce_strs.R

#' Latest Update: 20200818 Enoch Chen
#' Purpose: Reproduce strs results in R, using colon.dta and popmort.dta
#' 
#'===============================================================================
#' 1 Preparation

#' Load required packages
x<-c(  "haven",       # read.dta()
       "tidyverse",   # dplyr::mutate
       "lubridate",   # decimal_date
       "survival",    # Surv(), survSplit()
       "relsurv")     # transrate(), joinrate(), rs.sruv()

lapply(x, require, character.only = TRUE)

#' Read the data from web
colon <- read_dta( "https://enochytchen.com/directory/data/colon.dta")
str(colon)

#' Extract the date of birth,
colon_temp <- colon %>%
  mutate(status     = as.numeric(status),
         subsite    = as_factor(subsite),   ## as_factor preserves labels
         sex        = as_factor(sex),       ## as_factor preserves labels
         dob        = as.Date(dx) - age*365.241
  ) %>%
  select(id, sex, status, subsite, stage, dob, dx, exit, age)
str(colon_temp)
summary(colon_temp)

#' Only keep stage=1
colon1 <- colon_temp[colon_temp$stage==1,]

#'===============================================================================
#' 2 Make ratetable
#' Read the popmort file from pauldickman.com
popmort <- read_dta( "https://enochytchen.com/directory/data/popmort.dta")[c(1:4)]

#'Rename the columns, since R cannot read underscore
colnames(popmort)[1:4] <- c("sex", "year", "age", "prob")

#' Make matrix of survival prob 
popmort_m  <- popmort[popmort$sex==1, ]
popmort_m2 <- popmort_m %>% spread("year", prob)
popmort_m2 <- as.matrix(popmort_m2[-c(1,2)])

popmort_f  <- popmort[popmort$sex==2, ]
popmort_f2 <- popmort_f %>% spread("year", prob)
popmort_f2 <- as.matrix(popmort_f2[-c(1,2)])

#' Use transrate to make a ratetable
#' matrix containing the yearly (conditional) probabilities of one year survival
popmort_new <- transrate(popmort_m2, popmort_f2, yearlim=c(1951, 2000), int.length=1)

#' Check whether it is ratetable
is.ratetable(popmort_new)

#'===============================================================================
#' 3A Ederer 2
#' Relative survival
rssurv_e2 <- rs.surv(Surv(time  =  (decimal_date(exit)-  decimal_date(dx)) * 365.241, # time in days
                          event = status== 1 | status== 2 ) ~ sex,
                     rmap = list(age = age * 365.241, year = dx),
                     data = colon1,
                     ratetable = popmort_new,
                     method = "ederer2")

rs.table_e2 <- as.data.frame(summary(rssurv_e2, time = c(0:10) * 365.241, scale = 365.241)
                             [c("strata", "time", "n.risk", "n.event", "surv", "std.err", "lower", "upper")])

#' Rename the columns
strs_e2 <- rs.table_e2 %>%
  mutate(cr_e2 = surv, 
         lo_cr_e2 = round(lower, digits = 4),
         hi_cr_e2 = round(upper, digits = 4),
         sex = ifelse(strata == "sexFemale=0", "Male", "Female"),
         
  )%>%
  select(sex, time, n.risk, n.event, cr_e2, lo_cr_e2, hi_cr_e2)

#'===============================================================================
#' 3B pohar-perme
#' Relative survival
rssurv_pohar <- rs.surv(Surv(time  =  (decimal_date(exit) - decimal_date(dx)) * 365.241, # time in days
                             event = status== 1 | status== 2 ) ~ sex,
                        rmap = list(age = age * 365.241, year = dx),
                        data = colon1,
                        ratetable = popmort_new,
                        method = "pohar-perme")

rs.table_pohar <- as.data.frame(summary(rssurv_pohar, time = c(0:10) * 365.241, scale = 365.241)
                                [c("strata", "time", "n.risk", "n.event", "surv", "std.err", "lower", "upper")])

#' Rename the columns
strs_pohar <- rs.table_pohar %>%
  mutate(cr_pp = surv, 
         lo_pp = round(lower, digits = 4),
         hi_pp = round(upper, digits = 4),
         sex = ifelse(strata == "sexFemale=0", "Male", "Female"),
         r   =   round( cr_pp/lag(cr_pp), digits = 4),
  )%>%
  select(sex, time, n.risk, n.event, cr_pp, lo_pp, hi_pp)

# Ende of R file ===============================================================


