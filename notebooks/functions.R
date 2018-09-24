# lambda project
# author: sebastian daza


# functions

# get original values from weibull transformation
get_orig_values_weibull = function(x, max_value) { 
    return ( (1 - exp(-exp(x))) * max_value )
}

# shifts with stacking for only one country (auxiliary function)
estimate_shift = function(models=NULL, # list
                          ps=NULL, # list, posterior samples
                          data=NULL, # data.table 
                          country=NULL, # string
                          weights= NULL, # vector, lenght = number of models
                          cfyear=NULL, # numeric 
                          segment=NULL, # string representing period, valid values 1950, 1950-1969, 1970-1989, 1990
                          model_pred = list('1950' = '1950', '1970' = '1950-1969', '1990' = '1970-1989', '2010' = '1990')
                         )  { 
  
    output = list()
    
    # equal weights (average) if they are not specified
    if (is.null(weights)) { weights = rep(1/length(models), length(models)) }
    
    # loop through models
    for (i in seq_along(models)) {
             
        if (is.null(ps)) {  s = data.table(posterior_samples(models[[i]])) } 
        else {  s = data.table(ps[[i]]) }
   
        # counterfactual using previous coefficients and intercepts (random effects)   
        if (is.null(segment)) { igyear = model_pred[as.character(cfyear)] }
        else { igyear = segment }
        
            
        if (!igyear %in% as.vector(unlist(model_pred))) { stop('Segment (period) is not valid!') }  
        
        colnames = names(s)
        betas = grep('^b_', colnames, value=TRUE)
        random = str_subset(colnames, paste0('^r_.+\\[', country, '.', igyear, ','))
        coef = c(betas, random)
#         print(coef)

        variables = c('ctry', 'year', sub('b_', '', betas))
        variables = variables[variables != 'Intercept']
        covariates = sub('b_', '', betas)
        
        data[, Intercept := 1]
        dt  = data[ctry==country & year==cfyear, ..covariates]
#         print(head(dt))
                             
        max_le = unique(test[ctry==country & year==cfyear, max_le])
        ex_obs = unique(test[ctry==country & year==cfyear, Ex])
    
#     print(ex_obs)
    
        st = s[, ..coef] # select coefficients
#         print(coef)
#         print('counterfactual')
#         print(head(st))
        for (h in seq_along(covariates)) {
            st[, covariates[h] := rowSums(.SD), .SDcols = grep(covariates[h], names(st), value=TRUE)]
        }

        mt = as.matrix(st[, ..covariates])
        
#         print(head(mt))
        
        # using observed values!
        cf = mt %*% as.vector(as.matrix(dt)) # counterfactual
        cf = unlist(sapply(cf, function(x) get_orig_values_weibull(x, max_value=max_le)))

        # using predicted values!
        pigyear =  data[ctry==country & year == cfyear, gyear]
#             print(igyear)
#               print('prediction')
        prandom = str_subset(colnames, paste0('^r_.+\\[', country, '.', pigyear, ','))
        pcoef = c(betas, prandom)
#             print(coef)
        pt = s[, ..pcoef]
#             print(head(pt))
#             print(covariates)
                               
        for (h in seq_along(covariates)) {
            pt[, covariates[h] := rowSums(.SD), .SDcols = grep(covariates[h], names(pt), value=TRUE)]
        }

#             print(dt)
        mpt = as.matrix(pt[, ..covariates])
#             print(head(mpt))
        ex_pred = mpt %*% as.vector(as.matrix(dt))
        ex_pred = unlist(sapply(ex_pred, function(x) get_orig_values_weibull(x, max_value=max_le)))

        output[[i]] = data.table(obs_ex=ex_obs, pred_ex = ex_pred, counterfactual=cf)
        output[[i]][, shift_obs := obs_ex - counterfactual]
        output[[i]][, shift_pred := pred_ex - counterfactual]
                                                      
#                     'prediction' = as.vector(as.matrix(setDT(predictions)) %*% weights),
#                     'counterfactual' = as.vector(as.matrix(setDT(cfs)) %*% weights)))
}
    if (length(output)==1) {
        return(output[[1]])
    }
    else { 
        for (i in 1:length(models)) {
            output[[i]] = output[[i]] * weights[i]
        }
#      return(sum of all elements in the list)
    }
}
                                
# estimate shift for each country 
compute_shifts = function(models = NULL, # list of models
                        ps = NULL, # list of posterior samples 
                        weights = NULL, # vector with model weigths
                        data = NULL, 
                        countries = NULL, 
                        years = NULL) { 

    model_pred = list('1950' = '1950', '1970' = '1950-1969', '1990' = '1970-1989', '2010' = '1990')
    
    # list to save results
    results = list()
    
    for (c in countries ) {
        
        iyears = as.numeric(unique(data[ctry==c & year %in% years, year]))
        segments = as.character(unique(data[ctry==c, gyear])) 

    for (ys in iyears) {
    
        for (seg in segments) {
            
        est = estimate_shift(models = models,
            ps = ps,
            weights = weights,
            data= data, 
            country = c, 
            cfyear = ys,
            segment = seg)

       name = paste0(c(c,ys,seg), collapse='.')
        
       results[[paste0(c(c,ys,seg), collapse='.')]] = est[, name := name]
            
       }
     }
    }
    
    results = rbindlist(results)
    results[, c('ctry', 'year', 'segment') := tstrsplit(name, ".", fixed=TRUE)][, 
                                        num_models := length(models)]
     
    return(results[, .(ctry, year, segment, num_models, obs_ex, pred_ex, counterfactual, shift_obs, shift_pred)])
    
}
                                
# lags with stacking for only one country (auxiliary function)                          
estimate_lag = function(models=NULL, # list
                          ps=NULL, # list, posterior samples
                          data=NULL, # data.table 
                          country=NULL, # string
                          weights= NULL, # vector, lenght = number of models
                          cfyear=NULL, # numeric 
                          segment=NULL, # string representing period, valid values 1950, 1950-1969, 1970-1989, 1990
                          predicted_values=FALSE # boolean
                         )  { 
  
    
    setorder(data, year)
    
    year_values = data[ctry==country, year]
    ex_values = data[ctry==country, Ex]
    
    if(!(length(year_values) == length(ex_values))) { stop('LE values should have same lenght as years')}
    
    differences = list()
    
    model_pred = list('1950' = '1950', '1970' = '1950-1969', '1990' = '1970-1989', '2010' = '1990')
    
    # equal weights (average) if they are not specified
    if (is.null(weights)) { weights = rep(1/length(models), length(models)) }
    
    # loop through models
    for (i in seq_along(models)) {
        
        if (is.null(ps)) {  s = data.table(posterior_samples(models[[i]])) } 
        else {  s = data.table(ps[[i]]) }
   
        # counterfactual using previous coefficients and intercepts (random effects)   
        if (is.null(segment)) { igyear = model_pred[as.character(cfyear)] }
        else { igyear = segment }
        
            
        if (!igyear %in% as.vector(unlist(model_pred))) { stop('Segment (period) is not valid!') }  
        
        colnames = names(s)
        betas = grep('^b_', colnames, value=TRUE)
        random = str_subset(colnames, paste0('^r_.+\\[', country, '.', igyear, ','))
        coef = c(betas, random)
#         print(coef)

        variables = c('ctry', 'year', sub('b_', '', betas))
        variables = variables[variables != 'Intercept']
        covariates = sub('b_', '', betas)
        
        data[, Intercept := 1]
        dt  = data[ctry==country & year==cfyear, ..covariates]
#         print(head(dt))
                             
        max_le = unique(test[ctry==country & year==cfyear, max_le])
        ex_obs = unique(test[ctry==country & year==cfyear, Ex])
    
#     print(ex_obs)
    
        st = s[, ..coef] # select coefficients
#         print(coef)
#         print('counterfactual')
#         print(head(st))
        for (h in seq_along(covariates)) {
            st[, covariates[h] := rowSums(.SD), .SDcols = grep(covariates[h], names(st), value=TRUE)]
        }

        mt = as.matrix(st[, ..covariates])
        
#         print(head(mt))
        
        cf = mt %*% as.vector(as.matrix(dt)) # counterfactual
        cf = unlist(sapply(cf, function(x) get_orig_values_weibull(x, max_value=max_le)))

#         print(head(cf))
                       
        if (predicted_values) { # using predicted values (all random effects) instead of observed Ex
            
           ex_values = predict(models[[i]], data[ctry==country], summary=FALSE)
           ex_values = apply(ex_values, 2, mean)
           ex_values  = unlist(lapply(ex_values,  function(x)  get_orig_values_weibull(x, max_le)))  
#            print(ex_values)
                                      
#             print(length(year_values))
#            print(length(cf))
                                      
           ind = NULL
           for (j in 1:length(cf)) {
             ind[j] = which.min(abs(ex_values - cf[j]))
           }
             
           differences[[i]]  = year_values[ind] - cfyear
                                    
        } else { 
            
           ind = NULL
           for (j in 1:length(cf)) {
             ind[j] = which.min(abs(ex_values - cf[j]))
           }
        
           differences[[i]] = year_values[ind] - cfyear
        } # using observed Ex values       
#             print(head(differences[[i]]))
      }  
                           
    # combine values (differences) using weights
    return( as.vector(as.matrix(setDT(differences)) %*% weights) ) # return a vector
}
                                      
# compute lags for each country 

compute_lags = function(models = NULL, # list of models
                        ps = NULL, # list of posterior samples 
                        weights = NULL, # vector with model weigths
                        data = NULL, 
                        countries = NULL, 
                        years = NULL, 
                        predicted_values=FALSE, 
                        model_pred = list('1950' = '1950', '1970' = '1950-1969', '1990' = '1970-1989', '2010' = '1990')) { 

   
    
    # list to save results
    lags = list()
    
    for (c in countries ) {
        
        iyears = as.numeric(unique(data[ctry==c & year %in% years, year]))
        segments = as.character(unique(data[ctry==c, gyear])) 

    for (ys in iyears) {
    
        for (seg in segments) {
            
        est = estimate_lag(models = models,
            ps = ps,
            weights = weights,
            data= data, 
            country = c, 
            cfyear = ys,
            segment = seg,
            predicted_values=predicted_values)

        name = paste0(c(c,ys,seg), collapse='.')
        lags[[paste0(c(c,ys,seg), collapse='.')]] = data.table(name, pred_lag = est)
            
        }
    }
    }
    
    lags = rbindlist(lags)
    lags[, c('ctry', 'year', 'segment') := tstrsplit(name, ".", fixed=TRUE)][, 
                                        num_models := length(models)]
    lags = lags[, .(ctry, year, segment, num_models, pred_lag)]
     
    return(lags)
    
}