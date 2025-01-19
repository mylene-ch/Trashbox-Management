#!/bin/bash


if [ $# -lt 1 ]; then
  echo "Erreur de parametre!!"
  exit 1
fi

if [ -f "$1" ]; then
  # Handle file deletion
  file_to_delete=$1
  n=$(head -n 1 .sh-trashbox/ID)
  file_to_put=".sh-trashbox/$n"
  file_name=$(basename "$file_to_delete")
  dir_name=$(dirname "$file_to_delete")
  time_delete=$(date +"%Y%m%d%H%M%S")

  # Copy file content to trashbox
  cat "$file_to_delete" > "$file_to_put"

  # Update INDEX for the file
  word=$(wc -w < ".sh-trashbox/INDEX")
  if [ $word -eq 0 ] # if INDEX is empty, with >, else with >>
  then
    echo "$n:FILE:$dir_name:$file_name:$time_delete" > ".sh-trashbox/INDEX"
  else
    echo "$n:FILE:$dir_name:$file_name:$time_delete" >> ".sh-trashbox/INDEX"
  fi
  # Increment ID
  echo $((n + 1)) > .sh-trashbox/ID

  # Remove the original file
  rm "$file_to_delete"

elif [ -d "$1" ]; then
  # Handle directory deletion
  dir_to_delete=$1
  n=$(head -n 1 .sh-trashbox/ID)
  dir_name=$(dirname "$dir_to_delete")
  dir_base_name=$(basename "$dir_to_delete")
  time_delete=$(date +"%Y%m%d%H%M%S")

  # Record directory deletion in INDEX
  if [ $(wc -w < ".sh-trashbox/INDEX") -eq 0 ]; then
    echo "$n:DIR:$dir_name:$dir_base_name:$time_delete" > ".sh-trashbox/INDEX"
  else
    echo "$n:DIR:$dir_name:$dir_base_name:$time_delete" >> ".sh-trashbox/INDEX"
  fi
  # Increment ID
  echo $((n + 1)) > .sh-trashbox/ID

  # Process all contents inside the directory
  for item in "$dir_to_delete"/*; do
    $0 $item
  done

  rmdir $1
else
  echo "Le fichier ou le dossier n'existe pas ou n'est pas valide"
  exit 1
fi
