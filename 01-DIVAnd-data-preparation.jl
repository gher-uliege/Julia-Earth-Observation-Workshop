# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.14.4
#   kernelspec:
#     display_name: Julia 1.8.0
#     language: julia
#     name: julia-1.8
# ---

# # DIVAnd data preparation for the Azores region
#
# This example downloads temperature from World Ocean Database (WOD)
# given a certain boundary box and time range by simulating a request
# made on the page:
# https://www.ncei.noaa.gov/access/world-ocean-database-select/dbsearch.html

using DIVAnd
using Dates
using Downloads: download
using PhysOcean
using PyPlot
using Statistics

# Bounding box corresponding to the Azores region

lonr = [-33, -24]
latr = [33.0, 40.0]

# Time range (start, end)
# DateTime requires the year, month, day (and optionally hours, minutes, seconds)

timer = [DateTime(2010,1,1),DateTime(2014,12,31)]

# Directory for the WOD files

WODdir = "WOD"

# Replace this by your emails address, so that the following reads if you
# download the data from World Ocean Database:
# ```julia
# email = "you@email.com"
# ```

email = ""

# The name of the variable. The list of all names is available when you execute
# `?WorldOceanDatabase.download`

WODname = "Temperature"
fname = "Azores-WOD-Temperature.nc"


# In the interest of time, the following is disabled
#
# ```julia
# WorldOceanDatabase.download(lonr,latr,timer,WODname,email,WODdir)
# # Load the variable as Float64 (except the time and identifier which are `DateTime`s and `String`s). Only data flagged as accepted will be loaded.
# obsvalue,obslon,obslat,obsdepth,obstime,obsids  = WorldOceanDatabase.load(Float64,WODdir,WODname);
# # Save the data in a single NetCDF file for quick access
# isfile(fname) && rm(fname)
# DIVAnd.saveobs(fname,WODname,obsvalue,(obslon,obslat,obsdepth,obstime),obsids)
# ```


if !isfile(fname)
    download("https://dox.ulg.ac.be/index.php/s/W5jIFPjXfSanRiO/download",fname)
else
    @info("Data file already downloaded")
end


varname = "Temperature"
obsval,obslon,obslat,obsdepth,obstime,obsid = DIVAnd.loadobs(Float64,fname,varname);

# Extract the bathymetry for plotting

bathname = "gebco_30sec_16.nc"
bathisglobal = true
if !isfile(bathname)
    download("https://dox.ulg.ac.be/index.php/s/U0pqyXhcQrXjEUX/download",bathname)
else
    @info("Bathymetry file already downloaded")
end
bx,by,b = DIVAnd.extract_bath(bathname,bathisglobal,lonr,latr);

# Spatial distrution of surface data.
# Adjust the month for a different month range

figure()
sel = (obsdepth .< 5) .& (1 .<= Dates.month.(obstime) .<= 12)
plot(obslon[sel],obslat[sel],".",color="#6699ff")
contourf(bx,by,b', levels = [-1e5,0],colors = [[.5,.5,.5]])
xlim(lonr)
ylim(latr)
gca().set_aspect(1/cosd(mean(by)))
title("Spatial distrution of surface data");

# Number of data points per year

figure()
hist(Dates.year.(obstime),5)
xlabel("year")
ylabel("number of data points");
