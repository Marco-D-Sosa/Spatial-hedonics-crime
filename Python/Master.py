import pandas as pd
import kagglehub
import hedonic_crime_model_1
import hedonic_crime_model_2



def main():
    print("Opening database...")
    path = kagglehub.dataset_download("marcodiazzz/buenos-aires-rentals-and-crime")
    df_base = pd.read_csv("f{path}/caba_housing_crime_panel.csv") 
    
    # =====================================================================

    print("Executing data preparation...")
    df_ready = hedonic_crime_model_1.prepare_data(df_base)

    print("Generating results and maps...")
    hedonic_crime_model_2.generate_results(df_ready)

    print("Executiong completed.")

if __name__ == "__main__":
    main()
