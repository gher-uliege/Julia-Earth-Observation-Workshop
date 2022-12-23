# Julia-Earth-Observation-Workshop

## Before the workshop

* It is important to install all the software before the workshop (see below).
* To get some sample data, you need to register at:
       * CMEMS: https://data.marine.copernicus.eu/register
       * NASA Earth data: https://urs.earthdata.nasa.gov/users/new

One can either user Docker or the native julia package manager to install all software dependencies. 

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
* Download and uncompress the [code](https://github.com/gher-uliege/Julia-Earth-Observation-Workshop/archive/refs/heads/main.zip) in this repository (or use `git clone https://github.com/gher-uliege/Julia-Earth-Observation-Workshop`)
* Activate environement

 ```julia
using Pkg
cd("this_directory")
Pkg.activate(".") # needs to be repeated for every session
Pkg.instantiate() # install all package
```

where `"this_directory"` is the directory containing the ipynb files. Note, in Windows a path `C:\Users\Foo\Bar` should be written as `raw"C:\Users\Foo\Bar"` or `"C:\\Users\\Foo\\Bar"`.
