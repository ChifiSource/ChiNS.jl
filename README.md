<div align="center">
<img width="200" src="https://github.com/ChifiSource/image_dump/blob/main/chins/chifiNS.png"><img>
<h6>chifi name server</h6>
</br>
</div>


`ChiNS` is a [toolips](https://github.com/ChifiSource/Toolips.jl)-powered UDP DNS server and load-balancer for the julia programming language.

##### map
- [get started](#get-started)
  - [adding chiNS](#adding-chins)
  - [first start](#first-start)
  - [zones]()
    - [zone editor]()
    - [load balancing]()
- [internals]()
  - [explanation]()
  - [server design]()
  - [flags]()
  - []()
- [contributing guidelines]()
## get started
`ChiNS` is intended to be an easy-to-implement, high-level solution for those looking to to deploy a single or multi-server web-network. The name `ChiNS` is derived from *chifi name server*, as this is the same nameserver used for [chifi source](https://github.com/ChifiSource) projects! This package operates entirely as a julia package, and is added with `Pkg`.
#### adding chiNS
To add the package, use `Pkg`.
```julia
using Pkg; Pkg.add("ChiNS")
```
For the latest updates that might sometimes be buggy, instead add `Unstable`
```julia
using Pkg; Pkg.add("ChiNS", rev = "Unstable")
```
###### first start
#### zones
###### zone editor
###### load balancing
