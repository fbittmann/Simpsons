

*Felix Bittmann
*2020

use "ciresults", clear
label var number "Episode Number"


*** All Episodes ***
preserve
gen group = mod(season, 2)
twoway (scatter meanval number if group == 0, mcolor(red)) ///
	(scatter meanval number if group == 1, mcolor(black)) ///
	(rcap lower upper number), legend(off) ytitle("Rating") ///
	xsize(30) ysize(8) note("IMDB Average (Raw) Rating including 95% Bootstrap CI") ///
	xlabel(0(20)441)
restore


	
*** Best Episodes Ever ***
preserve
gsort -meanval
gen rank = _n
label var rank "Rank"
local limit = 20
local limitplus = `limit' + 1
twoway (scatter meanval rank in 1/`limit', mlabel(title) mlabangle(33) ///
	mlabgap(1.2cm) mlabpos(12) mlabsize(tiny)) ///
	(rcap lower upper rank in 1/`limit'), legend(off) ytitle("Rating") xlabel(1(1)`limit') ///
	xscale(range(0/`limitplus')) note("IMDB Average (Raw) Rating including 95% Bootstrap CI")
restore	


*** Boxplots for Seasons ***
graph box meanval, over(season) ytitle("Rating") noout ///
	note("Outliers not depicted")




***Histogramme fuer alle Seasons***
use alldata, clear

foreach NUM of numlist 1/20 {
	quiet sum rating if season == `NUM'
	local meanval = r(mean)
	histogram rating if season == `NUM', disc name(g`NUM', replace) ///
	xtitle("") ytitle("") title("Season `NUM'") xline(`meanval') nodraw
}

graph combine g1 g2 g3 g4 g5 g6 g7 g8 g9 g10 ///
	g11 g12 g13 g14 g15 g16 g17 g18 g19 g20
