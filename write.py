import socket
import struct
# HOST = None
# PORT = None
# s = None



HOST = 'localhost'    # The remote host
PORT = 6449              # The same port as used by the server
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

OSC_formatter = "/foo/notes"
OSC_formatter += "\x00\x00,ff\x00"

def initialize_socket(socket, host, port):
    HOST = host
    PORT = port
    s = socket

def update_mouse(x_coor, y_coor):
    float1 = struct.pack('!f',x_coor)
    float2 = struct.pack('!f',y_coor)
    message = OSC_formatter + float1 + float2
    s.sendto(message, (HOST, PORT))
    #s.close()
