using Pkg; Pkg.activate(".")
using Toolips
using Revise
using ChiNS

IP = "127.0.0.1"
PORT = 53
ChiNSServer = ChiNS.start(IP, PORT)
