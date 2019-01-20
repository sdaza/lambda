program define bs_assessment
set more off

/*this do file assesses variability of 
predicted values when we use bootstrap.
There are 100 bootstrap and for each one
of them we use 400 Bayesian simulations
to get a predicted value. 
We do the same with shift_pred, the values
of shifts in predicted values for a year
when using different segments
Because we use two methods to do the bootstrap
there are two files we can run this program on:
	bs_shift_1900.dta uses a bootrastp where the draw of estimates
	is proportional to their probability of being accurate

	bs_shift_1900_uniform.dta uses a bootstrap where the draw
	of estimates follows a uniform distribution: each one has
	the same prob of being drawn

to run program issue following command
bs_assessment `1' where `1' is the name of the file...!!!!!make sure you type the .dta part of the file name as well!!!!!!

####Because Paraguay and Ecuador do not have a segment for 1950, we must use the segment 1950-1969 in lieu of segment 1950###

*/


use `1'
local s=1

if "`1'"=="bs_shift_1900_uniform.dta"{
local s=2
}
else{
}


local count=0
foreach name in "Argentina" "Bolivia" "Brazil" "Chile" "Colombia" "Costa_Rica" "Cuba" "Dominican_Republic" "Ecuador" "El_Salvador" "Guatemala" "Honduras" "Mexico" "Nicaragua" "Panama" "Paraguay" "Peru" "Uruguay" "Venezuela"  {

/*
we only keep segment 1950-1969 for Ecuador and Paraguay and segment
1950 for all other countries. This segment is the benchmark we will use
throughout to evaluate shifts
*/

preserve
keep if ctry=="`name'" 

if ctry=="Ecuador" {
keep if segment=="1950-1969"
}
else if ctry=="Paraguay" {
keep if segment=="1950-1969"
}
else {
keep if segment=="1950"
}

local count=`count'+1

sort year sample_index
gen ave_pred_`s'=.
gen sd_pred_`s'=.
gen N_pred_`s'=.
gen ave_dev_`s'=.
gen sd_dev_`s'=.

by year sample_index:replace pred=. if pred==0
by year sample_index:replace ave_pred_`s'=sum(pred)/_N
by year sample_index:replace ave_pred_`s'=ave_pred_`s'[_N] 
by year sample_index:replace sd_pred_`s'=sum((pred-ave_pred_`s')^2)/_N
by year sample_index:replace sd_pred_`s'=sqrt(sd_pred_`s'[_N])

by year sample_index:replace ave_dev_`s'=sum(abs((obs-pred)/obs)/_N)
by year sample_index:replace ave_dev_`s'=ave_dev_`s'[_N] 
by year sample_index:replace sd_dev_`s'=sum((abs((obs-pred)/pred)-ave_dev_`s')^2/_N)
by year sample_index:replace sd_dev_`s'=sqrt(sd_dev_`s'[_N])

by year sample_index:replace N_pred_`s'=_N

sort year sample_index
gen ave_shift_pred_`s'=.
gen sd_shift_pred_`s'=.
gen ave_shift_obs_`s'=.
gen sd_shift_obs_`s'=.

gen N_shift_pred_`s'=.
gen N_shift_obs_`s'=.

by year sample_index:replace shift_pred=. if shift_pred==0
by year sample_index:replace ave_shift_pred_`s'=sum(shift_pred)/_N 
by year sample_index:replace ave_shift_pred_`s'=ave_shift_pred_`s'[_N]  
by year sample_index:replace sd_shift_pred_`s'=sum((shift_pred-ave_shift_pred_`s')^2)/_N 
by year sample_index:replace sd_shift_pred_`s'=sqrt(sd_shift_pred_`s'[_N]) 
by year sample_index:replace N_shift_pred_`s'=_N 

by year sample_index:replace shift_obs=. if shift_obs==0
by year sample_index:replace ave_shift_obs_`s'=sum(shift_obs)/_N 
by year sample_index:replace ave_shift_obs_`s'=ave_shift_obs_`s'[_N]  
by year sample_index:replace sd_shift_obs_`s'=sum((shift_obs-ave_shift_obs_`s')^2)/_N 
by year sample_index:replace sd_shift_obs_`s'=sqrt(sd_shift_obs_`s'[_N]) 

by year sample_index:replace N_shift_obs_`s'=_N 

by year sample_index : keep if _n==_N
save `count'_bs_assessment.dta, replace
restore

}
use 1_bs_assessment.dta
forvalues h=2/19 {
append using `h'_bs_assessment
}
sort ctry year sample_index
save bs_assessment_`s'_ALL.dta, replace
/*!del *_bs_assessment.dta*/

end
