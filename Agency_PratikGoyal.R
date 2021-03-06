rm(list=ls())
setwd("C:/Users/pratik/Desktop/final project/AgencyPerformance/AgentPerformance")
data<-read.csv("agency_final.csv",header = TRUE, sep = ",",na.strings =99999)##Loading the data
summary(data)
str(data)
data1<-data[data$STAT_PROFILE_DATE_YEAR!=2015,]#Removing 2015 year beacasue Unsufficent data
data1<-data1[,-c(2,28,29,32,33)]##Removing a variables tha are not required
#converting data type to num and categorical
x=setdiff(names(data1),c("AGENCY_ID","PROD_ABBR","PROD_LINE","STATE_ABBR","VENDOR_IND","VENDOR"))
y<-setdiff(names(data1),x)
num<-data1[which(names(data1)%in% x)]
cat<-data1[which(names(data1)%in% y)]
cat<- data.frame(apply(cat,2,as.factor))
num<- data.frame(apply(num,2,as.numeric))
data2<-cbind(num,cat)
sum(is.na(data2))## checking na values 

#Storing the data which has to scale for 12 months 
y1<-subset(data2,data2$MONTHS!=12)
y2<-subset(data2,data2$MONTHS==12)
x<-setdiff(names(y1),c("RETENTION_POLY_QTY","POLY_INFORCE_QTY","PREV_POLY_INFORCE_QTY","NB_WRTN_PREM_AMT","WRTN_PREM_AMT","PREV_WRTN_PREM_AMT","PRD_ERND_PREM_AMT","PRD_INCRD_LOSSES_AMT","MONTHS","CL_BOUND_CT_MDS","CL_QUO_CT_MDS","CL_BOUND_CT_SBZ","CL_QUO_CT_SBZ","CL_BOUND_CT_eQT","CL_QUO_CT_eQT","PL_BOUND_CT_ELINKS","PL_QUO_CT_ELINKS","PL_BOUND_CT_PLRANK","PL_QUO_CT_PLRANK","PL_BOUND_CT_eQTte","PL_QUO_CT_eQTte","PL_BOUND_CT_APPLIED","PL_QUO_CT_APPLIED","PL_BOUND_CT_TRANSACTNOW","PL_QUO_CT_TRANSACTNOW"))
y<-setdiff(names(y1),x)
x<-y1[which(names(y1)%in% x)]
y<-y1[which(names(y1)%in% y)]

##Scaling the Data to 12 months
for(i in 1:nrow(y)){
  
  y[i,]=(y[i,]*12)/y$MONTHS[i]
}
scale_varibles<-cbind(y,x)
scaling_variable<-rbind(scale_varibles,y2)
unique(scale_varibles$PL_QUO_CT_TRANSACTNOW)
write.csv(scaling_variable,"scale_varibles(NA).csv")
#storing all the NA variables with the count of NA values
Na_variable<-data.frame(sapply(scaling_variable,function(x)sum(is.na(x))))
Na_variable$Percentage = (Na_variable$sapply.scaling_variable..function.x..sum.is.na.x.../nrow(scaling_variable))*100
names=data.frame(names(scaling_variable))
names2=data.frame(Na_variable$sapply.scaling_variable..function.x..sum.is.na.x...,Na_variable$Percentage)
names1=cbind(names,names2)
names(names1)[1:3] <- c("Variable Name", "Na count", "Percentage Na")
# DROPPING THE VARIABLE WHICH HAS MORE THAN 30% NA valuse
newdata<-subset(names1$`Variable Name`, names1$`Percentage Na`>30)
scale_variblesal<-subset(scaling_variable, select = -c(CL_BOUND_CT_MDS,CL_QUO_CT_MDS,CL_BOUND_CT_SBZ,CL_QUO_CT_SBZ,CL_BOUND_CT_eQT,CL_QUO_CT_eQT,PL_START_YEAR,PL_END_YEAR,CL_START_YEAR,CL_END_YEAR))

#REMOVING NA VALUES AND IMPUTING SOME VALUES
library(DMwR)
scale_varibles2<-centralImputation(scale_variblesal)
sum(is.na(scale_varibles2))
write.csv(scale_varibles,"scale_varibles2.csv")

#### Computation of retention ratio
for (i in 1:nrow(scale_varibles2)){
  if(scale_varibles2$RETENTION_POLY_QTY[i] > scale_varibles2$PREV_POLY_INFORCE_QTY[i]){
    scale_varibles2$RETENTION_POLY_QTY[i] = scale_varibles2$PREV_POLY_INFORCE_QTY[i]
  }
}
write.csv(scale_varibles2,"scale_variblesret.csv")
for (i in 1:nrow(scale_varibles2)){
  if(scale_varibles2$RETENTION_POLY_QTY[i] == 0){
    scale_varibles2$RETENTION_RATIO[i] = 0
  }
  else{
    scale_varibles2$RETENTION_RATIO[i] =scale_varibles2$RETENTION_POLY_QTY[i]/scale_varibles2$PREV_POLY_INFORCE_QTY[i]
  }
}
write.csv(scale_varibles2,"scale_variblesret1.csv")
save.image()

scale_varibles2$LOSS_RATIO_3YR<-NULL
scale_varibles2$LOSS_RATIO<-NULL
#COMPUTING NB_WRTN_PREM_AMT,PRD_INCRD_LOSS,WRTN_PREM_AMT
for(i in 1:nrow(scale_varibles2))
{
  {
    if(scale_varibles2$NB_WRTN_PREM_AMT[i] < 0)
    {
      scale_varibles2$NB_WRTN_PREM_AMT[i]= -1 * scale_varibles2$NB_WRTN_PREM_AMT[i]}
  }
  {
    if(scale_varibles2$WRTN_PREM_AMT[i] < 0)
    {
      scale_varibles2$WRTN_PREM_AMT[i] = -1 * scale_varibles2$WRTN_PREM_AMT[i]}
  }
  {
    if(scale_varibles2$PREV_WRTN_PREM_AMT[i] < 0)
    {
      scale_varibles2$PREV_WRTN_PREM_AMT[i] = -1 * scale_varibles2$PREV_WRTN_PREM_AMT[i]}
  }
  {
    if(scale_varibles2$PRD_ERND_PREM_AMT[i] < 0)
    {
      scale_varibles2$PRD_ERND_PREM_AMT[i] = -1 * scale_varibles2$PRD_ERND_PREM_AMT[i]}
  }
  
  {
    if(scale_varibles2$PRD_INCRD_LOSSES_AMT[i] < 0)
    {
      scale_varibles2$PRD_INCRD_LOSSES_AMT[i] = -1 * scale_varibles2$PRD_INCRD_LOSSES_AMT[i]}
  }
}
#Creating a New vaiable of Concatenation in which we have AGENCY_ID,STATE_ABBR,PROD_ABBR
scale_varibles2$conc<-paste(scale_varibles2$AGENCY_ID,scale_varibles2$STATE_ABBR,scale_varibles2$PROD_ABBR)
scale_varibles2$Net_Loss_Profit<-scale_varibles2$WRTN_PREM_AMT-scale_varibles2$PREV_WRTN_PREM_AMT
write.csv(scale_varibles2,"scale_varibles2.csv")
scale_varibles3<-scale_varibles2[,c(1:19,21:34,20)]
scale_varibles3<-scale_varibles3[order(scale_varibles3[,32],scale_varibles3[,32],decreasing = F),]
library(plyr)
scale_varibles3 = rename(scale_varibles3,c("GROWTH_RATE_3YR"="GROWTH_RATE"))
# DIVIDING INTO TRAIN AND TEST
Train<-scale_varibles3[which(scale_varibles3$STAT_PROFILE_DATE_YEAR<=2011),]
Test<-scale_varibles3[which(scale_varibles3$STAT_PROFILE_DATE_YEAR>2011),]
save.image()

#COMPUTING GROWTH RATE
for (i in 1:nrow(Train)){
  if(Train$PREV_WRTN_PREM_AMT[i] !=0){
    Train$GROWTH_RATE[i]=((Train$Net_Loss_Profit[i])/Train$PREV_WRTN_PREM_AMT[i])*100
  }
  else{
    Train$GROWTH_RATE[i] = NA
  }
}
sum(is.na(Train$GROWTH_RATE))
Train$GROWTH_RATE<-round(Train$GROWTH_RATE,digits = 2)
freq<-data.frame(table(Train$conc))
library(dplyr)
colnames(freq)<-c("conc","Frequency")
Train1<-left_join(Train,freq,by="conc")
Train2<-Train1[Train1$Frequency==7,]
Train3<-na.omit(Train2)
sum(is.na(Train3))
Train4<-Train3[-c(1),]
save.image()
write.csv(Train4,"Final.csv")
names(Train4)
i=seq(from = 1, to = nrow(Train4),by = 6)
j= head(i,6)
par(mfrow=c(2,3))
sample1<-data.frame()
for (k in j){
    sample1<-Train4[k:(k+5),]
    acf(sample1$GROWTH_RATE,lag.max = 30)
}
Train5<-Train4
Train5$Number_of_Relation<-Train4$STAT_PROFILE_DATE_YEAR-Train4$AGENCY_APPOINTMENT_YEAR
Train5$AGENCY_APPOINTMENT_YEAR<-NULL
Final_data<-Train5
Final_data$AGENCY_ID<-NULL
Final_data<-Final_data[which(Final_data$STAT_PROFILE_DATE_YEAR==2011),]
Final_data$Frequency<-NULL
Final_data$MONTHS<-NULL
Final_data$PROD_ABBR<-NULL
Final_data$PROD_LINE<-NULL
Final_data$STATE_ABBR<-NULL
sum(is.infinite(Final_data$GROWTH_RATE))
library(plyr)
Final1<-reshape(Final_data,idvar="conc",timevar = "STAT_PROFILE_DATE_YEAR",direction = "wide")
sum(is.na(Final1))
Final2<-na.omit(Final1)
sum(is.na(Final2))
save.image()
Final2$conc<-as.factor(Final2$conc)
Final2$conc<-NULL
names(Final2)
str(Final2)
library(randomForest)
model<-randomForest(Final2$GROWTH_RATE.2011~.,data = Final2,keep.forest = TRUE,ntree=400,mtry=20)
print(model)
important_vara<-data.frame(randomForest::importance(model))
pred = predict(model, Final2)
library(DMwR)
regr.eval(Final2$GROWTH_RATE.2011, pred)
sse = sum((Final2$GROWTH_RATE.2011 - pred)^2)
sst = sum((Final2$GROWTH_RATE.2011 - mean(Final2$GROWTH_RATE.2011))^2)
R2<-1-(sse/sst)
R2
save.image()
#R-Square is 88.2%
library(h2o)
localh2o <- h2o.init(ip='localhost', port = 54321, max_mem_size = '1g',nthreads = 1)
model.hex <- as.h2o(localh2o, object = Final2, key = "model.hex")
#To extract features using autoencoder method
model = h2o.deeplearning(x = setdiff(colnames(model.hex), "GROWTH_RATE.2011"), 
                         y = "GROWTH_RATE.2011",
                         data = model.hex, 
                         hidden = c(50,50,50),
                         activation = "RectifierWithDropout",
                         input_dropout_ratio = 0.1, 
                         epochs = 100,seed=123,
                         classification = F)

names(model.hex)
features <- as.data.frame.H2OParsedData(h2o.deepfeatures(model.hex [,-20], model = model))
Final_data1<-data.frame(Final2,features)
View(Final_data1)
require(randomForest)
rf_DL <- randomForest(GROWTH_RATE.2011 ~ ., data=Final_data1, keep.forest=TRUE, ntree=30)
print (rf_DL)
# importance of attributes
round(importance(rf_DL), 2)
importanceValues = data.frame(attribute=rownames(round(importance(rf_DL), 2)),MeanDecreaseGini = round(importance(rf_DL), 2))
importanceValues
importanceValues = importanceValues[order(-importanceValues$IncNodePurity),]
importanceValues


# Top 20 Important attributes
Top30ImpAttrs = as.character(importanceValues$attribute[1:30])
Top30ImpAttrs
#Final_Data2<-Top30ImpAttrs[which(names(Top30ImpAttrs)%in% Final_data)]

#Final_Data2<-subset(Final_data,select = c("Net_Loss_Profit.2011","PREV_WRTN_PREM_AMT.2011","WRTN_PREM_AMT.2011","DF.C1","DF.C2","DF.C6","DF.C4","PRD_ERND_PREM_AMT.2011","DF.C3","Number_of_Relation.2011","PREV_POLY_INFORCE_QTY.2011","DF.C5" ,"MIN_AGE.2011","POLY_INFORCE_QTY.2011","ACTIVE_PRODUCERS.2011","MAX_AGE.2011","VENDOR.2011","NB_WRTN_PREM_AMT.2011","PL_QUO_CT_eQTte.2011","PRD_INCRD_LOSSES_AMT.2011","GROWTH_RATE.2011"))
Final_Data2 = subset(Final_data1,select = c(Top30ImpAttrs,"GROWTH_RATE.2011"))
rf_DL1 <- randomForest(GROWTH_RATE.2011 ~ ., data=Final_Data2, keep.forest=TRUE, ntree=400)
print(rf_DL1)
pred = predict(rf_DL1, Final_Data2)
library(DMwR)
regr.eval(Final_Data2$GROWTH_RATE.2011, pred)
sse = sum((Final_Data2$GROWTH_RATE.2011 - pred)^2)
sst = sum((Final_Data2$GROWTH_RATE.2011 - mean(Final_Data2$GROWTH_RATE.2011))^2)
R21<-1-sse/sst
R21
#R2 value is 90.4%
save.image()
