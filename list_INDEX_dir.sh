#!/bin/bash

file=".sh-trashbox/INDEX"

total_line=$(wc -l < "$file")

for ((i=1; i<=total_line; i++))
do 
  file_info=$(head -n $i "$file" | tail -n 1)
  if [ -n "$file_info" ] && [ "$file_info" != " " ]; then
    file_num=$(echo "$file_info" | cut -d ':' -f 1)
    file_type=$(echo "$file_info" | cut -d ':' -f 2)
    Dir_name=$(echo "$file_info" | cut -d ':' -f 3)
    File_name=$(echo "$file_info" | cut -d ':' -f 4)
    delet_date=$(echo "$file_info" | cut -d ':' -f 5)
    year=$(echo "$file_info" | cut -d ':' -f 5 | sed -E 's/(2[0-9]+)(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])([01][0-9]|2[0-3])([0-5][0-9])([0-5][0-9])/\1/')
    month=$(echo "$file_info" | cut -d ':' -f 5 | sed -E 's/(2[0-9]+)(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])([01][0-9]|2[0-3])([0-5][0-9])([0-5][0-9])/\2/')
    day=$(echo "$file_info" | cut -d ':' -f 5 | sed -E 's/(2[0-9]+)(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])([01][0-9]|2[0-3])([0-5][0-9])([0-5][0-9])/\3/')
    hour=$(echo "$file_info" | cut -d ':' -f 5 | sed -E 's/(2[0-9]+)(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])([01][0-9]|2[0-3])([0-5][0-9])([0-5][0-9])/\4/')
    minutes=$(echo "$file_info" | cut -d ':' -f 5 | sed -E 's/(2[0-9]+)(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])([01][0-9]|2[0-3])([0-5][0-9])([0-5][0-9])/\5/')
    seconds=$(echo "$file_info" | cut -d ':' -f 5 | sed -E 's/(2[0-9]+)(0[1-9]|1[0-2])(0[1-9]|[12][0-9]|3[01])([01][0-9]|2[0-3])([0-5][0-9])([0-5][0-9])/\6/')

    if [ $file_type = "DIR" ]
    then
        echo "File$file_num"
        echo "This was a directory."
        echo "Directory name was $File_name, Stored in $Dir_name"
        echo "This file was deleted: $year-$month-$day at $hour:$minutes:$seconds"
        echo "******"
    else

        echo "File$file_num"
        echo "This was a file."
        echo "Filename was $File_name, Stored in $Dir_name"
        echo "This file was deleted: $year-$month-$day at $hour:$minutes:$seconds"
        echo "******"
    fi
  fi
done