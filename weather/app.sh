#! /usr/bin/bash

city_form_preamble="http://api.openweathermap.org/data/2.5/weather?q="

if [ $1 != "" ]; then
	city_input=$1
else
	echo -n "Enter the name of the city for which you require weather information."
	read city_input
fi

if [ $2 != "" ]; then
	api_key=$2
else
	echo -n "Enter the API key:"
	read api_key
fi

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
	place=$(echo $api_response | jq -r .name)
	long=$(echo $api_response | jq -r .coord.lon)
	lat=$(echo $api_response | jq -r .coord.lat)
	weather=$(echo $api_response | jq -r .weather.[0].main)
	description=...$(echo $api_response | jq -r .weather.[0].description)
	icon=$(echo $api_response | jq -r .weather.[0].icon)
	temp=$(echo $api_response | jq -r .main.temp)
	feels_like_temp=$(echo $api_response | jq -r .main.feels_like)
	min_temp=$(echo $api_response | jq -r .main.temp_min)
	max_temp=$(echo $api_response | jq -r .main.temp_max)
	humidity=$(echo $api_response | jq -r .main.humidity)
	timezone=$(echo $api_response | jq -r .timezone)
else
	place=$(echo $api_response | jq -r .list.name)
	long=$(echo $api_response | jq -r .list.coord.lon)
	lat=$(echo $api_response | jq -r .list.coord.lat)
	weather=$(echo $api_response | jq -r .list.weather.[0].main)
	description=...$(echo $api_response | jq -r .list.weather.[0].description)
	icon=$(echo $api_response | jq -r .list.weather.[0].icon)
	temp=$(echo $api_response | jq -r .list.main.temp)
	feels_like_temp=$(echo $api_response | jq -r .list.main.feels_like)
	min_temp=$(echo $api_response | jq -r .list.main.temp_min)
	max_temp=$(echo $api_response | jq -r .list.main.temp_max)
	humidity=$(echo $api_response | jq -r .list.main.humidity)
	timezone=$(echo $api_response | jq -r .list.timezone)
fi

# output data
echo $place
echo $long
echo $lat
echo $weather
echo $description
echo $icon
echo $temp
echo $feels_like_temp
echo $min_temp
echo $max_temp
echo $humidity
echo $timezone
