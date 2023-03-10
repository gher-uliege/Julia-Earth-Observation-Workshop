# Julia-Earth-Observation-Workshop


Link to this webpage: https://tinyurl.com/JuliaEO21-code

## Before the workshop

* It is important to install all the software before the workshop (see below).
* To get some sample data, you need to register at these sites and have your username and password with you for the workshop:
     * CMEMS: https://data.marine.copernicus.eu/register
     * NASA Earth data: https://urs.earthdata.nasa.gov/users/new
      
One can either user Docker or the native julia package manager to install all software dependencies. 

## Workshop material

* Download and uncompress the [code](https://github.com/gher-uliege/Julia-Earth-Observation-Workshop/archive/refs/heads/main.zip) in this repository (or use `git clone https://github.com/gher-uliege/Julia-Earth-Observation-Workshop`). The notebooks are already included in the shared USB drive.


## Installation with Docker

* Install [Docker](https://docs.docker.com/get-docker/)
* Open a terminal (Windows users, please use a PowerShell terminal)


### Using docker without fast internet

* Locate the file `julia-gher.tar.gz` (1.8 GB) on the folder copied from the USB drive
* Load it with the following command

```
docker load -i julia-gher.tar.gz
```

### Using docker with fast internet

* Run in a terminal run the following command:

```bash
docker pull abarth/julia-gher
```

### Start the container

* Go to the directory contaning the notebooks

```bash
cd "replace this with the directory name with the notebook"
```

* Run in a terminal run the following commands (for Windows user this needs to be a PowerShell terminal):

```bash
docker run -p 8888:8888 -v ${PWD}:/home/jovyan/data abarth/julia-gher
```

where `${PWD}` is automatically replaced by your current directory which is made available inside the docker container under the `/home/jovyan/data`.
If you see the error
`Error starting userland proxy: listen tcp4 0.0.0.0:8888: bind: address already in use.`, it means that the port 8888 is already taken.
Either you use a different port, or stop the other program currently using port 8888.


* Look for these lines:

```
    To access the server, open this file in a browser:
        file:///home/jovyan/.local/share/jupyter/runtime/jpserver-7-open.html
    Or copy and paste one of these URLs:
        http://1a8fae3e9eb9:8888/lab?token=SOME-LONG-TOKEN
     or http://127.0.0.1:8888/lab?token=SOME-LONG-TOKEN
```

Open the link `http://127.0.0.1:8888/lab?token=SOME-LONG-TOKEN` with your 48 characters long token.


## Installation directly with julia's package manager

* Install [julia](https://julialang.org/downloads/)
* On Linux, install also matplotlib (e.g. runnning`sudo apt install python3-matplotlib` in terminal for Debian/Ubuntu)
* Activate and instantiate the environement and start jupyter notebook:

 ```julia
using Pkg
cd("this_directory")
Pkg.activate(".") # needs to be repeated for every session
Pkg.instantiate() # install all package
using IJulia
notebook(dir=pwd())
```

where `"this_directory"` is the directory containing the ipynb files. Note, in Windows a path `C:\Users\Foo\Bar` should be written as `raw"C:\Users\Foo\Bar"` or `"C:\\Users\\Foo\\Bar"`.


Now open the first notebooks file `01-DIVAnd-data-preparation.ipynb` in the jupyter interface.
