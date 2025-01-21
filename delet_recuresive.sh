#!/bin/bash

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
  echo "Erreur de parametre!!"
  exit 1
fi

# Check if the argument is a file
if [ -f "$1" ]; then
  # Handle file deletion
  file_to_delete=$1
  
  # Retrieve the next available ID from the .sh-trashbox/ID file
  n=$(head -n 1 .sh-trashbox/ID)
  
  # Define the path for storing the file in the trashbox
  file_to_put=".sh-trashbox/$n"
  file_name=$(basename "$file_to_delete")
  dir_name=$(dirname "$file_to_delete")
  time_delete=$(date +"%Y%m%d%H%M%S")  # Current timestamp for deletion logging

  # Copy the file content to the trashbox
  cat "$file_to_delete" > "$file_to_put"

  # Update the INDEX file with the file's metadata
  word=$(wc -w < ".sh-trashbox/INDEX")
  if [ $word -eq 0 ]; then
    # If INDEX is empty, overwrite it with the first entry
    echo "$n:FILE:$dir_name:$file_name:$time_delete" > ".sh-trashbox/INDEX"
  else
    # Otherwise, append the new entry
    echo "$n:FILE:$dir_name:$file_name:$time_delete" >> ".sh-trashbox/INDEX"
  fi

  # Increment the ID counter for the next file
  echo $((n + 1)) > .sh-trashbox/ID

  # Delete the original file
  rm "$file_to_delete"

# Check if the argument is a directory
elif [ -d "$1" ]; then
  # Handle directory deletion
  dir_to_delete=$1
  
  # Retrieve the next available ID from the .sh-trashbox/ID file
  n=$(head -n 1 .sh-trashbox/ID)
  dir_name=$(dirname "$dir_to_delete")
  dir_base_name=$(basename "$dir_to_delete")
  time_delete=$(date +"%Y%m%d%H%M%S")  # Current timestamp for deletion logging

  # Log the directory deletion in the INDEX file
  if [ $(wc -w < ".sh-trashbox/INDEX") -eq 0 ]; then
    # If INDEX is empty, overwrite it with the first entry
    echo "$n:DIR:$dir_name:$dir_base_name:$time_delete" > ".sh-trashbox/INDEX"
  else
    # Otherwise, append the new entry
    echo "$n:DIR:$dir_name:$dir_base_name:$time_delete" >> ".sh-trashbox/INDEX"
  fi

  # Increment the ID counter for the next directory
  echo $((n + 1)) > .sh-trashbox/ID

  # Recursively process all items inside the directory
  for item in "$dir_to_delete"/*; do
    $0 $item  # Reinvoke the script on each item
  done

  # Remove the empty directory after its contents are handled
  rmdir $1
else
  # Handle invalid file or directory input
  echo "Le fichier ou le dossier n'existe pas ou n'est pas valide"
  exit 1
fi
