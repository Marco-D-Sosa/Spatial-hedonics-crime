


*establecemos los datos en panel
gen date_m = .
replace date_m = tm(2017m7) if date==6
replace date_m = tm(2018m1) if date==5
replace date_m = tm(2019m4) if date==1
replace date_m = tm(2023m12) if date==3
replace date_m = tm(2024m7) if date==7
replace date_m = tm(2024m8) if date==2
replace date_m = tm(2024m9) if date==10
replace date_m = tm(2024m10) if date==9
replace date_m = tm(2024m11) if date==8
replace date_m = tm(2024m12) if date==4
xtset id date_m

*Al no tener informacion sobre baños o habitaciones para algunos años particulares (principalmente los mas viejos), hacemos uso de los datos en panel (y suponemos que no se contruyeron baños o habitaciones adicionales de un periodo a otro) para completar la informacion
gsort id -date_m
bysort id (date_m): replace bathrooms = bathrooms[_n+1] if missing(bathrooms)
bysort id (date_m): replace bedrooms = bedrooms[_n-1] if missing(bedrooms)
bysort id (date_m): replace bedrooms = bedrooms[_n+1] if missing(bedrooms)
bysort id (date_m): replace bedrooms = bedrooms[_n-1] if missing(bedrooms)
sort id date_m

*Deflactamos los precios por IPC (dic-2016 = 100)
replace price = price*(100/113.8) if date_m==tm(2017m7)
replace price = price*(100/127.0) if date_m==tm(2018m1)
replace price = price*(100/213.1) if date_m==tm(2019m4)
replace price = price*(100/6607.7) if date_m==tm(2024m7)
replace price = price*(100/6883.4) if date_m==tm(2024m8)
replace price = price*(100/7122.2) if date_m==tm(2024m9)
replace price = price*(100/7314.0) if date_m==tm(2024m10)
replace price = price*(100/7491.4) if date_m==tm(2024m11)
replace price = price*(100/7694.0) if date_m==tm(2024m12)
*Y convertimos USD a ARS usando el tc promedio dic-2016
replace price = price*14.97 if currency=="USD"

*Lo mismo para ITF
replace average_tfi = average_tfi*(100/113.8) if date_m==tm(2017m7)
replace average_tfi = average_tfi*(100/127.0) if date_m==tm(2018m1)
replace average_tfi = average_tfi*(100/213.1) if date_m==tm(2019m4)
replace average_tfi = average_tfi*(100/3533.2) if date_m==tm(2023m12)
replace average_tfi = average_tfi*(100/6607.7) if date_m==tm(2024m7)
replace average_tfi = average_tfi*(100/6883.4) if date_m==tm(2024m8)
replace average_tfi = average_tfi*(100/7122.2) if date_m==tm(2024m9)
replace average_tfi = average_tfi*(100/7314.0) if date_m==tm(2024m10)
replace average_tfi = average_tfi*(100/7491.4) if date_m==tm(2024m11)
replace average_tfi = average_tfi*(100/7694.0) if date_m==tm(2024m12)

*aplicamos logaritmo a algunas variables
gen lprice = ln(price)
gen lcrimes = ln(tot_crimes)
gen lthreats = ln(tot_threats)
gen lhomicides = ln(tot_homicides)
gen ltheft = ln(theft)
gen linjuries = ln(tot_injuries)
gen lrobbery = ln(tot_robbery)
gen ltraffic = ln(tot_traffic)
