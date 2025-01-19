#!/bin/bash


trash=".sh-trashbox"

if [ ! -d "$trash" ]
then
    mkdir .sh-trashbox
fi
 
echo 1 > .sh-trashbox/ID 

echo > .sh-trashbox/INDEX



