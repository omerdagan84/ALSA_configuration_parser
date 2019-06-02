#!/bin/bash

echo "#configuration file" > file.conf
item_l=()
param=""
ctrl_parse=0
cat $1 | while read line
do
	if [ $ctrl_parse -eq 0 ]
	then
		min=-1
		max=-1
		type=""
		values=-1
		wait_for_item=0
		item_l=()
	fi
	param=$(echo $line | awk {'print $1'})
	case $param in
		numid=*)
			ctrl_parse=1
			name=$(echo $line | awk -F, {'print $3'})
			;;
		";")
			if [ $wait_for_item -eq 1 ]; then
				item_l+="'""$(echo $line | awk -F\' '{print $2}')""' "
			fi

			if [[ $line == *"type="* ]]; then
#				set -x
				type=$(echo $line | sed -n -E 's/^.*(type=)([a-z,A-Z]*),.*/\2/p')
#				echo $type
#				set +x
				case $type in
					ENUMERATED)
						items=$(echo $line | sed -n -E 's/^.*(items=)([0-9]*),.*/\2/p')
						wait_for_item=1

						;;
					BOOLEAN)
						values=$(echo $line | sed -n -E 's/^.*(values=)([0-9]*),.*/\2/p')

						;;
					INTEGER)
						min=$(echo $line | sed -n -E 's/^.*(min=)([0-9]*),.*/\2/p')

						max=$(echo $line | sed -n -E 's/^.*(max=)([0-9]*),.*/\2/p')

						values=$(echo $line | sed -n -E 's/^.*(values=)([0-9]*),.*/\2/p')

						;;

				esac
			fi
			;;
		":")
			case $type in
				ENUMERATED)
					echo "#$name options($item_l)" >> file.conf
					;;
				BOOLEAN)
					echo "#$name $values(on\\off)" >> file.conf
					;;
				INTEGER)
					echo "#$name $values($min..$max)" >> file.conf
					;;	
			esac 
			echo "amixer -q cset $name" >> file.conf
			echo "#-------------------------" >> file.conf
			echo "detected
			$name
			type= $type 
			min= $min 
			max=$max 
			values=$values
			items=$item_l"
			ctrl_parse=0
			;;
		*) 
			;;
	esac
done
