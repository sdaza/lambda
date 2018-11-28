
# run models in parallel

library(doParallel)
library(data.table)

cl = makeCluster(15)
registerDoParallel(cl)
seed = 103231

df = fread('/home/s/sdaza/00projects/lambda/data/bs_samples.csv')

results = foreach(i=1:100, .combine=cbind) %dopar% {

    library(data.table)
    library(brms)
    library(loo)

    prior = set_prior("normal(0, 5)", class = "b")

    test = copy(df[sample_index==i])
    test[, y := le/max(le+1.05), by = ctry] # adjustment is by country!
    test[, wy := log(-log(1-y))]
    test[, max_le := max(le+1.05), by = ctry] # to recover values later

    m1.1 = brm(formula = wy ~ 1 + igdp_log  + (igdp_log|ctry_year),
           data = test,
           iter = 2000,
           chains = 2,
           seed = seed,
           prior=prior,
           cores=1)

    m1.2 = brm(formula = wy ~ 1 + igdp_log  + iurban_log +  (igdp_log|ctry_year),
          data = test,
          iter = 2000,
          chains = 2,
          seed = seed,
          prior = prior,
          cores=1)

    m1.3 = brm(formula = wy ~ 1 + igdp_log  + ilit_log +  (igdp_log|ctry_year),
          data = test,
          iter = 2000,
          chains = 2,
          seed = seed,
          prior = prior,
          cores=1)

    m1.4 = brm(formula = wy ~ 1 + igdp_log + ilit_log + iurban_log + (igdp_log|ctry_year),
          data = test,
          iter = 2000,
          chains = 2,
          seed = seed,
          prior = prior,
          control=  list(adapt_delta=0.90),
          cores=1)

    loo1.1 = loo(m1.1, reloo=TRUE)
    loo1.2 = loo(m1.2, reloo=TRUE)
    loo1.3 = loo(m1.3, reloo=TRUE)
    loo1.4 = loo(m1.4, reloo=TRUE)

    loo_list_noyear = list(loo1.1, loo1.2, loo1.3, loo1.4)

    loo_model_weights(loo_list_noyear)

}

saveRDS(t(results), "/home/s/sdaza/00projects/lambda/output/weights.rds")
