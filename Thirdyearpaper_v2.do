*** Third-Year Paper ***
*** Version 2: 2017.12.13 ***
*** For the Use of "Two-Children" Policy Paper ***
set more off
drop _all


** !!!If only focus on families with numkid<=1 in 2010 **
//Two ways to determine numkid2010
//(1) Match "adult_matched" data sets in 2010 and current year
* 2012 -- Already has info on numkid10

* 2014
use "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2010/cfps2010adult_matched.dta"
gen numkid10 = numkid
keep fid fpid mpid numkid10
merge 1:1 fid fpid mpid using "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2014/cfps2014.dta", nogen keep(match)
save "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2014/cfps2014_restricted1.dta", replace

* 2016
use "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2010/cfps2010adult_matched.dta"
gen numkid10 = numkid
keep fid fpid mpid numkid10
merge 1:1 fid fpid mpid using "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2016/cfps2016.dta", nogen keep(match)
save "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2016/cfps2016_restricted1.dta", replace

//(2) Use the information of the age of child to refer back to how many kids families had in 2010 -- then also child's age information must be available for the entire sample
* 2014
use "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2014/cfps2014_matched_full.dta"
bysort fid fpid mpid: gen olderthan4 = (age>=4 & age~=.)
bysort fid fpid mpid: gen numkid10 = sum(olderthan4)
bysort fid fpid mpid: egen age_oldest = max(age)
drop if age~=age_oldest
bysort fid fpid mpid: gen n = _N
drop if n>1
drop n
merge 1:1 fid fpid mpid using "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2014/cfps2014_expense.dta", nogen keep(1 3) //Observations with parents' and expenditure info only need to be dropped
save "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2014/cfps2014_restricted2.dta", replace

* 2016
use "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2016/cfps2016_matched_full.dta"
bysort fid fpid mpid: gen olderthan6 = (age>=6 & age~=.)
bysort fid fpid mpid: gen numkid10 = sum(olderthan6)
bysort fid fpid mpid: egen age_oldest = max(age)
drop if age~=age_oldest
bysort fid fpid mpid: gen n = _N
drop if n>1
drop n
merge 1:1 fid fpid mpid using "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2016/cfps2016_expense.dta", nogen keep(1 3) //Observations with parents' and expenditure info only need to be dropped
save "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2016/cfps2016_restricted2.dta", replace

//Combine (1) and (2)
* 2014
use "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2014/cfps2014_restricted1.dta"
merge 1:1 fid fpid mpid using "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2014/cfps2014_restricted2.dta", nogen
replace wave = 2014
save "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2014/cfps2014_restricted.dta", replace

*2016
use "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2016/cfps2016_restricted1.dta"
merge 1:1 fid fpid mpid using "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2016/cfps2016_restricted2.dta", nogen
replace wave = 2016
save "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2016/cfps2016_restricted.dta", replace

** Generate Restricted Full Sample
use "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2010/cfps2010.dta"
append using "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2012/cfps2012.dta"
append using "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2014/cfps2014_restricted.dta"
append using "/Users/Jianing/Desktop/Princeton/Datasets/CFPS/CFPS2016/cfps2016_restricted.dta"
save "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/cfps10121416_v2.dta", replace

* Construct Level Data
use "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/cfps10121416_v2.dta"
//Change the order of rankClass variable
gen RankClass = .
replace RankClass = 5 if rankClass==1 & wave~=2010
replace RankClass = 4 if rankClass==2 & wave~=2010
replace RankClass = 3 if rankClass==3 & wave~=2010
replace RankClass = 2 if rankClass==4 & wave~=2010
replace RankClass = 1 if rankClass==5 & wave~=2010
drop rankClass
rename RankClass rankClass
//Generate categorical class percentile (with Chinese and Math combined) in 2010 as in 2012/2014/2016
gen rankAve = (rankChinese+rankMath)/2 if wave==2010
replace rankClass = 5 if rankAve>0 & rankAve<=0.1 & wave==2010
replace rankClass = 4 if rankAve>0.1 & rankAve<=0.25 & wave==2010
replace rankClass = 3 if rankAve>0.25 & rankAve<=0.5 & wave==2010
replace rankClass = 2 if rankAve>0.5 & rankAve<=0.75 & wave==2010
replace rankClass = 1 if rankAve>0.75 & rankAve<=1 & wave==2010
label define rankClass 5 "Top 10%"  4 "11-25%" 3 "26-50%" 2 "51-75%" 1 "Bottom 24%", replace
label values rankClass rankClass
label var rankClass "Class Percentile"
//Separate household income into groups instead of leaving it as numerical levels
gen hhincome_l = .
label var hhincome_l "Household Wage Income Level"
if hhincome~=. {
replace hhincome_l = 1 if hhincome<=25000
replace hhincome_l = 2 if hhincome>25000 & hhincome<=40000
replace hhincome_l = 3 if hhincome>40000 & hhincome<=60000
replace hhincome_l = 4 if hhincome>60000 & hhincome<=90000
replace hhincome_l = 5 if hhincome>90000 & hhincome<=150000
replace hhincome_l = 6 if hhincome>150000
}
label define hhincome_l 1 "Below 25,000" 2 "25,000-40,000" 3 "40,000-60,000" 4 "60,000-90,000" 5 "90,000-150,000" 6 "Above 150,000", replace
label values hhincome_l hhincome_l
//Generate age groups for mothers
gen mage_gr = .
label var mage_gr "Mother's Age Group"
if mage~=. {
replace mage_gr = 1 if  mage<30
replace mage_gr = 2 if mage>=30 & mage<35
replace mage_gr = 3 if mage>=35 & mage<40
replace mage_gr = 4 if mage>=40 & mage<45
replace mage_gr = 5 if mage>=45 & mage<50
}
label define mage_gr 1 "Below 30" 2 "30-35" 3 "35-40" 4 "40-45" 5 "45-50", replace
label values mage_gr mage_gr

label var numkid "Number of Children"

gen relax14 = (wave>=2014)
label var relax14 "2014 Relaxation"
label define relax14 0 "Before 2014 Relaxation" 1 "2014 Relaxation"
label values relax14 relax14
gen relax16 = (wave>=2016)
label var relax16 "Complete Relaxation" 
label define relax16 0 "Before Complete Relaxation" 1 "Complete Relaxation"
label values relax16 relax16

gen wave12 = (wave==2012)
label var wave12 "2012 Survey"
label define wave12 0 "Not 2012 Survey" 1 "2012 Survey"
label values wave12 wave12
gen wave14 = (wave==2014)
label var wave14 "2014 Survey"
label define wave14 0 "Not 2014 Survey" 1 "2014 Survey"
label values wave14 wave14
gen wave16 = (wave==2016)
label var wave16 "2016 Survey"
label define wave16 0 "Not 2016 Survey" 1 "2016 Survey"
label values wave16 wave16

label var hhincome "Total Household Income"
label var totalexp "Total Household Expenditures"
label var consumable "Consumables"
label var food "Food"
label var dress "Clothing"
label var housing "Housing Expenses"
label var daily "Daily Commodities"
label var med "Medical Care"
label var leisure "Entertainment"

label var fage "Husband's Age"
label var mage "Wife's Age"
label var feduc "Husband's Education"
label var meduc "Wife's Education"
label var fhasjob "Husband's Employment"
label var mhasjob "Wife's Employment"

label var gender "Male"
label var careeduc "Care about Child's Education"
label var educexpense "Child's Education Expense"
label var metotal "Child's Medical Expense"
label var medins_child "Child's Medical Insurance"


save "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/cfps10121416_v2.dta", replace

/*
//Choices on Sample Selections
(1) Version 1
Sample: Married & Info on parents' siblings & mage<50
Control Group: (fsibling==0 & msibling==0) | urban==0 | numkid>=2
2014 Treatment Group: (fsibling==0 | msibling==0) & urban==1 & numkid<=1 & control==0
2016 Treatment Group: fsibling>0 & msibling>0 & urban==1 & numkid<=1

(2) Full
Sample: Married & Info on parents' siblings & mage<50
Control Group: (fsibling==0 & msibling==0) | urban==0 | numkid10>=2
2014 Treatment Group: (fsibling==0 | msibling==0) & urban==1 & numkid10<=1 & control==0
2016 Treatment Group: fsibling>0 & msibling>0 & urban==1 & numkid10<=1

(3) Urban
Sample: Urban & Married & Info on parents' siblings & mage<50
Control Group: (fsibling==0 & msibling==0) | numkid10>=2
2014 Treatment Group: (fsibling==0 | msibling==0) & numkid10<=1 & control==0
2016 Treatment Group: (fsibling>0 & msibling>0) & numkid10<=1

(4) Restricted & Urban
Sample: Urban & Married & numkid10<=1 & Info on parents' siblings & mage<50
Control Group: fsibling==0 & msibling==0
2014 Treatment Group: (fsibling==0 | msibling==0) & control==0
2016 Treatment Group: fsibling>0 & msibling>0
*/

use "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/cfps10121416_v2.dta"
//16848 observations
drop if fsibling==. | msibling==.
drop if provcd==65 | provcd==63 | provcd==46
keep if mage<50
** Full
//12905 observations
//Control Group
gen control = (fsibling==0 & msibling==0) | urban==0 | numkid10>=2
label var control "Control Group"
//2014 Treatment Group
gen treat14 = (fsibling==0 | msibling==0) & urban==1 & numkid10<=1 & control==0
label define treat14 0 "Control 2014" 1 "Treat 2014"
label values treat14 treat14
label var treat14 "2014 Treatment Group"
//2016 Treatment Group
gen treat16 = (fsibling>0 & msibling>0) & urban==1 & numkid10<=1
label define treat16 0 "Control 2016" 1 "Treat 2016"
label values treat16 treat16
label var treat16 "2016 Treatment Group"
save "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/cfps10121416_v2_full.dta", replace

** Urban
use "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/cfps10121416_v2.dta"
drop if fsibling==. | msibling==.
drop if provcd==65 | provcd==63 | provcd==46
keep if mage<50
keep if urban==1
//5674 observations
//Control Group
gen control = ((fsibling==0 & msibling==0) | numkid10>=2)
label var control "Control Group"
//2014 Treatment Group
gen treat14 = (fsibling==0 | msibling==0) & numkid10<=1 & control==0
label define treat14 0 "Control 2014" 1 "Treat 2014"
label values treat14 treat14
label var treat14 "2014 Treatment Group"
//2016 Treatment Group
gen treat16 = ((fsibling>0 & msibling>0) & numkid10<=1)
label define treat16 0 "Control 2016" 1 "Treat 2016"
label values treat16 treat16
label var treat16 "2016 Treatment Group"
save "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/cfps10121416_v2_urban.dta", replace

** Restricted & Urban
use "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/cfps10121416_v2.dta"
drop if fsibling==. | msibling==.
drop if provcd==65 | provcd==63 | provcd==46
keep if mage<50
keep if urban==1
keep if numkid10<=1
//3963 observations
//Control Group
gen control = (fsibling==0 & msibling==0)
label var control "Control Group"
//2014 Treatment Group
gen treat14 = (fsibling==0 | msibling==0) & control==0
label define treat14 0 "Control 2014" 1 "Treat 2014"
label values treat14 treat14
label var treat14 "2014 Treatment Group"
//2016 Treatment Group
gen treat16 = (fsibling>0 & msibling>0)
label define treat16 0 "Control 2016" 1 "Treat 2016"
label values treat16 treat16
label var treat16 "2016 Treatment Group"
save "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/cfps10121416_v2_restricted.dta", replace


** Potential Results using Different Sample Selections ** 
global samples "full restricted urban"
foreach sample in $samples {
drop _all
use "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/cfps10121416_v2_`sample'.dta"

bysort wave: gen obs = _N
label var obs "Observations"

** Generate summary statistics matrix ** 
estpost tabstat control treat14 treat16 urban numkid hhincome totalexp savings consumable ///
	food dress housing daily med trco leisure ///
	fage mage feduc fhasjob fhealth meduc mhasjob mhealth ///
	gender age schoolyr gradeChinese gradeMath rankClass careeduc communic positiveself happiness educexpense metotal medins_child ///
	obs, ///
	by(wave) s(mean sem)  column(statistics)
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/SummaryStats.tex", main(mean) aux(semean) pa nostar unstack noobs label replace

estpost tabstat control treat14 treat16 urban numkid hhincome totalexp savings consumable ///
	food dress housing daily med trco leisure ///
	fage mage feduc fhasjob fhealth meduc mhasjob mhealth ///
	gender age schoolyr gradeChinese gradeMath rankClass careeduc communic positiveself happiness educexpense metotal medins_child ///
	obs if control==1, ///
	by(wave) s(mean sem)  column(statistics)
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/SummaryStats_control.tex", main(mean) aux(semean) pa nostar unstack noobs label replace

estpost tabstat control treat14 treat16 urban numkid hhincome totalexp savings consumable ///
	food dress housing daily med trco leisure ///
	fage mage feduc fhasjob fhealth meduc mhasjob mhealth ///
	gender age schoolyr gradeChinese gradeMath rankClass careeduc communic positiveself happiness educexpense metotal medins_child ///
	obs if treat14==1, ///
	by(wave) s(mean sem)  column(statistics)
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/SummaryStats_treat14.tex", main(mean) aux(semean) pa nostar unstack noobs label replace

estpost tabstat control treat14 treat16 urban numkid hhincome totalexp savings consumable ///
	food dress housing daily med trco leisure ///
	fage mage feduc fhasjob fhealth meduc mhasjob mhealth ///
	gender age schoolyr gradeChinese gradeMath rankClass careeduc communic positiveself happiness educexpense metotal medins_child ///
	obs if treat16==1, ///
	by(wave) s(mean sem)  column(statistics)
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/SummaryStats_treat16.tex", main(mean) aux(semean) pa nostar unstack noobs label replace

drop obs
}

** Regressions **
** Produce output tables **
foreach sample in $samples {
** Expenditures
* Total expenditure
eststo clear
eststo: reg totalexp treat14##relax14 treat16##relax16 i.wave if urban==1, r
eststo: reg totalexp treat14##relax14 treat16##relax16 i.provcd i.wave if urban==1, r
eststo: reg totalexp treat14##relax14 treat16##relax16 i.provcd i.wave i.mage_gr if urban==1, r
eststo: reg totalexp treat14##relax14 treat16##relax16 i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg totalexp treat14##relax14 treat16##relax16 i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/Regression_totalexp.tex", ///
	replace label noomit keep(1.treat14#1.relax14 1.treat16#1.relax16) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap
	
eststo clear
eststo: reg totalexp treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16, r
eststo: reg totalexp treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd if urban==1, r
eststo: reg totalexp treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd i.mage_gr if urban==1, r
eststo: reg totalexp treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg totalexp treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/Regression_totalexp_extend.tex", ///
	replace label noomit keep(1.treat14#1.wave12 1.treat14#1.wave14 1.treat14#1.wave16 1.treat16#1.wave12 1.treat16#1.wave14 1.treat16#1.wave16) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap

* Consumables
global consume "consumable food dress housing daily med leisure"

foreach var in $consume {
eststo clear
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.wave if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/Regression_`var'.tex", ///
	replace label noomit keep(1.treat14#1.relax14 1.treat16#1.relax16 1.gender) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap

eststo clear
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.mage_gr if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/Regression_`var'_extend.tex", ///
	replace label noomit keep(1.treat14#1.wave12 1.treat14#1.wave14 1.treat14#1.wave16 1.treat16#1.wave12 1.treat16#1.wave14 1.treat16#1.wave16 1.gender) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap	
}


* Expenditures on first-born
global expfirst "educexpense metotal medins_child"
foreach var in $expfirst {
eststo clear
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.wave if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/Regression_`var'.tex", ///
	replace label noomit keep(1.treat14#1.relax14 1.treat16#1.relax16 1.gender) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap

eststo clear
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.mage_gr if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/Regression_`var'_extend.tex", ///
	replace label noomit keep(1.treat14#1.wave12 1.treat14#1.wave14 1.treat14#1.wave16 1.treat16#1.wave12 1.treat16#1.wave14 1.treat16#1.wave16 1.gender) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap	
}


** Savings
eststo clear
eststo: reg savings treat14##relax14 treat16##relax16 i.wave if urban==1, r
eststo: reg savings treat14##relax14 treat16##relax16 i.provcd i.wave if urban==1, r
eststo: reg savings treat14##relax14 treat16##relax16 i.provcd i.wave i.mage_gr if urban==1, r
eststo: reg savings treat14##relax14 treat16##relax16 i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg savings treat14##relax14 treat16##relax16 i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/Regression_savings.tex", ///
	replace label noomit keep(1.treat14#1.relax14 1.treat16#1.relax16) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap
	
eststo clear
eststo: reg savings treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16, r
eststo: reg savings treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd if urban==1, r
eststo: reg savings treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd i.mage_gr if urban==1, r
eststo: reg savings treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg savings treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/Regression_savings_extend.tex", ///
	replace label noomit keep(1.treat14#1.wave12 1.treat14#1.wave14 1.treat14#1.wave16 1.treat16#1.wave12 1.treat16#1.wave14 1.treat16#1.wave16) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap

	
** First-born outcomes
global educfirst "rankClass gradeChinese gradeMath"
foreach var in $educfirst {
eststo clear
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.wave if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/Regression_`var'.tex", ///
	replace label noomit keep(1.treat14#1.relax14 1.treat16#1.relax16 1.gender) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap

eststo clear
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.mage_gr if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/Regression_`var'_extend.tex", ///
	replace label noomit keep(1.treat14#1.wave12 1.treat14#1.wave14 1.treat14#1.wave16 1.treat16#1.wave12 1.treat16#1.wave14 1.treat16#1.wave16 1.gender) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap	
}

global psychfirst "positiveself happiness"
foreach var in $psychfirst {
eststo clear
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.wave if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/Regression_`var'.tex", ///
	replace label noomit keep(1.treat14#1.relax14 1.treat16#1.relax16 1.gender) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap

eststo clear
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.mage_gr if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/Regression_`var'_extend.tex", ///
	replace label noomit keep(1.treat14#1.wave12 1.treat14#1.wave14 1.treat14#1.wave16 1.treat16#1.wave12 1.treat16#1.wave14 1.treat16#1.wave16 1.gender) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap	
}

* Parents' Attention
global parentatt "careeduc communic"
foreach var in $parentatt {
eststo clear
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.wave if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/Regression_`var'.tex", ///
	replace label noomit keep(1.treat14#1.relax14 1.treat16#1.relax16 1.gender) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap

eststo clear
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.mage_gr if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/Regression_`var'_extend.tex", ///
	replace label noomit keep(1.treat14#1.wave12 1.treat14#1.wave14 1.treat14#1.wave16 1.treat16#1.wave12 1.treat16#1.wave14 1.treat16#1.wave16 1.gender) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap	
}

** Mother's employment status
eststo clear
eststo: reg totalexp treat14##relax14 treat16##relax16 i.wave if urban==1, r
eststo: reg totalexp treat14##relax14 treat16##relax16 i.provcd i.wave if urban==1, r
eststo: reg totalexp treat14##relax14 treat16##relax16 i.provcd i.wave i.mage_gr if urban==1, r
eststo: reg totalexp treat14##relax14 treat16##relax16 i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg totalexp treat14##relax14 treat16##relax16 i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/Regression_mhasjob.tex", ///
	replace label noomit keep(1.treat14#1.relax14 1.treat16#1.relax16) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap
	
eststo clear
eststo: reg totalexp treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16, r
eststo: reg totalexp treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd if urban==1, r
eststo: reg totalexp treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd i.mage_gr if urban==1, r
eststo: reg totalexp treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg totalexp treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/`sample'/Regression_mhasjob_extend.tex", ///
	replace label noomit keep(1.treat14#1.wave12 1.treat14#1.wave14 1.treat14#1.wave16 1.treat16#1.wave12 1.treat16#1.wave14 1.treat16#1.wave16) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap

}



** Produce Aggregate Regression Tables **
drop _all
use "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/cfps10121416_v2_full.dta"
* Household & Mother's Outcomes
global household "totalexp consumable savings food dress housing daily med leisure"
foreach var in $household {
eststo clear
eststo: reg `var' treat14##relax14 treat16##relax16 i.provcd i.wave if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.provcd i.wave i.mage_gr if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1 & numkid10<=1, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/Regression_`var'.tex", ///
	replace label noomit keep(1.treat14#1.relax14 1.treat16#1.relax16) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap

eststo clear
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd i.mage_gr if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1 & numkid10<=1, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/Regression_`var'_extend.tex", ///
	replace label noomit keep(1.treat14#1.wave12 1.treat14#1.wave14 1.treat14#1.wave16 1.treat16#1.wave12 1.treat16#1.wave14 1.treat16#1.wave16) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap
}

* Child's Outcomes
global child "educexpense metotal medins_child rankClass gradeChinese gradeMath positiveself happiness careeduc communic"
foreach var in $child {
eststo clear
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
eststo: reg `var' treat14##relax14 treat16##relax16 i.gender i.schoolyr i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1 & numkid10<=1, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/Regression_`var'.tex", ///
	replace label noomit keep(1.treat14#1.relax14 1.treat16#1.relax16) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap

eststo clear
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.mage_gr if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc, r
eststo: reg `var' treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.gender i.schoolyr i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.mhasjob i.meduc if urban==1 & numkid10<=1, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/Regression_`var'_extend.tex", ///
	replace label noomit keep(1.treat14#1.wave12 1.treat14#1.wave14 1.treat14#1.wave16 1.treat16#1.wave12 1.treat16#1.wave14 1.treat16#1.wave16) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap	
}

* Mother's Employment
eststo clear
eststo: reg mhasjob treat14##relax14 treat16##relax16 i.provcd i.wave if urban==1, r
eststo: reg mhasjob treat14##relax14 treat16##relax16 i.provcd i.wave i.mage_gr if urban==1, r
eststo: reg mhasjob treat14##relax14 treat16##relax16 i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.meduc if urban==1, r
eststo: reg mhasjob treat14##relax14 treat16##relax16 i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.meduc, r
eststo: reg mhasjob treat14##relax14 treat16##relax16 i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.meduc if urban==1 & numkid10<=1, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/Regression_mhasjob.tex", ///
	replace label noomit keep(1.treat14#1.relax14 1.treat16#1.relax16) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap

eststo clear
eststo: reg mhasjob treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd if urban==1, r
eststo: reg mhasjob treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd i.mage_gr if urban==1, r
eststo: reg mhasjob treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.meduc if urban==1, r
eststo: reg mhasjob treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.meduc, r
eststo: reg mhasjob treat14##wave12 treat14##wave14  treat14##wave16 treat16##wave12 treat16##wave14 treat16##wave16 i.provcd i.wave i.mage_gr i.hhincome_l i.fhasjob i.feduc i.meduc if urban==1 & numkid10<=1, r
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/Regression_mhasjob_extend.tex", ///
	replace label noomit keep(1.treat14#1.wave12 1.treat14#1.wave14 1.treat14#1.wave16 1.treat16#1.wave12 1.treat16#1.wave14 1.treat16#1.wave16) cells(b(star) se(par)) starl(* 0.10 ** 0.05 *** 0.01) wrap

	
** Summary Statistcs -- Treatment vs. Control Comparison
//Urban sample
use  "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/cfps10121416_v2_urban.dta"

bysort wave: gen obs = _N
label var obs "Observations"

eststo clear
eststo: estpost tabstat control treat14 treat16 urban numkid hhincome totalexp savings consumable ///
	food dress housing daily med trco leisure ///
	fage mage feduc fhasjob fhealth meduc mhasjob mhealth ///
	gender age schoolyr gradeChinese gradeMath rankClass careeduc communic positiveself happiness educexpense metotal medins_child ///
	obs if control==1, ///
	by(wave) s(mean sem)  column(statistics) nototal
eststo: estpost tabstat control treat14 treat16 urban numkid hhincome totalexp savings consumable ///
	food dress housing daily med trco leisure ///
	fage mage feduc fhasjob fhealth meduc mhasjob mhealth ///
	gender age schoolyr gradeChinese gradeMath rankClass careeduc communic positiveself happiness educexpense metotal medins_child ///
	obs if treat14==1, ///
	by(wave) s(mean sem)  column(statistics) nototal
eststo: estpost tabstat control treat14 treat16 urban numkid hhincome totalexp savings consumable ///
	food dress housing daily med trco leisure ///
	fage mage feduc fhasjob fhealth meduc mhasjob mhealth ///
	gender age schoolyr gradeChinese gradeMath rankClass careeduc communic positiveself happiness educexpense metotal medins_child ///
	obs if treat16==1, ///
	by(wave) s(mean sem)  column(statistics) nototal
esttab using "/Users/Jianing/Desktop/Princeton/Fall_2017/Third_year_Paper/StataOutput/v2/SummaryStats_comp.tex", main(mean) aux(semean) pa nostar unstack noobs label replace

** Figures **
bysort treat14 wave: egen avesavings = mean(totalexp) if treat14~=.
twoway scatter avesavings wave || connected avesavings wave if treat14==0, msymbol(circle) mlcolor(red) || ///
	connected avesavings wave if treat14==1, msymbol(circle) mlcolor(green) ||, xlabel(2010(2)2016)
