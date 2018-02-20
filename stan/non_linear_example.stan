data {
  int<lower=0> N; 
  real x[N]; 
  real Y[N]; 
} 

parameters {
  real alpha; 
  real beta;  
  real<lower=.5,upper= 1> lambda; // orginal gamma in the JAGS example  
  real<lower=0> tau; 
} 

transformed parameters {
  real sigma; 
  sigma <- 1 / sqrt(tau); 
} 

model {
  real m[N];
  for (i in 1:N) 
    m[i] <- alpha - beta * pow(lambda, x[i]);
  
  Y ~ normal(m, sigma); 
  
  alpha ~ normal(0.0, 1000); 
  beta ~ normal(0.0, 1000); 
  lambda ~ uniform(.5, 1); 
  tau ~ gamma(.0001, .0001); 
}

generated quantities {
  real Y_mean[N]; 
  real Y_pred[N]; 
  for(i in 1:N){
    # Posterior parameter distribution of the mean
    Y_mean[i] <- alpha - beta * pow(lambda, x[i]);
    # Posterior predictive distribution
    Y_pred[i] <- normal_rng(Y_mean[i], sigma);   
    }
}