module ChiNS
using Toolips

using ToolipsUDP

mutable struct DNSFlags
    QR::Bool
    opcode::Int64
    AA::Bool
    TC::Bool
    RD::Bool
    RA::Bool
    RCOD::Int64
end

mutable struct DNSHeader
    ID::String
    flags::DNSFlags
    QDCOUNT::String
    ANCOUNT::String
    NSCOUNT::String
    ARCOUNT::String
end

mutable struct DNSResponse
    header::DNSHeader
    question::Any
    answer::Any
end

function build_response(data::String)
    tid = data[1:2]
    println(tid)
end

function handler(c::UDPConnection)
    response = build_response(c.packet)
end

function start(ip::String = "127.0.0.1", port::Int64 = 53)
    myserver = UDPServer(handler, ip, port)
    myserver.start()
    myserver
end


end # - module
        