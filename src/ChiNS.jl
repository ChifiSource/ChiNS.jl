module ChiNS
using Toolips
using ToolipsUDP
using JSON
import ToolipsUDP: onstart

ZONE_DIR::String = "zones"

onstart(c::Dict{Symbol, Any}, E::ToolipsUDP.UDPExtension{:zones}) = begin
    fs = filter!(fname -> contains(fname, ".zone"), readdir(ZONE_DIR))
    zones = Dict{String, Any}(begin
        fnamesplits = split(f, ".")
        domain = join(fnamesplits[1:length(fnamesplits) - 1], ".")
        string(domain) => JSON.parse(read(ZONE_DIR * "/" * f, String))
    end for f in fs)
    push!(c, :zones => zones)
end

mutable struct DNSFlags
    QR::Bool
    opcode::Int64
    AA::Bool
    TC::Bool
    RD::Bool
    RA::Bool
    Z::String
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

function build_flags(data::String)
    bits::String = join([bitstring(s) for s in Vector{UInt8}(data)])
    DNSFlags(parse(Bool, bits[1]), parse(Int64, bits[2:5]), parse(Bool, bits[6]), parse(Bool, bits[7]), parse(Bool, bits[8]),
    parse(Bool, bits[9]), String(bits[10:12]), parse(Int64, bits[13:16]))::DNSFlags
end

function build_header(id::String, flags::DNSFlags, data::String = s)
    QDCOUNT = "01"
    println(data)
    nothing
end

function get_question(data::String)
    current_len = 0
    current::String = ""
    parts = Vector{String}()
    global qdata = data
    count = 0
    indcount = 0
    state = false
    for byte in data
        indcount += 1
        if state
            current = current * byte
            count += 1
            if count == current_len
                push!(parts, current)
                current = ""
                state = false
                count = 0
            end
            if Int64(UInt8(byte)) == 0
                break
            end
        else
            state = true
            current_len = Int64(UInt8(byte))
        end
    end
    return(parts, data[indcount + 2:indcount + 3])
end

function build_response(data::String)
    tid = data[1:2]
    flags::DNSFlags = build_flags(data[3:4])
    name, type  = get_question(data[13:length(data)])
    d = Vector{UInt8}(type)
    questiontype = [Int64(pg) for pg in d]
    if questiontype[1] == 0 && questiontype[2] == 1
        println(name)
    end
end

function handler(c::UDPConnection)
    println(c.data)
    response = build_response(c.packet)
end

function start(ip::String = "127.0.0.1", port::Int64 = 53; 
    path::String = ZONE_DIR)
    global ZONE_DIR = path
    myserver = UDPServer(handler, ip, port)
    myserver.start()
    myserver
end


end # - module
        