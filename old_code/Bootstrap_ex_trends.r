

library("latticeExtra")
library("Hmisc")
library("data.table")
library("foreign")

#setwd("X:/Palloni_Datasets/BOOKLA-DATA-2013/Latin America Mortality Database/Life Tables 85+")
setwd("C:/Users/Hiram/Box Sync/Beltran-Sanchez/Uncertainty in LAMBdA estimates")
#dat<-data.frame(read.dta("E0_LA1850-2010_wei_long.dta",convert.factors=F))
#tmp<-read.dta("E0_LA1850-2010_wei_long.dta",convert.factors=T)
#dat<-data.frame(dat,author.lab=tmp$author,ctry.lab=tmp$ctry,sex.lab=tmp$sex)
#rm(tmp)
#datos<-dat
#save(datos,file="Ex_0_5_60_and_prob.RData")
load("Ex_0_5_60_and_prob.RData")

bst<-function(sample.size,datos){
  out<-NULL
  yrs<-sort(unique(datos$myear))
  for(yr in 1:length(yrs)){#yr=1;sample.size=500
   cat("Country:",datos$ctry[1],", Year:",yrs[yr],"\n")  
   foo<-subset(datos,myear==yrs[yr])  
   if(dim(foo)[1]>1){  
   tmp<-sample(foo$Ex,sample.size,replace=T,prob=foo$wei)
   ot<-c(median(tmp),quantile(tmp,probs=c(0.25,0.75)),yrs[yr])        
   }
   if(dim(foo)[1]==1) {ot<-c(foo$Ex,NA,NA,yrs[yr])}  
   out<-rbind(out,ot);rownames(out)<-NULL 
   }  
   data.frame(ctry=datos$ctry[1],myear=out[,4],Ex=out[,1],Q25=out[,2],Q75=out[,3])    
}

set.seed(87654321)
ages<-c(0,5,60)
sample<-1000
ctry.list<-unique(dat$ctry)
boots.ex<-NULL
for(ct in 1:length(ctry.list)){#ct=1
  out<-data.frame(bst(sample.size=sample,dat=subset(dat,ctry==ctry.list[ct] & sex==1 & age==ages[1])),sex=1,age=ages[1])
  out<-rbind(out,data.frame(bst(sample.size=sample,dat=subset(dat,ctry==ctry.list[ct] & sex==2 & age==ages[1])),sex=2,age=ages[1]))  
  out<-rbind(out,data.frame(bst(sample.size=sample,dat=subset(dat,ctry==ctry.list[ct] & sex==1 & age==ages[2])),sex=1,age=ages[2]))    
  out<-rbind(out,data.frame(bst(sample.size=sample,dat=subset(dat,ctry==ctry.list[ct] & sex==2 & age==ages[2])),sex=2,age=ages[2]))      
  out<-rbind(out,data.frame(bst(sample.size=sample,dat=subset(dat,ctry==ctry.list[ct] & sex==1 & age==ages[3])),sex=1,age=ages[3]))
  out<-rbind(out,data.frame(bst(sample.size=sample,dat=subset(dat,ctry==ctry.list[ct] & sex==2 & age==ages[3])),sex=2,age=ages[3]))
  boots.ex<-rbind(boots.ex,out)  
}
boots.ex$ctry.lab<-boots.ex$ctry
boots.ex$ctry.lab<-factor(boots.ex$ctry.lab,levels=sort(unique(dat$ctry)),labels=levels(dat$ctry.lab))
boots.ex$sex<-factor(boots.ex$sex,levels=1:2,labels=c("Male","Female"))

theme.novpadding <-list(layout.heights =list(top.padding=0, main.key.padding=0, key.axis.padding=0, axis.xlab.padding=0,
                                             xlab.key.padding=0, key.sub.padding=0, bottom.padding=0.2), 
                        layout.widths = list(left.padding=0.1, key.ylab.padding=0, ylab.axis.padding=0, 
                                             axis.key.padding=0,  right.padding=0))

#setwd("X:/Hiram/Book Mortality in LAC")
#pdf("Brazil_Boostrap_e0_e5_e60_by_sex.pdf",width=11.5,height=6,pointsize=7)
xYplot(Cbind(Ex,Q25,Q75)~myear | paste("Age ",age,sep=''),data=subset(boots.ex,ctry.lab=="Brazil"),
       groups=sex,ylim=c(0,80),
       col=c("blue","red"),lty=1,lwd=2,par.strip.text=list(cex=1.2,lines=1.3,font=2),pch=c(20),
       par.settings=theme.novpadding,between=list(x=0.2,y=0.2),#key=key.leg,
       xlab=list("Year",font=2),ylab=list("Life expectancy with inter-quartile range",font=2),
       scales=list(alternating=1,y=list(alternating=3,font=2,cex=1),
                  x=list(alternating=3,rot=90,at=seq(1800,2010,20),labels=as.character(seq(1800,2010,20)),font=2,cex=1)),
       panel=function(x,y,...){
         panel.abline(h=seq(10,90,10),col="black",lty=2)  
         panel.abline(v=seq(1840,2010,10),col="black",lty=2)  
         #panel.abline(v=seq(1850,2010,50),col="grey",lty=1)  
         panel.xYplot(x,y,...) 
       })
#dev.off()


#setwd("Z:/Brasil")
#pdf("presentation/Boostrap_e0-e5-e60_by_sex-country.pdf",width=8.5,height=6,pointsize=7)
ylimit<-list(c(18,83),c(30,78),c(0,25))
for(ag in 1:length(ages)){#ag=2
 fig1<-xYplot(Cbind(Ex,Q25,Q75)~myear | ctry.lab,data=subset(boots.ex,sex=="Male" & age==ages[ag]),ylim=ylimit[[ag]],
       col=c("blue"),lty=1,lwd=1,par.strip.text=list(cex=0.9,lines=1.3,font=2),pch=c(20),layout=c(4,5),
       par.settings=theme.novpadding,between=list(x=0.2,y=0.2),#key=key.leg,
       xlab="Periodo",ylab=list(paste("e(",ages[ag],") con rango inter-cuartil",sep=''),font=2),
       scales=list(alternating=1,y=list(alternating=3),x=list(alternating=3)),
       #main=c(paste("Males: e(",ages[ag],") estimate drawing a sample of ",sample," with replacement by year-country",sep='')),
       main=c("Hombres"),
       panel=function(x,y,...){
         panel.abline(h=seq(10,90,10),col="black",lty=3)  
         panel.abline(v=seq(1840,2010,10),col="black",lty=3)  
         panel.abline(v=seq(1850,2010,50),col="grey",lty=1)  
         panel.xYplot(x,y,...) 
       })
 fig2<-xYplot(Cbind(Ex,Q25,Q75)~myear | ctry.lab,data=subset(boots.ex,sex=="Female" & age==ages[ag]),ylim=ylimit[[ag]],
       col=c("blue"),lty=1,lwd=1,par.strip.text=list(cex=0.9,lines=1.3,font=2),pch=c(20),layout=c(4,5),
       par.settings=theme.novpadding,between=list(x=0.2,y=0.2),#key=key.leg,
       xlab="Periodo",ylab=list(paste("e(",ages[ag],") con rango inter-cuartil",sep=''),font=2),
       scales=list(alternating=1,y=list(alternating=3),x=list(alternating=3)),
       #main=c(paste("Females: e(",ages[ag],") estimate drawing a sample of ",sample," with replacement by year-country",sep='')),
       main=c("Mujeres"),
       panel=function(x,y,...){
         panel.abline(h=seq(10,90,10),col="black",lty=3)  
         panel.abline(v=seq(1840,2010,10),col="black",lty=3)  
         panel.abline(v=seq(1850,2010,50),col="grey",lty=1)  
         panel.xYplot(x,y,...) 
       })
 print(fig1)
 print(fig2)  
}  
#dev.off()


