
#install.packages("nlrwr")
#install.packages("minpack.lm")
#install.packages("leaps")
#install.packages("mgcv")

library("minpack.lm")
require("foreign")
require("data.table")
require("MASS")


#/\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\.
#
# Fitting a logistic function similar to that of Preston (1976)  a/(1+exp(B+exp(lnC*GDP))
# output: alpha, beta & C [model: alpha/(1+exp(beta + exp(ln(C)*dgp))) ], BIC and AIC
#
#\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.
logfnS<-function(gdp.pc,alpha,beta,C){
  alpha / (1 + exp( beta + exp(log(C) * gdp.pc )))	
 }

 # Logistic fitting
log.fnS<-function(data){
  datos<-na.omit(data)
 # estimating starting values for the parameters. Assume alpha=1, then estimate logit(yvar)=beta+gamma^GDP
   yvar <- datos$yvar/(1.05 * max(datos$yvar)) # scale to within unit height
   datos$z <- log(yvar/(1 - yvar))             # logit transformation
	 pars<- nls(z ~ beta+exp(log(C)*gdp.pc),
      data=datos,
      start=list(beta=1,C=1))
   nlsFormula <- "yvar ~ logfnS(gdp.pc,alpha,beta,C)"
   nlsInitial <- c(alpha=max(datos$yvar),coef(pars)[1],coef(pars)[2])
   mod1<-nlsLM(formula = nlsFormula,
     data=datos,
     start=nlsInitial,
     control=nls.lm.control(maxiter=1000))
     #,lower=c(30,-1000,-1000),upper=c(90,1000,1000))
     MSE.p <- mean(residuals(mod1)^2)
   return(data.frame(
     alpha=coef(mod1)[1],
     beta=coef(mod1)[2],
     C=coef(mod1)[3],
     alpha.se=summary(mod1)$coefficients[1,2],
     beta.se=summary(mod1)$coefficients[2,2],
     C.se=summary(mod1)$coefficients[3,2],
     MSE=MSE.p))
}
# foo<-datos[,c("gdp.pc","year","median")];setnames(foo,colnames(foo),c("gdp.pc","year","yvar"))
# foo<-subset(foo,year>1950)
#example: log.fnS(data=foo)

#/\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\.
#
# Predicting values from a logistic function
# pars: alpha,gamma,beta [model: alpha/(1+exp((dgp-gamma)*beta)) ]
#
#\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.
pred.log.fnS<-function(pars,newX){
	alpha<-pars[1]
	beta<-pars[2]
	C<-pars[3]
	out<-unlist(apply(rbind(newX),2,FUN=function(x) alpha/(1 + exp(beta+exp(log(C)*x)))))
  return(out)
}
#example:
# pred.log.fnS(pars=log.fnS(data=dat2),newX=quantile(dat2$gdp.pc,probs=seq(0,1,0.25),na.rm=T))



#/\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\.
#
# Fitting a logistic function
# output: alpha, gamma & beta [model: alpha/(1+exp((dgp-gamma)*beta)) ], BIC and AIC
#
#\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.
logfn<-function(gdp.pc,alpha,gamma,beta){
  alpha/(1 + exp((gdp.pc-gamma)*beta))
 }
 # Logistic fitting
log.fn<-function(data){
 datos<-na.omit(data)
 nlsFormula <- "yvar ~ logfn(gdp.pc,alpha,gamma,beta)"
 nlsInitial <- c(alpha=max(datos$yvar),gamma=mean(datos$gdp.pc),beta=1/mean(datos$year))
 mod1<-nlsLM(formula = nlsFormula, data=datos,start=nlsInitial,control=nls.lm.control(maxiter=1000))
 MSE.p <- mean(residuals(mod1)^2)
 return(data.frame(alpha=coef(mod1)[1],gamma=coef(mod1)[2],beta=coef(mod1)[3],
 	                 alpha.se=summary(mod1)$coefficients[1,2],gamma.se=summary(mod1)$coefficients[2,2],beta.se=summary(mod1)$coefficients[3,2],
 	                 MSE=MSE.p))
}
# foo<-datos[,c("gdp.pc","year","median")];setnames(foo,colnames(foo),c("gdp.pc","year","yvar"))
# foo<-subset(foo,year>1950)
#example: log.fn(data=foo)

#/\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\.
#
# Predicting values from a logistic function
# pars: alpha,gamma,beta [model: alpha/(1+exp((dgp-gamma)*beta)) ]
#
#\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.
pred.log.fn<-function(pars,newX){
	alpha<-pars[1]
	gamma<-pars[2]
	beta<-pars[3]
	out<-unlist(apply(rbind(newX),2,FUN=function(x) alpha/(1 + exp((x-gamma)*beta))))
  return(out)
}
#example:
# pred.log.fn(pars=log.fn(datos=dat2),newX=quantile(dat2$gdp.pc,probs=seq(0,1,0.25),na.rm=T))



#/\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\.
#
# Fitting a Box-Cox function
# output: lambda (for Box-Cox), alpha & beta [model: Box-Cox(Y) = alpha+beta*log(dgp)], BIC and AIC
#
#\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.
# Box-Cox with free lambda, lambda -> (0,3), if lambda=0 --> log(yvar)= alpha + beta*log(gdp)
free.bx.fn<-function(datos){
foo<-boxcox(yvar~log(gdp.pc),data=datos,plotit=F,lambda=seq(0,3,0.01))
 lambda1<-foo$x[foo$y==max(foo$y)]
 if(lambda1==0) datos$yvar2<-log(datos$yvar)
 if(lambda1>0) datos$yvar2<-(datos$yvar^lambda1 -1)/lambda1
  mod1<-lm(yvar2~log(gdp.pc),data=datos)
	pred<-pred.free.bx.fn(pars=data.frame(lambda=lambda1,alpha=coef(mod1)[1],beta=coef(mod1)[2]),newX=datos$gdp.pc)
	MSE.p<-sum((datos$yvar-pred)^2,na.rm=T)/dim(datos)[1]
return(data.frame(lambda=lambda1,alpha=coef(mod1)[1],beta=coef(mod1)[2],alpha.se=summary(mod1)$coefficients[1,2],beta.se=summary(mod1)$coefficients[2,2],
       MSE=MSE.p))
}
#example: free.bx.fn(datos=foo)

# Box-Cox with lambda=0 so the model is log(yvar)= alpha + beta*log(gdp)
bx.fn<-function(datos){
  mod1<-lm(log(yvar)~log(gdp.pc),data=datos)
	pred<-pred.bx.fn(pars=data.frame(alpha=coef(mod1)[1],beta=coef(mod1)[2]),newX=datos$gdp.pc)
	MSE.p<-sum((datos$yvar-pred)^2,na.rm=T)/dim(datos)[1]
 return(data.frame(alpha=coef(mod1)[1],beta=coef(mod1)[2],alpha.se=summary(mod1)$coefficients[1,2],beta.se=summary(mod1)$coefficients[2,2],
	    MSE=MSE.p))
}
#example: bx.fn(datos=foo)

#/\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\.
#
# Predicting values from a linear model using Box-Cox transformation
# pars: lambda [Box-Cox], alpha,beta [model: alpha+beta*log(dgp) ]
#
#\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.
# Box-Cox with free lambda, if lambda=0 --> log(yvar)= alpha + beta*log(gdp)
pred.free.bx.fn<-function(pars,newX){#pars=coeff1,newX=q1
	lambda<-pars[1]
	alpha<-pars[2]
	beta<-pars[3]
	bxcx.y<-unlist(tapply(as.vector(newX),1:length(newX),FUN=function(x) alpha+beta*log(x)))
	if(lambda==0) out<-unlist(tapply(as.vector(bxcx.y),1:length(bxcx.y),FUN=function(x) exp(x)))
	if(lambda>0)  out<-unlist(tapply(as.vector(bxcx.y),1:length(bxcx.y),FUN=function(x) (x*lambda + 1)^(1/lambda)))
  return(out)
}

# Box-Cox with lambda=0
pred.bx.fn<-function(pars,newX){
	alpha<-pars[1]
	beta<-pars[2]
	bxcx.y<-unlist(tapply(as.vector(newX),1:length(newX),FUN=function(x) alpha+beta*log(x)))
	out<-unlist(tapply(as.vector(bxcx.y),1:length(bxcx.y),FUN=function(x) exp(x)))
  return(out)
}
#example:
# pred.bx.fn(pars=bx.fn(datos=dat1),newX=quantile(dat1$gdp.pc,probs=seq(0,1,0.25),na.rm=T))


#/\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\.
#
# Function that takes predicts life exp between the lowest and highest quartile of income
# with respect to the median. It uses a logistic or free Box-Cox fitting
#
#\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.
ex.pred<-function(data,fitting,indices){
	tmp<-data
	tmp<-tmp[indices,]
	q1<-quantile(tmp$gdp.pc,probs=seq(0.25,0.75,0.25),na.rm=T)
  if(fitting=="logistic") {
 	coeff1<-log.fn(data=tmp)#;print(coeff1)
 	p1<-pred.log.fn(pars=coeff1,newX=q1)
  diff1<-p1[2]-p1[1]
  diff2<-p1[3]-p1[2]
  out<-c(diff1,diff2); names(out)<-c("median.minus.q1","q3.minus.median")
 }
  if(fitting=="free-boxcox") {
 	coeff1<-free.bx.fn(datos=tmp)#;print(coeff1)
 	p1<-pred.free.bx.fn(pars=coeff1,newX=q1)
  diff1<-p1[2]-p1[1]
  diff2<-p1[3]-p1[2]
  out<-c(diff1,diff2); names(out)<-c("median.minus.q1","q3.minus.median")
 }
 return(out)
}
#example: tmp<-datos[,c("year","gdp.pc","median")]
#nms<-colnames(tmp);nms[nms=="median"]<-"yvar";colnames(tmp)<-nms
#ex.pred(data=subset(tmp,year>=1950),fitting="free-boxcox")
#tmp<-boot(data=subset(tmp,year<1950),fitting="free-boxcox",statistic=ex.pred,R=5)


#/\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\.
#
# Function that takes a dataset and estimates a logistic or Box-Cox, it then selects the best model as min(MSE)
#
#\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.
best.fit<-function(data){
 bx1<-free.bx.fn(datos=data);bxn<-c("lambda","alpha","beta","MSE") #BX:   lambda, alpha, beta
 log1<-log.fn(data=data)   ;lon<-c("alpha","gamma","beta","MSE")  #log:  alpha, gamma, beta
 log1S<-log.fnS(data=data) ;lsn<-c("alpha","beta","C","MSE")     #logS: alpha, beta, C
 coef<-rep(NA,length(bxn)+length(lon)+length(lsn)); names(coef)<-c(paste("FB",bxn,sep="."),paste("Lg",lon,sep="."),paste("LS",lsn,sep="."))
 min1<-min(bx1$MSE,log1$MSE,log1S$MSE)
  if(bx1$MSE==min1)   { coef[1:4]<-bx1[bxn] }
	if(log1$MSE==min1)  { coef[5:8]<-log1[lon] }
  if(log1S$MSE==min1) { coef[9:12]<-log1S[lsn] }
 return(unlist(coef))
}
#example: best.fit(data=dat1)



#/\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\.
#
# Function that takes the two datasets and estimates \Delta(i) using a logistic or Box-Cox fitting
# fitting: logistic, Sam.logistic, free-boxcox, constraint-boxcox
#
#\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.
Delta.fn<-function(datos1,datos2,yvar,fitting){
	dat1<-datos1
	dat2<-datos2
  nms<-colnames(dat1);nms[nms==yvar]<-"yvar";setnames(dat1,colnames(dat1),nms)
  nms<-colnames(dat2);nms[nms==yvar]<-"yvar";setnames(dat2,colnames(dat2),nms)
  q1<-quantile(dat1$gdp.pc,probs=seq(0.25,0.75,0.25),na.rm=T)
  q2<-quantile(dat2$gdp.pc,probs=seq(0.25,0.75,0.25),na.rm=T)
 if(fitting=="logistic") {
 	coeff1<-log.fn(data=dat1)#;print(coeff1)
 	coeff2<-log.fn(data=dat2)#;print(coeff2)
 	p1<-pred.log.fn(pars=coeff1,newX=q1)
  p2<-pred.log.fn(pars=coeff2,newX=q2)
	pi1<-pred.log.fn(pars=coeff2,newX=q1)
	pi2<-pred.log.fn(pars=coeff1,newX=q2)
	delta1<- (pi1-p1)/(p2-p1)
	delta2<- (p2-pi2)/(p2-p1)
	Delta<-(1/(2*length(q1)))*(sum(delta1)+sum(delta2))
  setnames(coeff1,colnames(coeff1),paste(colnames(coeff1),1,sep=".")) #adding label 1 for parameters estimated <1950
	setnames(coeff2,colnames(coeff2),paste(colnames(coeff2),2,sep=".")) #adding label 2 for parameters estimated >=1950
	out<-data.frame(Delta=Delta,coeff1,coeff2)
 }
 if(fitting=="Sam.logistic") {
 	coeff1<-log.fnS(data=dat1)#;print(coeff1)
 	coeff2<-log.fnS(data=dat2)#;print(coeff2)
 	p1<-pred.log.fnS(pars=coeff1,newX=q1)
  p2<-pred.log.fnS(pars=coeff2,newX=q2)
	pi1<-pred.log.fnS(pars=coeff2,newX=q1)
	pi2<-pred.log.fnS(pars=coeff1,newX=q2)
	delta1<- (pi1-p1)/(p2-p1)
	delta2<- (p2-pi2)/(p2-p1)
	Delta<-(1/(2*length(q1)))*(sum(delta1)+sum(delta2))
  setnames(coeff1,colnames(coeff1),paste(colnames(coeff1),1,sep=".")) #adding label 1 for parameters estimated <1950
	setnames(coeff2,colnames(coeff2),paste(colnames(coeff2),2,sep=".")) #adding label 2 for parameters estimated >=1950
	out<-data.frame(Delta=Delta,coeff1,coeff2)
 }
 if(fitting=="constraint-boxcox") {
 	coeff1<-bx.fn(datos=dat1)
 	coeff2<-bx.fn(datos=dat2)
 	p1<-pred.bx.fn(pars=coeff1,newX=q1)
  p2<-pred.bx.fn(pars=coeff2,newX=q2)
	pi1<-pred.bx.fn(pars=coeff2,newX=q1)
	pi2<-pred.bx.fn(pars=coeff1,newX=q2)
	delta1<- (pi1-p1)/(p2-p1)
	delta2<- (p2-pi2)/(p2-p1)
	Delta<-(1/(2*length(q1)))*(sum(delta1)+sum(delta2))
  setnames(coeff1,colnames(coeff1),paste(colnames(coeff1),1,sep=".")) #adding label 1 for parameters estimated <1950
  setnames(coeff2,colnames(coeff2),paste(colnames(coeff2),2,sep=".")) #adding label 2 for parameters estimated >=1950
	out<-data.frame(Delta=Delta,coeff1,coeff2)
 }
 if(fitting=="free-boxcox") {
  coeff1<-free.bx.fn(datos=dat1)
 	coeff2<-free.bx.fn(datos=dat2)
 	p1<-pred.free.bx.fn(pars=coeff1,newX=q1)
  p2<-pred.free.bx.fn(pars=coeff2,newX=q2)
	pi1<-pred.free.bx.fn(pars=coeff2,newX=q1)
	pi2<-pred.free.bx.fn(pars=coeff1,newX=q2)
	delta1<- (pi1-p1)/(p2-p1)
	delta2<- (p2-pi2)/(p2-p1)
	Delta<-(1/(2*length(q1)))*(sum(delta1)+sum(delta2))
  setnames(coeff1,colnames(coeff1),paste(colnames(coeff1),1,sep=".")) #adding label 1 for parameters estimated <1950
  setnames(coeff2,colnames(coeff2),paste(colnames(coeff2),2,sep=".")) #adding label 2 for parameters estimated >=1950
	out<-data.frame(Delta=Delta,coeff1,coeff2)
 }
return(out)
}



#/\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\./\.
#
# Function that takes the best fitting model in terms of lowest MSE in each period, <1950, 1950+ and then
# estimates \Delta(i) using the best model in each period
# fitting: logistic or boxcox
#
#\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.\/.
Delta.best.fn<-function(coef1,coef2,p1,p2,pi1,pi2,q1){
	delta1<- (pi1-p1)/(p2-p1)
	delta2<- (p2-pi2)/(p2-p1)
	Delta<-(1/(2*length(q1)))*(sum(delta1)+sum(delta2)); names(Delta)<-"Delta"
	return(unlist(c(Delta,as.vector(coef1),as.vector(coef2))))
}

#DeltaK.fn<-function(dattos,indices){	#
DeltaK.fn<-function(dattos){	#
	tmp<-na.omit(dattos)
#	tmp<-tmp[indices,]#these indices are used for the bootstrap
  dat1<-tmp[tmp$year<1950,]; dat2<-tmp[tmp$year>=1950,]

	q1<-quantile(dat1$gdp.pc,probs=seq(0.25,0.75,0.25),na.rm=T)
  q2<-quantile(dat2$gdp.pc,probs=seq(0.25,0.75,0.25),na.rm=T)

  log1<-log.fn(data=dat1); log1S<-log.fnS(data=dat1); bx12<-free.bx.fn(datos=dat1); bx1<-bx.fn(datos=dat1)
  log2<-log.fn(data=dat2); log2S<-log.fnS(data=dat2); bx22<-free.bx.fn(datos=dat2); bx2<-bx.fn(datos=dat2)
  if(log1$MSE>100) log1$MSE<-100;if(log1S$MSE>100) log1S$MSE<-100;if(bx1$MSE>100) bx1$MSE<-100;if(bx12$MSE>100) bx12$MSE<-100
  if(log2$MSE>100) log2$MSE<-100;if(log2S$MSE>100) log2S$MSE<-100;if(bx2$MSE>100) bx2$MSE<-100;if(bx22$MSE>100) bx22$MSE<-100

  min1<-min(log1$MSE,log1S$MSE,bx1$MSE,bx12$MSE)#
  min2<-min(log2$MSE,log2S$MSE,bx2$MSE,bx22$MSE)#

	bxn<-c("lambda","alpha","beta","MSE");lon<-c("alpha","gamma","beta","MSE");lsn<-c("alpha","beta","C","MSE"); cont.bx<-c("alpha","beta","MSE")
	coef1<-rep(NA,length(bxn)+length(lon)+length(lsn));coef2<-rep(NA,length(bxn)+length(lon)+length(lsn))
	names(coef1)<-names(coef2)<-c(paste("FB",bxn,sep="."),paste("Lg",lon,sep="."),paste("LS",lsn,sep="."))

  if(log1$MSE==min1)  { coeff1<-log1; coef1[5:8]<-coeff1[lon];  p1<-pred.log.fn(pars=coeff1,newX=q1);    pi2<-pred.log.fn(pars=coeff1,newX=q2) }
  if(log1S$MSE==min1) { coeff1<-log1S;coef1[9:12]<-coeff1[lsn]; p1<-pred.log.fnS(pars=coeff1,newX=q1);   pi2<-pred.log.fnS(pars=coeff1,newX=q2) }
	if(bx12$MSE==min1)  { coeff1<-bx12; coef1[1:4]<-coeff1[bxn]; p1<-pred.free.bx.fn(pars=coeff1,newX=q1);pi2<-pred.free.bx.fn(pars=coeff1,newX=q2) }
  if(bx1$MSE==min1)   { coeff1<-bx1;  coef1[1:4]<-c(0,coeff1[cont.bx]);  p1<-pred.bx.fn(pars=coeff1,newX=q1);     pi2<-pred.bx.fn(pars=coeff1,newX=q2) }

	if(log2$MSE==min2)  { coeff2<-log2; coef2[5:8]<-coeff2[lon];  p2<-pred.log.fn(pars=coeff2,newX=q2);    pi1<-pred.log.fn(pars=coeff2,newX=q1) }
  if(log2S$MSE==min2) { coeff2<-log2S;coef2[9:12]<-coeff2[lsn]; p2<-pred.log.fnS(pars=coeff2,newX=q2);   pi1<-pred.log.fnS(pars=coeff2,newX=q1) }
  if(bx22$MSE==min1)  { coeff2<-bx12; coef2[1:4]<-coeff2[bxn];  p2<-pred.free.bx.fn(pars=coeff2,newX=q2);pi1<-pred.free.bx.fn(pars=coeff2,newX=q1) }
  if(bx2$MSE==min2)   { coeff2<-bx2;  coef2[1:4]<-c(0,coeff2[cont.bx]);   p2<-pred.bx.fn(pars=coeff2,newX=q2);     pi1<-pred.bx.fn(pars=coeff2,newX=q1) }

  #setnames(coeff1,colnames(coeff1),paste(colnames(coeff1),1,sep="."));setnames(coeff2,colnames(coeff2),paste(colnames(coeff2),2,sep="."))
	names(coef1)<-paste(names(coef1),1,sep=".")
  names(coef2)<-paste(names(coef2),2,sep=".")
	return(Delta.best.fn(coef1=coef1,coef2=coef2,p1=p1,p2=p2,pi1=pi1,pi2=pi2,q1=q1))
}
# example:
#foo<-na.omit(data.frame(yvar=N.samples[[1]],gdp.pc=datos$gdp.pc,year=datos$year))
# DeltaK.fn(dattos=foo)
