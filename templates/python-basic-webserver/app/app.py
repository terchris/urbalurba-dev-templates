"""
filename: templates/python-basic-webserver/app/app.py
This is a basic web server using Flask and Python
It serves a simple "Hello world" message on the root URL
It is a simple example to demonstrate how to set up a Flask project
and how to run a basic web server
"""
from flask import Flask
from datetime import datetime

app = Flask(__name__)
port = 6000

@app.route('/')
def hello_world():
    # Format the current time to a string "Time: HH:MM:SS Date: DD/MM/YYYY"
    time_date_string = datetime.now().strftime('Time: %H:%M:%S Date: %d/%m/%Y')
    
    return f'Hello world ! Template: python-basic-webserver. {time_date_string}'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=port, debug=True)
    print(f'Server running at http://localhost:{port}')