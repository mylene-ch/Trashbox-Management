#!/bin/bash

# Constants

trashbox_dir=".sh-trashbox"
index_file="$trashbox_dir/INDEX"
id_file="$trashbox_dir/ID"



total_line=$(wc -l < "$index_file")
num_in_ID=$(head -n 1 "$id_file")

if [ "$1" == "-r" ]; then
  shift
  for name in "$@"; do
    latest_entry=""
    latest_time=0

    # Search for the latest entry matching the name in INDEX
    for ((i=1; i<=total_line; i++)); do
      line=$(sed -n "${i}p" "$index_file")
      id=$(echo "$line" | cut -d ':' -f 1)
      type=$(echo "$line" | cut -d ':' -f 2)
      original_dir=$(echo "$line" | cut -d ':' -f 3)
      file_name=$(echo "$line" | cut -d ':' -f 4)
      del_time=$(echo "$line" | cut -d ':' -f 5)

      if [[ "$file_name" == "$name" ]]; then
        if (( del_time > latest_time )); then
          latest_time=$del_time
          latest_entry="$id:$type:$original_dir:$file_name:$del_time"
        fi
      fi
    done

    if [ -n "$latest_entry" ]; then #if $latest_entry is empty
      # Parse the latest entry
      id=$(echo "$latest_entry" | cut -d ':' -f 1)
      type=$(echo "$latest_entry" | cut -d ':' -f 2)
      original_dir=$(echo "$latest_entry" | cut -d ':' -f 3)
      file_name=$(echo "$latest_entry" | cut -d ':' -f 4)

      # Check and recreate the original directory if necessary
      if [ ! -d "$original_dir" ] && [ "$original_dir" != "." ]; then
        echo "Original directory $original_dir doesn't exist. Recreating..."
        mkdir -p "$original_dir" # -p:parents 1) create all parent directory if not exist, 2) if the directory exist, exit without raising errors
      fi

      if [ "$type" == "FILE" ]; then
        mv "$trashbox_dir/$id" "$original_dir/$file_name"
        echo "File '$file_name' has been restored to '$original_dir'."
      elif [ "$type" == "DIR" ]; then
        if [ ! -d "$original_dir/$file_name" ]; then
          mkdir -p "$original_dir/$file_name"
          echo "Directory '$file_name' has been recreated in '$original_dir'."
        else
          echo "Directory '$original_dir/$file_name' already exists."
        fi
      fi

      # Update the INDEX file to remove the restored entry
      if [[ $id -eq 1 ]]
      then
          echo " " >> "tmp_file.txt"
          tail -n +$(($id + 1)) ".sh-trashbox/INDEX" >> "tmp_file.txt"
          mv "tmp_file.txt" ".sh-trashbox/INDEX"

      elif [ $id -eq `expr $num_in_ID - 1` ]
      then
          head -n $(($id - 1)) ".sh-trashbox/INDEX" > "tmp_file.txt"
          echo " " >> "tmp_file.txt"
          mv "tmp_file.txt" ".sh-trashbox/INDEX"
      else
          head -n $(($id - 1)) ".sh-trashbox/INDEX" > "tmp_file.txt"
          echo " " >> "tmp_file.txt"
          tail -n +$(($id + 1)) ".sh-trashbox/INDEX" >> "tmp_file.txt"
          mv "tmp_file.txt" ".sh-trashbox/INDEX"
      fi
    else
      echo "Item '$name' not found in the trashbox."
    fi
  done

elif [ "$1" == "-d" ]; then
  # Code for the -d mode remains unchanged
  dir_to_put=$2
  if [ ! -d "$dir_to_put" ]; then
    mkdir "$dir_to_put"
  fi

  shift 2
  while [ $# -gt 0 ]; do
    file_to_restore=$1
    latest_line=""
    latest_time=0

    for ((i=1; i<=total_line; i++)); do
      line=$(sed -n "${i}p" "$index_file")
      id=$(echo "$line" | cut -d ':' -f 1)
      dir_name=$(echo "$line" | cut -d ':' -f 3)
      file_name=$(echo "$line" | cut -d ':' -f 4)
      del_time=$(echo "$line" | cut -d ':' -f 5)

      if [[ "$file_name" == "$file_to_restore" ]]; then
        if (( del_time > latest_time )); then
          latest_time=$del_time
          latest_line="$id:$dir_name:$file_name:$del_time"
        fi
      fi
    done

    if [ -n "$latest_line" ]; then
        id=$(echo "$latest_line" | cut -d ':' -f 1)
        file_name=$(echo "$latest_line" | cut -d ':' -f 3)
        mv "$trashbox_dir/$id" "$dir_to_put/$file_name"
        echo "File '$file_name' has been restored to '$dir_to_put'."

        if [[ $id -eq 1 ]]
        then
            echo " " >> "tmp_file.txt"
            tail -n +$(($id + 1)) ".sh-trashbox/INDEX" >> "tmp_file.txt"
            mv "tmp_file.txt" ".sh-trashbox/INDEX"

        elif [ $id -eq `expr $num_in_ID - 1` ]
        then
            head -n $(($id - 1)) ".sh-trashbox/INDEX" > "tmp_file.txt"
            echo " " >> "tmp_file.txt"
            mv "tmp_file.txt" ".sh-trashbox/INDEX"
        else
            head -n $(($id - 1)) ".sh-trashbox/INDEX" > "tmp_file.txt"
            echo " " >> "tmp_file.txt"
            tail -n +$(($id + 1)) ".sh-trashbox/INDEX" >> "tmp_file.txt"
            mv "tmp_file.txt" ".sh-trashbox/INDEX"
        fi
    else
      echo "File '$file_to_restore' not found in the trashbox."
    fi

    shift
  done

else
  # Default behavior (restore to the current directory)
  while [ $# -gt 0 ]; do
    file_to_restore=$1
    latest_line=""
    latest_time=0

    for ((i=1; i<=total_line; i++)); do
      line=$(sed -n "${i}p" "$index_file")
      id=$(echo "$line" | cut -d ':' -f 1)
      dir_name=$(echo "$line" | cut -d ':' -f 3)
      file_name=$(echo "$line" | cut -d ':' -f 4)
      del_time=$(echo "$line" | cut -d ':' -f 5)

      if [[ "$file_name" == "$file_to_restore" ]]; then
        if (( del_time > latest_time )); then
          latest_time=$del_time
          latest_line="$id:$dir_name:$file_name:$del_time"
        fi
      fi
    done

      if [ -n "$latest_line" ]; then
        id=$(echo "$latest_line" | cut -d ':' -f 1)
        file_name=$(echo "$latest_line" | cut -d ':' -f 3)
        mv "$trashbox_dir/$id" "./$file_name"
        echo "File '$file_name' has been restored to the current directory."

        if [[ $id -eq 1 ]]
        then
            echo " " >> "tmp_file.txt"
            tail -n +$(($id + 1)) ".sh-trashbox/INDEX" >> "tmp_file.txt"
            mv "tmp_file.txt" ".sh-trashbox/INDEX"

        elif [ $id -eq `expr $num_in_ID - 1` ]
        then
            head -n $(($id - 1)) ".sh-trashbox/INDEX" > "tmp_file.txt"
            echo " " >> "tmp_file.txt"
            mv "tmp_file.txt" ".sh-trashbox/INDEX"
        else
            head -n $(($id - 1)) ".sh-trashbox/INDEX" > "tmp_file.txt"
            echo " " >> "tmp_file.txt"
            tail -n +$(($id + 1)) ".sh-trashbox/INDEX" >> "tmp_file.txt"
            mv "tmp_file.txt" ".sh-trashbox/INDEX"
      fi
    else
      echo "File '$file_to_restore' not found in the trashbox."
    fi

    shift
  done
fi

##check if there are any directory left in the bin but has been restored with the files already
for ((i=1; i<=total_line; i++))
do
    line=$(head -n $i .sh-trashbox/INDEX | tail -n 1)
    
    words_in_line=$(echo $line | wc -w)
    if [ $words_in_line -gt 0 ];then
        #echo "line has : $line"
        id=$(echo $line | cut -d ':' -f 1)
        type=$(echo $line | cut -d ':' -f 2)
        original_dir=$(echo $line | cut -d ':' -f 3)
        file_name=$(echo $line | cut -d ':' -f 4)
        #echo "id = $id"
        if [ -d "$original_dir/$file_name" ]; then
            if [[ $id -eq 1 ]]
            then
                echo " " >> "tmp_file.txt"
                tail -n +$(($id + 1)) ".sh-trashbox/INDEX" >> "tmp_file.txt"
                mv "tmp_file.txt" ".sh-trashbox/INDEX"

            elif [ $id -eq $(($num_in_ID - 1)) ]
            then
                head -n $(($id - 1)) ".sh-trashbox/INDEX" > "tmp_file.txt"
                echo " " >> "tmp_file.txt"
                mv "tmp_file.txt" ".sh-trashbox/INDEX"
            else
                head -n $(($id - 1)) ".sh-trashbox/INDEX" > "tmp_file.txt"
                echo " " >> "tmp_file.txt"
                tail -n +$(($id + 1)) ".sh-trashbox/INDEX" >> "tmp_file.txt"
                mv "tmp_file.txt" ".sh-trashbox/INDEX"
            fi
        fi
    fi
    
done

check=$(wc -w < ".sh-trashbox/INDEX")
if [ $check -eq 0 ]
then
  ./init-trashbox.sh
fi