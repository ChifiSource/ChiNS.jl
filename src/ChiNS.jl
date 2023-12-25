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

global qdata = ""

function get_question(data::String)
    current_len = 0
    current::String = ""
    parts = Vector{String}()
    global qdata = data
    count = 0
    state = false
    for byte in data
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
    println(parts)
end

function build_response(data::String)
    tid = data[1:2]
    flags::DNSFlags = build_flags(data[3:4])
    try
        name = get_question(data[13:length(data)])
    catch e
        Base.show(e)
    end
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
        