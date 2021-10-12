#!/bin/sh

URL=https://yemekhane.boun.edu.tr/aylik-menu
raw_data=$(curl -s $URL)


# $1 -> data 
# $2 -> item

month=$(echo "$raw_data" | grep -m1  -Po 'aylik_menu-(.*?)-01' | cut -c 12- | rev | cut -c 4- | rev)
n_days=$(cal $(date +"%m %Y") | awk 'NF {DAYS = $NF}; END {print DAYS}')

get_item()
{
	echo $(echo "$1" | grep $2 | grep -Po '"">(.*?)<\/a>'| cut -c 4- | rev | cut -c 5- | rev)
}



# $1 -> day
get_menu()
{
	local oglen_data=$(echo "$raw_data" |  grep -A13 aylik_menu-$month-$(printf %02d $1)-0 | tail -n +7)


	local oglen_corba=$(get_item "$oglen_data" ccorba)
	local oglen_ana=$(get_item "$oglen_data" anaa-yemek)
	local oglen_vegan=$(get_item "$oglen_data" vejetarien)
	local oglen_yardimci=$(get_item "$oglen_data" yardimciyemek)
	local oglen_aperatif=$(get_item "$oglen_data" aperatiff)

	local aksam_data=$(echo "$raw_data" |  grep -A28 aylik_menu-$month-$(printf %02d $1)-0 | tail -n +23)

	local aksam_corba=$(get_item "$aksam_data" ccorba)
	local aksam_ana=$(get_item "$aksam_data" anaa-yemek)
	local aksam_vegan=$(get_item "$aksam_data" vejetarien)
	local aksam_yardimci=$(get_item "$aksam_data" yardimciyemek)
	local aksam_aperatif=$(get_item "$aksam_data" aperatiff)



	echo -n '{"tarih":"'$month-$(printf %02d $1)'","ogle":{"corba":"'$oglen_corba'","ana":"'$oglen_ana'","vegan":"'$oglen_vegan'","yardimci":"'$oglen_yardimci'","aperatif":"'$oglen_aperatif'"},"aksam":{"corba":"'$aksam_corba'","ana":"'$aksam_ana'","vegan":"'$aksam_vegan'","yardimci":"'$aksam_yardimci'","aperatif":"'$aksam_aperatif'"}}'

	if [ "$1" != "$n_days" ]
	then
		echo -n ,
	fi
}


echo -n {"\""$month"\"":'[' 

for i in $(seq 1 $n_days)
do
get_menu $i
done

echo -n ']}'
