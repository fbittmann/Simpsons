

*Felix Bittmann
*2020




clear
*ssc install fre, replace


import delimited "ratingsadded.csv"


rename v1 title
rename v2 number
rename v3 season
rename v4 url
rename v5 t9
rename v6 t8
rename v7 t7
rename v8 t6
rename v9 t5
rename v10 t4
rename v11 t3
rename v12 t2
rename v13 t1
rename v14 t0
rename v15 total


*Gen Season ID*
bysort season: gen season_number = _n


*Check for errors*
duplicates report t9 - t0
assert r(unique_value) == r(N)


*Delete zeroes*
// foreach VAR of varlist t9 - t0 {
// 	replace `VAR' = 1 if `VAR' == 0
// }

********************************************************************************

***Bootstrap Means for Each Episode ***
set seed 98234
tempname z
postfile `z' str88 title number season season_number meanval lower upper n using ciresults, replace

local casenumbers = _N
foreach NUM of numlist 1 / `casenumbers' {
	display "##################################################################"
	display "Current episode: `NUM'"
	preserve
	keep in `NUM'
	tempfile tempdata`NUM'
	
	sum total
	local a = r(mean) + 1
	set obs `a'

	gen str10 temp = ""


	local val = 2
	foreach VAR of varlist t9 - t0 {
		quiet sum `VAR', meanonly
		local r = r(mean)
		if `r' == 0 {
			continue
		}
		quiet codebook `VAR'
		local name = r(cons)
		local ratingcat = substr("`name'", 2, 1)
		local endval = `val' + `r' - 1
		replace temp = "`ratingcat'" in `val'/`endval'
		local val = `val' + `r'
	}



	destring temp, gen(rating)
	drop temp
	replace rating = rating + 1
	label var rating "IMDB Episode Rating"
	fre rating



	*histogram rating, disc

	*graph box rating
	quiet sum rating
	assert r(N) > 800
	
	save `tempdata`NUM'', replace
	quiet bootstrap r(mean), reps(1800) bca nodots: sum rating if !missing(rating), meanonly
	estat bootstrap, bca

	matrix test1 = e(b)
	local meanval = test1[1, 1]
	matrix cis = e(ci_bca)
	local lower = cis[1, 1]
	local upper = cis[2, 1]


	local x1 = number in 1
	local x2 = season in 1
	local x3 = season_number in 1
	local tit = title in 1

	post `z' ("`tit'") (`x1') (`x2') (`x3') (`meanval') (`lower') (`upper') (e(N))
	restore
}
postclose `z'


***Generate File with all ratings and episodes***
use `tempdata1', clear
foreach NUM of numlist 2 / `casenumbers' {
	append using `tempdata`NUM''
}

foreach VAR of varlist title number season season_number {
	replace `VAR' = `VAR'[_n-1] if missing(`VAR') & !missing(`VAR'[_n-1])
}

label var number "Episode Number"
compress
save "alldata", replace


