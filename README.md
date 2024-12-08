# Serial-to-HTTP  for macOS

This project provides a Python-based bridge to handle HTTP requests from a PC (serial host) connected via a USB serial cable or Virtual ][ emulator's named pipes. It receives HTTP requests from the serial port, fetches results using the requests library, and sends the response back via the same serial connection.

## Installation

Before running the script, make sure to install the required Python packages:

`pip install pyserial requests`
## Usage

### Prerequisites
1. Setup the hardware or emulator:
For USB serial connection: Connect the USB serial cable to your macOS device.
For Virtual ][ emulator:
Launch the emulator.
Configure the Super Serial Card to use Unix Named Pipes.
Check the option Force DCD input line to be on.
Run the script:
python ser2http.py
The script will automatically detect the host environment. Detection priority is as follows:

2. Serial ports matching /dev/*serial*. If multiple ports are found, the script will prompt you to select one.
Named pipes in Virtual ][ emulator.
If no suitable host is detected, the script will exit.

## Options
-q: Suppress debug output of responses.
-p port: Specify the port directly.
Example
To run the script and detect the port automatically:
`python ser2http.py`
To specify a port directly:
`python ser2http.py -p /dev/cu.usbserial-0001`
To suppress debug output:
`python ser2http.py -q`

## Features

Detects and communicates with either USB serial ports or Virtual ][ emulator's named pipes.
Handles HTTP requests with methods such as GET, POST, PUT, and DELETE.
Provides debug output for transmitted and received data unless suppressed with the -q option.
## File Structure

- ser2http.py: Main script to handle serial-to-HTTP communication.
- serhostmgr.py: Manages serial/pipe communication interfaces.
- httpclientmgr.py: Processes HTTP requests and responses.
- dumparray.py: Utility for debugging data dumps.

## Interface Details

The interface between the ser2http server and the serial host is defined as follows:

### Message Layout

#### Header
- [0] ID Byte:
	- From Serial Host to Server: 0x01
	- From Server to Serial Host: 0x02
- [1-2] Message Length:
Specifies the length of the body in two bytes.
Order: lower byte first, followed by upper byte.

#### Body
- [0] Command: HTTP command code, defined as follows:
	- CMD_PARSE: 1
	- CMD_QUERY: 2
	- CMD_POST: 3
	- CMD_PUT: 4
	- CMD_DELETE: 5
- [1-n] Payload: Arbitrary-length message content.
