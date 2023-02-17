#! /bin/bash
development_dir=$( pwd )

function something() {

# looking over config.ns file in development_dir and setting entry point
# entry_point is the file path where the program would start (eg. main.sh)
entry_point=$( grep "^entry_point=" "$development_dir/config.ns" | cut -f2 -d"=" )
entry_point="$development_dir/$entry_point"

imported_files_path=$( grep 'import' $entry_point | cut -f2 -d' ' | nl -s"|${development_dir}/" -bt | cut -f2 -d'|' )

run_file_path="$development_dir/.run.sh"		# file that would run
rm $run_file_path 2> /dev/null

# appending content from imported files to .run.sh file
for import_file in $import_files
do
	cat $import_file >> $run_file_path
done

# appending content of entry_point file
imports_end_num=$( grep "^import " -n $entry_point | cut -f1 -d: | tail -n1 )
main_file_code_start=$(( $imports_end_num + 1 ))
tail -n+$(( $imports_end_num + 1 )) $entry_point >> $run_file_path

chmod 755 $run_file_path
$run_file_path
}

function bind() {
	local file_path=$1

	local imported_files_path=$( grep 'import' $file_path | cut -f2 -d' ' | nl -s"|${development_dir}/" -bt | cut -f2 -d'|' )
	if [[ -z $imported_files_path ]]
	then
		return 0
	fi

	local imported_file_path
	for imported_file_path in $imported_files_path
	do
		bind $imported_file_path
		cat $imported_file_path >> "${development_dir}/.run.temp"
	done

	grep "^import " -n $file_path
	imports_end_num=$( grep "^import " -n $file_path | cut -f1 -d: | tail -n1 )
	main_file_code_start=$(( $imports_end_num + 1 ))
	tail -n+$(( $imports_end_num + 1 )) $file_path >> "${development_dir}/.run.temp"
}

rm "${development_dir}/.run.temp"
bind $1
