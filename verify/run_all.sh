#!/bin/bash

main="$1"
mkdir -p output
rm -rf output/*

POINTS=0

dir=`dirname "$1"`

cd "$dir"
if [ -f yarn.lock ];
then
	yarn || npm install
else
	npm install
fi

cd -

for folder in robot/*
do
	if [ -d $folder ];
	then
		if [ -f "$folder"/run.txt ];
		then
			echo `head -n 1 "$folder"/run.txt`
			P=`head -n 2 "$folder"/run.txt | tail -n 1`
		else
			echo `basename $folder`
			P=10
		fi
		for file in "$folder"/*.s
		do
			inputfile="verify/$file"
			outputfile=output/`basename "$file"`.out
			originalfile="$file.out"
			errorsfile=output/`basename "$file"`.err
			title=`head -n 1 "$file" | grep '#' | cut -d '#' -f 2`
			if [ `echo -n "$title" | wc -c` -eq 0 ];
			then
				title=`basename $file`
			fi
			node "$1" "$inputfile" > "$outputfile"
			strtitle="Verifying $title"
			printf '%s' "$strtitle"
			pad=$(printf '%0.1s' "."{1..60})
			padlength=65
			if diff "$originalfile" "$outputfile" &> "$errorsfile"
			then
				str="ok (""$P""p)"
				POINTS=$(($POINTS+$P))
			else
				str="error (0p)"
			fi
			printf '%*.*s' 0 $((padlength - ${#strtitle} - ${#str} )) "$pad"
		    printf '%s\n' "$str"
		done
	fi
done

echo 'Points: '$POINTS
