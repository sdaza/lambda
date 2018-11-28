# model covariates
# lambda
# author: sebastian daza

library(here)
library(haven)
library(sdazar)
library(ggplot2)
library(brms)
options(mc.cores = parallel::detectCores())
library(imputeTS)
# library(stringr)
# library(ggridges)
# library(patchwork)


# set path
setwd('00projects/lambda')

# load data
df = data.table(read_stata('data/Ex_LA1850-2013_SES_ABBREVIATED_april-3-2018.dta'))

country_labels = c("Argentina", "Bolivia", "Brazil", "Chile", "Colombia",
                   "Costa_Rica", "Cuba", "Dominican_Republic", "Ecuador",
                   "El_Salvador", "Guatemala", "Honduras", "Mexico", "Nicaragua",
                   "Panama", "Paraguay", "Peru", "Uruguay", "Venezuela")

df[, ctry := factor(ctry, labels=country_labels)]

head(df)

# select covarites
covariates = names(df)[10:28]

c = df[tseries2==1 & age==0 & year>=1900, lapply(.SD,Max),
       .SDcols=covariates, by=.(ctry, year)]

le = df[tseries2==1 & age==0 & year>=1900, .(Ex=Mean(Ex)), by=.(ctry, year)]

# check
(nrow(c) + nrow(le))/2

dt = merge(c, le, by=c('ctry', 'year'))

# missing data
print(countmis(dt))

test = dt[year>=1900, .(ctry, year, gdp_pc, urban, lit, Ex, water, sewage, elec, us_aid, tfr)]

# periods
test[year<1950, gyear:='1950']
test[year>=1950 & year<1970, gyear:='1950-1969']
test[year>=1970 & year<1990, gyear:='1970-1989']
test[year>=1990, gyear :='1990']

# transform variable: weibull
test[, y := Ex/max(Ex+1.05), by = ctry] # adjustment is by country!
test[, wy := log(-log(1-y))]
max_le = test[, .(max_le = max(Ex+1.05)), by = ctry] # to recover values later
test[, ctry_year := paste0(ctry,'.', gyear)]

# define order
setorder(test, year)

# interpolation
test[, igdp_pc := na.interpolation(gdp_pc, option='stine'), by=ctry]
test[, iurban := na.interpolation(urban, option='stine'), by=ctry]
test[, ilit := na.interpolation(lit, option='stine'), by=ctry]
test[, itfr := na.interpolation(tfr, option='stine'), by=ctry]

test[, igdp_log := scale(log(igdp_pc), scale=FALSE, center=TRUE)]
test[, iurban_log := scale(log(iurban), scale=FALSE, center=TRUE)]
test[, ilit_log := scale(log(ilit), scale=FALSE, center=TRUE)]

# models

m2.1 = brm(formula = wy ~ 1 + igdp_log  + (igdp_log|ctry_year),
           data = test,
           iter = 2000,
           chains = 2,
           prior = c(set_prior("normal(0,2)", class = "b")))

summary(m2.1)

resid = resid(m2.1, type = 'pearson')[, "Estimate"]
fit = predict(m2.1)[, 'Estimate']

ggplot(data = NULL, aes(y = resid, x = fit)) +
    geom_point(size=0.2, alpha=0.8, color='gray') +
    stat_smooth(geom='line', color='red') +
    theme_classic()

pacf(resid)

# model with autocorrelation
setorder(test, ctry, year)
head(test[, .(year, ctry)])

m2.1a = brm(formula = wy ~ 1 + igdp_log + (igdp_log|ctry_year),
          autocor = cor_arr(~ year|ctry, r=1),
          data = test,
          iter = 2000,
          chains = 2)
          # prior = c(set_prior('normal(0,.5)', class = 'ar'),
          #           set_prior('normal(0,5)', class = 'b')))
summary(m2.1a)

resid = resid(m2.1a, type = 'pearson')[, "Estimate"]
acf(resid)

fit = predict(m2.1a)[, 'Estimate']

ggplot(data = NULL, aes(y = resid, x = fit)) +
    geom_point(size=0.2, alpha=0.8, color='gray') +
    stat_smooth(geom='line', color='red') +
    theme_classic()
