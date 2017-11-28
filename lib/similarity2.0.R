library(entropy)


###################data processing######################
web.train<-read.csv("../data/web.train2.0.csv")
movie.train<-read.csv("../data/movie.train2.0.csv")

dataprocess<-function(data){
  data<-data[,-1]
  
  #movie
  if(ncol(data)>1600){
    data[is.na(data)]<-0
    matrix<-as.matrix(data)
    
  }else{
    #web
    feature<-unique(unlist(data))
    feature<-feature[!is.na(feature)]
    
    matrix<-matrix(0,nrow=nrow(data),ncol=length(feature))
    colnames(matrix)<-feature
    
    for(i in 1:nrow(data)){
      for(j in 1:length(feature)){
        matrix[i,j]<-ifelse(feature[j]%in%data[i,],1,0)
      }
    }
    
  }
  return(matrix)
}

web.train.matrix<-dataprocess(web.train)
movie.train.matrix<-dataprocess(movie.train)

######################function###############
getSpearman <- function(x,y) 
{
  return(cor(x,y,method="spearman"))
}


getEntropy <- function(x,y) 
{
  library(entropy)
  
  p.x<-as.vector(table(x))
  p.y<-as.vector(table(y))
  
  etp <- KL.empirical(p.x,p.y)
  return(etp)
}

getMSD <- function(x,y) 
{
  msd <- mean((x-y)^2)
  return(msd)
}

########################form matrix of web#################
d<-nrow(web.train.matrix)
web.sp.similarity<-matrix(NA,ncol=d,nrow=d)
web.entropy.similarity<-matrix(NA,ncol=d,nrow=d)
web.msd.similarity<-matrix(NA,ncol=d,nrow=d)

for(i in 1:d) {
  for(j in ((i+1):d)){
    #web.sp.similarity[i,j]= getSpearman(web.train.matrix[i,],web.train.matrix[j,])
    web.entropy.similarity[i,j]= getEntropy(web.train.matrix[i,],web.train.matrix[j,])
    web.msd.similarity[i,j]= getMSD(web.train.matrix[i,],web.train.matrix[j,])
  }
}

makesymmetric<-function(data){
  data[!upper.tri(data)] <- 0
  data.f<-data+t(data)
  #diag(data.f)<-1
  return(data.f)
}

#web.sp.sim<-makesymmetric(web.sp.similarity) 
#diag(web.sp.sim)<-1
#colnames(web.sp.sim)<-web.train[1,]
web.sp.sim<-cor(t(web.train.matrix), t(web.train.matrix),method="spearman")
save(web.sp.sim,file="~/Desktop/Proj4/web.sp.sim.Rdata")

web.entropy.sim<-makesymmetric(web.entropy.similarity)
save(web.entropy.sim,file="~/Desktop/Proj4/web.entropy.sim.Rdata")

web.msd.sim<-makesymmetric(web.msd.similarity)
save(web.msd.sim,file="~/Desktop/Proj4/web.msd.sim.Rdata")

#################form matrix of movie##############
d2<-nrow(movie.train.matrix)
mv.sp.similarity<-matrix(NA,ncol=d2,nrow=d2)
mv.entropy.similarity<-matrix(NA,ncol=d2,nrow=d2)
mv.msd.similarity<-matrix(NA,ncol=d2,nrow=d2)

mv.sp.sim<-cor(t(movie.train.matrix), t(movie.train.matrix),method="spearman")
save(mv.sp.sim,file="~/Desktop/Proj4/mv.sp.sim.Rdata")


for(k in (1:d2-1)) {
  for(l in ((k+1):d2)){
    #mv.sp.similarity[i,j]= getSpearman(movie.train.matrix[i,],movie.train.matrix[j,])
    mv.entropy.similarity[k,l]= getEntropy(movie.train.matrix[k,],movie.train.matrix[l,])
    mv.msd.similarity[k,l]= getMSD(movie.train.matrix[k,],movie.train.matrix[l,])
  }
  print(k)
}

mv.entropy.sim<-makesymmetric(mv.entropy.similarity)
save(mv.entropy.sim,file="~/Desktop/Proj4/mv.entropy.sim.Rdata")

mv.msd.sim<-makesymmetric(mv.msd.similarity)
save(mv.msd.sim,file="~/Desktop/Proj4/mv.msd.sim.Rdata")

