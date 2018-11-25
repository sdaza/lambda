
# Description of output files

For more details see notebook `stacking_covariates_update`

<<<<<<< HEAD
- 1900 full = wy ~ 1 + igdp_log + ilit_log + iurban_log + (igdp_log|ctry_year)
- 1950 full = wy ~ 1 + igdp_log + ilit_log + iurban_log + iwater_log + isewage_log + ielec_log + (igdp_log|ctry_year)
=======
- 1900 full = wy ~ 1 + igdp_log + ilit_log + iurban_log + (igdp_log|ctry_year) 
- 1950 full = wy ~ 1 + igdp_log + ilit_log + iurban_log + iwater_log + isewage_log + ielec_log + (igdp_log|ctry_year) 
>>>>>>> 75cce9ce751f597ecfe02c1263f04a76d5541cbe

## GDP only models or individual models (no stacking)

#### GDP only

- `shift_1900_gdponly.csv`: shifts using data since 1900 with GDP as the only varying coefficient. See notebook for more details.
- `shift_1900_gdponly_year.csv`: shifts using data since 1900 with GPD and year (standardized variable) as the only covariates. See notebooks for more details.
- `shift_1900_gdponly_autocorrelation.csv`: shifts using data since 1900 with GPD as only varying coefficient and autocorrelation adjustment (one lag of LE variable). See notebooks for more details.


- `shift_1950_gdponly.csv`: shifts using data since 1950 with GDP as the only varying coefficient. See notebook for more details.
- `shift_1950_gdponly_year.csv`: shifts using data since 1950 with GPD and year (standardized variable) as the only covariates. See notebooks for more details.
- `shift_1950_gdponly_autocorrelation.csv`: shifts using data since 1950 with GPD as only varying coefficient and autocorrelation adjustment (one lag of LE variable). See notebooks for more details.

#### Full
- `shift_1900_full_autocorrelation.csv`: shifts using data since 1900 using all covariates available + adjustment outcorrelation See notebook for more details.
- `shift_1950_full_autocorrelation.csv`: shifts using data since 1950 using all covariates available + adjustment outcorrelation. See notebook for more details.See notebook for more details.


- `shift_1950_gdponly.csv`: shifts using data since 1950 with GDP as the only varying coefficient. See notebook for more details.
- `shift_1950_gdponly_year.csv`: shifts using data since 1950 with GPD and year (standardized variable) as the only covariates. See notebooks for more details.
- `shift_1950_gdponly_autocorrelation.csv`: shifts using data since 1950 with GPD as only varying coefficient and autocorrelation adjustment (one lag of LE variable). See notebooks for more details. 

#### Full
- `shift_1900_full_autocorrelation.csv`: shifts using data since 1900 using all covariates available + adjustment outcorrelation See notebook for more details.
- `shift_1950_full_autocorrelation.csv`: shifts using data since 1950 using all covariates available + adjustment outcorrelation. See notebook for more details.See notebook for more details.

## Stacking

#### 1900

<<<<<<< HEAD
- `shift_1900_stacking.csv`: shifts using data since 1900 with stacking. GDP is the only varying coefficient, all the rest are constant. Stacking consists of 4 models:
  - wy ~ 1 + igdp_log + (igdp_log|ctry_year)
  - wy ~ 1 + igdp_log  + iurban_log +  (igdp_log|ctry_year)
  - wy ~ 1 + igdp_log  + ilit_log +  (igdp_log|ctry_year)
  - wy ~ 1 + igdp_log + ilit_log + iurban_log + (igdp_log|ctry_year)


- `shift_1900_stacking_year.csv`: shifts using data since 1900 with stacking adjusting for year (standardized variable). GDP is the only varying coefficient, all the rest are constant. Stacking consists of 4 models:
  - wy ~ 1 + igdp_log + zyear + (igdp_log|ctry_year)
  - wy ~ 1 + igdp_log  + iurban_log +  zyear + (igdp_log|ctry_year)
  - wy ~ 1 + igdp_log  + ilit_log +  zyear + (igdp_log|ctry_year)
  - wy ~ 1 + igdp_log + ilit_log + iurban_log + zyear + (igdp_log|ctry_year)

#### 1950

- `shift_1950_stacking.csv`: shifts using data since 1900 with stacking. GDP is the only varying coefficient, all the rest are constant. Stacking consists of 4 models:
  - wy ~ 1 + igdp_log + (igdp_log|ctry_year)
=======
- `shift_1900_stacking.csv`: shifts using data since 1900 with stacking. GDP is the only varying coefficient, all the rest are constant. Stacking consists of 4 models: 
  - wy ~ 1 + igdp_log + (igdp_log|ctry_year) 
  - wy ~ 1 + igdp_log  + iurban_log +  (igdp_log|ctry_year)
  - wy ~ 1 + igdp_log  + ilit_log +  (igdp_log|ctry_year)
  - wy ~ 1 + igdp_log + ilit_log + iurban_log + (igdp_log|ctry_year) 


- `shift_1900_stacking_year.csv`: shifts using data since 1900 with stacking adjusting for year (standardized variable). GDP is the only varying coefficient, all the rest are constant. Stacking consists of 4 models: 
  - wy ~ 1 + igdp_log + zyear + (igdp_log|ctry_year) 
  - wy ~ 1 + igdp_log  + iurban_log +  zyear + (igdp_log|ctry_year)
  - wy ~ 1 + igdp_log  + ilit_log +  zyear + (igdp_log|ctry_year)
  - wy ~ 1 + igdp_log + ilit_log + iurban_log + zyear + (igdp_log|ctry_year) 

#### 1950

- `shift_1950_stacking.csv`: shifts using data since 1900 with stacking. GDP is the only varying coefficient, all the rest are constant. Stacking consists of 4 models: 
  - wy ~ 1 + igdp_log + (igdp_log|ctry_year) 
>>>>>>> 75cce9ce751f597ecfe02c1263f04a76d5541cbe
  - wy ~ 1 + igdp_log + ilit_log + iurban_log + (igdp_log|ctry_year)
  - wy ~ 1 + igdp_log + iwater_log + isewage_log + ielec_log +(igdp_log|ctry_year)
  - wy ~ 1 + igdp_log + ilit_log + iurban_log + iwater_log + isewage_log + ielec_log + (igdp_log|ctry_year)

<<<<<<< HEAD
- `shift_1950_stacking_year.csv`: shifts using data since 1950 with stacking adjusting for year (standardized variable). GDP is the only varying coefficient, all the rest are constant. Stacking consists of 4 models:
  - wy ~ 1 + igdp_log + zyear + (igdp_log|ctry_year)
  - wy ~ 1 + igdp_log + ilit_log + iurban_log + zyear + (igdp_log|ctry_year)
  - wy ~ 1 + igdp_log + iwater_log + isewage_log + ielec_log + zyear  +(igdp_log|ctry_year)
  - wy ~ 1 + igdp_log + ilit_log + iurban_log + iwater_log + isewage_log + ielec_log + zyear + (igdp_log|ctry_year)


# Cause of death

## No time adjustment
- `shift_cause_1970_gdponly.csv`: shift using available data with GDP as the only varying coefficient. Two groups: <1970 and >=1970.
    - y ~ 1 + igdp_log + (igdp_log|ctry_year)
- `shift_cause_1970_socieconomic.csv`: shift using available data with GDP and literacy and urbanicity. Two groups: <1970 and >=1970.
    - y ~ 1 + igdp_log + ilit_log + iurban_log + (igdp_log|ctry_year)
- `shift_cause_1970_sanitation.csv`: shift using available data with GDP and sanitation variables. Two groups: <1970 and >=1970.
    - y ~ 1 + igdp_log + iwater_log + isewage_log + ielec_log +(igdp_log|ctry_year)
- `shift_cause_1970_full.csv`: shift using available data with GDP and all socieconomic and sanitation variables. Two groups: <1970 and >=1970.
    - y ~ 1 + igdp_log + ilit_log + iurban_log + iwater_log + isewage_log + ielec_log + (igdp_log|ctry_year)

## Time adjustment

- `shift_cause_1970_gdponly_year.csv`: shift using available data with GDP as the only varying coefficient and adjusting for year. Two groups: <1970 and >=1970.
    - y ~ 1 + igdp_log + zyear + (igdp_log|ctry_year)
- `shift_cause_1970_socieconomic_year.csv`: shift using available data with GDP and literacy and urbanicity, adjusting for year. Two groups: <1970 and >=1970.
    - y ~ 1 + igdp_log + ilit_log + iurban_log + zyear + (igdp_log|ctry_year)
- `shift_cause_1970_sanitation_year.csv`: shift using available data with GDP and sanitation variables, adjusting for year. Two groups: <1970 and >=1970.
    - y ~ 1 + igdp_log + iwater_log + isewage_log + ielec_log + zyear + (igdp_log|ctry_year)
- `shift_cause_1970_full_year.csv`: shift using available data with GDP and all socieconomic and sanitation variables, adjusting for year. Two groups: <1970 and >=1970.
    - y ~ 1 + igdp_log + ilit_log + iurban_log + iwater_log + isewage_log + ielec_log + zyear +  (igdp_log|ctry_year)
=======
- `shift_1950_stacking_year.csv`: shifts using data since 1950 with stacking adjusting for year (standardized variable). GDP is the only varying coefficient, all the rest are constant. Stacking consists of 4 models: 
  - wy ~ 1 + igdp_log + zyear + (igdp_log|ctry_year) 
  - wy ~ 1 + igdp_log + ilit_log + iurban_log + zyear + (igdp_log|ctry_year)
  - wy ~ 1 + igdp_log + iwater_log + isewage_log + ielec_log zyear + +(igdp_log|ctry_year)
  - wy ~ 1 + igdp_log + ilit_log + iurban_log + iwater_log + isewage_log + ielec_log + zyear + (igdp_log|ctry_year)
>>>>>>> 75cce9ce751f597ecfe02c1263f04a76d5541cbe
