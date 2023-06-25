import sqlite3
import requests
from datetime import datetime, timedelta

# Binance API endpoint
API_URL = 'https://api.binance.com/api/v3/klines'

# Parameters for the API request
symbol = 'BTCUSDT'  # BTC/USDT trading pair
interval = '1d'    # 1 day interval
start_time = int((datetime.now() - timedelta(days=365 * 2)).timestamp() * 1000)  # 2 years ago in milliseconds
end_time = int(datetime.now().timestamp() * 1000)  # Current time in milliseconds

# SQLite database setup
database_file = 'database.db'
conn = sqlite3.connect(database_file)
cursor = conn.cursor()

# Create the table if it doesn't exist
cursor.execute('''
    CREATE TABLE IF NOT EXISTS btc_price (
        timestamp INTEGER PRIMARY KEY,
        open REAL,
        high REAL,
        low REAL,
        close REAL,
        volume REAL
    )
''')
conn.commit()

# Delete existing data from the table
cursor.execute('DELETE FROM btc_price')

# Commit the deletion
conn.commit()


# Fetch BTC price data from Binance API
response = requests.get(API_URL, params={
    'symbol': symbol,
    'interval': interval,
    'startTime': start_time,
    'endTime': end_time,
    'limit': 1000  # Maximum number of data points per request
})

# Parse the response and insert data into the database
data = response.json()
for candle in data:
    timestamp = int(candle[0] / 1000)  # Convert milliseconds to seconds
    open_price = float(candle[1])
    high_price = float(candle[2])
    low_price = float(candle[3])
    close_price = float(candle[4])
    volume = float(candle[5])

    # Insert data into the table
    cursor.execute('''
        INSERT INTO btc_price (timestamp, open, high, low, close, volume)
        VALUES (?, ?, ?, ?, ?, ?)
    ''', (timestamp, open_price, high_price, low_price, close_price, volume))
conn.commit()

# Close the database connection
conn.close()

