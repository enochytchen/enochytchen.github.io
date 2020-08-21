#' create_ratetable.R
#' 
#' Authors: Enoch Chen, Paul Dickman
#' Contact info: enoch.yitung.chen@ki.se 
#' Tutorial: https://enochytchen.com/tutorials/ratetable/
#' Latest Update: 20200817 Enoch Chen
#'
#' Purpose: To model survival in multiple time scales (continuous attained age & time-split calendar year) 
#'          using stpm2, and then based on the model create a ratetable
#'          In this example. we use two dimensions (subsite + stage) in the ratetable.
#'===============================================================================
#' Acknowledgements: we acknowledge the people who contributed to this porject
#'                   - Alexander Ploner's contribution on optimising the codes, including making the syntax more tidy, solving the convergence problem of the models, and transforming the data frame into lists
#'                   - Nurgul Batyrbekova's insight in modeling survival data on multiple time scale
#'                   - Joshua Entrop's teaching on plotting regression model results
#'                   - Quang Thinh Trac's help on writing a loop to run AIC/BIC test
#'===============================================================================
#' MIT licenses
#' Based on <http://opensource.org/licenses/MIT>

#' Copyright (c) <2020>, <Enoch Chen>

#' Permission is hereby granted, free of charge, to any person obtaining
#' a copy of this software and associated documentation files (the
#' "Software"), to deal in the Software without restriction, including
#' without limitation the rights to use, copy, modify, merge, publish,
#' distribute, sublicense, and/or sell copies of the Software, and to
#' permit persons to whom the Software is furnished to do so, subject to
#' the following conditions:

#' The above copyright notice and this permission notice shall be
#' included in all copies or substantial portions of the Software.

#' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#' EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#' MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#' NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
#' LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#' OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
#' WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#'===============================================================================
#' Start of R file ===============================================================

#' 1 Preparation

#' Clear all
#' Use it if you need to clear all
#' rm(list = ls()) 

#' Load required packages
x<-c(  "haven",       # read.dta()
       "tidyverse",   # dplyr::mutate
       "lubridate",   # decimal_date
       "survival",    # Surv(), survSplit()
       "rstpm2",      # stpm2()
       "splines",     # nsx()
       "relsurv",     # transrate(), joinrate(), rs.surv()
       "popEpi",      # as.data.frame(ratetable)
       "ggplot2")     # ggplot()

lapply(x, require, character.only = TRUE)

#' Read the data from web 
colon <- read_dta( "http://enochytchen.com/directory/data/colon.dta")
str(colon)

#' Extract the date of birth,
#' Will take care of derived variables (entry/exit years) later
colon2 <- colon %>%
  mutate(sex     = as_factor(sex),       ## as_factor preserves labels
         status  = as.numeric(status),
         subsite = as_factor(subsite),   ## as_factor preserves labels
         stage   = as_factor(stage),       ## as_factor preserves labels
         strata  = as_factor(paste(subsite, stage, sep = ", ")), # strata consists all the dimensions
         dob     = as.Date(dx) - age*365.241,
  ) %>%
  select(id, sex, status, subsite, stage, strata, dob, dx, exit, age)
str(colon2)
summary(colon2)

#' Vital status (status) is coded as follows
#' 1 [Dead: cancer]
#' 2 [Dead: other]
#' 0 [Alive]
#' 4 [Lost to follow-up]

#'===============================================================================
#' 2 Splitting the time
#' Split calendar time into 2-year intervals;
#' splitting in 1-year intervals leads to convergence problems later if
#' stpm2 does not have enough events within each time interval
colon_split <- survSplit(Surv(decimal_date(dx), decimal_date(exit), status, type = "mstate") ~ .,
                         data = colon2, cut = seq(1975, 1995, by = 2),
                         event = "status", episode = "period"
) %>%
  # changed word "censor" to 0, so to keep it consistent with original definition
  mutate(status = as.numeric(ifelse(as.character(status) == "censor",
                                    "0", as.character(status))) )

#' Inspect: select the first 20 to take a look
head(colon_split, 20)

#' For downstream analysis, we want age as primary time scale;
#' Calculate age at entry and age at exit
#' Also, it would be nice to have the period expressed as actual starting year
#' of the time interval; see ?survSplit for its definition
#' (i.e. 1 = before first interval)
colon_split = mutate(colon_split,
                     age_start = tstart - decimal_date(dob),
                     age_stop  = tstop  - decimal_date(dob),
                     period    = 1975 + (period - 2)*2) # *2 for 2-year intervals

#' Save the data for running AIC/BIC test
#' saveRDS(colon_split, "./Data/split_colon.rds")

#'===============================================================================
#' 3.1 Flexible parametric model 
#' Primary time scale: attained age is the underlying time scale
#'                     (modelled using a natural spline)
#' Secondary time scale: attained year is modelled using a
#'                       natural spline after time splitting

fpm <- stpm2(Surv(time = age_start, time2 = age_stop, event = status==2) ~
                  sex + nsx(period, df=2) + subsite+ stage, data = colon_split,
             tvc = list(sex=3, period=2), df = 3)
summary(fpm)

#' A nice hazard plot
#' Age-specific hazard by sex, subsite=2, stage =1, 1980
newdata = data.frame(sex = levels(colon2$sex), 
                     subsite = "Descending and sigmoid", 
                     stage = "Localised",
                     period = 1980)
newdata
plot(fpm, newdata = newdata[2,,drop=FALSE],
     type = "hazard", ci = FALSE,
     xlim = c(40,110), xlab = "Attained age (years)",
     ylim = c(1E-6,100), ylab  = "Hazard (log-scale)",
     log = "y", main = "Age-specific log-hazard for subsite=2, stage =1, period 1980, by sex")
lines(fpm, newdata = newdata[1,,drop=FALSE],
      type = "hazard", lty = 2, col = "red")
legend("topleft", legend=c("Female", "Male"),
       col=c("black", "red"), lty=1:2)

#===============================================================================
#' 4.1 Create a table of predicted rates and probabilities
#' First create an empty data frame with the required structure
#' Must use the same variable names as the fpm model has
#' Age range 0-110 extrapolates brutally, and leads to a warning
#'       about negative hazards; this goes away when we stick to starting
#'       age 40...
colon_new <- expand.grid(sex = levels(colon2$sex), 
                         subsite = levels(colon2$subsite),
                         stage = levels(colon2$stage),
                         age_stop = 1:110, 
                         period = 1975:1995)


#' 4.2 Populate the empty data frame with predicted hazards (based on the fitted model)
colon_new$hazard <- predict(fpm, newdata = colon_new, type = "hazard")

colon_new <- colon_new %>%
  mutate(prob  = exp(-hazard),
         age   = age_stop,   
  ) %>%
  select(sex, subsite, stage, age, period, prob, hazard)
str(colon_new)

#' Take look at the first 20 rows
head(colon_new, 20)

#===============================================================================
#' 5 Create ratetable
#' 5.1 Subset the newcolon data
#' transrate() requires using survival probability (prob)
#'  p > 1 for negative hazards...
#'  Make a new strata consisting all the dimensions
popmort_new <- colon_new %>%
  mutate(strata = paste(subsite, stage, sep = ", "),
  )%>%
  select(age, sex, period, strata, prob)

#' transrate() wants two matrices, both age x year, one for men, one for
#' women;  using split() repeatedly to make it work
#' split() converted a data.fram into lists based on the specified variable

#' First, split our popmort file by strata
pm_split = split(popmort_new[, -4], popmort_new$strata)
str(pm_split)

#' Then we split the list again by sex
pm_split = lapply(pm_split, function(x) split(x[, -2], x$sex))
str(pm_split)

#' Using spread + as.matrix to generate the input matrices that transrate()
#' needs
spread_df = function(x)
{
  ret =  spread(x, period, prob)
  rownames(ret) = ret$age - 1 # Drop the age variable
  ret = ret[, -1]
  as.matrix( ret )
}
pm_split = lapply(pm_split, function(x) lapply(x, spread_df ))
str(pm_split)

#' Now do the transrate() for each strar=ta; we get a list of
#' ratetable-objects
pm_split = lapply(pm_split, function(x) transrate(x$Male, x$Female, yearlim = c(1975, 1995)))
str(pm_split)

#' We can directly use the jointable-command on this list
myratetable <- joinrate(pm_split, dim.name="strata")
str(myratetable)

#' Check whether is a readable ratetable for rs.surv()
is.ratetable(myratetable) 


#===============================================================================
#' 6  Use rs.surv() to estimate non-parametric relative survival by time since diagnosis
#' 6.1 rs.surv(), the follow-up time must be specified in days.
rssurv<-rs.surv(Surv(time  =  (decimal_date(exit)-  decimal_date(dx)) * 365.241,
                     event = status == 2) ~
                  sex  + subsite+ stage,                     
                rmap = list(age = age*365.241, year = dx, strata = strata),
                ratetable = myratetable,
                data = colon2,
                method = "ederer2")

rssurv.sum <- summary(rssurv, time = c(0:10) * 365.241, scale = 365.241)
rs.table   <- as.data.frame(rssurv.sum[c("strata", "time", "n.risk", "n.event", "surv", "std.err", "lower", "upper")])

#' Cut the value from the strata
#' We split the strata to get variables
rs.table_temp <- data.frame(do.call(rbind, 
                                    strsplit(as.character(strsplit(as.character(rs.table$strata), ",")),"=", fixed=TRUE)
))

rs.table_temp <- rs.table_temp %>%
  mutate(sex        = substr(X2,1,1),
         subsite2   = substr(X3,1,1),
         subsite3   = substr(X4,1,1), 
         subsite4   = substr(X5,1,1),
         Localised  = substr(X6,1,1),
         Regional   = substr(X7,1,1),
         Distant    = substr(X8,1,1),
  )%>% 
  select(sex, subsite2, subsite3, subsite4, Localised, Regional, Distant)

rs.table <- cbind(rs.table[ ,-c(1, 9)], rs.table_temp)

#' Take a look
#' surv here is cumulative relative survival 
head(rs.table, 20)

# Make plotdata for subsite=2 and Localised=1
rssurv.plotdata <- subset( rs.table, (subsite2 == 1 & Localised ==1) )
summary(rssurv.plotdata)

#' 7 Plot RS by time since diagnosis
#' if sex is a proper factor, no need for setting the scale manually
#' fill=sex means that the confidence regions are also colored
#' alpha=0.25 fixes transparency at 25%, i.e. less heavy
ggplot(rssurv.plotdata, aes(x = time, y = surv, color = sex, fill = sex )) +
  geom_smooth(alpha = 0.25) +   
  scale_x_continuous(breaks = seq(0, 10, by = 2), limits = c(0,10))+
  scale_y_continuous(breaks = seq(0, 1.2, by = 0.2), limits = c(0,1.2))+
  labs(title="Cumulative relative survival for subsite=2 & stage = 1",
       x="Time since diagnosis (years)", 
       y="Cumulative relative survival") +
  theme(plot.title = element_text(size = 10))

#' End of R file ===============================================================


