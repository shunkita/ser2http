import sys
import serial
from serial.tools import list_ports
import threading
import queue
import glob
from functools import reduce

import ser2http
import dumparray as da

# port speed
#PSPEED = 115200
PSPEED = 19200
#
#
class HostInThread(threading.Thread):
    def __init__(self, device, queue):  
        self.device = device
        self.queue = queue
        self._stop_event = threading.Event() 
        self._closed = False
        super().__init__(daemon=True)

    def run(self):
        try:
            while not self._stop_event.is_set():
                receive_byte = self.device.read(1)
                if not receive_byte:
                    continue
            
                if receive_byte[0] == 0x01:    # check id byte
                    len_payload = self.device.read(2)
                    bytes_to_read = len_payload[0] + (len_payload[1] * 256)
                    payload = self.device.read(bytes_to_read)
                    self.queue.put(payload)
                else:
                    print("Device in data error", receive_byte.hex(), "\n")
                    continue

        except serial.SerialException as e:
            print(f"Host Thread.run: serial exception {e}")
        except Exception as e:
            print(f"Host Thread.run: exception {e}")
        finally:
            self.stop()

    def stop(self):
        if (not self._closed):
            print('Get request Thread stopped')
            self._stop_event.set()
            if (self.device is not None):
                try:
                    self.device.close()
                    print("Host input device Closed")
                except Exception as e:
                    print(f"Error closing device: {e}")
            else:
                print("Device already closed or invalid")
            self._closed = True

#
# HostIOManager: manages information of Host interface device
#
class HostIOManager():
    def __init__(self):
        self.device = None
        self.request_queue = queue.Queue() 
        self.request_thread = None
        self.stop_event = threading.Event() #stop event

    def start(self):
        pass

    def write_data(self, data):
        pass

    def close_device(self):
        pass
    #
    #
    #
    def start_thread(self, device, queue):
        self.request_thread = HostInThread(device, queue)
        self.request_thread.start()

    def stop_thread(self):
        if self.request_thread is not None:
            self.request_thread.stop()
            self.request_thread.join(timeout=3) 
###
            self.request_thread = None            
            print("Host thread stopped successfully")
        self.close_device()
    #
    # send client data to serial port
    #
    def send_response(self, response, quiet):

        length = len(response)
        #  header format [0] id byte:0x02
        #                [1] length LowByte
        #                [2] length HighByte
        header = bytearray(3)
        header[0] = 0x02         
        header[1] = length & 0xff
        header[2] = length >> 8
        message = header + response
        self.write_data(message)
        if (quiet):
            return
        print("\nResponse:")
        da.dump_bytearray(response)

#
# SerialIOOManager: manages serial port's  information
#
class SerialIOManager(HostIOManager):
    def __init__(self, ser):
        self.ser = ser
        super().__init__()

    def start(self):
        self.start_thread(self.ser, self.request_queue)

    def write_data(self, data):
        self.ser.write(data)

    def close_device(self):
        if (self.ser is not None and self.ser.is_open):
            try:
                self.ser.close()
                print("Serial device closed")
            except Exception as e:
                print(f"Error closing serial device: {e}")
        else:
            print("Serial device already closed or invalid")
    
#
# ViiIOManager: manages Virtual]['s named pipe information
#
class ViiIOManager(HostIOManager):
    def __init__(self, infd, outfd):
        self.infd = infd
        self.outfd = outfd
        super().__init__()

    def start(self):
        self.start_thread(self.infd, self.request_queue)

    def write_data(self, data):
        self.outfd.write(data)
        self.outfd.flush()

    def close_device(self):
        try:
            if (self.infd is not None):
                self.infd.close()
                print("Input pipe closed")
        except Exception as e:
            print(f"Error closing input pipe: {e}")
        finally:
            self.infd = None
        
        try:
            if (self.outfd is not None):
                self.outfd.close()
                print("Output pipe closed")
        except Exception as e:
            print(f"Error closing output pipe: {e}")
        finally:
            self.outfd = None

#
# select_port: select /dev/*usbserial* device (for macOS environment)
#              if multiple port is exist,  ask user which port to use.
#
def select_port(default_name='usbserial'):  # default name for macOS
    ports = list_ports.comports() 

#    for info in ports:
#         print(info.device)

    devices = [info.device for info in ports if default_name in info.device]

    return select_device(devices)
#
# select_pipe: select /tmp/VII-Untitled-slot?
#              if multiple pipe is exist,  ask user which pipe to use.
def select_pipe():  # default name for macOS

    devices = glob.glob("/private/tmp/VII-Untitled-slot?")

    if len(devices) == 0:
        return None
    else:
        sortlist = sorted(devices, reverse = True)
        return sortlist[0]
#
# select_device:  ask user which device to use if more than 2 devices exists
#
def select_device(list):
    
    if len(list) == 0:                 # device not found
        return None
    elif len(list) == 1:               # only 1 device found
        return list[0]
    else:                              # 2 or more device found
        for i in range(len(list)):
            print("input %3d: select %s" % (i, list[i]))
        print("input number of target device >> ", end="")
        num = int(input())
        return list[num]

#
# setup_hostmanager: first, try to open serial port,
#                    if fails then try to Virtual ]['s named pipes
#
def setup_hostmanager(argport):

# Serial port
    if (argport is None):
        port = select_port()
    else:
        port = argport

    if (port is not None):
        try:
            print("Selected serial port:", port)
            print("Port speed:", PSPEED)
            ser = serial.Serial(port, PSPEED)
            serdevice = SerialIOManager(ser)
            return serdevice
        except:
            print("Serial port open error")
            return None
 
# Virtual ]['s pipe
    try:
        pipe_device = select_pipe()
        if pipe_device:
            global in_pipe
            global out_pipe
            in_pipe = pipe_device + '/OUT'
            out_pipe = pipe_device + '/IN'
            ofifo = open(out_pipe,'wb')
            ififo = open(in_pipe,'rb')
            device = ViiIOManager(ififo, ofifo)
            print("Selected Virtual ][:", pipe_device)
            return device                     # Found Virtual ][, then return
    except OSError as oe:
        pass

