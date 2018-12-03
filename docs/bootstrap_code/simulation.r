library("latticeExtra")
require("foreign")
require("data.table")
require("boot")

#setwd("C:/Users/Hiram/Box Sync/Beltran-Sanchez/Uncertainty in LAMBdA estimates")
setwd("//Client/C$/Users/Hiram/Box Sync/Beltran-Sanchez/Uncertainty in LAMBdA estimates")
load("LA_uncertainty_all.RData"))

datos<-all.data
source("function_decomp.r")

#/\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\.
#
# Estimating Model uncertainty AND Parameter uncertainty via bootstrapping Delta K times (K=100) in each of the 1000 samples created above
# Thus, the bootstrap is done in each sample N from above, leading to N*K bootstrap samples (1000*100=10,000)
#
#\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.
samples<-1:1000
time1<-Sys.time()
rep<-1:100
Delta1<-NULL
pars1<-NULL
for(sample in 1:length(samples)) {#sample=2
 print(paste("sample",sample,sep=": "))	
 foo<-data.frame(N.samples[sample],gdp.pc=datos$gdp.pc,year=datos$year);colnames(foo)<-c("yvar","gdp.pc","year")
 out<-tapply(rep,rep,FUN=function(x){
	 #foo<-data.frame(e0=N.samples[1],gdp.pc=datos$gdp.pc,year=datos$year)
   foo$index<-1:dim(foo)[1]
   tmp2<-foo[sample(foo$index,replace=T),]
   DeltaK.fn(tmp2)})
 out2<-data.frame(matrix(unlist(out),ncol=length(out$`1`), byrow=TRUE))
 tmp<-data.frame(sample=sample,t(out2[1]));colnames(tmp)<-c("sample",paste("boot",1:dim(out2)[1],sep=""))	
 Delta1<-rbind(Delta1,tmp)
 
 coff<-t(out2[2:dim(out2)[2]])#;nms<-names(out$`1`);rownames(coff)<-nms[-1]	
 cof<-data.frame(sample=sample,coff);colnames(cof)<-c("sample",paste("boot",1:dim(coff)[2],sep=""))	
 cof$pars<-factor(1:length(names(out$`1`)[-1]),levels=1:length(names(out$`1`)[-1]),labels=names(out$`1`)[-1])
 cof<-cof[c("sample","pars",paste("boot",1:dim(out2)[1],sep=""))]	
 pars1<-rbind(pars1,cof)
}
Sys.time()-time1

save(Delta1,file="Delta1.RData")
save(pars1,file="Parameters1.RData")
