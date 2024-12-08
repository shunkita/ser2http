#
# dump_bytearray: display dump
#
def dump_bytearray(byte_array):
    def hex_dump(data, length=16):
        for i in range(0, len(data), length):
            chunk = data[i:i+length]
            hex_str = ' '.join([f'{b:02X}' for b in chunk])
            ascii_str = ''.join([chr(b) if 32 <= b < 127 else '.' for b in chunk])
            print(f'{hex_str.ljust(length*3)} {ascii_str}')
    hex_dump(byte_array)
