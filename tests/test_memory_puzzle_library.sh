#! /bin/bash
source memory_puzzle_library.sh

SEPARATOR=$( seq -f"-" -s"\0" 20 )
HEADING_SEPARATOR=$( seq -f"=" -s"\0" 20 )

cells=(A B C ? D ? E F G H I ? W P ? ?)
moves_value=()
moves_position=()

# Test function for update_cells_string()
function test_update_cells_string() {
	local position=$1
	local number_of_cells=$2
	local updation_string=("${@:3:$2}")
	local expected_string="${@:(-1)}"

	local actual_string=$( update_cells_string $position $number_of_cells "${updation_string[@]}" )
	assert_expectations "$actual_string" "$expected_string"
}

# Test cases for update_cells_string()

function test_cases_update_cells_string() {
	test_case_heading "update_cells_string()"

	local updation_string=(? ? ? ? ? ?)
	
	echo -e "\nTest Case : Valid Inputs"
	echo $SEPARATOR
#	cells=(A B C ? D ? E F G H I ? W P ? ?)
	test_update_cells_string 2 4 "${updation_string[@]:0:4}" "A ? C ?"
	test_update_cells_string 1 4 "${updation_string[@]:0:4}" "${cells[@]:0:4}" "? B C ?"
	test_update_cells_string 2 6 "${updation_string[@]}" "${cells[@]}" "A ? C ? D ?"
	test_update_cells_string 5 6 "${updation_string[@]}" "${cells[@]}" "A B C ? ? ?"

}


# test function for validate_cell_position()
function test_validate_cell_position() {
	local cell_position=$1
	local number_of_cells=$2
	local cells=("${@:3:$2}")
	local expected_result="${@:(-1)}"

	validate_cell_position $cell_position $number_of_cells "${cells[@]}" 1>/dev/null
	local actual_result=$?
	assert_expectations "$actual_result" "$expected_result"
}

# test cases for validate_cell_position()
function test_cases_validate_cell_position() {
	test_case_heading "validate_cell_position"

	echo -e "\nTest Case : Valid cell number"
	echo $SEPARATOR
	test_validate_cell_position 4 6 "${cells[@]}" 0
	test_validate_cell_position 6 6 "${cells[@]}" 0

	echo -e "\nTest Case : Valid flipped cell number"
	echo $SEPARATOR
	test_validate_cell_position 2 6 "${cells[@]}" 1
	test_validate_cell_position 5 6 "${cells[@]}" 1

	echo -e "\nTest Case : InValid cell number"
	echo $SEPARATOR
	test_validate_cell_position 12 6 "${cells[@]}" 2
	test_validate_cell_position 11 6 "${cells[@]}" 2

}

# Test function for show_grid()
function test_show_grid() {
	local rows=$1
	local columns=$2
	local cells=("${@:3}")

	echo "Row x Columns : $rows x $columns"

	local result=$( show_grid $rows $columns "${cells[@]}" )
	echo "$result"
	echo
}

# Test cases for show_grid()
function test_cases_show_grid() {
	test_case_heading "show_grid()"
	

	echo -e "\nTest Case : Valid"
	echo $SEPARATOR
	test_show_grid 4 4 "${cells[@]}"
	test_show_grid 2 3 "${cells[@]}"
	test_show_grid 2 2 "${cells[@]}"
	test_show_grid 2 8 "${cells[@]}"
	test_show_grid 1 8 "${cells[@]}"
}


# test function for prompt_move_message()
function test_prompt_move_message() {
	local move=$1
	local expected=$2
	
	local actual=$(prompt_move_message $move)
	assert_expectations "$actual" "$expected"
}

function test_cases_prompt_move_message() {
	test_case_heading "prompt_move_message()"
	
	echo -e "\nTest Cases"
	echo $SEPARATOR
	test_prompt_move_message 1 "Enter a cell to reveal : "
	test_prompt_move_message 2 "Guess a cell to match : "
	test_prompt_move_message 3 "Enter a cell to reveal : "
}

# test for play_moves
function test_play_moves() {
	local rows="${@:1:1}"
	local columns="${@:2:1}"
	local number_of_cells=(${@:3:1})
	local moves=(${@:4:2})
	local values=(${@:6})
	play_moves $rows $columns $number_of_cells ${values[@]} << end
${moves[0]}
${moves[1]}
end
}

function test_cases_play_moves() {
	test_case_heading "play_moves()"
	
	echo -e "\nTest Case : 2 x 3"
	echo $SEPARATOR

	values=(A C A T D T)
	test_play_moves 2 3 6 4 6 ${values[@]}
		
}


# test function for validate_moves()
function test_validate_moves() {
	local number_of_cells=$1
	local expected="$2"
	
	local actual="$( echo -n $( validate_moves $number_of_cells ) )"
	assert_expectations "$actual" "$expected"
}

function test_cases_validate_moves() {
	test_case_heading "validate_moves()"
	
	echo -e "\nTest Cases"
	echo $SEPARATOR
	
	moves_position=(2 3)
	moves_value=(A B)
	test_validate_moves 6 "$( echo -n 'Validating Cells... ' ; echo -n 'Wrong match, try again :)' )"
	
	moves_value=(A A)
	test_validate_moves 6 "$( echo -n 'Validating Cells... ' ; echo -n 'Correct Match :)' )"
}


function test_is_puzzle_possible() {
	local number_of_cells=$1
	local expected=$2
	
	$(is_puzzle_possible $number_of_cells > /dev/null)
	
	local actual=$?
	
	assert_expectations $actual $expected
}


function test_cases_is_puzzle_possible() {
	test_case_heading "is_puzzle_possible()"
	
	echo -e "\nTest Cases : Even Number"
	echo $SEPARATOR
	
	test_is_puzzle_possible 4 0
	test_is_puzzle_possible 16 0
	
	echo -e "\nTest Cases : Odd Number"
    echo $SEPARATOR
     
	test_is_puzzle_possible 9 1
	test_is_puzzle_possible 25 1
}

function test_all_cases() {
	test_cases_update_cells_string
	test_cases_validate_cell_position
	test_cases_show_grid
	test_cases_prompt_move_message
	test_cases_validate_moves
	test_cases_play_moves
	test_cases_is_puzzle_possible
}

test_all_cases
