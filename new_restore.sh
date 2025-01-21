#!/bin/bash

# Constants for directory and file paths
trashbox_dir=".sh-trashbox"
index_file="$trashbox_dir/INDEX"
id_file="$trashbox_dir/ID"

# Read the total number of lines in the INDEX file
total_line=$(wc -l < "$index_file")

# Get the next available ID from the ID file
num_in_ID=$(head -n 1 "$id_file")

# If the script is run with the `-r` flag (restore by name)
if [ "$1" == "-r" ]; then
  shift # Remove the flag from arguments

  # Process each file name provided as an argument
  for name in "$@"; do
    latest_entry="" # Stores the most recent matching entry
    latest_time=0   # Timestamp of the latest entry

    # Loop through all lines in the INDEX file to find the latest match
    for ((i=1; i<=total_line; i++)); do
      line=$(sed -n "${i}p" "$index_file")
      id=$(echo "$line" | cut -d ':' -f 1)
      type=$(echo "$line" | cut -d ':' -f 2)
      original_dir=$(echo "$line" | cut -d ':' -f 3)
      file_name=$(echo "$line" | cut -d ':' -f 4)
      del_time=$(echo "$line" | cut -d ':' -f 5)

      # Check if the file name matches and update the latest entry if necessary
      if [[ "$file_name" == "$name" ]]; then
        if (( del_time > latest_time )); then
          latest_time=$del_time
          latest_entry="$id:$type:$original_dir:$file_name:$del_time"
        fi
      fi
    done

    if [ -n "$latest_entry" ]; then # Ensure there is a matching entry
      # Parse the latest entry details
      id=$(echo "$latest_entry" | cut -d ':' -f 1)
      type=$(echo "$latest_entry" | cut -d ':' -f 2)
      original_dir=$(echo "$latest_entry" | cut -d ':' -f 3)
      file_name=$(echo "$latest_entry" | cut -d ':' -f 4)

      # Recreate the original directory if it doesn't exist
      if [ ! -d "$original_dir" ] && [ "$original_dir" != "." ]; then
        echo "Original directory $original_dir doesn't exist. Recreating..."
        mkdir -p "$original_dir" # `-p` ensures parent directories are created if needed
      fi

      # Restore the file or directory
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
      if [[ $id -eq 1 ]]; then
        # First entry in the INDEX file
        echo " " >> "tmp_file.txt"
        tail -n +$(($id + 1)) ".sh-trashbox/INDEX" >> "tmp_file.txt"
        mv "tmp_file.txt" ".sh-trashbox/INDEX"
      elif [ $id -eq $(($num_in_ID - 1)) ]; then
        # Last entry in the INDEX file
        head -n $(($id - 1)) ".sh-trashbox/INDEX" > "tmp_file.txt"
        echo " " >> "tmp_file.txt"
        mv "tmp_file.txt" ".sh-trashbox/INDEX"
      else
        # Entry in the middle of the INDEX file
        head -n $(($id - 1)) ".sh-trashbox/INDEX" > "tmp_file.txt"
        echo " " >> "tmp_file.txt"
        tail -n +$(($id + 1)) ".sh-trashbox/INDEX" >> "tmp_file.txt"
        mv "tmp_file.txt" ".sh-trashbox/INDEX"
      fi
    else
      echo "Item '$name' not found in the trashbox."
    fi
  done

# If the script is run with the `-d` flag (restore to a directory)
elif [ "$1" == "-d" ]; then
  dir_to_put=$2 # Target directory for restoration

  # Create the target directory if it doesn't exist
  if [ ! -d "$dir_to_put" ]; then
    mkdir "$dir_to_put"
  fi

  shift 2 # Skip the flag and directory arguments

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

# Final check for leftover directories in the trashbox
# Cleans up the INDEX file if a restored directory remains listed
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

# Reinitialize the trashbox if the INDEX is empty
check=$(wc -w < ".sh-trashbox/INDEX")
if [ $check -eq 0 ]; then
  ./init-trashbox.sh
fi
