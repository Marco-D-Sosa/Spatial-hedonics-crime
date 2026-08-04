**********************************************************************
******                                                          ******
******   The Cost of the Insecurity in Ciudad de Buenos Aires   ******
******                    Diaz de Sosa, Marco                   ******
******                     De Barrio, Pedro                     ******
******                     Neyra Oré, Álvaro                    ******
******                     Neyra Oré, Renato                    ******
******                                                          ******
****** Stata version 17                                         ******
**********************************************************************

*ssc install geodist
*ssc install spmap
*ssc install outreg2



capture cd "C:\Users\HP\Downloads\Spatial-hedonics-crime\STATA"
use "caba_housing_crime_panel", clear

* The dataset is prepared, and the necessary variables are created
do "1_hedonic_crime_model"

* Statistics and other results are obtained
do "2_hedonic_crime_model"
