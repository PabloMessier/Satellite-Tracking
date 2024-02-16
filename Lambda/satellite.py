import os
import sys
import logging
import time
import requests
from colorama import Fore, init

# Initialize colorama to autoreset colors
init(autoreset=True)

# Setting up custom logging
class ColorFormatter(logging.Formatter):
    def format(self, record):
        if record.levelno == logging.WARNING:
            record.msg = Fore.YELLOW + record.msg
        elif record.levelno >= logging.ERROR:
            record.msg = Fore.RED + record.msg
        else:
            record.msg = Fore.WHITE + record.msg
        return logging.Formatter.format(self, record)

# Configure logger
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
formatter = ColorFormatter('%(asctime)s - %(levelname)s - %(message)s')
ch.setFormatter(formatter)
logger.addHandler(ch)

# Function to check operating system
def check_os():
    platforms = {
        'linux': 'Linux',
        'linux2': 'Linux',
        'darwin': 'macOS',
        'win32': 'Windows'
    }
    return platforms.get(sys.platform, 'Unknown')

# Function to get the current location of the ISS
def get_iss_current_location():
    connected = True
    connection_timeframe = 60  # You might want to adjust this based on your actual requirements
    while connected and connection_timeframe > 0:
        api_url = "http://api.open-notify.org/iss-now.json"
        response = requests.get(api_url)
        connection_timeframe -= 1
        
        if response.status_code == 200:
            data = response.json()
            timestamp = data['timestamp']
            latitude = data['iss_position']['latitude']
            longitude = data['iss_position']['longitude']
            logger.info(f"Timestamp: {timestamp}")
            logger.info(f"ISS Current Location - Latitude: {latitude}, Longitude: {longitude}")
        else:
            logger.error("Failed to retrieve data from the API.")
            break  # Exit the loop if there's an error

        if connection_timeframe == 0:
            logger.warning("Connection timeframe exceeded, disconnecting...")
            connected = False
        
        time.sleep(5)  # Be cautious with sleep in Lambda due to execution time limits and associated costs

# Lambda handler function
def handler(event, context):
    os_type = check_os()
    if os_type not in ['Linux', 'macOS', 'Windows']:
        logger.error("Unsupported operating system.")
        return {
            'statusCode': 500,
            'body': 'Unsupported operating system.'
        }
    get_iss_current_location()
    return {
        'statusCode': 200,
        'body': 'ISS location fetched successfully.'
    }