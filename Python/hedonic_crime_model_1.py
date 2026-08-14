import pandas as pd
import numpy as np



def prepare_data(df):    
    
    # Create the correct date var
    df['date_m'] = pd.NaT
    df.loc[ df['date'] == 'July 2017', 'date_m'] = pd.to_datetime('2017-07-01')
    df.loc[ df['date'] == 'January 2018', 'date_m'] = pd.to_datetime('2018-01-01')
    df.loc[ df['date'] == 'April 2019', 'date_m'] = pd.to_datetime('2019-04-01')
    df.loc[ df['date'] == 'December 2023', 'date_m'] = pd.to_datetime('2023-12-01')
    df.loc[ df['date'] == 'July 2024', 'date_m'] = pd.to_datetime('2024-07-01')
    df.loc[ df['date'] == 'August 2024', 'date_m'] = pd.to_datetime('2024-08-01')
    df.loc[ df['date'] == 'September 2024', 'date_m'] = pd.to_datetime('2024-09-01')
    df.loc[ df['date'] == 'October 2024', 'date_m'] = pd.to_datetime('2024-10-01')
    df.loc[ df['date'] == 'November 2024', 'date_m'] = pd.to_datetime('2024-11-01')
    df.loc[ df['date'] == 'December 2024', 'date_m'] = pd.to_datetime('2024-12-01')    
    
    # Since information regarding bathrooms or rooms is unavailable for certain specific years 
    # (primarily the oldest ones), utilize panel data—assuming that no additional bathrooms or 
    # rooms were built between periods—to complete the dataset.
    df = df.sort_values(by=['id', 'date_m'])
    df['bathrooms'] = df.groupby('id')['bathrooms'].bfill()
    df['bedrooms'] = df.groupby('id')['bedrooms'].bfill()    
    
    # Deflated prices using the IPC (Dec. 2016 = 100)
    df['price'] = df['price'].astype(float)
    df.loc[ df['date_m'] == '2017-07-01', 'price'] = df['price']*(100/113.8)
    df.loc[ df['date_m'] == '2018-01-01', 'price'] = df['price']*(100/127.0)
    df.loc[ df['date_m'] == '2019-04-01', 'price'] = df['price']*(100/213.1)
    df.loc[ df['date_m'] == '2024-07-01', 'price'] = df['price']*(100/6607.7)
    df.loc[ df['date_m'] == '2024-08-01', 'price'] = df['price']*(100/6883.4)
    df.loc[ df['date_m'] == '2024-09-01', 'price'] = df['price']*(100/7122.2)
    df.loc[ df['date_m'] == '2024-10-01', 'price'] = df['price']*(100/7314.0)
    df.loc[ df['date_m'] == '2024-11-01', 'price'] = df['price']*(100/7491.4)
    df.loc[ df['date_m'] == '2024-12-01', 'price'] = df['price']*(100/7694.0)
    # Converted USD to ARS using the average exchange rate for December 2016
    df.loc[ df['currency'] == 'USD', 'price'] = df['price']*14.97    
    
    #The same applies to the TFI
    df['average_tfi'] = df['average_tfi'].astype(float)
    df.loc[ df['date_m'] == '2017-07-01', 'average_tfi'] = df['average_tfi']*(100/113.8)
    df.loc[ df['date_m'] == '2018-01-01', 'average_tfi'] = df['average_tfi']*(100/127.0)
    df.loc[ df['date_m'] == '2019-04-01', 'average_tfi'] = df['average_tfi']*(100/213.1)
    df.loc[ df['date_m'] == '2023-12-01', 'average_tfi'] = df['average_tfi']*(100/6607.7)
    df.loc[ df['date_m'] == '2024-07-01', 'average_tfi'] = df['average_tfi']*(100/6607.7)
    df.loc[ df['date_m'] == '2024-08-01', 'average_tfi'] = df['average_tfi']*(100/6883.4)
    df.loc[ df['date_m'] == '2024-09-01', 'average_tfi'] = df['average_tfi']*(100/7122.2)
    df.loc[ df['date_m'] == '2024-10-01', 'average_tfi'] = df['average_tfi']*(100/7314.0)
    df.loc[ df['date_m'] == '2024-11-01', 'average_tfi'] = df['average_tfi']*(100/7491.4)
    df.loc[ df['date_m'] == '2024-12-01', 'average_tfi'] = df['average_tfi']*(100/7694.0)
    
    # Apply a logarithm to some variables
    df['lprice'] = np.log(df['price'])
    df['lcrimes'] = np.log(df['tot_crimes'])
    df['lthreats'] = np.log(df['tot_threats'])
    df['lhomicides'] = np.log(df['tot_homicides'])
    df['ltheft'] = np.log(df['tot_theft'])
    df['linjuries'] = np.log(df['tot_injuries'])
    df['lrobbery'] = np.log(df['tot_robbery'])
    df['ltraffic'] = np.log(df['tot_traffic'])
    
    # Structure the data as a panel
    df = df.sort_values(by=['id', 'date_m'], ascending=[True, False])
    df = df.set_index(['id', 'date_m'])
    
    # =====================================================================
    return df
