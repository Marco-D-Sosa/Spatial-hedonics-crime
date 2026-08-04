**********************************************************************
******                                                          ******
******   The Cost of the Insecurity in Ciudad de Buenos Aires   ******
******                    Diaz de Sosa, Marco                   ******
******                     De Barrio, Pedro                     ******
******                     Neyra Oré, Álvaro                    ******
******                     Neyra Oré, Renato                    ******
******                                                          ******
**********************************************************************

*ssc install geodist
*ssc install spmap
*ssc install outreg2

capture cd "C:\Users\HP\Downloads\Spatial-hedonics-crime"
use "caba_housing_crime_panel", clear

* Se prepara el dataset y crean las variables necesarias
run "1_hedonic_crime_model"

* Se obtienen estadidisticas y demas resultados
run "2_hedonic_crime_model"
