# Julia-Earth-Observation-Workshop


## With Docker

* Install [Docker](https://docs.docker.com/get-docker/)

```bash
docker pull abarth/julia-gher
docker run -p 8888:8888 -v $PWD:/home/jovyan/data abarth/julia-gher
```

If you see the error
`Error starting userland proxy: listen tcp4 0.0.0.0:8888: bind: address already in use.`, it means that the port 8888 is already taken.
Either you use a different port, or stop the other program currently using port 8888.


## Native julia

* Install [julia](https://julialang.org/downloads/)
* On Linux, install also matplotlib (e.g. `sudo apt install python3-matplotlib` in Debian/Ubuntu)
* Activate environement

 ```julia
using Pkg
cd("this_directory")
Pkg.activate(".") # needs to be repeated for every session
Pkg.instantiate() # install all package
Pkg.add(url="https://github.com/gher-uliege/DINCAE_utils.jl", rev="main")
```
