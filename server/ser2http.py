import sys
import argparse
import serhostmgr as sh
import httpclientmgr as hcm


# Function to parse command-line arguments
def parse_args():
    parser = argparse.ArgumentParser(description='Serial to HTTP bridge')
    parser.add_argument('-p', '--port', type=str, help='Specify the serial port name')
    parser.add_argument('-q', '--quiet', action='store_true', help='disable debug dump')
    return parser.parse_args()

#
# main: main loop
#
def main():
    args = parse_args()


    if args.quiet:
        print(f"Dump mode is {'off' if args.quiet else 'on'}")


#    print(sys.implementation.name)
    host_mgr = sh.setup_hostmanager(args.port)
    if (host_mgr == None):
        print("No host device found, exit")
        exit()

    http_client_mgr = hcm.HttpClientManager()
    try:
        host_mgr.start()

        while True:
            if not host_mgr.request_queue.empty():
                request_data = host_mgr.request_queue.get()
                response = http_client_mgr.com_handle(request_data)
                if (response is not None):
                    host_mgr.send_response(response.encode('ascii'), args.quiet)

    except KeyboardInterrupt:
        print("Main Thread terminated by user ")
        host_mgr.stop_thread()
    finally:
        host_mgr.close_device()
        print("Resources cleaned up.")

if __name__ == "__main__":
    main()
