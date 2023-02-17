#! /bin/bash

function generate_values() {
	local number_of_cells=$1

	local alphabets_needed=$(( $number_of_cells / 2 ))
	local alphabets_string=( $( jot -c -s" "  $alphabets_needed A Z ) )
	alphabets_string=( ${alphabets_string[@]} ${alphabets_string[@]})
	local results=()
	local letter_remaining=$(( $number_of_cells - 1 ))

	local index=0
	local random_number
	while [[ $index -lt $number_of_cells ]]
	do
		random_number=$( jot -r 1 0 $letter_remaining )
		results[$index]=${alphabets_string[$random_number]}
		alphabets_string=( ${alphabets_string[@]:0:$random_number} ${alphabets_string[@]:$(($random_number + 1))} )
		index=$(( $index + 1 ))
		letter_remaining=$(( $letter_remaining - 1 ))
	done

	echo "${results[@]}"
}


function update_cells_string(){
	local position=$(( $1 - 1 ))
	local number_of_cells=$2
	local updation_string=("${@:3:$2}")

	local character=""
	local counter=0
	local new_string=()
	while [[ $counter -lt $number_of_cells ]]
	do
		character=${cells[$counter]}
		if [[ $counter -eq $position ]]
		then
			character=${updation_string[$counter]}
		fi
	new_string[$counter]=$character
	counter=$(( $counter + 1 ))
	done
	echo ${new_string[*]}
}


function validate_cell_position()
{
	local cell_position=$1
	local number_of_cells=$2

	if [[ $cell_position -gt $number_of_cells || $cell_position -lt 1 ]]
	then
		echo "Error : Invalid Cell Number , Try Again."
		return 2
	fi

	local character=${cells[$(( $cell_position - 1 ))]}
	if [[ $character != "?" ]]
	then
		echo "Error : Cell is already flipped!"
		return 1
	fi

	return 0
}


function show_grid()
{
	local rows=$1
	local columns=$2
	local row_separator=$( echo -n "+" ; seq -s"+" -f"-----" $columns )
	local cell_number=0
	local row=1

	echo "$row_separator"

	while [[ $row -le $rows  ]]
	do
		local column=1
		while [[ $column -le $columns ]]
		do
			echo -n "|  ${cells[$cell_number]}  "
			column=$(( $column + 1 ))
			cell_number=$(( $cell_number + 1 ))
		done
		echo "|"
		echo "$row_separator"
		row=$(( $row + 1 ))
	done

}

function prompt_move_message() {
	local move=$1
	
	local message="Enter a cell to reveal : "
	if [[ $move -eq 2 ]]
	then
		message="Guess a cell to match : "
	fi
	echo "$message"
}

function play_moves() {
	local number_of_rows=$1
	local number_of_columns=$2
	local number_of_cells=$3
	local values=(${@:4})

	local cell_number
	local move=1

	while [[ $move -le 2 ]]
	do

		read -p "$(prompt_move_message $move)" cell_number

		validate_cell_position $cell_number $number_of_cells
		if [[ $? -ne 0 ]]
		then
			if [[ $move -eq 2 ]]
			then
				move=2
			fi
			continue
		fi

		if [[ $move == 1 ]]
		then
			moves_value[0]=${values[$(( $cell_number - 1 )) ]}
			moves_position[0]=$cell_number
		else
			moves_value[1]=${values[$(( $cell_number - 1 )) ]}
			moves_position[1]=$cell_number
		fi

		cells=( $( update_cells_string $cell_number $number_of_cells "${values[@]}" ) )
		move=$(( $move + 1 ))
		clear
		show_grid $number_of_rows $number_of_columns
	done
}


function validate_moves() {
	local number_of_cells=$1
	local question_marks=( $( seq -f"?" -s" " $number_of_cells ) )

	echo "Validating Cells..."
	sleep 1

	if [[ ${moves_value[0]} != ${moves_value[1]} ]]
	then
		cells=( $( update_cells_string ${moves_position[0]} $number_of_cells "${question_marks[@]}" ) )
		cells=( $( update_cells_string ${moves_position[1]} $number_of_cells "${question_marks[@]}" ) )
		echo "Wrong match, try again :)"
	else
		echo "Correct Match :)"
	fi

	sleep 2
}

function is_puzzle_possible() {
	local number_of_cells=$1

	if [[ $(( $number_of_cells % 2 )) -ne 0 ]]
	then
		echo "Either rows or columns should be even ! "
		exit 1
	fi
}


## Function with game logic
function start_game()
{
	local number_of_rows=$1
	local number_of_columns=$2

	local number_of_cells=$(( $number_of_rows * $number_of_columns ))
	is_puzzle_possible $number_of_cells

	cells=( $( seq -f"?" -s" " $number_of_cells ) )
	local values=( $( generate_values $number_of_cells ) )

	clear
	show_grid $number_of_rows $number_of_columns

	while echo ${cells[*]} | grep -q "?"
	do
		play_moves $number_of_rows $number_of_columns $number_of_cells ${values[@]}

		validate_moves $number_of_cells

		clear
		show_grid $number_of_rows $number_of_columns

	done

	echo "Congratulations , You won"
	sleep 3
	kill -n 15 $song_pid &> /dev/null
	clear
}


function main()
{
	local number_of_rows
	local number_of_columns

	cells=()
	moves_position=()
	moves_value=()

	read -p "Enter the number of rows : " number_of_rows
	read -p "Enter the number of columns : " number_of_columns
	
	afplay -v 0.5 bg_sound.mp3 &
	local song_pid=$( jobs -p | head -n1)
	trap "(kill -n 15 $song_pid; kill -n 9 $$) &> /dev/null" SIGINT
	start_game $number_of_rows $number_of_columns
}
