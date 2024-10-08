#! /usr/bin/bash

if [ $1 != "" ]; then
	city_input=$1
else
	exit 1
fi

if [ $2 != "" ]; then
	api_key=$2
else
	exit 1
fi

city_form_preamble="http://api.openweathermap.org/data/2.5/weather?q="
api_postamble="&appid="$api_key"&units=metric"

city_input=$(
echo $city_input | sed 's/_/%20/g'
)

city_form=$city_form_preamble$city_input$api_postamble

api_response=$(
curl -s $city_form 
)

count=$(echo $api_response | jq -r .count)
if [[ -n $count ]] then
	long=$(echo $api_response | jq -r .coord.lon)
	lat=$(echo $api_response | jq -r .coord.lat)
else
	long=$(echo $api_response | jq -r .list.coord.lon)
	lat=$(echo $api_response | jq -r .list.coord.lat)
fi

city_form_preamble="http://api.openweathermap.org/data/2.5/air_pollution?lat="
long_postamble="&lon="
api_postamble="&appid="

api_request=$city_form_preamble$lat$long_postamble$long$api_postamble$api_key

api_response=$(
curl -s $api_request 
)

# no2=$(echo $api_response | jq -r .list.[0].components.no2)
# o3=$(echo $api_response | jq -r .list.[0].components.o3)
# so2=$(echo $api_response | jq -r .list.[0].components.so2)
# pm2_5=$(echo $api_response | jq -r .list.[0].components.pm2_5)
# pm10=$(echo $api_response | jq -r .list.[0].components.pm10)
# 
# nh3=$(echo $api_response | jq -r .list.[0].components.nh3)
# no=$(echo $api_response | jq -r .list.[0].components.no)
# 
# table_header="CO NO NO2 O3 SO2 NH3 PM2.5 PM10"
# data="$co $no $no2 $o3 $so2 $pm2_5 $pm10 $nh3"
# 
# table_data="$table_header
# $data"
# 
# echo "$table_data" > ./aqi/printout.txt
# 
# column ./aqi/printout.txt -t -s " "

echo "
       Good  Fair  Mod   Poor  Very Poor
       |     |     |     |     |"

# Qualitative name	 Index	 Pollutant concentration in μg/m3
#                            SO2	      NO2	       PM10	        PM2.5	   O3	        CO
# Good	             1	     [0; 20)	  [0; 40)	   [0; 20)	    [0; 10)	   [0; 60)	    [0; 4400)
# Fair	             2	     [20; 80)	  [40; 70)	   [20; 50)	    [10; 25)   [60; 100)	[4400; 9400)
# Moderate	         3	     [80; 250)	  [70; 150)	   [50; 100)	[25; 50)   [100; 140)	[9400-12400)
# Poor	             4	     [250; 350)	  [150; 200)   [100; 200)	[50; 75)   [140; 180)	[12400; 15400)
# Very Poor	         5	     ⩾350	      ⩾200         ⩾200	        ⩾75	       ⩾180         ⩾15400

# NH3: min value 0.1 - max value 200
# NO: min value 0.1 - max value 100

# https://openweathermap.org/air-pollution-index-levels

# co
value=$(echo $api_response | jq -r .list.[0].components.co)
# cast to int
value=$( printf "%.0f" $value )
if ((0 <= $value <= 4400)); then
	echo "CO     [░░░░░░░░░░░░░░░░░░░░░░░]"
elif ((4401 <= $value <= 9400)); then
	echo "CO     [▓▓▓▓▓░░░░░░░░░░░░░░░░░░]"
elif ((9401 <= $value <= 12400)); then
	echo "CO     [▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░]"
elif ((12401 <= $value <= 15400)); then
	echo "CO     [▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░]"
else
	echo "CO     [▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓]"
fi

# no2
value=$(echo $api_response | jq -r .list.[0].components.no2)
# cast to int
value=$( printf "%.0f" $value )
if (($value >= 0 && $value <= 40)); then
	echo "NO2    [░░░░░░░░░░░░░░░░░░░░░░░]"
elif (($value >= 41 && $value <= 70)); then
	echo "NO2    [▓▓▓▓▓░░░░░░░░░░░░░░░░░░]"
elif (($value >= 71 && $value <= 150)); then
	echo "NO2    [▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░]"
elif (($value >= 151 && $value <= 200)); then
	echo "NO2    [▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░]"
else
	echo "NO2    [▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓]"
fi

# o3
value=$(echo $api_response | jq -r .list.[0].components.o3)
# cast to int
value=$( printf "%.0f" $value )
if (($value >= 0 && $value <= 4400)); then
	echo "O3     [░░░░░░░░░░░░░░░░░░░░░░░]"
elif (($value >= 4401 && $value <= 9400)); then
	echo "O3     [▓▓▓▓▓░░░░░░░░░░░░░░░░░░]"
elif (($value >= 9401 && $value <= 12400)); then
	echo "O3     [▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░]"
elif (($value >= 12401 && $value <= 15400)); then
	echo "O3     [▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░]"
else
	echo "O3     [▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓]"
fi
	
# so2
value=$(echo $api_response | jq -r .list.[0].components.so2)
# cast to int
value=$( printf "%.0f" $value )
if (($value >= 0 && $value <= 4400)); then
	echo "SO2    [░░░░░░░░░░░░░░░░░░░░░░░]"
elif (($value >= 4401 && $value <= 9400)); then
	echo "SO2    [▓▓▓▓▓░░░░░░░░░░░░░░░░░░]"
elif (($value >= 9401 && $value <= 12400)); then
	echo "SO2    [▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░]"
elif (($value >= 12401 && $value <= 15400)); then
	echo "SO2    [▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░]"
else
	echo "SO2    [▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓]"
fi
	
# pm2_5
value=$(echo $api_response | jq -r .list.[0].components.pm2_5)
# cast to int
value=$( printf "%.0f" $value )
if (($value >= 0 && $value <= 4400)); then
	echo "PM2.5  [░░░░░░░░░░░░░░░░░░░░░░░]"
elif (($value >= 4401 && $value <= 9400)); then
	echo "PM2.5  [▓▓▓▓▓░░░░░░░░░░░░░░░░░░]"
elif (($value >= 9401 && $value <= 12400)); then
	echo "PM2.5  [▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░]"
elif (($value >= 12401 && $value <= 15400)); then
	echo "PM2.5  [▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░]"
else
	echo "PM2.5  [▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓]"
fi
	
# pm10
value=$(echo $api_response | jq -r .list.[0].components.pm10)
# cast to int
value=$( printf "%.0f" $value )
if (($value >= 0 && $value <= 4400)); then
	echo "PM10   [░░░░░░░░░░░░░░░░░░░░░░░]"
elif (($value >= 4401 && $value <= 9400)); then
	echo "PM10   [▓▓▓▓▓░░░░░░░░░░░░░░░░░░]"
elif (($value >= 9401 && $value <= 12400)); then
	echo "PM10   [▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░]"
elif (($value >= 12401 && $value <= 15400)); then
	echo "PM10   [▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░]"
else
	echo "PM10   [▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓]"
fi
