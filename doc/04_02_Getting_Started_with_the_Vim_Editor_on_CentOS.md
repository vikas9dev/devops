# 🧩 Getting Started with the Vim Editor on CentOS

In this section, we’ll get hands-on with the **Vim** editor — a powerful text editor that you’ll be using throughout this course to create and modify files.

> 💡 If you're already comfortable with another editor like **Nano**, feel free to use that. But if you're new to Linux text editors, **Vim** is a great place to start.

## Installing Vim on CentOS

By default, **Vim** is not installed on CentOS; however, **Vi** (a simpler version) is usually available. Since Vim is an enhanced version of Vi, let’s start by installing it:

```bash
sudo yum install vim -y
```

> If you encounter any issues during installation (e.g., network errors), don’t spend too much time troubleshooting. Simply recreate your VM or switch to an **Ubuntu** VM, where Vim is pre-installed. We'll learn more about networking with Vagrant later in the course.

## Basic Vim Operations

Let’s walk through the basics of using Vim to create, edit, save, and quit files.

### 1. Opening a File

To create or open a file, use:

```bash
vim firstfile.txt
```

The `.txt` extension is optional — it's just for readability.

### 2. Vim Modes

Vim has **three modes**:

- **Command Mode**: Default mode when you open a file.
- **Insert Mode**: For writing and editing content. Enter this by pressing `i`.
- **Extended Mode**: For commands like saving or quitting. Access this by pressing `Esc` followed by `:`.

### 3. Writing and Saving

1. Press `i` to enter **Insert Mode**.
2. Type your content:
   ```
   Welcome to Linux.
   I hope you enjoy learning the command line!
   ```
3. Press `Esc` to return to **Command Mode**.
4. Enter `:w` to **save** the file.
5. To quit, use `:q`.
6. To save and quit in one go: `:wq`.

### 4. Quitting Without Saving

If you've made changes you don't want to keep:

```bash
:q!
```

This **force quits** without saving.

## Navigating Inside Vim

Use these shortcuts for efficient navigation:

- `:set nu` – Show line numbers
- `gg` – Go to the beginning of the file
- `G` – Go to the end of the file
- `w` – Move cursor forward one word
- `5w` – Move cursor 5 words forward
- `b` – Move back one word
- `nb` – Move back N words (like `5b`)

## Copy, Paste, and Delete in Vim

### Copying (Yanking)

- `yy` – Copy current line
- `4yy` – Copy 4 lines from the current line
- `p` – Paste below the cursor
- `P` – Paste above the cursor

### Cutting (Deleting)

- `dd` – Delete (cut) current line
- `4dd` – Delete (cut) 4 lines
- `u` – Undo last change
- `U` – Undo all changes (entire line)
- `CTRL + R` – Redo

> Deleting in Vim is essentially a **cut** operation. You can paste it using `p` or `P`.

### Deleting All Lines

```bash
117dd
```

(Deletes 117 lines, assuming that's your total line count)

Undo with `u` or quit without saving with `:q!`.

## Searching in Vim

To search for a word:

1. Press `/` in **Command Mode**
2. Type the word (e.g., `/network`)
3. Press `Enter`
4. Use `n` to jump to the next match

> Search is **case-sensitive** by default.

Vim is an extremely powerful tool once you’re comfortable with it. In upcoming sessions, we’ll build on these fundamentals with more advanced features.

> 💪 **Pro Tip**: Practice is key. Use Vim as much as possible during this course to build muscle memory.

---
