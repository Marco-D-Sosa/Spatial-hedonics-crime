import pandas as pd
import matplotlib.pyplot as plt
import geopandas as gpd
import kagglehub
from linearmodels.panel import RandomEffects
import numpy as np
import seaborn as sns



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
    gdf_neighborhoods = gpd.read_file(f"{path_map}/neighborhoods_coord.geojson")
    gdf_neighborhoods['id'] = gdf_neighborhoods['id'].astype(str)
    df_collapsed3['id_neighborhood'] = df_collapsed3['id_neighborhood'].astype(str)
    gdf_map = gdf_neighborhoods.merge(df_collapsed3, left_on='id', right_on='id_neighborhood')
    gdf_map.plot(
    column='price', 
    cmap='Blues', 
    scheme='Quantiles', 
    legend=True,
    figsize=(10, 8),
    edgecolor='black',
    linewidth=0.8
    )
    plt.title("Map of average prices by neighborhood")
    plt.axis('off')
    plt.show()
    df_collapsed4 = df.groupby('id_neighborhood')['tot_crimes'].mean().reset_index()
    df_collapsed4['id_neighborhood'] = df_collapsed3['id_neighborhood'].astype(str)
    gdf_map2 = gdf_neighborhoods.merge(df_collapsed4, left_on='id', right_on='id_neighborhood')
    gdf_map2.plot(
    column='tot_crimes', 
    cmap='Reds', 
    scheme='Quantiles', 
    legend=True,
    figsize=(10, 8),
    edgecolor='black',
    linewidth=0.8
    )
    plt.title("Map of average crime rates by neighborhood")
    plt.axis('off')
    plt.show()
    print("="*60)
    
    # Main econometric model
    structural = ['accommodates', 'bathrooms', 'bedrooms', 'beds', 'C(room_type)']
    control = ['min_dist_uni', 'tot_universities', 'tot_establishments', 'number_hospitals', 'average_tfi']  
    formula = "lprice ~ 1 + lcrimes + " + " + ".join(structural) + " + " + " + ".join(control) + "+ C(date)"
    periodos_a_eliminar = ['July 2017', 'January 2018']
    df = df[~df['date'].isin(periodos_a_eliminar)].copy()
    model_re = RandomEffects.from_formula(formula, data=df, check_rank=False)
    results = model_re.fit(cov_type='robust')
    print("--- Main econometric model ---")
    print(results.summary)
    print("="*60)
    
    # Calculation of marginal and total cost
    sample_index = results.resids.index
    mean_price = df.loc[sample_index, 'price'].mean()
    mean_crimes = df.loc[sample_index, 'tot_crimes'].mean()
    gamma = results.params['lcrimes']
    print(f"Price elasticity of crime (gamma): {gamma:.4f}")
    print("="*60)
    print(f"Marginal cost per percentage of crime: {(gamma / 100) * mean_price:.4f}")
    print("="*60)
    print(f"Marginal cost per unit of crime: {(gamma * mean_price) / mean_crimes:.4f}")
    print("="*60)
    print(f"Total cost of prevention (per dwelling): {gamma * mean_price:.4f}")
    print("="*60)
    
    # Map of predicted prices
    fitted = results.fitted_values.copy()
    fitted = fitted.reset_index()
    fitted.columns = ['id', 'date_m', 'price_pred']
    df_map = df.merge(fitted, on=['id', 'date_m'], how='left')
    df_pred_collapsed = df_map.groupby('id_neighborhood')['price_pred'].mean().reset_index()
    df_pred_collapsed['id_neighborhood'] = df_pred_collapsed['id_neighborhood'].astype(str)
    gdf_map_pred = gdf_neighborhoods.merge(df_pred_collapsed, left_on='id', right_on='id_neighborhood')
    gdf_map_pred.plot(
        column='price_pred',
        cmap='Blues',
        scheme='Quantiles',
        legend=True,
        figsize=(10, 8),
        edgecolor='black',
        linewidth=0.8
        )
    plt.title("Map of average predicted prices by neighborhood")
    plt.axis('off')
    plt.show()
    
    # Model with disaggregated offenses
    crimes = ['lthreats', 'lhomicides', 'ltheft', 'linjuries', 'lrobbery', 'ltraffic']
    formula2 = "lprice ~ 1 + " + "+" .join(crimes) + " + " + "+".join(structural) + " + " + " + ".join(control) + " + C(date)"
    df[crimes] = df[crimes].replace([np.inf, -np.inf], np.nan)
    model2_re = RandomEffects.from_formula(formula2, data=df)
    results2 = model2_re.fit(cov_type='robust')
    print(results2.summary)
     
    # Regression plot
    sns.regplot(
    data=df, 
    x='lcrimes', 
    y='lprice',
    ci=None,
    scatter_kws={'color': 'blue', 'alpha': 0.5},
    line_kws={'color': 'red'}
    )
    plt.title("Relationship between insecurity and rental prices")
    plt.xlabel("ln(Crimes)")
    plt.ylabel("ln(Price)")
    plt.show()
    
    # =====================================================================
