#! /usr/bin/bash

if [ $1 != "" ]; then
	city_input=$1
else
	echo -n "Enter the name of the city for which you require weather information:"
	read city_input
fi

# if [ $2 != "" ]; then
# 	api_key=$2
# else
# 	echo -n "Enter the API key:"
# 	read api_key
# fi

clock_display=$(
bash ./digital_clock/app.sh $city_input crazy %H:%M 12 5a8c6304f61bdb20dc8ee51191b659b1
)

echo "$clock_display"

weather_display=$(
bash ./weather/app.sh $city_input 5a8c6304f61bdb20dc8ee51191b659b1
)

echo "$weather_display"

aqi_display=$(
bash ./aqi/app.sh $city_input 5a8c6304f61bdb20dc8ee51191b659b1
)

echo "$aqi_display"
