cd "C:/Users/Liyf/OneDrive/Desktop/金融学原理/stata"
clear
log using statalog, text replace
set more off
insheet using statadata.csv,clear
describe
sum
sum, d
sum mktrf
histogram gm
kdensity gm

ren  mktrf rm
gen rgm=gm-rf
gen rm2=sp500index-rf

gen rford=ford-rf
gen rtoyota=toyota-rf

reg rgm rm
reg rgm rm2

scatter rgm rm || lfit rgm rm, text(-7 -18 "rgm=-1.86+.928*rm" , box place(se) just(left) margin(l+4 t+1 b+1) width(35))

reg rgm rm  hml smb

// 生成空变量
gen id=_n
gen hm1=.
gen hm2=.
gen b1=.
gen b2=.
gen mm=.
local count=1	// 估值次数=样本数量

******** regressions ******************
foreach i in "rgm" "rford" "rtoyota" {
	sum `i'	// `表示引入一个变量，说明这是个变量而不是字符
	replace mm=r(mean) if id==`count'

	// reg=regression, 回归
	// 第一次回归，CAPM
	reg `i' rm
	replace b1=_b[rm] if id==`count'
	gen h`i'1=_b[rm]*rm
	dis "h`i':", h`i'1
	sum h`i'1
	replace hm1= r(mean) if id==`count'

	// 第二次回归，三因子
	reg `i' rm  hml smb
	replace b2=_b[rm] if id==`count'
	gen h`i'2=_b[rm]*rm+_b[hml]*hml+_b[smb]*smb
	sum h`i'2
	replace hm2= r(mean) if id==`count'

	local ++count
}

sum h*

// capm: 很差，斜率甚至是负的
scatter mm hm1 || lfit mm hm1 , saving(CAMPa, replace) 

scatter mm hm2 || lfit mm hm2 , saving(FF3a, replace) 

scatter mm b1 || lfit mm b1 , saving(CAMP, replace) 

scatter mm b2 || lfit mm b2, saving(FF3,  replace)

log close

