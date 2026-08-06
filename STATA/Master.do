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



global path "" // Add your path to the folder here

cd "$path"
use "caba_housing_crime_panel", clear

* The dataset is prepared, and the necessary variables are created
do "hedonic_crime_model_1"

* Statistics and other results are obtained
do "hedonic_crime_model_2"
