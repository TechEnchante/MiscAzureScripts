import yfinance as yf
import pandas as pd
import datetime
import os

# Define the ticker symbols for which you want to fetch the data
tickerSymbols = ['AAPL', 'MSFT', 'AMD']  # Example tickers

# Specify the folder path to save the CSV files
folderPath = "C:\\Users\\adam_\\OneDrive\\Desktop\\Azure Script\\Secondary Scripts\\Resource Group Test Case\\MonthlyTradeDataCSVsForTradingApp"

# Get the current date
currentDate = datetime.date.today()
one_month_ago = currentDate - datetime.timedelta(days=30)  # Calculate the date one month ago

# Loop through each ticker symbol
for tickerSymbol in tickerSymbols:
    # Get data for the specified ticker
    tickerData = yf.Ticker(tickerSymbol)

    # Get the data for the past month
    tickerDf = tickerData.history(start=one_month_ago, end=currentDate)

    # Generate a filename based on the ticker symbol and current date
    filename = os.path.join(folderPath, f"trading_data_{tickerSymbol}_{one_month_ago}_{currentDate}.csv")

    # Write data to a CSV file
    tickerDf.to_csv(filename)

    print(f"Trading data for {tickerSymbol} from {one_month_ago} to {currentDate} has been written to {filename}")
