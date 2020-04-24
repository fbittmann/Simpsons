


*Felix Bittmann
*2020

use "alldata.dta", clear


set seed 98234
tempname z
postfile `z' season meanval lower upper using season_ci, replace

foreach NUM of numlist 1/20 {
	quiet bootstrap r(mean), reps(600) bca: sum rating if season == `NUM' & !missing(rating), meanonly
	estat bootstrap, bca
	
	matrix test1 = e(b)
	local meanval = test1[1, 1]
	matrix cis = e(ci_bca)
	local lower = cis[1, 1]
	local upper = cis[2, 1]
	post `z' (`NUM') (`meanval') (`lower') (`upper')
}
postclose `z'

********************************************************************************

use "season_ci", clear
label var season "Season"
label var meanval "Rating"

twoway (scatter meanval season) ///
	(rcap lower upper season), legend(off) ytitle("Rating") ///
	note("IMDB Average Rating including 95% Bootstrap CI")
