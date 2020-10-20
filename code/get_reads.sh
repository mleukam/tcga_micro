#!/bin/bash

#first get the log file name: 1748
#pull the number of reads from 1748.err
#then get the uuid of the sample from 1748.out
#then, export that data to the sample_uuid/Analysis

for file in $1/*/*
do
	file="${file%.*}"
	echo "processing file $file"
	if [ -f $file".out" ]
	then
		download=$(grep -m 1 'File to Download' "$file.out")
		uuid=$(echo -n $download | tail -c 36)
	fi
	if [ -f $file".err" ]
	then
		processed=$(grep -m 1 'processed' "$file.err")
		size=${#processed}
		
		# get rid of the last 6 characters, i.e. "reads"
		reads=${processed:31:$size}
		readsize=${#reads}

		if [ $readsize -lt 10 ]
		then
			continue
		fi
		numreads=${reads::-6}
	fi

	# echo $file

	if [ -f $file".out" ] && [ -f $file".err" ]
	then
		#getting name of TCGA project
		name=${file:  46:$((${#file}-55))}
		echo $name

		resdir="/n/scratch3/users/m/mw292/AGAMEMNON/TCGA/Results/$name/$uuid/Analysis/$uuid"
		# echo $uuid
		echo "number of reads: $numreads"
		echo "result dir: $resdir"

		if [ ${#numreads} -gt 7 ]
		then
			echo "$numreads" > $resdir"/bam_reads.txt"
		fi
	fi

done