# Linux Command Syntax and Help Systems

## Objective

My objective was to understand the basic structure of Linux commands and learn how I can find help when I do not know a command or option. I practiced copying a file, searching for a disk-space command, opening manual pages, and checking how my shell finds commands.

## Command Structure

Most Linux commands follow this format:

```text
command [options] [arguments]
```

### Command

A command tells Linux what I want to do. Examples from this lab are `ls`, `cp`, `df`, `man`, `type`, and `which`.

### Options

Options change how a command works. They normally begin with one hyphen (`-`) for a short option or two hyphens (`--`) for a long option.

For example:

```bash
cp -v source-file destination-folder/
```

The `-v` option means verbose mode, so I can see which file is copied.

### Arguments

Arguments tell a command which file, folder, or item I want to use.

For example:

```bash
cp command-practice/source/example.txt command-practice/destination/
```

`command-practice/source/example.txt` is the source file and `command-practice/destination/` is the destination folder.

## Short and Long Options

Short options use one hyphen:

```bash
ls -l
cp -v
```

Long options use two hyphens:

```bash
df --help
```

The exercise asked me to investigate these `ls` options:

| Option | Purpose |
|---|---|
| `-a` | Shows hidden files and folders, including names that begin with `.`. |
| `-l` | Shows a detailed list, including permissions, owner, size, and modification time. |
| `-h` | Shows file sizes in an easier-to-read format, such as KB, MB, or GB. |
| `-R` | Lists files and folders recursively, including subfolders. |
| `-t` | Sorts files by modification time. |
| `-S` | Sorts files by file size. |


## Combining Options

I can combine many short options in one command when the command supports them.

For example:

```bash
ls -la
```

This combines `-l` for a detailed list and `-a` for hidden files.



## The `--` Separator

The double-hyphen separator (`--`) tells many commands that everything after it is an argument, not an option.

For example:

```bash
command -- -filename
```

This is useful when a file name begins with `-`.


## Manual Pages

### `man command`

I use `man` to open the installed manual page for a command.

Examples from my exercise:

```bash
man df
man 1 passwd
man 5 passwd
```


### Manual Sections

Linux manual pages are divided into numbered sections.

- `man 1 passwd` opens the user-command manual page for `passwd`.
- `man 5 passwd` opens the file-format manual page for `passwd`.

The first page documents the `passwd` command that I can run. The second page documents the `/etc/passwd` file format.

### Navigation and Search

Manual pages open in an interactive viewer. I can scroll with the arrow keys or Page Up and Page Down. I can usually search by pressing `/`, typing a word, and pressing Enter. I can exit a manual page by pressing q.

## Help and Documentation Commands

| Command | Purpose | Example |
|---|---|---|
| `--help` | Shows built-in command help and options. | `df --help` |
| `man` | Opens a manual page. | `man df` |
| `whatis` | Shows a short description of a command. | `whatis df` |
| `apropos` | Searches manual-page names and descriptions by keyword. | `apropos space` |
| `info` | Opens GNU Info documentation when it is installed. | `info ls` |
| `type` | Shows how my shell understands a command. | `type cd` |
| `which` | Shows the path of an executable command. | `which python3` |

## Practical Exercises

### Copying a File with `cp`

I created source and destination folders, created an empty file, copied it, and checked the destination folder.

```bash
mkdir -p ~/linux-fundamentals-lab/{command-practice/source,command-practice/destination}
touch command-practice/source/example.txt
cp -v command-practice/source/example.txt command-practice/destination/
ls -l command-practice/destination/
```

My exercise specification used `~/command-practice/`, but I created `command-practice` inside my `linux-fundamentals-lab` folder.

The `cp` options I was asked to investigate are:

| Option | Purpose |
|---|---|
| `-r` or `-R` | Copies a directory and its contents recursively. |
| `-i` | Asks before overwriting an existing file. |
| `-v` | Shows each file being copied. |
| `-a` | Archive mode; preserves file attributes and copies directories recursively. |


### Finding a Disk-Space Command

I tried to find a command for checking disk space.

```bash
apropos "disk space"
sudo mandb
apropos "disk space"
apropos disk
apropos space
whatis df
man df
df --help
```

My exact search for `disk space` returned:

```text
disk space: nothing appropriate.
```

I then searched for `space`, which found `df`:

```text
df (1) - report file system space usage
```

I also used `whatis df` and received the same short description.

`apropos` helps me discover commands by searching keywords. `whatis` gives me a short description of one known command. `man` gives me the full manual page, while `--help` gives me quick command help in the terminal.

I entered `man df` and `df --help`, but I did not capture their output.

### Finding Command Types and Locations

I used these commands:

```bash
type ls
type cd
type pwd
which ls
which python3
```

`type` checks how my current shell interprets a command. It can identify an alias, a shell builtin, a function, or an executable command.

`which` searches my `PATH` and shows the location of an executable command. It does not show shell builtins because they are part of the shell, not separate executable files.

`cd` is a shell builtin because changing directories must change the current shell's working directory. If `cd` were a separate program, it could only change its own working directory and would not change mine after the program ended.

## Verification Results

- I created `example.txt` in my source folder.
- I copied `example.txt` to my destination folder using `cp -v`.
- My copy command showed:

  ```text
  'command-practice/source/example.txt' -> 'command-practice/destination/example.txt'
  ```

- I verified that `example.txt` existed in the destination directory with `ls -l`.
- I used `apropos space` and found `df` as a disk-space command.
- I used `whatis df` and received:

  ```text
  df (1) - report file system space usage
  ```

- I confirmed that `ls` is aliased to `ls --color=auto`.
- I confirmed that `cd` and `pwd` are shell builtins.
- I found `/usr/bin/ls` with `which ls`.
- I found `/usr/bin/python3` with `which python3`.

## Troubleshooting

### `apropos "disk space"` Did Not Return a Result

My exact search phrase did not match a manual-page description. I then used a shorter keyword:

```bash
apropos space
```

This search found `df` successfully.

## What I Learned

- I learned that Linux commands are made of commands, options, and arguments.
- I learned that short options use one hyphen and long options use two hyphens.
- I learned that `cp -v` shows the file being copied.
- I learned that `apropos` can help me find a command when I only know a related word.
- I learned that `whatis` gives me a short command description.
- I learned that `man` gives detailed documentation and `--help` gives quick command help.
- I learned that `type` can show aliases and shell builtins.
- I learned that `which` shows the path of executable commands.
- I learned that `cd` is a shell builtin because it needs to change my current shell directory.

## References

- Practical exercise — command investigation specification.
- My Ubuntu WSL2 terminal output.
- Local Linux help tools used in my exercise: `apropos`, `whatis`, and `man`.
