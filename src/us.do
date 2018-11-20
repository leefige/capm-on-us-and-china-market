*******
*
* CAPM, FF-3 & FF-5 on US DATA
* Auth: Yifei Li
*
*******

clear
*** NOTE: use your own project path to fill in following `base_dir' ***
global base_dir = "~"
local name = "1963-1984"

cd $base_dir
log using "./log/us_`name'", text replace
set more off

insheet using "./data/us/`name'.csv", clear


describe
sum

// use Ri represent Ri - rf
ren mktrf Rm

*** rename portfolios for normalization ***
ren smalllobm me1bm1
ren smallhibm me1bm5
ren biglobm me5bm1
ren bighibm me5bm5

*** start ***
gen id=_n
gen beta_a = .

gen eer = .
gen er = .

local cnt = 0
forvalues size = 1/5 {
	forvalues book = 1/5 {
		local ++cnt
		
		// use Ri represent Ri - rf
		gen R`cnt' = me`size'bm`book' - rf
		sum R`cnt'
		replace er = r(mean) if id == `cnt'		// record mean of actual ER_i
		
		*** quation a) ***
		reg R`cnt' Rm	// get regression of Ri ~ Rm
		replace beta_a = _b[Rm] if id == `cnt'
		
		*** question b), now that we've got beta_i ***
		gen h`cnt' = _b[Rm] * Rm
		sum h`cnt'
		replace eer = r(mean) if id ==`cnt'		// record mean of expected EER_i
	}
}

dis "For question a), betas are:"
sum beta_a, d

dis "For question b), graph:"
sum er, d
sum eer, d
scatter er eer || lfit er eer || function y=x, range(-0.5 2) , ///
xlabel(-0.5(0.5) 2) , ylabel(-0.5(0.5) 2) , ///
title("CAPM_us_`name'") , legend(order(1 2) label(1 "ER")) , ///
saving(./fig/CAPM_us_`name'.gph, replace)

*** quation c) ***
sum Rm beta_a
scatter er beta_a || lfit er beta_a, range(0 2) , ///
xlabel(-0.5(0.5) 2) , ylabel(-0.5(0.5) 2) , ///
title("SML_us_`name'") , legend(label(1 "ER")) , ///
saving(./fig/SML_us_`name'.gph, replace) ///

***********************************************************************

*** question f) 3-factor ***
gen beta_3_rm = .
gen beta_3_smb = .
gen beta_3_hml = .
gen eer_ff3 = .

forvalues i = 1/25 {
	reg R`i' Rm smb hml		// get regression of Ri ~ (Rm smb hml)
	replace beta_3_rm = _b[Rm] if id == `i'
	replace beta_3_smb = _b[smb] if id == `i'
	replace beta_3_hml = _b[hml] if id == `i'
	
	*** question b), now that we've got beta_i ***
	gen h`i'_3 = _b[Rm] * Rm + _b[smb] * smb + _b[hml] * hml
	sum h`i'_3
	replace eer_ff3 = r(mean) if id ==`i'		// record mean of expected EER_i
}

sum eer_ff3, d
scatter er eer_ff3 || lfit er eer_ff3 || function y=x, range(-0.5 1.7) , ///
xlabel(-0.5(0.5) 1.7) , ylabel(-0.5(0.5) 1.7) , ///
title("FF3_us_`name'") , legend(order(1 2) label(1 "ER")) , ///
saving(./fig/FF3_us_`name'.gph, replace)

*** question g) 5-factor ***
gen beta_5_rm = .
gen beta_5_smb = .
gen beta_5_hml = .
gen beta_5_rmw = .
gen beta_5_cma = .
gen eer_ff5 = .

forvalues i = 1/25 {
	reg R`i' Rm smb hml rmw cma		// get regression of Ri ~ (Rm smb hml rmw cma)
	replace beta_5_rm = _b[Rm] if id == `i'
	replace beta_5_smb = _b[smb] if id == `i'
	replace beta_5_hml = _b[hml] if id == `i'
	replace beta_5_rmw = _b[rmw] if id == `i'
	replace beta_5_cma = _b[cma] if id == `i'
	
	*** question b), now that we've got beta_i ***
	gen h`i'_5 = _b[Rm] * Rm + _b[smb] * smb + _b[hml] * hml + ///
					_b[rmw] * rmw + _b[cma] * cma
	sum h`i'_5
	replace eer_ff5 = r(mean) if id ==`i'		// record mean of expected EER_i
}

sum eer_ff5, d
scatter er eer_ff5 || lfit er eer_ff5 || function y=x, range(-0.5 1.7) , ///
xlabel(-0.5(0.5) 1.7) , ylabel(-0.5(0.5) 1.7) , ///
title("FF5_us_`name'") , legend(order(1 2) label(1 "ER")) , ///
saving(./fig/FF5_us_`name'.gph, replace)

log close

