# Trashbox Management Scripts

This project provides a set of Bash scripts to implement a file and directory trash management system. Instead of permanently deleting files or directories, these scripts move them to a hidden trashbox directory (.sh-trashbox), allowing users to restore them later if needed.

## Features

- **Safe Deletion**: Move files and directories to a trashbox instead of permanently deleting them.
- **Restoration**: Restore deleted files and directories to their original locations.
- **Trash Initialization**: Set up the trashbox system by creating necessary directories and files.
- **Listing Deleted Items**: View the details of deleted files and directories, including their original location and deletion time.
- **Recursive Deletion**: Handle nested files and directories during deletion.

## Files in the Project

### 1. `init-trashbox.sh`

Initializes the trashbox system by creating the `.sh-trashbox` directory and required files (`ID` and `INDEX`).

#### Functionality:

- Creates the `.sh-trashbox` directory if it does not exist.
- Initializes the `ID` file with the value `1`.
- Initializes the `INDEX` file as an empty file.

### 2. `delet_recuresive.sh`

Handles the deletion of files and directories. Moves files to the trashbox and updates the `INDEX` file with metadata about the deleted items.

#### Functionality:

- Handles both files and directories.
- Records details such as:
  - Unique ID
  - File or directory type
  - Original location
  - Deletion timestamp
- Recursively processes directories.

### 3. `list_INDEX_dir.sh`

Lists the contents of the `INDEX` file, providing details about deleted files and directories.

#### Functionality:

- Displays metadata for each item in the trashbox:
  - File/Directory ID
  - Type (file or directory)
  - Original location
  - Deletion time (formatted as `YYYY-MM-DD HH:MM:SS`).

### 4. `new_restore.sh`

Restores files or directories from the trashbox to their original locations or a specified directory.

#### Functionality:

- Restores the most recent version of a file or directory based on deletion time.
- Recreates the original directory structure if necessary.
- Updates the `INDEX` file to reflect restored items.

## How to Use

### 1. Initialize the Trashbox

Run the following command to set up the trashbox:

```bash
./init-trashbox.sh
```

### 2. Delete Files or Directories

Use the script `delet_recuresive.sh` to safely delete files or directories:

```bash
./delet_recuresive.sh <path-to-file-or-directory>
```

### 3. List Deleted Items

View the contents of the trashbox using:

```bash
./list_INDEX_dir.sh
```

### 4. Restore Files or Directories

Restore items from the trashbox using:

```bash
./new_restore.sh -r <file-or-directory-name>
```

Restore to a specific directory:

```bash
./new_restore.sh -d <target-directory> <file-or-directory-name>
```

## Requirements

- Bash shell
- Basic Linux utilities (e.g., `mkdir`, `rm`, `cat`, `mv`, `wc`, `sed`)

## Limitations

- The scripts assume the trashbox directory is `.sh-trashbox` in the current working directory.
- Files and directories with the same name may lead to ambiguity during restoration.


