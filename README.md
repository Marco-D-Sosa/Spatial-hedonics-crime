# Spatial Hedonics: Crime & Short-Term Rentals in Buenos Aires

Stata and Python codebase for estimating the costs of crime in the Autonomous City of Buenos Aires (CABA) using a spatial hedonic pricing model on short-term rental housing.

This repository contains two independent workflows (Python and Stata) that execute the analytical pipeline.

## Repository Structure

* `Python/`: Contains the fully automated Python pipeline.
* `Stata/`: Contains the Stata `.do` files (requires manual data handling).

---

## 🐍 Python Workflow (Fully Automated)

The Python pipeline is completely automated, handling data downloading, processing, and output generation entirely in memory or via console prints.

### 1. Requirements
Navigate to the Python directory and install the required dependencies:
```bash
cd Python
pip install -r requirements.txt
```

### 2. Execution
Run the master script. This will handle the data setup and sequentially call the required modules (`hedonic_crime_model_1.py` and `hedonic_crime_model_2.py`).
`python Master.py`

## 📊 Stata Workflow

Unlike the Python pipeline, the Stata workflow requires a manual download of the database and setting up a local working directory.

### 1. Dependencies

The code relies on the following external Stata packages: `geodist`, `spmap`, and `outreg2`.

Installation: The installation commands are included at the very beginning of the `Master.do` file, currently commented out with an asterisk (*). If you need to install them, simply remove the * and run those lines before proceeding.

### 2. Data Setup

1. Download the required database from here: [(https://www.kaggle.com/datasets/marcodiazzz/buenos-aires-rentals-and-crime)]
2. Place the downloaded database directly inside the `Stata/` folder, alongside the `.do` files.
3. Open `Master.do`. At the top of the file, locate the designated path variable and replace it with your local absolute path to the `Stata/ directory`. This only needs to be configured once.

### 3. Execution

Run the master script. It will load the database, generate the necessary output directories, and sequentially call `hedonic_crime_model_1.do` and `hedonic_crime_model_2.do`.
```bash
do Master.do
```
