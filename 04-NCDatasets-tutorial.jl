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

# # Tutorials
#
# ## Data from Copernicus Marine
#
# This examples shows how to download sea surface temperature from the
# [Mediterranean Sea High Resolution and Ultra High Resolution Sea Surface Temperature Analysis ](https://doi.org/10.48670/moi-00172) provided by
# [Copernicus Marine Service](https://marine.copernicus.eu/).
# Username and password are obtained after [registration](https://resources.marine.copernicus.eu/registration-form).

# The username and password can be added to the URL. For example
# `https://example.org/path` should become `https://username:password@example.org/path`:

using NCDatasets, PyPlot, Statistics, URIs

# Add here your username and password so that the following lines read:
# ```julia
# username = "me";
# password = "paßwörth";
# ```

username = ENV["CMEMS_USERNAME"];
password = ENV["CMEMS_PASSWORD"];

# Add username and password to url

url = "https://nrt.cmems-du.eu/thredds/dodsC/SST_MED_SST_L4_NRT_OBSERVATIONS_010_004_a_V2"
url2 = string(URI(URI(url),userinfo = string(username,":",password)));

# Note this will output the URL with username/password. Add a semicolon to the
# next line to surpress the output

ds = NCDataset(url2)

# But we will use a local file to save bandwith

close(ds)
url2 = "SST_MED_SST_L4_NRT_OBSERVATIONS_010_004_a_V2_slice1.nc"
ds = NCDataset(url2)

# Load the data

ncvar = ds["analysed_sst"];
SST = ncvar[:,:,1]
lon = ds["lon"][:]
lat = ds["lat"][:]
time = ds["time"][1]

# Make a plot

clf()
pcolormesh(lon,lat,nomissing(SST,NaN)')
cbar = colorbar(orientation="horizontal")
cbar.set_label(ncvar.attrib["units"])
gca().set_aspect(1/cosd(mean(lat)))
title("$(ncvar.attrib["long_name"]) $time")

# Alternatively, one can also create the files `.netrc` and `.ncrc` in the your home directory with your credentials as explained for the NASA EarthData example which allows you to manage your passwords in a central configuration file and reduce the risk to accidentally share your credentials.

# ## Data from NASA EarthData
#
# This example shows show to download data via OPeNDAP from the [NASA EarthData](https://www.earthdata.nasa.gov/)
# which requires a username and password.
#
# You need to be registered at [https://urs.earthdata.nasa.gov/users/new](https://urs.earthdata.nasa.gov/users/new)
# to get your credentials.
#
# Simply adding username and password to the URL for NASA Earth Data OPeNDPAP services is unfortunately not sufficient as it uses a different authentication mechanism.
#
# Create a `.netrc` file with the following content in your home directory:
#
# ```
# machine urs.earthdata.nasa.gov
#     login YOUR_USERNAME
#     password YOUR_PASSWORD
# ```
#
# where `YOUR_USERNAME` and `YOUR_PASSWORD` is your Earth Data username and password.
#
# Create a `.ncrc` file with the following content in your home directory:
#
# ```
# HTTP.NETRC=/home/abarth/.netrc
# ```
#
# where `HTTP.NETRC` is the full path to your new `.netrc` file.
# Note: if you are using docker, your home directory is `/home/jovan/`.
# You can test whether your configuration files are correct independently of NCDatasets
# by using the tool `ncdump` (one line):
#
# ```bash
# ncdump -h "https://opendap.earthdata.nasa.gov/providers/POCLOUD/collections/GHRSST%20Level%204%20MUR%20Global%20Foundation%20Sea%20Surface%20Temperature%20Analysis%20(v4.1)/granules/20190101090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1"
# ```
#
# This should return the metadata of the OPeNDAP resource:
#
# ```
# netcdf \20190101090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04 {
# dimensions:
# 	lat = 17999 ;
# 	lon = 36000 ;
# 	time = 1 ;
# variables:
# 	short analysed_sst(time, lat, lon) ;
# [...]
# ```
#
#
# This is the typically error message which is returned when the credentials are not configured properly:
#
# ```
# syntax error, unexpected WORD_WORD, expecting SCAN_ATTR or SCAN_DATASET or SCAN_ERROR
# context: HTTP^ Basic: Access denied.
# ```
#
# When there is an error on the server side (500 internal server error), you might get the following error:
#
# ```
# syntax error, unexpected $end, expecting SCAN_ATTR or SCAN_DATASET or SCAN_ERROR
# context: ^
# ncdump: https://opendap.earthdata.nasa.gov/providers/POCLOUD/collections/GHRSST%20Level%204%20MUR%20Global%20Foundation%20Sea%20Surface%20Temperature%20Analysis%20(v4.1)/granules/20190101090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1: NetCDF: Malformed or inaccessible DAP2 DDS or DAP4 DMR response
# ```

# Creating these configuration files is a bit fidely from jupyerlab.
# You can create these programmatically via these commands (where you need to put your username and password):

# +
write(expanduser("~/.netrc"),"""
machine urs.earthdata.nasa.gov
    login USERNAME
    password PASSWORD
""");

write(expanduser("~/.ncrc"),"""
HTTP.NETRC=$(expanduser("~/.netrc"))
""");
# -

# Check the content of the file with:

print(read(expanduser("~/.netrc"),String))

print(read(expanduser("~/.ncrc"),String))

# > **_Important:_** You must *restart* julia (e.g. Kernel > Restart Kernel if you use Jupyterlab)
#
# Here we use the [GHRSST Level 4 MUR Global Foundation Sea Surface Temperature Analysis (v4.1)](https://podaac.jpl.nasa.gov/dataset/MUR-JPL-L4-GLOB-v4.1) dataset.
# In the following example, we download the data via OPeNDAP for a chosen bounding box and given time instance.

# +
using NCDatasets, PyPlot, Dates, Statistics

url = "https://opendap.earthdata.nasa.gov/providers/POCLOUD/collections/GHRSST%20Level%204%20MUR%20Global%20Foundation%20Sea%20Surface%20Temperature%20Analysis%20(v4.1)/granules/20190101090000-JPL-L4_GHRSST-SSTfnd-MUR-GLOB-v02.0-fv04.1"

ds = NCDataset(url)
# -

# Did you got an "Access denied" error? If yes, please check:
# * check your credentials at https://urs.earthdata.nasa.gov/
# * check the content of your files in `~/.ncrc` and `~/.netrc`
# * restart Julia
# * check the `ncdump -h` shell command above in a terminal
# * be aware that a `.ncrc` file in your current directory overrides the file in your home directory


# Bounding box

# range of longitude
lonr = (-6, 37.0)
# range of latitude
latr = (29, 45.875)

# Load a subset

# +
ds_subset = NCDatasets.@select(
    ds["analysed_sst"],
    $lonr[1] <= lon <= $lonr[2] && $latr[1] <= lat <= $latr[2])

ncvar = ds_subset["analysed_sst"]
SST = ncvar[:,:,1]
lon = ds_subset["lon"][:]
lat = ds_subset["lat"][:]
time = ds_subset["time"][1]
# -

# Make a plot

clf()
pcolormesh(lon,lat,nomissing(SST,NaN)');
gca().set_aspect(1/cosd(mean(lat)))
cbar = colorbar(orientation="horizontal")
cbar.set_label(ncvar.attrib["units"])
plt.title("$(ncvar.attrib["long_name"]) $time")


# ## Access data from S3 object storage

# NASA EarthData is also available from AWS S3 object storage at the AWS region us-west-2. This example assumes that you have access to an AWS instance in this region (available thought e.g. [Pangeo Cloud](https://pangeo.io/cloud.html) after registration thanks to funding from the NSF and the fine folks at [Pangeo](https://github.com/pangeo-data)).
#
# The S3 access token available from [https://archive.podaac.earthdata.nasa.gov/s3credentials](https://archive.podaac.earthdata.nasa.gov/s3credentials) are only valid for 1 hour. It is therefore preferable to get this token programmatically using your EarthData username and password. The function `earthdata_s3credentials` is a translation of ["Sample script to receive credentials"](https://web.archive.org/web/20220623090241/https://nasa.github.io/cumulus-distribution-api/#temporary-s3-credentials) to Julia:
#
# ```julia
# using AWS, Base64, JSON3, HTTP, NCDatasets, URIs
# using AWS: @service
# @service S3
#
# function earthdata_s3credentials(
#     username, password;
#     credentials_url = "https://archive.podaac.earthdata.nasa.gov/s3credentials")
#
#     origin = URI(credentials_url).scheme
#
#     resp = HTTP.get(credentials_url,redirect=false)
#     authorize_url = Dict(resp.headers)["Location"]
#
#     auth = base64encode(string(username,":",password))
#
#     resp2 = HTTP.post(authorize_url,["Origin" => origin],
#                       "credentials=$auth",redirect=false)
#     redirect_url=Dict(resp2.headers)["Location"]
#
#     # cookie jar
#     jar = Dict{String, Set{HTTP.Cookie}}()
#
#     # raises a 500 error, as in the shell script, but we get a cookie!
#     HTTP.get(redirect_url; cookies=true,
#              cookiejar = jar, redirect = false,
#              status_exception = false)
#
#     resp4 = HTTP.get(credentials_url; cookies=true, cookiejar = jar, redirect = false)
#
#     cred = JSON3.read(resp4.body)
#     return cred
# end
#
# # add your credentials here (or get it programmatically from environment variables or a file)
# username = "..."
# password = "..."
#
# cred = earthdata_s3credentials(username,password)
# @info "Token expires: $(cred.expiration)"
#
#
# ENV["AWS_ACCESS_KEY_ID"] = cred.accessKeyId;
# ENV["AWS_SECRET_ACCESS_KEY"] = cred.secretAccessKey;
# ENV["AWS_SESSION_TOKEN"] = cred.sessionToken;
#
# c = AWS.global_aws_config();
#
# resp = S3.list_objects("podaac-ops-cumulus-protected",
#      Dict("prefix" => "MODIS_TERRA_L3_SST_MID-IR_DAILY_4KM_NIGHTTIME_V2019.0/",
#           "delimiter" => '/'))
#
# # download the first object
# data = S3.get_object("podaac-ops-cumulus-protected",resp["Contents"][1]["Key"]);
#
# # load the NetCDF dataset
# ds = NCDataset("temp-memory","r",memory = data)
# ```
#
# Output:
# ```
# CDataset: temp-memory
# Group: /
#
# Dimensions
#    lat = 4320
#    lon = 8640
#    rgb = 3
#    eightbitcolor = 256
#
# Variables
#   sst4   (8640 × 4320)
#     Datatype:    Int16
#     Dimensions:  lon × lat
#     Attributes:
#      long_name            = 4um Sea Surface Temperature
# [...]
# ```
#
# The example requires NCDatasets 0.12.5 which allows one to read a NetCDF dataset directly from a vector of bytes in memory.
#
# To debug, it is useful to run the `aws` shell command to list all keys in the buckets (it requires the `AWS_*` environment variables to be set):
#
# ```bash
# aws s3 ls s3://podaac-ops-cumulus-protected/MODIS_TERRA_L3_SST_THERMAL_DAILY_4KM_NIGHTTIME_V2019.0/
# ```
