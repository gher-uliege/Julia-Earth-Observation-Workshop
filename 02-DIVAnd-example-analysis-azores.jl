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

# # DIVAnd analysis for the Azores region
#
# This example performs a temperature analysis using World Ocean Database
# data from the Azores region.
# The analysis is done for every season for the data from 2010 until end of 2014.
#
# For testing purposes, let's start with a a limited number of vertical levels.

using DIVAnd
using DataStructures
using Dates
using Downloads: download
using NCDatasets
using PyPlot
using Statistics

# Download the file `Temperature.nc` (if it is not already present). It will be placed in the same directory as this notebook. This file based on the World Ocean Database.

# +
fname = "Azores-WOD-Temperature.nc"
if !isfile(fname)
    download("https://dox.ulg.ac.be/index.php/s/W5jIFPjXfSanRiO/download",fname)
else
    @info("Data file already downloaded")
end
# -

# Download the bathymetry if it is not already present

# +
bathname = "gebco_30sec_16.nc"

if !isfile(bathname)
    download("https://dox.ulg.ac.be/index.php/s/U0pqyXhcQrXjEUX/download",bathname)
else
    @info("Bathymetry file already downloaded")
end

bathisglobal = true
# -

# Load the tmperature data from the file

varname = "Temperature"
obsval,obslon,obslat,obsdepth,obstime,obsid = DIVAnd.loadobs(Float64,fname,varname);
@show size(obsval);

# The file contains about 1 000 000 measurements.
# Print some basic statistics about the data. Keep an eye on the ranges.

checkobs((obslon,obslat,obsdepth,obstime),obsval,obsid)

# Define the resolution. It is recommended to start with a low resolution and increase the resolution when the results are suitable.

dx = 0.1 # longitude resolution in degrees
dy = 0.1 # latitude resolution in degrees

# Define the bounding box of the spatial domain

lonr = -33:dx:-24    # the range of longitudes (start:step:end)
latr = 33.0:dy:40.0  # the range of latitudes (start:step:end)

# Define the depth levels

# +
depthr = [0.,5., 10., 15., 20., 25., 30., 40., 50., 66,
    75, 85, 100, 112, 125, 135, 150, 175, 200, 225, 250,
    275, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750,
    800, 850, 900, 950, 1000, 1050, 1100, 1150, 1200, 1250,
    1300, 1350, 1400, 1450, 1500, 1600, 1750, 1850, 2000]

# or for testing just a few levels
depthr = [0.,20.,50.]

@show size(depthr);
# -

# The error variance of the observation (scaled by the error variance of the background).
# Note that this is the inverse of the signal-to-noise ratio used in the 2D version of `DIVA`.

epsilon2 = 0.2;

# * Correlation length in meters (in x, y, and z directions)
# * 300_000. is the same as 300000., but the former is easier to read.

# +
sz = (length(lonr),length(latr),length(depthr))

lenx = fill(300_000.,sz)
leny = fill(300_000.,sz)
lenz = [10+depthr[k]/15 for i = 1:sz[1], j = 1:sz[2], k = 1:sz[3]];
# -

# Year range and averaging time window

# +

# winter: January-March    1,2,3
# spring: April-June       4,5,6
# summer: July-September   7,8,9
# autumn: October-December 10,11,12

monthlists = [
    [1,2,3],
    [4,5,6],
    [7,8,9],
    [10,11,12]
];
# -

# * Other possible choises for the time selector are `TimeSelectorYearListMonthList` and `TimeSelectorRunningAverage`.
# * Type `?` followed by these functions for more information

# +
TS = TimeSelectorYearListMonthList([2010:2015],monthlists)

# File name based on the variable (but all spaces are replaced by _)
filename = "DIVAnd-analysis-$(lowercase(varname)).nc"

# Time origin for the NetCDF file
timeorigin = DateTime(1900,1,1,0,0,0)

# Extract the bathymetry for plotting
bx,by,b = DIVAnd.extract_bath(bathname,bathisglobal,lonr,latr);
# -

# A list of all metadata

metadata = OrderedDict(
    # Name of the project (SeaDataCloud, SeaDataNet, EMODNET-chemistry, ...)
    "project" => "SeaDataCloud",

    # URN code for the institution EDMO registry,
    # e.g. SDN:EDMO::1579
    "institution_urn" => "SDN:EDMO::1579",

    # Production group
    #"production" => "Diva group",

    # Name and emails from authors
    "Author_e-mail" => ["Your Name1 <name1@example.com>", "Other Name <name2@example.com>"],

    # Source of the observation
    "source" => "observational data from SeaDataNet/EMODNet Chemistry Data Network",

    # Additional comment
    "comment" => "...",

    # SeaDataNet Vocabulary P35 URN
    # http://seadatanet.maris2.nl/v_bodc_vocab_v2/search.asp?lib=p35
    # example: SDN:P35::WATERTEMP
    "parameter_keyword_urn" => "SDN:P35::WATERTEMP",

    # List of SeaDataNet Parameter Discovery Vocabulary P02 URNs
    # http://seadatanet.maris2.nl/v_bodc_vocab_v2/search.asp?lib=p02
    # example: ["SDN:P02::TEMP"]
    "search_keywords_urn" => ["SDN:P02::TEMP"],

    # List of SeaDataNet Vocabulary C19 area URNs
    # SeaVoX salt and fresh water body gazetteer (C19)
    # http://seadatanet.maris2.nl/v_bodc_vocab_v2/search.asp?lib=C19
    # example: ["SDN:C19::3_1"]
    "area_keywords_urn" => ["SDN:C19::3_3"],

    "product_version" => "1.0",

    "product_code" => "something-to-decide",

    # bathymetry source acknowledgement
    # see, e.g.
    # * EMODnet Bathymetry Consortium (2016): EMODnet Digital Bathymetry (DTM).
    # https://doi.org/10.12770/c7b53704-999d-4721-b1a3-04ec60c87238
    #
    # taken from
    # http://www.emodnet-bathymetry.eu/data-products/acknowledgement-in-publications
    #
    # * The GEBCO Digital Atlas published by the British Oceanographic Data Centre on behalf of IOC and IHO, 2003
    #
    # taken from
    # https://www.bodc.ac.uk/projects/data_management/international/gebco/gebco_digital_atlas/copyright_and_attribution/

    "bathymetry_source" => "The GEBCO Digital Atlas published by the British Oceanographic Data Centre on behalf of IOC and IHO, 2003",

    # NetCDF CF standard name
    # http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
    # example "standard_name" = "sea_water_temperature",
    "netcdf_standard_name" => "sea_water_temperature",

    "netcdf_long_name" => "sea water temperature",

    "netcdf_units" => "degree Celsius",

    # Abstract for the product
    "abstract" => "...",

    # This option provides a place to acknowledge various types of support for the
    # project that produced the data
    "acknowledgement" => "...",

    "documentation" => "https://doi.org/doi_of_doc",

    # Digital Object Identifier of the data product
    "doi" => "...")

# * Make the NetCDF global and variable attributes based on the metadata.
# * Custom attributes can be added by changing `ncglobalattrib`:
#
# ```julia
# ncglobalattrib["attribute_name"] = "attribute_value"
# ```
#

ncglobalattrib,ncvarattrib = SDNMetadata(metadata,filename,varname,lonr,latr)

# Plot the results near the surface for debugging and quick inspection.
#
# To generate the plots, we define a function `plotres` (see next cell) that will be used as an optional argument when we call the interpolation with `DIVAnd`.

function plotres(timeindex,sel,fit,erri)
    tmp = copy(fit)
    tmp[erri .> .5] .= NaN;
    figure(figsize = (10,5))

    # select the data near the surface
    selsurface = sel .& (obsdepth .< 5)
    vmin,vmax = quantile(obsval[selsurface],(0.01,0.99))

    # plot the data
    subplot(1,2,1)
    scatter(obslon[selsurface],obslat[selsurface],10,obsval[selsurface];
            vmin = vmin, vmax = vmax)
    xlim(minimum(lonr),maximum(lonr))
    ylim(minimum(latr),maximum(latr))
    colorbar(orientation="horizontal")
    contourf(bx,by,b', levels = [-1e5,0],colors = [[.5,.5,.5]])
    gca().set_aspect(1/cosd(mean(by)))
    title("Observations (season $(timeindex))")

    # plot the analysis
    subplot(1,2,2)
    pcolor(lonr,latr,permutedims(tmp[:,:,1],[2,1]);
           vmin = vmin, vmax = vmax)
    colorbar(orientation="horizontal")
    contourf(bx,by,b', levels = [-1e5,0],colors = [[.5,.5,.5]])
    gca().set_aspect(1/cosd(mean(by)))
    title("Analysis (season $(timeindex))")
end

# Launch the analysis. Plotting can be disabled by commenting the line containing `plotres`.
#
# Here we use `diva3d`, which performs a series of 3D analyses (lon, lat and depth) for the different periods defined previously.

# +
if isfile(filename)
   rm(filename) # delete the previous analysis
end

@time dbinfo = diva3d(
    (lonr,latr,depthr,TS),
    (obslon,obslat,obsdepth,obstime),
    obsval,
    (lenx,leny,lenz),
    epsilon2,
    filename,varname,
    bathname = bathname,
    bathisglobal = bathisglobal,
    plotres = plotres,
    ncvarattrib = ncvarattrib,
    ncglobalattrib = ncglobalattrib,
    timeorigin = timeorigin,
    QCMETHOD = 0,
);


residual = dbinfo[:residuals];
# -

# This generates many plots (one for every time instance).
# The number in the title is the time index starting with the first season and year.
#

# Save the observation metadata in the NetCDF file

DIVAnd.saveobs(filename,(obslon,obslat,obsdepth,obstime),obsid)

# # Residuals

# Range of the residuals

res = dbinfo[:residuals]
@show extrema(res)

# Residuals with NaNs removed

# +
res = residual[.!isnan.(residual)]

@show extrema(res);
@show quantile(res,[0.01,0.99]);
# -

# Get the identifier of the anomalous point

i = findfirst(minimum(res) .== residual)
obsid[i]

# For future analysis the residuals can also be saved.

# +
resname = "$(varname)_residuals.nc"
DIVAnd.saveobs(resname,"$(varname)_residual",residual,(obslon,obslat,obsdepth,obstime),obsid)
# -

# * Visualize the residuals (observations minus analysis)
# * Change depth and time
# * Adjust colorbare range (`clim`) to see large residuals

figure()
sel = (obsdepth .<  5) .& (Dates.month.(obstime) .== 1)
print("Number of data points: $(sum(sel))")
scatter(obslon[sel],obslat[sel],10,residual[sel]; cmap="RdBu_r")
clim(-3,3)
# set the correct aspect ratio
gca().set_aspect(1/cosd(mean(latr)))
colorbar();
contourf(bx,by,b', levels = [-1e5,0],colors = [[.5,.5,.5]])

# DIVAnd computes also a quality score (a-dimensional)
# which can be used to remove bad data (or flag)

figure()
qcvalues = dbinfo[:qcvalues]
scatter(obslon[sel],obslat[sel],10,qcvalues[sel]; cmap="RdBu_r")
# set the correct aspect ratio
gca().set_aspect(1/cosd(mean(latr)))
colorbar()
contourf(bx,by,b', levels = [-1e5,0],colors = [[.5,.5,.5]])

# Histgram of the quality score

figure()
hist(qcvalues,1000)
xlim(0,20)
xlabel("number of data points")
ylabel("qc value")

# Choose a maximum value of the quality score

max_qcvalue = 7
good = qcvalues .< max_qcvalue;

# # Final analysis
# Repeat the analysis keeping only the good data

obslon,obslat,obsdepth,obstime = obslon[good],obslat[good],obsdepth[good],obstime[good]
obsval = obsval[good];

@time dbinfo = diva3d(
    (lonr,latr,depthr,TS),
    (obslon,obslat,obsdepth,obstime),
    obsval,
    (lenx,leny,lenz),
    epsilon2,
    filename,varname,
    bathname = bathname,
    bathisglobal = bathisglobal,
    plotres = plotres,
    ncvarattrib = ncvarattrib,
    ncglobalattrib = ncglobalattrib,
    timeorigin = timeorigin,
);
