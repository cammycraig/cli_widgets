#! /usr/bin/bash

rm -f ./digital_clock/clock_display.txt
touch ./digital_clock/clock_display.txt

if [ $1 != "" ]; then
	city_input=$1
else
	exit 1
fi

if [ $2 != "" ]; then
	font=$2
else
	exit 1
fi

if [ $3 != "" ]; then
	format=$3
else
	exit 1
fi

if [ $4 != "" ]; then
	military=$4
else
	exit 1
fi

if [ $5 != "" ]; then
	api_key=$5
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
	differential=$(echo $api_response | jq -r .timezone)
else
	differential=$(echo $api_response | jq -r .list.timezone)
fi

utc_epoch=$(date -u +%s)

timezone_relative_epoch=$(($utc_epoch+$differential))

timezone_relative_date=$(date -u -d @$timezone_relative_epoch +"$format")

for (( i=0; i<${#timezone_relative_date}; i++ )); do
	if [ ${timezone_relative_date:$i:1} == ":" ]; then
		clock_display="$(paste -d '' ./digital_clock/clock_display.txt ./digital_clock/digit_fonts/"$font"/colon.txt)"
		echo "${clock_display}" > ./digital_clock/clock_display.txt
	else
		clock_display="$(paste -d '' ./digital_clock/clock_display.txt ./digital_clock/digit_fonts/"$font"/"${timezone_relative_date:$i:1}".txt)"
		echo "${clock_display}" > ./digital_clock/clock_display.txt
	fi
done

# add am/pm for 12h times

postfix_code=""

if [ $military == 12 ]; then
	echo "$(date +"%P")" > ./digital_clock/postfix.txt
	line_count=$(wc -l < ./digital_clock/clock_display.txt)
	line_count=$(($line_count-1))
	for ((i = 0 ; i < $line_count ; i++ )); do
		sed -i '1s/^/\n /' ./digital_clock/postfix.txt
	done
	clock_display="$(paste -d ' ' ./digital_clock/clock_display.txt ./digital_clock/postfix.txt)"
	echo "${clock_display}" > ./digital_clock/clock_display.txt
fi

cat ./digital_clock/clock_display.txt


