import pandas as pd
import matplotlib.pyplot as plt
import geopandas as gpd
import kagglehub



def generate_results(df):    
    
    # Obtain relevant descriptive statistics
    print("="*60)
    print("--- Table of average prices by year ---")
    df_collapsed1 = df.groupby('date')['price'].mean().reset_index()
    print(df_collapsed1)
    print("="*60)
    print("--- Table of average crimes per year ---")
    df_collapsed2 = df.groupby('date')['tot_crimes'].mean().reset_index()
    print(df_collapsed2)
    print("="*60)
    
    
    
    
    
    df_collapsed3 = df.groupby('id_neighborhood')['price'].mean().reset_index()
    path_map = kagglehub.dataset_download("marcodiazzz/buenos-aires-rentals-and-crime")
    gdf_neighborhoods = gpd.read_file(f"{path_map}/neighbordhoods_coord.csv")
    gdf_neighborhoods['_ID'] = gdf_neighborhoods['_ID'].astype(str)
    df_collapsed3['id_neighborhood'] = df_collapsed3['id_neighborhood'].astype(str)
    gdf_map = gdf_neighborhoods.merge(df_collapsed3, left_on='_ID', right_on='id_neighborhood')
    gdf_map.plot(
    column='price', 
    cmap='Blues', 
    scheme='Quantiles', 
    legend=True,
    figsize=(10, 8)
    )
    plt.title("Map of average prices by neighborhood")
    plt.axis('off')
    plt.show()
    print("="*60)
    
    
    
    
    
    
    """
    # 4) Map of average crime rates by neighborhood
    preserve
    collapse (mean) tot_crimes, by(id_neighborhood)
    spmap tot_crimes using "neighborhoods_coord.dta", id(id_neighborhood) fcolor(Reds) clmethod(quantile)
    graph export "$path\results\crime_map.png", replace 
    restore
    
    # Main econometric model
    local structural = "accommodates bathrooms bedrooms beds i.(room_type)"
    local control = "min_dist_uni tot_universities tot_establishments number_hospitals average_tfi"
    xtreg lprice lcrimes `structural' `control' i.(date), re robust
    outreg2 using "$path\results\modelo_principal.txt", replace
    
    # Calculation of marginal and total cost
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
    
    # Map of predicted prices
    predict price_pred if e(sample), xb
    preserve
    collapse (mean) price_pred, by(id_neighborhood)
    spmap price_pred using "neighborhoods_coord.dta", id(id_neighborhood) fcolor(Blues) clmethod(quantile)
    restore
    
    # Model with disaggregated offenses
    local crimes = "lthreats lhomicides ltheft linjuries lrobbery ltraffic"
    xtreg lprice `crimes' `structural' `control' i.(date), re robust
    outreg2 using "$path\results\disaggregated_model.txt", replace
    
    # Regression plot
    twoway (scatter lprice lcrimes, mcolor(blue%50)) (lfit lprice lcrimes, lcolor(red)), ///
       title("Relationship between insecurity and rental prices") xtitle("ln(Crimes)") ytitle("ln(Price)")
    
    graph export "$path\results\graph_reg.png", replace 
    
    # =====================================================================
"""