
# Description of output files

## GDP only models

- `shift_1900_gdponly.csv`: shifts using data since 1900 with GDP as the only varying coefficient. See notebook for more details.
- `shift_1900_gdponly_year.csv`: shifts using data since 1900 with GPD and year (standardized variable) as the only covariates. See notebooks for more details.
- `shift_1900_gdponly_autocorrelation.csv`: shifts using data since 1900 with GPD as only varying coefficient and autocorrelation adjustment (one lag of LE variable). See notebooks for more details. 

## Stacking

- `shift_1900_stacking.csv`: shifts using data since 1900 with stacking. GDP is the only varying coefficient, all the rest are constant. Stacking consists of 4 models: 
  - wy ~ 1 + igdp_log + (igdp_log|ctry_year) 
  - wy ~ 1 + igdp_log  + iurban_log +  (igdp_log|ctry_year)
  - wy ~ 1 + igdp_log  + ilit_log +  (igdp_log|ctry_year)
  - wy ~ 1 + igdp_log + ilit_log + iurban_log + (igdp_log|ctry_year) 
  Most of weight (97%) goes to the last model. 
