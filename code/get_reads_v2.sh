#!/bin/bash
#SBATCH -c 1									# cores
#SBATCH --mem 48G								# memory
#SBATCH -t 0-04:00								# runtime in D-HH:MM format
#SBATCH -p short								# parition (short, medium, long)
#SBATCH -o /home/mjl62/logs/getreads_v2_%j.out		# file for STDOUT, with job in filename
#SBATCH -e /home/mjl62/logs/getreads_v2_%j.err		# file for STDERR, with job in filename
#SBATCH --open-mode=append						# append log files
#SBATCH --mail-type=ALL							# email notification type
#SBATCH --mail-user=mleukam@bidmc.harvard.edu	# email to which notifications will be sent

# set unofficial BASH strict mode
set -euo pipefail
IFS=$'\n\t'

## write in error handling function
error_exit()
{
#	----------------------------------------------------------------
#	Function for exit due to fatal program error
#		Accepts 1 argument:
#			string containing descriptive error message
#	----------------------------------------------------------------
	echo "${progname}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

# make array of relevant filepaths
input_folder=/n/scratch3/users/m/mw292/AGAMEMNON/TCGA/Results2/
x=$(find ${input_folder} -name 'pufferfish_mapping.log') || error_exit "unable to execute find"

# extract metadata and readcount and add to csv
for f in "${x[@]}"
do
	# get the 10th field in filepath separated by slashes
	# which is tcga_project (folder name)
	proj=$(echo ${f} | awk -F'/' '{print $10}')
	# get gdc file_id from filepath
	fileid=$(echo ${f} | awk -F'/' '{print $11}')
	# get readcounts (6th field by whitespace in line with 'Observed')
	readcount=$(grep 'Observed' ${f} | awk -F' ' '{print $6}')
	# write line of csv
	# echo automatically adds newline
	echo "${proj},${fileid},${readcount}"
done > ~/tcga_micro/2021_01_20_readcounts.csv  || error_exit "unable to extract values"

## exit
exit 0