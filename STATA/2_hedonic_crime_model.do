* Obtain relevant descriptive statistics
* 1) Table of average prices by year
preserve
   collapse (mean) price, by(date)
   export excel using "C:\Users\HP\Downloads\Spatial-hedonics-crime\STATA\average tables", sheetmodify sheet("sheet1") cell(B2) firstrow(variables)
restore
sum price
* 2) Table of average crimes per year
preserve
   collapse (mean) tot_crimes, by(date)
   export excel using "C:\Users\HP\Downloads\Spatial-hedonics-crime\STATA\average tables", sheetmodify sheet("sheet2") cell(B2) firstrow(variables)
restore
* 3) Map of average prices by neighborhood
preserve
collapse (mean) price, by(id_neighborhood)
spmap price using "neighborhoods_coord.dta", id(id_neighborhood) fcolor(Blues) clmethod(quantile)
graph export "C:\Users\HP\Downloads\Spatial-hedonics-crime\STATA\price map.png", replace
restore
* 4) Map of average crime rates by neighborhood
preserve
collapse (mean) tot_crimes, by(id_neighborhood)
spmap tot_crimes using "neighborhoods_coord.dta", id(id_neighborhood) fcolor(Reds) clmethod(quantile)
graph export "C:\Users\HP\Downloads\Spatial-hedonics-crime\STATA\crime_map.png", replace 
restore

* Main econometric model
local structural = "accommodates bathrooms bedrooms beds i.(room_type)"
local control = "min_dist_uni tot_universities tot_establishments number_hospitals average_tfi"
xtreg lprice lcrimes `structural' `control' i.(date), re robust
outreg2 using "C:\Users\HP\Downloads\Spatial-hedonics-crime\STATA\modelo_principal.txt", replace

* Calculation of marginal and total cost
summarize price if e(sample)
local mean_price = r(mean)
summarize tot_crimes if e(sample)
local mean_crimes = r(mean)
matrix b = e(b)
local gamma = b[1,"lcrimes"]
display "Price elasticity of crime (gamma): " `gamma'
display "Marginal cost per percentage of crime: " (`gamma'/100*`mean_price')
display "Marginal cost per unit of crime: " (`gamma'*`mean_price'/`mean_crimes')
display "Total cost of prevention (per dwelling): " (`gamma'*`mean_price')

* Map of predicted prices
predict price_pred if e(sample), xb
preserve
collapse (mean) price_pred, by(id_neighborhood)
spmap price_pred using "neighborhoods_coord.dta", id(id_neighborhood) fcolor(Blues) clmethod(quantile)
restore

* Model with disaggregated offenses
local crimes = "lthreats lhomicides ltheft linjuries lrobbery ltraffic"
xtreg lprice `crimes' `structural' `control' i.(date), re robust
outreg2 using "C:\Users\HP\Downloads\Spatial-hedonics-crime\STATA\disaggregated_model.txt", replace

* Regression plot
twoway (scatter lprice lcrimes, mcolor(blue%50)) ///
       (lfit lprice lcrimes, lcolor(red)), ///
       title("Relationship between insecurity and rental prices") ///
       xtitle("ln(Crimes)") ytitle("ln(Price)")
	   
graph export "C:\Users\HP\Downloads\Spatial-hedonics-crime\STATA\graph_reg.png", replace 
