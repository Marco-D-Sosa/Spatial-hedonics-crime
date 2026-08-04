

*Obtenemos estadisticas descriptivas relevantes
*1) tabla de precios promedio por año
preserve
   collapse (mean) price, by(date)
   export excel using "C:\Users\HP\Downloads\Monografia\Bases_datos\Graficos y tablas\tablas promedio", sheetmodify sheet("sheet1") cell(B2) firstrow(variables)
restore
sum price
*2) tabla de delitos promedio por año
preserve
   collapse (mean) tot_crimes, by(date)
   export excel using "C:\Users\HP\Downloads\Monografia\Bases_datos\Graficos y tablas\tablas promedio", sheetmodify sheet("sheet2") cell(B2) firstrow(variables)
restore
*3) mapa de precio promedio por barrio
preserve
collapse (mean) price, by(neighbor)
merge m:1 neighbor using neighbor_db.dta
spmap price using neighbors_coord.dta, id(id) fcolor(Blues) clmethod(quantile)
graph export "C:\Users\HP\Downloads\Monografia\Bases_datos\Graficos y tablas\mapa_precios.png", replace 
restore
*4) mapa de delitos promedio por barrio
preserve
collapse (mean) tot_crimes, by(neighbor)
merge m:1 neighbor using neighbor_db.dta
spmap tot_crimes using neighbors_coord.dta, id(id) fcolor(Reds) clmethod(quantile)
graph export "C:\Users\HP\Downloads\Monografia\Bases_datos\Graficos y tablas\mapa_delitos.png", replace 
restore

*Modelo econometrico principal
local estructural = "accommodates bathrooms bedrooms beds i.(room_type)"
local control = "dist_min_uni total_universidades total_establecimientos cantidad_hospitales average_tfi"
xtreg lprice lcrimes `estructural' `control' i.(date), re robust
outreg2 using "C:\Users\HP\Downloads\Monografia\Bases_datos\Graficos y tablas\modelo_principal.txt", replace

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
collapse (mean) precio_pred, by(neighbor)
merge m:1 neighbor using neighbor_db.dta
spmap precio_pred using neighbors_coord.dta, id(id) fcolor(Blues) clmethod(quantile)
restore

*Modelo con delitos desagregados
local delitos = "lthreats lhomicides ltheft linjuries lrobbery ltraffic"
xtreg lprice `delitos' `estructural' `control' i.(date), re robust
outreg2 using "C:\Users\HP\Downloads\Monografia\Bases_datos\Graficos y tablas\modelo_desagregado.txt", replace

*Grafico de la regresion
twoway (scatter lprice lcrimes, mcolor(blue%50)) ///
       (lfit lprice lcrimes, lcolor(red)), ///
       title("Relación entre inseguridad y precio de alquiler") ///
       xtitle("ln(Delitos)") ytitle("ln(Precio)")
	   
graph export "C:\Users\HP\Downloads\Monografia\Bases_datos\Graficos y tablas\graph_reg.png", replace 
