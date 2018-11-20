*******
*
* CAPM on CHINESE 000001 SSE COMPOSITE
* Auth: Yifei Li
*
*******

clear
*** NOTE: use your own project path to fill in following `base_dir' ***
global base_dir = "~"
local name = "2008-2018"

cd $base_dir
log using "./log/cn_`name'", text replace
set more off

insheet using "./data/cn/`name'.csv", clear


describe
sum

// Rm: market portfolio
ren idxmonret Rm

*** start ***
gen id=_n
gen beta_a = .

gen eer = .
gen er = .

local cnt = 0
forvalues size = 1/5 {
	forvalues book = 1/5 {
		local ++cnt
		
		// use Ri represent ret
		ren s`size'b`book' R`cnt'
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
scatter er eer || lfit er eer, range(-0.003 0) || function y=x, range(-0.005 0.02) , ///
xlabel(-0.005(0.005) 0.02) , ylabel(-0.005(0.005) 0.02) , ///
title("CAPM_cn_`name'") , legend(order(1 2) label(1 "ER")) , ///
saving(./fig/CAPM_cn_`name'.gph, replace)

*** quation c) ***
sum Rm beta_a
scatter er beta_a || lfit er beta_a, range(0 1.2) , ///
xlabel(-0.05(0.25) 1.2) , ylabel(-0.05(0.25) 1.2) , ///
title("SML_cn_`name'") , legend(label(1 "ER")) , ///
saving(./fig/SML_cn_`name'.gph, replace) ///

log close

