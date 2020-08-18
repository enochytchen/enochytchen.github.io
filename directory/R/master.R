# How to make a reference score while selecting a master program
# Created: 20200626 Enoch Chen
# Updated: 20200626 Enoch Chen

################################################################
# 1.1 Clear all
rm(list = ls()) 

# 1.2 Packages
#Install packages if you haven't done it.
install.packages(c("dummies","ggplot2"))

# Require multiple packages at the same time 
x<-c("dummies","ggplot2")
lapply(x, require, character.only = TRUE)

################################################################
# 2.1 Assign parameters
# Finance (tuition fee, living expense)
beta_fin_low<-0.3
beta_fin_middle<-0.1
beta_fin_high<-0

# Quality of education (freedom, peers)
beta_qual_high<-0.3
beta_qual_middle<-0.2
beta_qual_low<-0.1

# Ranking (by university, by subject)
# To you, does the uni ranking matter?
beta_ranking <- 0.2

# City itself (culture, language, safety)
beta_cul <- 0.1
beta_lang <- 0.1
beta_safety <- 0.2

# Job market
beta_job <- 0.2

# Doing a PhD at that uni afterwards
beta_PhD_high <- 0.3
beta_PhD_middle <- 0.2
beta_PhD_low <- 0.1

# Relationship and family
# Do you have any on-going relationship?
# Will long distance work?
beta_long_distance <- -0.3

# My effort (undergrad, GRE, IELTS, TOEFL, Publication, internship)
# If you need less effort to enter, the weight is higher
beta_effort_high <- 0.1
beta_effort_middle <- 0.2
beta_effort_low<- 0.3


################################################################
# 3.1 Create a dataset  
#Fill in the scores for your candidate programs/unis
uni <-   c("Karolinska", "Harvard", "LHSTM", "NTU")
fin <-   c(2,3,2,1)

qual <-  c(2,3,3,2)
rank <-  c(1,1,1,0)
cul <- c(1,0,1,1)
lang <- c(1,1,1,0)
safety <-c(1,0,1,1)
job <- c(1,1,1,0)
phd <- c(3,2,1,1)
long <- c(1,1,1,0)
effort <-c(2,3,2,1)

assessment<-data.frame(uni,fin,qual,rank,cul,lang,safety,job,phd,long,effort)

# 3.2 Make dummy variables for categorical variables
fin_dum<-dummy(assessment$fin,sep="_")
qual_dum<-dummy(assessment$qual,sep="_")
phd_dum<-dummy(assessment$phd,sep="_")
effort_dum<-dummy(assessment$effort,sep="_")

#Put dummy variables into the dataset
new_assessment <-data.frame(uni,fin,fin_dum,qual,qual_dum,rank,cul,lang,safety,job,phd,phd_dum,long,effort,effort_dum)

# 3.3 Make a scale to prepare the score for turning it into percentage
# Sum up all the highest weight in each category
scale<-as.numeric(beta_fin_low+beta_qual_high+beta_ranking+beta_cul+beta_lang+beta_safety+beta_job+beta_PhD_high
                  +beta_effort_low)

################################################################
# 4.1 Calculate the score
attach(new_assessment)
new_assessment$score<- (beta_fin_low*fin_1+beta_fin_middle*fin_2+beta_fin_high*fin_3+
                       beta_qual_high*qual_3+beta_qual_middle*qual_2+
                       beta_ranking*rank+
                       beta_cul*cul+
                       beta_lang*lang+
                       beta_safety*safety+
                       beta_job*job+
                       beta_PhD_high*phd_3+ 
                       beta_PhD_middle*phd_2+
                       beta_PhD_low*phd_1+
                       beta_long_distance*long+
                       beta_effort_high*effort_3+
                       beta_effort_middle*effort_2+
                       beta_effort_low*effort_1)/scale
#Turn into percentage
new_assessment$score_percentage<-new_assessment$score*100

# Draw a bar chart for comparison
barchart<-barplot(new_assessment$score_percentage,names.arg=uni,
        main= "How much do the candidate programs satisfy my requirements?",
        xlab="University",
        ylab="Satisfication score (%)",
        ylim=c(0,100))
text(barchart, new_assessment$score_percentage,new_assessment$score_percentage)