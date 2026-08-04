****************************
******** MONOGRAFIA ********
********** GRUPO9 **********
****************************
*ssc install geodist
*ssc install spmap
*ssc install outreg2

capture cd "D:\Escritorio\Eco. espacial y ambiental\Monografía"
capture cd "C:\Users\HP\Downloads\Monografia\Bases_datos"
capture cd "C:\Users\Alvaro de Jesus\Desktop\Economía Espacial y Ambiental\practica\Monografía final"
capture cd ""
use "bases_merge", clear

*establecemos los datos en panel
gen fecha_m = .
replace fecha_m = tm(2017m7) if fecha==6
replace fecha_m = tm(2018m1) if fecha==5
replace fecha_m = tm(2019m4) if fecha==1
replace fecha_m = tm(2023m12) if fecha==3
replace fecha_m = tm(2024m7) if fecha==7
replace fecha_m = tm(2024m8) if fecha==2
replace fecha_m = tm(2024m9) if fecha==10
replace fecha_m = tm(2024m10) if fecha==9
replace fecha_m = tm(2024m11) if fecha==8
replace fecha_m = tm(2024m12) if fecha==4
xtset id fecha_m

*Al no tener informacion sobre baños o habitaciones para algunos años particulares (principalmente los mas viejos), hacemos uso de los datos en panel (y suponemos que no se contruyeron baños o habitaciones adicionales de un periodo a otro) para completar la informacion
gsort id -fecha_m
bysort id (fecha_m): replace bathrooms = bathrooms[_n+1] if missing(bathrooms)
bysort id (fecha_m): replace bedrooms = bedrooms[_n-1] if missing(bedrooms)
bysort id (fecha_m): replace bedrooms = bedrooms[_n+1] if missing(bedrooms)
bysort id (fecha_m): replace bedrooms = bedrooms[_n-1] if missing(bedrooms)
sort id fecha_m

*Deflactamos los precios por IPC (dic-2016 = 100)
replace price = price*(100/113.8) if fecha_m==tm(2017m7)
replace price = price*(100/127.0) if fecha_m==tm(2018m1)
replace price = price*(100/213.1) if fecha_m==tm(2019m4)
replace price = price*(100/6607.7) if fecha_m==tm(2024m7)
replace price = price*(100/6883.4) if fecha_m==tm(2024m8)
replace price = price*(100/7122.2) if fecha_m==tm(2024m9)
replace price = price*(100/7314.0) if fecha_m==tm(2024m10)
replace price = price*(100/7491.4) if fecha_m==tm(2024m11)
replace price = price*(100/7694.0) if fecha_m==tm(2024m12)
*Y convertimos USD a ARS usando el tc promedio dic-2016
replace price = price*14.97 if currency=="USD"

*Lo mismo para ITF
replace PromedioITF = PromedioITF*(100/113.8) if fecha_m==tm(2017m7)
replace PromedioITF = PromedioITF*(100/127.0) if fecha_m==tm(2018m1)
replace PromedioITF = PromedioITF*(100/213.1) if fecha_m==tm(2019m4)
replace PromedioITF = PromedioITF*(100/3533.2) if fecha_m==tm(2023m12)
replace PromedioITF = PromedioITF*(100/6607.7) if fecha_m==tm(2024m7)
replace PromedioITF = PromedioITF*(100/6883.4) if fecha_m==tm(2024m8)
replace PromedioITF = PromedioITF*(100/7122.2) if fecha_m==tm(2024m9)
replace PromedioITF = PromedioITF*(100/7314.0) if fecha_m==tm(2024m10)
replace PromedioITF = PromedioITF*(100/7491.4) if fecha_m==tm(2024m11)
replace PromedioITF = PromedioITF*(100/7694.0) if fecha_m==tm(2024m12)

*aplicamos logaritmo a algunas variables
gen lprice = ln(price)
gen ldelitos = ln(tot_delitos)
gen lamenazas = ln(tot_amenazas)
gen lhomicidios = ln(tot_homicidios)
gen lhurto = ln(tot_hurto)
gen llesiones = ln(tot_lesiones)
gen lrobo = ln(tot_robo)
gen lvialidad = ln(tot_vialidad)

*Obtenemos estadisticas descriptivas relevantes
*1) tabla de precios promedio por año
preserve
   collapse (mean) price, by(fecha)
   export excel using "C:\Users\HP\Downloads\Monografia\Bases_datos\Graficos y tablas\tablas promedio", sheetmodify sheet("sheet1") cell(B2) firstrow(variables)
restore
sum price
*2) tabla de delitos promedio por año
preserve
   collapse (mean) tot_delitos, by(fecha)
   export excel using "C:\Users\HP\Downloads\Monografia\Bases_datos\Graficos y tablas\tablas promedio", sheetmodify sheet("sheet2") cell(B2) firstrow(variables)
restore
*3) mapa de precio promedio por barrio
preserve
collapse (mean) price, by(barrio)
merge m:1 barrio using barrio_db.dta
spmap price using barrios_coord.dta, id(id) fcolor(Blues) clmethod(quantile)
graph export "C:\Users\HP\Downloads\Monografia\Bases_datos\Graficos y tablas\mapa_precios.png", replace 
restore
*4) mapa de delitos promedio por barrio
preserve
collapse (mean) tot_delitos, by(barrio)
merge m:1 barrio using barrio_db.dta
spmap tot_delitos using barrios_coord.dta, id(id) fcolor(Reds) clmethod(quantile)
graph export "C:\Users\HP\Downloads\Monografia\Bases_datos\Graficos y tablas\mapa_delitos.png", replace 
restore

*Modelo econometrico principal
local estructural = "accommodates bathrooms bedrooms beds i.(room)"
local control = "dist_min_uni total_universidades total_establecimientos cantidad_hospitales PromedioITF"
xtreg lprice ldelitos `estructural' `control' i.(fecha), re robust
outreg2 using "C:\Users\HP\Downloads\Monografia\Bases_datos\Graficos y tablas\modelo_principal.txt", replace

* calculo de costo marginal y total
summarize price if e(sample)
local mean_price = r(mean)
summarize tot_delitos if e(sample)
local mean_delitos = r(mean)
matrix b = e(b)
local gamma = b[1,"ldelitos"]
display "Elasticidad precio-delitos (gamma): " `gamma'
display "Costo marginal por % de delito: " (`gamma'/100*`mean_price')
display "Costo marginal por unidad de delito: " (`gamma'*`mean_price'/`mean_delitos')
display "Costo total de la prevención (por vivienda): " (`gamma'*`mean_price')

*Mapa de precios predichos
predict precio_pred if e(sample), xb
preserve
collapse (mean) precio_pred, by(barrio)
merge m:1 barrio using barrio_db.dta
spmap precio_pred using barrios_coord.dta, id(id) fcolor(Blues) clmethod(quantile)
restore

*Modelo con delitos desagregados
local delitos = "lamenazas lhomicidios lhurto llesiones lrobo lvialidad"
xtreg lprice `delitos' `estructural' `control' i.(fecha), re robust
outreg2 using "C:\Users\HP\Downloads\Monografia\Bases_datos\Graficos y tablas\modelo_desagregado.txt", replace

*Grafico de la regresion
twoway (scatter lprice ldelitos, mcolor(blue%50)) ///
       (lfit lprice ldelitos, lcolor(red)), ///
       title("Relación entre inseguridad y precio de alquiler") ///
       xtitle("ln(Delitos)") ytitle("ln(Precio)")
	   
graph export "C:\Users\HP\Downloads\Monografia\Bases_datos\Graficos y tablas\graph_reg.png", replace 
