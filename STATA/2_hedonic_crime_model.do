
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
graph export "C:\Users\HP\Downloads\Spatial-hedonics-crime\STATA\mapa_precios.png", replace
restore
*4) mapa de delitos promedio por barrio
preserve
collapse (mean) tot_crimes, by(id_neighborhood)
spmap tot_crimes using "neighborhoods_coord.dta", id(id_neighborhood) fcolor(Reds) clmethod(quantile)
graph export "C:\Users\HP\Downloads\Spatial-hedonics-crime\STATA\mapa_delitos.png", replace 
restore

*Modelo econometrico principal
local estructural = "accommodates bathrooms bedrooms beds i.(room_type)"
local control = "min_dist_uni total_universidades total_establecimientos cantidad_hospitales average_tfi"
xtreg lprice lcrimes `estructural' `control' i.(date), re robust
outreg2 using "C:\Users\HP\Downloads\Spatial-hedonics-crime\STATA\modelo_principal.txt", replace

* calculo de costo marginal y total
summarize price if e(sample)
local mean_price = r(mean)
summarize tot_crimes if e(sample)
local mean_delitos = r(mean)
matrix b = e(b)
local gamma = b[1,"lcrimes"]
display "Elasticidad precio-delitos (gamma): " `gamma'
display "Costo marginal por % de delito: " (`gamma'/100*`mean_price')
display "Costo marginal por unidad de delito: " (`gamma'*`mean_price'/`mean_delitos')
display "Costo total de la prevención (por vivienda): " (`gamma'*`mean_price')

*Mapa de precios predichos
predict precio_pred if e(sample), xb
preserve
collapse (mean) precio_pred, by(neighborhood)
spmap precio_pred using "neighborhoods_coord.dta", id(id) fcolor(Blues) clmethod(quantile)
restore

*Modelo con delitos desagregados
local delitos = "lthreats lhomicides ltheft linjuries lrobbery ltraffic"
xtreg lprice `delitos' `estructural' `control' i.(date), re robust
outreg2 using "C:\Users\HP\Downloads\Spatial-hedonics-crime\STATA\modelo_desagregado.txt", replace

*Grafico de la regresion
twoway (scatter lprice lcrimes, mcolor(blue%50)) ///
       (lfit lprice lcrimes, lcolor(red)), ///
       title("Relación entre inseguridad y precio de alquiler") ///
       xtitle("ln(Delitos)") ytitle("ln(Precio)")
	   
graph export "C:\Users\HP\Downloads\Spatial-hedonics-crime\STATA\graph_reg.png", replace 
