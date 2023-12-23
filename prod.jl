using Pkg; Pkg.activate(".")
using Toolips
using ChiNS

IP = "127.0.0.1"
PORT = 8000
ChiNSServer = ChiNS.start(IP, PORT)
