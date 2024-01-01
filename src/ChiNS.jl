module ChiNS
using Toolips
using ToolipsUDP
using JSON
import ToolipsUDP: onstart
import Toolips: string
SRCDIR = @__DIR__
ZONE_DIR::String = "$SRCDIR/../zones"

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
    opcode::String
    AA::Bool
    TC::Bool
    RD::Bool
    RA::Bool
    Z::String
    RCOD::String
end

function string(flags::DNSFlags)
    QR, opcode, AA, TC, RD = Int64(flags.QR), flags.opcode, Int64(flags.AA), Int64(flags.TC), Int64(flags.RD)
    RA, Z, RCOD = Int64(flags.RA), flags.Z, flags.RCOD
  #  [print("$field: ", getfield(flags, field), " ") for field in fieldnames(DNSFlags)]
    byte1 =  parse(UInt8, "$(QR)$(flags.opcode)$AA$TC", base = 2)
    byte2 = parse(UInt8, "$RD$RA$Z$RCOD", base = 2)
    String([byte1, byte2])
end

mutable struct DNSHeader
    ID::String
    flags::DNSFlags
    QDCOUNT::UInt16
    ANCOUNT::UInt16
    NSCOUNT::UInt16
    ARCOUNT::UInt16
end

function string(header::DNSHeader)
    ID, flags = header.ID, header.flags
    bytes = Vector{UInt8}()
    [begin
        bs = bitstring(field)
        bytes = vcat(bytes, [parse(UInt8, bs[1:8], base = 2), parse(UInt8, bs[9:16], base = 2)])
    end for field in [header.QDCOUNT, header.ANCOUNT, header.NSCOUNT, header.ARCOUNT]]
    "$ID$(string(flags))$(String(bytes))"
end

mutable struct DNSResponse
    header::DNSHeader
    question::Any
    answer::Any
end

function build_flags(data::String)
    bits::String = join([bitstring(s) for s in Vector{UInt8}(data)])
    DNSFlags(true, bits[2:6], parse(Bool, bits[7]), parse(Bool, bits[8]), parse(Bool, bits[9]),
    parse(Bool, bits[10]), String(bits[11:13]), bits[13:16])::DNSFlags
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

function build_body(c::UDPConnection, data::String, qt::Vector{Int64})
    if questiontype[1] == 0 && questiontype[2] == 1
        qt = "a"
    end
end

function build_response(c::UDPConnection, data::String)
    tid = data[1:2]
    flags = build_flags(data[3:4])
    name, type  = get_question(data[13:length(data)])
    d = Vector{UInt8}(type)
    questiontype = [Int64(pg) for pg in d]
    qt::String = ""
    if questiontype[1] == 0 && questiontype[2] == 1
        qt = "a"
    end
    println(join(["$part." for part in name]), "\n requested from $(c.ip)")
    zone = c[:zones][join(name, ".")]
    qcount = UInt16(1)
    ancount = UInt16(length(zone[qt]))
    nscount = UInt16(1)
    arcount = UInt16(1)
    header = DNSHeader(tid, flags, qcount, ancount, nscount, arcount)
 #   body = build_body(c, data[14:length(data)], questiontype)
 #   println(body)
    string(header)
end

function handler(c::UDPConnection)
    response = build_response(c, c.packet)
    println(length(response))
    respond(c, response)
    return
end

function start(ip::String = "127.0.0.1", port::Int64 = 53; 
    path::String = ZONE_DIR)
    global ZONE_DIR = path
    myserver = UDPServer(handler, ip, port)
    myserver.start()
    myserver
end

function list_zones()
    [begin
        zonedata = JSON.parse(read(ZONE_DIR * "/" * zone_fname, String))
        println("""---
        URL: $(zonedata["\$origin"])
        ~
        ns: $(zonedata["ns"][1]["host"])
        ns2: $(zonedata["ns"][2]["host"])
        refresh: $(zonedata["soa"]["refresh"])
        retry: $(zonedata["soa"]["retry"])
        ip: $(zonedata["a"][2]["value"])
        """)
    end for zone_fname in readdir(ZONE_DIR)]
    nothing
end

function get_zone()

end

function remove_zone()

end

function add_zone()

end

function save_zone(d::Dict{String, <:Any})

end

end # - module
        