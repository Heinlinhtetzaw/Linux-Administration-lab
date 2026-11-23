###Linux Filesystem Navigation and File Operations

## Objective
To understand the structure of the Linux filesystem hierarchy, differentiate between absolute and relative paths, and gain hands-on proficiency in creating, navigating, copying, moving, inspecting, and deleting files and directories via the command line in an Ubuntu WSL2 environment.

## Linux Filesystem Overview
The Linux filesystem organizes all data into a single, unified inverted-tree hierarchy starting at the root directory (`/`). Unlike Windows—which partitions storage under separate drive letters (`C:\`, `D:\`)—Linux mounts all storage devices, partitions, system configurations, and hardware interfaces as directories and files under `/`. Because Linux treats everything as a file, standard file manipulation commands can interact consistently across user data, logs, and system components.

## Important Directories
`/` - The root directory; the top-level starting point of the entire linux filesystem hierarchy.
`/home` - Personal home directories for standard users.(eg. `/home/heinlinhtetzaw`).
`/etc` - Stores system-wide configuration files and service settings.
`/var` - Contains variable data files that change frequently during operation, such as system logs, caches, and spools.
`/tmp` - Temporary storage space for applications and users; contents are typically cleared upon system reboot.
`/usr` - Contains read-only user utilities, shared libraries, documentation, and non-essential system binaries.
`/root` -The personal home directory for the `root` (superuser/administrator) account, kept separate from `/home`.
`/dev` - Contains special device files representing physical and virtual hardware components (e.g., disks, USBs).
`/proc` - A virtual filesystem providing real-time kernel and process information directly from system memory. 

## Absolute and Relative Paths
# Absolute Path
An absolute path defines the complete location of a file or directory starting from the root directory (`/`). It always begins with a forward slash and resolves to the exact same target regardless of my current directory.
Example: `/home/heinlinhtetzaw/linux-fundamentals-lab/documents/report.txt`
# Relative Path
A relative path defines a location in relation to my current working directory. It never starts with `/` and uses shorthand notations such as `.` (current directory), `..` (parent directory), and `~` (my user home directory).
Example: When my working directory is `/home/heinlinhtetzaw`, the relative path `linux-fundamentals-lab/documents/report.txt` (or `~/linux-fundamentals-lab/documents/report.txt`) points to the file.

## Command Praticed
`pwd` - Prints the full absolute path of my current working directory.

`cd` - Changes my current working directory.
Example - `cd ~/linux-fundamentals-lab`

`ls` - Lists directory contents ('`-l` for long format, `-a` for hidden files, `-R` for recursive).
Example - `ls -lR ~/linux-fundamentals-lab/`

`mkdir` - Creates new directories (`-p` creates parent directories and supports brace expansion).
Example - `mkdir -p ~/linux-fundamentals-lab/{documents,logs,scripts,backup}`

`touch` - Creates empty files or updates access/modification timestamps on existing files.
Example - `touch ~/linux-fundamentals-lab/logs/system.log`

`cp` - Copies files or directories from a source path to a destination path.
Example - `cp ~/linux-fundamentals-lab/documents/report.txt ~/linux-fundamentals-lab/backup/`

`mv` - Moves files/directories to a new location or renames them in place.
Example - `mv ~/linux-fundamentals-lab/documents/notes.txt ~/linux-fundamentals-lab/documents/meeting-notes.txt`

`rm` - Removes files permanently (`-i` prompts for confirmation before each deletion).
Example - `rm -i ~/linux-fundamentals-lab/backup/report.txt` 

`rmdir` -  Removes empty directories safely (fails if the directory still contains files).
Example -  `rmdir ~/linux-fundamentals-lab/backup/` 

`find`  - Seraches for files and directories matching specific criteria (`-type`, `-maxdepth`). 
Example -  `find ~/linux-fundamentals-lab -type f`

`state` - Displays detailed file metadata including inode, permissions, UID/GID, size and timestamps. 
Example - `stat ~/linux-fundamentals-lab/documents/report.txt` 

`file` - Determines the file type by inspecting its contents and headers rather than its externsion. 
Example - `file ~/linux-fundamentals-lab/documents/report.txt`

### Practical Exercise
# Directory Creation
I created the main lab workspace and four subdirectories simultaneously using `mkdir -p` with brace expension, then verified the directory structure up to two levels deep using `find`.
```bash
mkdir -p ~/linux-fundamentals-lab/{documents,logs,scripts,backup}
find ~/linux-fundamentals-lab -maxdepth 2 -type d ```

# File Creation
I populated the subdirectories with empty placeholder files (report.txt, notes.txt, system.log and test.sh) using touch and verified theri placeholder recursiverly with ls -lR:
```bash
touch ~/linux-fundamentals-lab/documents/report.txt
touch ~/linux-fundamentals-lab/documents/notes.txt
touch ~/linux-fundamentals-lab/logs/system.log
touch ~/linux-fundamentals-lab/scripts/test.sh
ls -lR ~/linux-fundamentals-lab/ ```

#Copying files
I duplicated report.txt from documents/ into backup/ while keeping the original file intact, then confirmed both copies existed using find:
```bash
cp ~/linux-fundamentals-lab/documents/report.txt ~/linux-fundamentals-lab/backup/
find ~/linux-fundamentals-lab -type f ```

# Renaming files
I renamed notes.txt to meeting-notes.txt inside the documents/ directory using mv and confirmed the updated filename with ls -l:
```bash
mv ~/linux-fundamentals-lab/documents/notes.txt ~/linux-fundamentals-lab/documents/meeting-notes.txt
ls -l ~/linux-fundamentals-lab/documents/ ```

# Moving files
I relocated test.sh from scripts/ into backup/ using mv and verified that it no longer existed in scripts/:
```bash 
mv ~/linux-fundamentals-lab/scripts/test.sh ~/linux-fundamentals-lab/backup/
find ~/linux-fundamentals-lab/ -type f ```

# Inspecting Metadata & Cleanup
I inspected the inode, permissions (0644), onwership (heinlinhtetzaw:generaluser), timestamps, and content classification of report.txt using stat and file. Afterward, I safely cleared the backup/ directory using interactive deletion ( rm -i ) followed by rmdir:
```bash
stat ~/linux-fundamentals-lab/documents/report.txt
file ~/linux-fundamentals-lab/documents/report.txt
rm -i ~/linux-fundamentals-lab/backup/report.txt
rm -i ~/linux-fundamentals-lab/backup/test.sh
rmdir ~/linux-fundamentals-lab/backup/ ```

# Verification
Final directory tree verification using tree ~/linux-fundamentals-lab/ and metadata output from stat and file:

``` output
heinlinhtetzaw@heinhtet-sv:~$ stat ~/linux-fundamentals-lab/documents/report.txt
  File: /home/heinlinhtetzaw/linux-fundamentals-lab/documents/report.txt
  Size: 0               Blocks: 0          IO Block: 4096   regular empty file
Device: 8,48    Inode: 37427       Links: 1
Access: (0644/-rw-r--r--)  Uid: ( 1000/heinlinhtetzaw)   Gid: ( 1000/generaluser)
Access: 2026-11-23 08:05:18.642705472 +0630
Modify: 2026-11-23 07:59:59.995384714 +0630
Change: 2026-11-23 07:59:59.995384714 +0630
 Birth: 2026-11-23 07:59:59.995384714 +0630

heinlinhtetzaw@heinhtet-sv:~$ file ~/linux-fundamentals-lab/documents/report.txt
/home/heinlinhtetzaw/linux-fundamentals-lab/documents/report.txt: empty

heinlinhtetzaw@heinhtet-sv:~$ tree ~/linux-fundamentals-lab/
/home/heinlinhtetzaw/linux-fundamentals-lab/
├── documents
│   ├── meeting-notes.txt
│   └── report.txt
├── logs
│   └── system.log
└── scripts

4 directories, 3 files ```

# What i learned
- Brace expansion streamlines setup: Using` {dir1,dir2,dir2}` with `mkdir -p ` lets me build complex multi-folder hierarchies in a single command.
- Moving vs Renaming: Linux users the same `mv` command for both operations moving a file within the same directory renames it, while moving it across directories relocated it.
- Safe deletion practices: Combining `rm -i` (interactive prompt) with `rmdir`( which only deltes empty directories) helps me avoid accidentally delteing non-empty directory trees.
- Metadata inspection: `stat` exposses low-level filesystem details (inodes, permission, timestamps) while `file` inspects actual content rather than relying on file extensions.

