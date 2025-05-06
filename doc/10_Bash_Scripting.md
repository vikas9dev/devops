# Bash Scripting

Bash scripting is a powerful way to automate tasks, streamline workflows, and manage system configurations in Unix-like operating systems. With a simple text file containing a series of commands, you can perform complex tasks quickly and efficiently.

## 1. VM Setup

We will be creating four virtual machines using Vagrant to practice our Bash scripts. Create a directory, and create a `Vagrantfile` in it:

```bash
mkdir 06_scripts/ && cd 06_scripts/
vi Vagrantfile
```

Insert the following content into the `Vagrantfile`:

```ruby
Vagrant.configure("2") do |config|
  # Define VM scriptbox
  config.vm.define "scriptbox" do |scriptbox|
    scriptbox.vm.box = "eurolinux-vagrant/centos-stream-9"
    scriptbox.vm.network "private_network", ip: "192.168.10.12"
    scriptbox.vm.hostname = "scriptbox"
    scriptbox.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end
  end

  # Define VM web01
  config.vm.define "web01" do |web01|
    web01.vm.box = "eurolinux-vagrant/centos-stream-9"
    web01.vm.network "private_network", ip: "192.168.10.13"
    web01.vm.hostname = "web01"
  end

  # Define VM web02
  config.vm.define "web02" do |web02|
    web02.vm.box = "eurolinux-vagrant/centos-stream-9"
    web02.vm.network "private_network", ip: "192.168.10.14"
    web02.vm.hostname = "web02"
  end

  # Define VM web03
  config.vm.define "web03" do |web03|
    web03.vm.box = "ubuntu/jammy64"
    web03.vm.network "private_network", ip: "192.168.10.15"
    web03.vm.hostname = "web03"
    web03.vm.boot_timeout = 300
    web03.vm.provision "shell", inline: <<-SHELL
    sudo touch /etc/cloud/cloud-init.disabled
    SHELL
  end
end
```

This `Vagrantfile` sets up four virtual machines for Bash scripting practice. It includes `scriptbox`, `web01`, `web02`, and `web03` with specific configurations. `scriptbox` has 1024 MB of RAM and a private IP of `192.168.10.12`. All VMs are assigned private network IPs and unique hostnames. These VMs provide an isolated environment for developing and testing Bash scripts effectively.

Start the `scriptbox` VM:

```bash
vagrant up scriptbox
vagrant ssh scriptbox
sudo -i
mkdir /opt/scripts/ && cd /opt/scripts/
yum install vim -y
vim firstscript.sh
```

## 2. Intro to Bash Scripting

A Bash script is essentially a text file containing a series of commands. You can create a script using any text editor, such as `nano`, `vi`, or `gedit`. The first line of the script should specify the interpreter that will execute the script, typically Bash:

```bash
#!/bin/bash
```

**Making the Script Executable:**  
After creating the script, you need to make it executable using the `chmod` command:

```bash
chmod +x script_name.sh
```

**Running the Script:**  
To run the script, you simply execute it from the command line:

```bash
./script_name.sh
```

**Basic Script Structure:**  
Here’s a simple example of a Bash script:

```bash
#!/bin/bash

# This is a comment
echo "Hello, World!" # This prints "Hello, World!" to the terminal

# Variables
NAME="John"
echo "Hello, $NAME!"

# Conditional Statements
if [ "$NAME" = "John" ]; then
    echo "Your name is John"
else
    echo "Your name is not John"
fi

# Loops
for i in {1..5}; do
    echo "Iteration $i"
done

# Functions
greet() {
    echo "Hello, $1!"
}
greet "Alice"

echo "The uptime of the sytem is: $(uptime)"

echo "Memory Utilization: "
free -m

echo "Disk Utilization: "
df -h

echo "CPU Utilization: "
mpstat
```

Yes, the .sh extension is optional for Bash scripts. While it is common practice to use the .sh extension to indicate that a file is a shell script, you can name your script file with any extension or even without an extension. The important part is to ensure the script is executable and has the correct shebang (#!/bin/bash) at the beginning.

For example:-

- `myscript.sh`
- `myscript`
- `myscript.bash`
  As long as the script is executable, you can run it with: `./myscript`

The first line of the file should ideally be the shebang (#!/bin/bash) when writing a Bash script. The shebang tells the system which interpreter to use to execute the script. Without it, the script may not run as expected, especially if the default shell is not Bash.

In vi, to see the line number we can use :**`se nu`**.

---

## 3. Bash Variables

Variables in Bash are temporary storage in memory, holding data that a process can use while it’s running. Once the process ends, all associated data is lost. Variables in a script allow us to store and retrieve data dynamically.

**Creating and Using Variables**

To create a variable in Bash, simply assign a value to a variable name:

```bash
SKILL="DevOps"
```

To retrieve the value, use the dollar sign followed by the variable name:

```bash
echo $SKILL
```

In Bash, the dollar sign is crucial to differentiate a variable from plain text.

Example of Variables in Action: Consider the following example where we store package names in a variable and use it to install packages:

```bash
PACKAGE="httpd wget unzip"
yum install $PACKAGE -y
```

This will install the packages `httpd`, `wget`, and `unzip`.

Implementing Variables in a Web Setup Script: We can enhance the web setup script by declaring variables for values that might change or be reused multiple times: `vim websetup.sh`

```bash
#!/bin/bash
PACKAGE="httpd wget unzip"
SVC="httpd"
URL="https://www.tooplate.com/zip-templates/2131_wedding_lite.zip"
ARTIFACT="2131_wedding_lite"
TMP_DIR="/tmp/webfiles"

# Use the variables in the script
yum install $PACKAGE -y
systemctl enable --now $SVC
mkdir -p $TMP_DIR
cd $TMP_DIR
wget $URL
unzip $ARTIFACT.zip
cp -r $ARTIFACT/* /var/www/html
systemctl restart $SVC
```

This approach makes the script more flexible and maintainable. Points to consider:-

- Variable Assignment: In Bash, **there should be NO SPACES around the = sign** when assigning values to variables.
- Quotes: Use double quotes around variables, especially when dealing with paths.

Get the IP address of the VM using `ip addr show` and open the URL in a browser. To remove the data:-

```bash
#!/bin/bash
sudo systemctl stop httpd
sudm rm -rf /var/www/html/ *
sudo yum remove httpd wget unzip -y
```

By using variables in Bash scripts, you can make your scripts more adaptable and easier to manage. Variables help isolate changes to specific values, reducing the need for multiple edits when updates are necessary.

---

## 4. Understanding Command Line Arguments in Bash Scripts

In this section, we’ll explore how to work with **command line arguments** in Bash scripts. If you've used commands like `ls`, `cp`, or `mv`, you've already used arguments — for instance, when you run `ls /home/user`, the path `/home/user` is an argument. Similarly, `cp source.txt destination.txt` uses two arguments: the source and destination file paths.

But how do we accept arguments **in our own scripts**? Imagine we want a script that accepts a **URL of a website artifact** so it can automatically download and deploy the site. This flexibility makes our scripts more dynamic and reusable.

Let’s walk through an example. We'll create a script named `4_args.sh` to illustrate how command line arguments work.

```bash
#!/bin/bash

echo "Value of \$0 is: $0"
echo "Value of \$1 is: $1"
echo "Value of \$2 is: $2"
echo "Value of \$3 is: $3"
```

Here:

- `$0` refers to the **script name** or its **path**.
- `$1`, `$2`, `$3` refer to the **first**, **second**, and **third** arguments respectively.

Now, make the script executable:

```bash
chmod +x 4_args.sh
```

If you run the script without arguments:

```bash
./4_args.sh
```

You’ll see:

- `$0` shows the script path.
- `$1`, `$2`, `$3` are **empty**, as nothing was passed.

Now try passing values:

```bash
./4_args.sh Linux Bash Script
```

Now:-

- `$1` becomes `./4_args.sh`
- `$1` becomes `Linux`
- `$2` becomes `Bash`
- `$3` becomes `Script`

This demonstrates how Bash automatically assigns passed arguments to numbered variables. **`$0`** is always the **script name**, and **`$1` through `$9`** are the **arguments**. More than 9 need special handling.

Now let’s use this in a practical scenario. Suppose you already have a script like `3_vars_websetup.sh`. Instead of hardcoding the `URL` and `artifact` name inside it, you can modify the script to accept them as arguments:

```bash
#!/bin/bash
PACKAGE="httpd wget unzip"
SVC="httpd"
TMP_DIR="/tmp/webfiles"

# Use the variables in the script
yum install $PACKAGE -y
systemctl enable --now $SVC
mkdir -p $TMP_DIR
cd $TMP_DIR

wget $1
unzip $2.zip
cp -r $2/* /var/www/html
systemctl restart $SVC

```

Make sure the user supplies both arguments; otherwise, the script may break or throw an error.

Here’s how you run it:

```bash
chmod +x 3_vars_websetup.sh
./3_vars_websetup.sh "https://www.tooplate.com/zip-templates/2131_wedding_lite.zip" "2131_wedding_lite"
```

Now, your script can dynamically download and deploy any artifact just by changing the input arguments — no need to edit the script itself. This is a simple but powerful way to make your scripts more flexible, maintainable, and reusable.

That’s how command line arguments work in Bash. In the next section, we’ll explore how to validate those arguments and provide default values or help messages for users.

---

## 5. Exploring System Variables in Bash Scripts

Let us dive into **system-defined variables** in Bash that provide valuable information about the current execution context. These variables are powerful tools that help you manage script behavior, check execution status, and work dynamically with user input. You may have encountered some of them already, such as `$0` for the script name or `$1` to `$9` for command-line arguments. Let's look at several others that are essential in any Bash scripting toolkit.

### Commonly Used System Variables

Here’s a breakdown of some critical Bash system variables and their purposes:

- **`$0`** – The name of the script.
- **`$1` to `$9`** – The first nine command-line arguments passed to the script.
- **`$#`** – The total number of arguments passed to the script.
- **`$@`** – All the arguments passed, preserved as separate quoted words.
- **`$*`** – All the arguments passed, as a single word.
- **`$?`** – The exit status of the last command executed.
- **`$$`** – The process ID (PID) of the current script.
- **`$USER`** – The username of the user executing the script.
- **`$HOSTNAME`** – The system's hostname.
- **`$RANDOM`** – A random number between 0 and 32767 generated each time it's called.
- **`$SECONDS`** – The number of seconds since the script started.
- **`$LINENO`** – The current line number in the script.

### Understanding `$?`: The Exit Status

One of the most useful variables is `$?`, which holds the **exit status of the last executed command**.

- A value of `0` means the last command executed successfully.
- A **non-zero** value indicates failure.

Let's see a few examples:

```bash
free -m
echo $?   # Outputs: 0 (success)
```

Now, let’s simulate a failure by running an invalid command:

```bash
freeeeee -m
echo $?   # Outputs: 127 (command not found)
```

Try another one:

```bash
free -x
echo $?   # Outputs: 1 (invalid option or usage error)
```

This is extremely useful in scripts for conditional checks:

```bash
some_command
if [ $? -ne 0 ]; then
    echo "Command failed!"
    exit 1
fi
```

This pattern is commonly used to make scripts **fail-safe** and **self-aware**, especially in automation or deployment pipelines.

### Additional Handy Variables

Here are a few more built-in variables that are helpful in practical scripting:

- `echo $USER` – Prints the current username.
- `echo $HOSTNAME` – Displays the system hostname.
- `echo $RANDOM` – Returns a new random number on each call.

These can be useful for:

- Logging who ran the script
- Identifying which machine it's running on
- Creating temporary file names with random suffixes

### Why These Variables Matter

As you start writing more advanced scripts, especially ones that handle user input, automate tasks, or interact with system resources, these variables become indispensable. They help you:

- Validate inputs
- Respond to errors
- Dynamically adjust script behavior
- Create reusable and robust scripts

---

## 6. Understanding Quotes in Bash: Single vs Double Quotes

Let's discuss a fundamental yet often misunderstood concept in Bash scripting — **quotes**. While it may seem simple at first glance, understanding how **single quotes** (`'`) and **double quotes** (`"`) behave can save you a lot of debugging time and make your scripts more predictable and powerful.

### The Two Types of Quotes in Bash

Bash supports two primary types of quotes:

- **Double quotes (`"`)**: Allow **variable expansion** and **command substitution**.
- **Single quotes (`'`)**: Treat everything **literally**, without expanding variables or interpreting special characters.

Let’s explore the difference with an example:

```bash
SKILL="DevOps"
echo "$SKILL"     # Output: DevOps
SKILL='DevOps'
echo '$SKILL'     # Output: DevOps

echo "I have got $SKILL skill" # Output: I have got DevOps skill
echo 'I have got $SKILL skill' # Output: I have got $SKILL skill
```

As you can see:

- Inside **double quotes**, `$SKILL` is expanded to its value.
- Inside **single quotes**, `$SKILL` is treated as a plain string — the variable is not expanded.

```bash
SKILL="Bash Scripting"
echo "$SKILL"     # Output: Bash Scripting
echo '$SKILL'     # Output: $SKILL
```

### Why This Matters

This distinction becomes important when constructing strings that include both **literal text** and **variable values**.

For instance, say we have a variable `VIRUS="ransomware"`, and we want to print:

> Due to ransomware virus, the company lost $9 million.

Let’s try this with double quotes:

```bash
VIRUS="ransomware"
echo "Due to $VIRUS virus, the company lost $9 million."
```

Output:

```
Due to ransomware virus, the company lost
```

Here, `$9` is interpreted as the **ninth positional parameter**, which likely doesn't exist, leading to an empty value — and the phrase becomes incomplete.

Now, try single quotes:

```bash
echo 'Due to $VIRUS virus, the company lost $9 million.'
```

Output:

```
Due to $VIRUS virus, the company lost $9 million.
```

It prints everything literally, including `$VIRUS`, which is **not what we want**.

### The Solution: Escaping Special Characters

To handle this correctly, use **double quotes** for variable expansion and **escape** special characters like `$` using a **backslash** (`\`):

```bash
echo "Due to $VIRUS virus, the company lost \$9 million."
```

Output:

```
Due to ransomware virus, the company lost $9 million.
```

This approach lets you:

- Expand the `VIRUS` variable
- Print the literal dollar sign

### Bonus Tip: Escaping in Vim or Scripts

When searching for or printing special characters like `$`, `*`, or `\` in scripts or editors like Vim, prefix them with a **backslash** to neutralize their special meaning.

### Summary

- **Double quotes** allow variable and command expansion.
- **Single quotes** treat everything as literal.
- Use **backslashes** to escape special characters when needed within double quotes.
- Understanding quoting behavior helps prevent bugs in string construction, command evaluation, and file manipulation in Bash.

Mastering quotes is essential for writing flexible, readable, and bug-free shell scripts. Try experimenting with different scenarios in your terminal to reinforce your understanding.

---

## 7. Understanding Command Substitution in Shell Scripting

In this section, we’ll explore *command substitution*—a fundamental concept you'll need if you want to write intelligent and dynamic shell scripts.

Command substitution allows you to capture the output of a command and assign it to a variable. You can do this in two ways: using backticks (`` ` ``) or the `$()` syntax. Both achieve the same result, but `$()` is generally preferred for its readability, especially with nested commands.

Let’s take a simple example. The `uptime` command prints system uptime. If you simply assign it like this:

```bash
up="uptime"
```

You’re just storing the string “uptime” into the variable `up`, not the command’s output.

To actually store the command’s result, you need to use command substitution:

```bash
up=$(uptime)
```

Now, `up` contains the actual output of the `uptime` command.

Let’s look at another example using the `who` command:

```bash
current_users=$(who)
```

This captures the list of users currently logged into the system.

You can also use command substitution with filtering tools like `grep` and `awk` to extract specific data. For instance, to get the amount of free RAM:

```bash
free_ram=$(free -m | grep Mem | awk '{print $4}')
```

This line filters the memory information and extracts the fourth field, which corresponds to available memory in MB.

Now you can use this variable to print a meaningful message:

```bash
echo "Available free RAM is $free_ram MB"
```

Here’s a simple script `6_command_substitution.sh` that demonstrates the power of command substitution to display system health:

```bash
#!/bin/bash

echo "Welcome $USER on $HOSTNAME"

free_ram=$(free -m | grep Mem | awk '{print $4}')
load=$(uptime | awk -F 'load average:' '{print $2}')
root_free=$(df / | tail -1 | awk '{print $4}')

echo "Available free RAM: $free_ram MB"
echo "Current load average: $load"
echo "Free root partition space: $root_free"
```

This script greets the user, then prints useful system information by combining system variables with command substitution. Later in this series, we’ll see how to run this script automatically on login to always stay informed about your system’s health.

---

## 8. Making Environment Variables Permanent with `export`

In this section, we’ll dive into **exporting variables** in the shell—how it works, why it's important, and how to make variables persist across sessions or become available system-wide.

You’ve probably already used variables in your scripts or terminal sessions. However, by default, these variables are **local** to the current shell session. Once you close the terminal or log out, they’re gone. If you want a variable to be accessible to child processes or persist across sessions, you’ll need to **export** it properly.

### Temporary vs Permanent Variables

Let’s say you define a variable:

```bash
SEASON="Monsoon"
```

To access it, you use `$SEASON`. But this variable only lives in the current shell. If you log out or open a new terminal, it's gone.

Even if you run a script that tries to use `$SEASON`, it won't work unless the variable is exported. That's because each script runs in a **child shell**, and non-exported variables from the parent shell are not inherited.

To make a variable available to child shells, you need to export it:

```bash
export SEASON="Monsoon"
```

Now, any script or command executed from this shell can access `$SEASON`. However, this export is still **temporary**—it will vanish when the shell session ends.

### Making Variables Permanent for a User

To make a variable persist across sessions for a specific user, you can add the export command to that user's **`.bashrc`** or **`.bash_profile`** file located in their home directory.

Example:

```bash
# Edit the file
vi ~/.bashrc

# Add the export command
export SEASON="Monsoon"
```

Once added, either **restart the shell** or manually source the file:

```bash
source ~/.bashrc
```

From now on, every time the user logs in, the variable will be set automatically.

### Setting Environment Variables Globally

If you want to set a variable for **all users** on the system, you should add it to the **`/etc/profile`** file:

```bash
sudo vi /etc/profile

# Add the global export
export SEASON="Winter"
```

This will make the variable available to all users on the system. Source the file:

```bash
source /etc/profile
```

Now, this variable will be available to every user when they log in. However, if a user also sets the same variable in their `.bashrc`, that value will **override** the global one. For example, if `/etc/profile` sets `SEASON="Winter"` and a user’s `.bashrc` sets `SEASON="Monsoon"`, then that user will see `"Monsoon"`.

### Recap

* Use `export VAR=value` to make a variable available to child processes.
* To make it persistent for a user, place the export command in `~/.bashrc` or `~/.bash_profile`.
* To make it global for all users, place it in `/etc/profile`.
* Variables in `.bashrc` will override those in `/etc/profile` for the same user.

Understanding and correctly using `export` is essential for creating robust, reusable scripts and environment configurations. 

---

## 9. Making Shell Scripts Interactive with `read`

In this section, we’ll explore how to make your shell scripts interactive using the `read` command. Interactive scripts allow you to accept user input at runtime, enabling dynamic behavior based on that input.

### Capturing User Input with `read`

The `read` command pauses script execution and waits for the user to enter a value. That input is then stored in a variable, which can be used later in the script.

Here’s a simple example:

```bash
#!/bin/bash

echo "Enter your skill:"
read SKILL
echo "Your skill is $SKILL"
```

When this script runs, it prompts the user to enter a value, stores it in the variable `SKILL`, and then prints it. This is the basic use of `read`.

### Using Options with `read`

The `read` command also supports several useful options:

* `-p` allows you to provide an inline prompt:

  ```bash
  read -p "Enter your username: " USERNAME
  ```

* `-s` suppresses user input (ideal for sensitive information like passwords):

  ```bash
  read -sp "Enter your password: " PASSWORD
  echo  # Just to move to the next line
  ```

Using these options, you can create a more user-friendly experience. For example:

```bash
#!/bin/bash

read -p "Enter your username: " USERNAME
read -sp "Enter your password: " PASSWORD
echo
echo "Hello, $USERNAME!"
# Do not print the password; -s is used to keep it hidden
```

When this script runs, the user sees the prompt for a username, types it in, and then is prompted for a password—without the password being echoed to the screen.

### When to Use Interactive Scripts

While `read` makes scripts interactive and flexible, it’s **not recommended** for automated environments like CI/CD pipelines or background processes. In DevOps and automation workflows, scripts should ideally run without requiring user input to avoid errors and interruptions.

However, for learning purposes, testing, or very specific user-driven scripts, `read` can be incredibly useful.

### Summary

* Use `read` to take user input during script execution.
* Enhance prompts with `-p` and protect sensitive input with `-s`.
* Avoid interactive scripts in automated or production environments.

---

## 10. Adding Decision Making to Your Shell Scripts with `if` Statements

Welcome to the decision-making part of scripting! Up until now, your shell scripts may have just executed a linear sequence of commands. But what if you want your script to make choices—like reacting to user input or the result of a command? That’s where `if` statements come into play.

### Why Use `if` Statements?

The `if` statement allows your script to evaluate conditions and take different actions depending on whether those conditions are true or false. This adds intelligence and flexibility to your scripts, making them capable of handling real-world scenarios like error checks, validation, branching logic, and more.

### Basic `if` Statement Syntax

Here’s the simplest structure:

```bash
if [ condition ]; then
  # commands to run if condition is true
fi
```
Or,
```bash
if [[ condition ]]; then
  # commands to run if condition is true
fi
```

Note: there should be a space between `[` and `condition` and another space between `condition` and `]`.

**`[` – Traditional Test Command**

* Also known as `test`, and works in **POSIX-compliant** shells (like `sh`).
* More limited in syntax and features.
* Requires **proper quoting** to avoid errors with empty variables or strings with spaces.

**`[[` – Bash Extended Test Command**

* **Bash-specific** (not POSIX), but more powerful and safer.
* Supports advanced string comparison (`==`, `!=`, `=~` for regex), logical operators (`&&`, `||`) directly.
* Less error-prone with unquoted variables (though still good practice to quote).

| Feature           | `[`         | `[[`           |    |            |
| --------------------- | --------------- | ---------------------- | -- | ---------------------- |
| Shell support     | POSIX, portable | Bash (and some others) |    |            |
| Safer with empty vars | No          | Yes            |    |            |
| Regex matching    | No          | Yes (`=~`)         |    |            |
| Logical ops (`&&`, \`\`)            | No | Yes (inside condition) |
| Quote handling    | Required    | Optional (mostly)      |    |            |

Use `[[ ... ]]` when writing **Bash scripts** — it's more robust and less prone to bugs. Use `[...]` only if you need **POSIX portability** (e.g., running in `/bin/sh`).

Let’s look at a practical example. Imagine we want to ask the user to enter a number and print a message based on whether that number is greater than 100.

```bash
#!/bin/bash

read -p "Enter a number: " NUM

if [[ $NUM -gt 100 ]]; then
  echo "You have entered the if block."
  sleep 3
  echo "Your number is greater than 100."
  date
else
  echo "Your number is less than or equal to 100."
fi

echo "Execution completed."
```

### Key Points

* **Spacing matters**: Always put spaces inside the square brackets. `[ $NUM -gt 100 ]` is correct. `[ $NUM-gt100 ]` will fail.
* **Operators**: Use `-gt` for “greater than”, `-lt` for “less than”, `-eq` for “equal to”, etc.
* **`then` and `fi`**: `then` marks the start of the `if` block, and `fi` (reverse of `if`) closes it.
* **`else` block**: Use `else` to handle the case when the condition is false.

### Enhancing with `elif`

You can also include `elif` (else-if) to test additional conditions:

```bash
if [[ $NUM -gt 100 ]]; then
  echo "Greater than 100"
elif [[ $NUM -eq 100 ]]; then
  echo "Exactly 100"
else
  echo "Less than 100"
fi
```

---

## 11. Using `elif` for Multi-Condition Checks in Shell Scripts

Welcome! In this section, we’ll expand on the decision-making capabilities of shell scripts by introducing the `elif` (else-if) statement. While `if` and `else` help us handle two possible outcomes, real-world scenarios often require more than just a binary choice. That’s where `elif` comes in—it allows us to evaluate multiple conditions in sequence.

### Why Use `elif`?

Imagine you want to check several possible conditions one after another. With just `if` and `else`, you’re limited to two paths. `elif` enables your script to consider multiple outcomes before falling back to a final `else` block.

### Practical Example: Checking Active Network Interfaces

Let’s say we want to check how many active network interfaces are present on a system, excluding the loopback interface. Here’s how we can approach it:

1. Use the `ip addr show` command to list interfaces.
2. Filter out the loopback interface using `grep -v`.
3. Count how many times the keyword `mtu` appears (indicating an interface).
4. Use `elif` to handle multiple scenarios based on the count.

Here's the script:

```bash
#!/bin/bash

# Count network interfaces (excluding loopback)
VALUE=$(ip addr show | grep -v "LOOPBACK" | grep -i mtu -c)

if [[ $VALUE -eq 1 ]]; then
  echo "Found one active network interface."
elif [[ $VALUE -gt 1 ]]; then
  echo "Found multiple active network interfaces."
else
  echo "No active network interface found."
fi
```

### Script Breakdown

* `grep -v "LOOPBACK"`: Excludes loopback interface from the results.
* `grep -i mtu -c`: Counts the case-insensitive occurrences of `mtu`.
* `$VALUE`: Stores the count result for condition checks.
* The `if`, `elif`, and `else` blocks print different messages based on how many interfaces are found.

### Output Example

If the script detects two active interfaces, you’ll see:

```
Found multiple active network interfaces.
```

This structured approach helps your scripts become more responsive and informative based on dynamic system states.

---

## 12. Modern and Traditional Bash Comparison Operators – What’s Best to Use?

If you’ve ever looked at a Bash script and thought:
**“What are these `-gt`, `-eq`, `-lt` operators? Can’t I just use `>`, `==`, or `<` like in other languages?”** — you're not alone. Let's clear the air around comparison operators in Bash and show you the modern and traditional ways to handle them effectively.

### 🧾 The Old-School Way: `-eq`, `-gt`, `-lt`, etc.

These are **arithmetic comparison operators** used with the traditional `[ ]` or the `test` command:

* `-eq` : equal to
* `-ne` : not equal to
* `-gt` : greater than
* `-lt` : less than
* `-ge` : greater than or equal to
* `-le` : less than or equal to

Example:

```bash
if [ "$VALUE" -gt 1 ]; then
  echo "More than one interface found"
fi
```

This approach is still very common, especially in POSIX-compliant scripts.

### ✅ The Modern Way: Using `[[ ]]` with Familiar Symbols

With Bash's `[[ ... ]]`, you can use more familiar operators — especially for **strings**, and in some cases, you can use logical operators more intuitively.

* String comparison:

  * `==` or `=` : equal to
  * `!=` : not equal
  * `=~` : regex match

But here's the catch:
For **numbers**, you still need to use `-gt`, `-lt`, etc., **even inside** `[[ ... ]]`. You **cannot** use `<`, `>`, or `==` for numeric comparison inside `[[ ]]`.

Incorrect numeric comparison (will not work as intended):

```bash
if [[ $VALUE > 1 ]]; then  # This compares strings, not numbers!
  echo "Wrong logic!"
fi
```

Correct:

```bash
if [[ $VALUE -gt 1 ]]; then
  echo "Correct logic"
fi
```

So when comparing numbers, even in modern scripts, stick with `-gt`, `-lt`, etc.

### 🧪 File and Boolean Operators

These are single-operand tests for files:

* `-f FILE` : file exists and is a regular file
* `-d FILE` : directory exists
* `-e FILE` : file or directory exists
* `-r FILE` : file is readable
* `-z` : string is empty
* `-n` : string is not empty

And don’t forget negation:
`! -f file.txt` → true if `file.txt` **does not exist**

### 🧠 Real-World Use: Process Monitoring

Let’s say you're checking if Apache is running using its PID file. Here are two valid approaches:

**Using exit code (`$?`)**:

```bash
systemctl status httpd > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
  echo "httpd is running"
else
  echo "httpd is not running"
fi
```

**Using `-f` to check PID file**:

```bash
if [[ -f /var/run/httpd/httpd.pid ]]; then
  echo "httpd is running"
else
  echo "Starting httpd..."
  systemctl start httpd
fi
```

Both approaches are valid — pick the one that suits your style or scenario best.

```bash
if [[ -f /var/run/httpd/httpd.pid ]]; then
  echo "httpd is running"
else
  echo "httpd is not running"
  echo "Starting httpd..."
  systemctl start httpd
  if [[ $? -eq 0 ]]; then
    echo "httpd started successfully"
  else
    echo "Failed to start httpd, Contact Admin"
  fi
fi
```

### ⏰ Bonus Tip: Automate with Cron

Once you’ve written a monitoring script like this, schedule it with a cron job to run every minute:

```bash
* * * * * /opt/scripts/11_monit.sh >> /var/log/monit_httpd.log 2>&1
```

This turns your script into a self-healing monitor for the `httpd` service.

### `> /dev/null 2>&1` 

The command:

```bash
systemctl status httpd > /dev/null 2>&1
```

breaks down like this:

* `> /dev/null`: This **redirects standard output (stdout)** to `/dev/null`, which is a special file that discards anything written to it. Think of it as a “black hole” for output.

* `2>&1`: This **redirects standard error (stderr)** (file descriptor 2) **to wherever standard output (stdout)** (file descriptor 1) is currently going — in this case, `/dev/null`.

**So what does this do?**

It **completely silences** the command — both normal output and error messages are discarded.

**Why use it?**

* To **run a command quietly** without printing anything to the terminal.
* Useful in scripts when you're **only interested in the exit status** (`$?`) and not in any output.

### Visual Summary:

| Part        | Meaning                                  |
| ----------- | ---------------------------------------- |
| `>`         | Redirect stdout                          |
| `/dev/null` | Discard the output                       |
| `2>&1`      | Redirect stderr to where stdout is going |

---

## 13. Understanding Loops in Bash Scripting

Loops are a fundamental part of bash scripting, allowing you to run commands repeatedly without writing them multiple times. In bash, two primary types of loops are commonly used: the **for loop** and the **while loop**. While there are a few others, this section focuses on the **for loop** and how it can simplify repetitive tasks.

The `for` loop is perfect for running a command a specific number of times or iterating over a list of values. For instance, if you need to add ten users using the `useradd` command, the only thing that changes each time is the username. Instead of writing the `useradd` command ten times, you can use a `for` loop to automate the process.

You can also use a `for` loop to run commands across multiple servers. By looping over a list of server addresses, you can log into each one and execute tasks, saving a lot of manual effort and time.

Let’s look at a basic example with a script named `13_for.sh`. Here's what it does:

```bash
#!/bin/bash

for VAR1 in java .net python ruby php
do
  echo "Looping over: $VAR1"
  sleep 1
  echo "-------------"
done
```

This loop goes through each programming language in the list, assigns it to the variable `VAR1`, and prints it. The `sleep` command is added just to slow it down for better visibility. The loop starts with `for` and ends with `done`, similar to how an `if` block is closed with `fi`.

Now, let’s consider a practical example with a script named `14_for.sh` to add users:

```bash
#!/bin/bash

my_users="Alpha Beta Gamma"

for usr in $my_users
do
  echo "Adding user $usr"
  useradd $usr
  id $usr
  echo "###############"
done
```

Here, the script iterates over the list of usernames and creates each user. It also displays the user's ID information and adds a separator for clarity. Since there are three usernames, the loop runs three times.

Using loops like these in your scripts not only makes your code cleaner but also drastically reduces manual work.

```bash
#!/bin/bash
echo "Bash version ${BASH_VERSION}"
for i in {0..10..2}; do
     echo "Welcome $i times"
done
```
Output:-
```
Bash version 5.1.8(1)-release
Welcome 0 times
Welcome 2 times
Welcome 4 times
Welcome 6 times
Welcome 8 times
Welcome 10 times
```
```bash
#!/bin/bash
echo "Bash version ${BASH_VERSION}"
for(( c=1; c<=5; c++ )); do
        echo "Welcome $c times"
done
```
Output:-
```
Bash version 5.1.8(1)-release
Welcome 1 times 
Welcome 2 times 
Welcome 3 times 
Welcome 4 times 
Welcome 5 times 
```
Infinite for loop to print Random numbers:-
```bash
#!/bin/bash
for(( ;; )); do
        echo $RANDOM
done
```

### While Loop in Bash

After understanding how `for` loops work with sequences, let’s dive into the **while loop** in Bash. Unlike the `for` loop, which iterates over a predefined list or sequence, a `while` loop runs **as long as a specified condition remains true**. This makes it ideal for scenarios where you don’t know in advance how many times a block of code needs to execute.

Let’s look at a basic example. Start by initializing a variable:

```bash
counter=0
```

Then, write a `while` loop that continues as long as the counter is less than 5:

```bash
while [ $counter -lt 5 ]
do
  echo "Looping..."
  echo "Value of counter is $counter"
  sleep 1
done
```

If you run this as - is, you'll notice it results in an **infinite loop**. Why? Because the value of `counter` never changes — it's always 0, and 0 is always less than 5. To fix this, you need to **increment the counter within the loop**:

```bash
counter=$((counter + 1))
```

Now, the complete loop looks like this:

```bash
counter=0

while [[ $counter -lt 5 ]]; do
  echo "Looping..."
  echo "Value of counter is $counter"
  sleep 1
  counter=$(( counter + 1 ))
done

echo "Out of the loop."
```

This script will run exactly five times, printing the counter value each time before exiting the loop once the condition becomes false.

#### Creating an Infinite Loop

Sometimes, you might want a loop to run forever—until you manually stop it or break the loop from inside. This is where the `true` keyword comes in:

```bash
num=2

while true
do
  echo $num
  num=$((num * 2))
  sleep 1
done
```

In this version, we start with the number 2 and keep doubling it on each iteration. Because the condition `true` is always satisfied, the loop will run infinitely. Be cautious with such loops—especially in scripts run as background processes or cron jobs—as they can consume significant system resources if not managed properly.

The `while` loop is powerful when you want code to execute until a dynamic condition changes. Just remember to update your condition inside the loop; otherwise, you risk creating infinite loops that can impact system performance.

---

## 14. Remote Command Execution with SSH in a Vagrant Setup

In this section, we’ll explore how to execute commands remotely from a central machine—referred to as the **script box** — to multiple web servers using SSH (How to execute commands from scriptbox to web01, web02). We'll also add a third machine running Ubuntu, which introduces some OS-specific nuances in handling remote access. Let’s walk through the complete setup and execution process.

We begin with a `Vagrantfile` that defines the following machines:

* **script-box** – the central control node
* **web01** and **web02** – primary target servers
* **web03** – an optional Ubuntu machine (you can skip this if your system resources are limited)

Each machine is assigned a static IP address:

* `web01` → 192.168.10.13
* `web02` → 192.168.10.14
* `web03` → 192.168.10.15

Save these IP addresses in scriptbox’s **/etc/hosts** file.

```bash
192.168.10.13 web01
192.168.10.14 web02
192.168.10.15 web03
```

### Testing Remote Connectivity

You can now test connectivity from the script box using ping or SSH. For example:

```bash
ping web01
ssh vagrant@web01
```

Initially, SSH will prompt you to confirm the fingerprint and then request a password. The default username and password are both `vagrant`.

### Handling Ubuntu’s Password Authentication

Ubuntu-based systems like `web03` often disable password authentication by default. If you encounter a `Permission denied (publickey)` error when logging in, follow these steps:

1. Log into `web03` from the host machine (not the script box) using key-based SSH.
2. Edit the SSH configuration file:

   ```bash
   sudo vim /etc/ssh/sshd_config
   sudo -i
   cd /etc/ssh/sshd_config.d/
   vim 60-cloudimg-settings.conf
   ```
   Ubuntu 20.04+ uses `/etc/ssh/sshd_config.d/` include path to override your main config.
3. Find and change:

   ```
   PasswordAuthentication no
   ```

   to

   ```
   PasswordAuthentication yes
   ```
4. Restart the SSH service:

   ```bash
   sudo systemctl restart ssh
   ```

Now you should be able to log into `web03` from the script box using password authentication.

### Creating a Dedicated User for Automation

Instead of using the default `vagrant` user, create a new user named **devops** on each machine. After logging into each web server:

1. Create the user:

   ```bash
   sudo adduser devops
   passwd devops
   ```
2. Add the user to the sudoers file using `visudo`:

   ```bash
   devops ALL=(ALL) NOPASSWD:ALL
   ```

This setup allows the script box to run privileged commands remotely via SSH without interactive password prompts.

### Remote Execution in Action

Once all machines are set up and the `devops` user is ready, you can perform remote command execution directly from the script box using SSH:

```bash
ssh devops@web01 uptime
ssh devops@web02 uptime
ssh devops@web03 uptime
```

This command:

* Connects to `web01` via SSH
* Runs the `uptime` command
* Returns the result to the script box without requiring an interactive login session

This approach is highly efficient for automating system administration tasks such as package installations, user management, or service configuration—especially across multiple machines.

By the end of this setup, you're equipped to perform remote command execution seamlessly from a single control node, making your Bash automation scripts far more powerful and scalable.

### Setting Up Key-Based SSH Authentication for Passwordless Login

When connecting to remote machines using SSH, you're typically prompted for a password each time. While this works, there's a more secure and efficient method: **key-based authentication**. Instead of entering a password on every login, you can configure your system to use a **public-private key pair**, which acts like a lock and key mechanism.

To begin, generate an SSH key pair using the following command (in scriptbox):

```bash
ssh-keygen
```

Just press Enter through the prompts to accept the defaults. This will create two files in the `~/.ssh` directory:

* `id_rsa` — your **private key** (keep this secure)
* `id_rsa.pub` — your **public key** (can be shared)

Think of the public key as the *lock* and the private key as the *key*. To enable passwordless login, you install the public key (the lock) on the remote machines (like `web01`, `web02`, and `web03`), and then use the private key (the key) from your local machine to authenticate.

Use the `ssh-copy-id` command to install your public key onto a remote machine (in scriptbox):

```bash
ssh-copy-id devops@web01
ssh-copy-id devops@web02
ssh-copy-id devops@web03
```

You'll be asked for the `devops` user’s password once for each machine—after that, the key will handle authentication.

Once done, test your setup:

```bash
ssh devops@web01
```

This time, SSH should log in without prompting for a password, thanks to the key stored in `~/.ssh/id_rsa`.

It is same as:-

```bash
ssh -i ~/.ssh/id_rsa devops@web01
```

By default, SSH uses `id_rsa` for authentication, but you can also specify a custom key using the `-i` flag:

```bash
ssh -i ~/.ssh/custom_key devops@web01
```

To verify your keys:

* View your **private key** with `cat ~/.ssh/id_rsa` (starts with `-----BEGIN OPENSSH PRIVATE KEY-----`)
* View your **public key** with `cat ~/.ssh/id_rsa.pub` (a shorter string ending with your username and hostname)

These two keys must match for authentication to succeed. With this setup complete, you're now ready for secure and seamless remote command execution.

---

## 15. Automation at Scale

Login to the script box:

```bash
vagrant ssh scriptbox
```
Perform the following operations:
```bash
mkdir remote_websetup && cd remote_websetup
vim remotehosts
```
Put the ip address or hostnames in remotehosts file:-
```
web01
web02
web03
```
Now connect to the remote machines using SSH:
```bash
for host in `cat remotehosts`;do echo $host; done
for host in `cat remotehosts`;do ssh devops@$host hostname; done
for host in `cat remotehosts`;do ssh devops@$host hostname && uptime; done
for host in `cat remotehosts`;do ssh devops@$host sudo yum install git -y; done
```
Create a new script named `multios_websetup.sh` with the following content:
```bash
#!/bin/bash

#Variable Declaration
URL="https://www.tooplate.com/zip-templates/2131_wedding_lite.zip"
ARTIFACT="2131_wedding_lite"
TMP_DIR="/tmp/webfiles"

yum help &> /dev/null

if [[ $? -eq 0 ]]; then
        # Variable setup
        sudo -i
        echo "Runnin setup on CentOs"
        PACKAGE="httpd wget unzip"                                                                               SVC="httpd"

        # Use the variables in the script
        yum install $PACKAGE -y
        systemctl enable --now $SVC
        mkdir -p $TMP_DIR
        cd $TMP_DIR
        wget $URL
        unzip $ARTIFACT.zip
        cp -r $ARTIFACT/* /var/www/html
        systemctl restart $SVC
else
        sudo -i
        PACKAGE="apache2 wget unzip"
        SVC="apache2"
        echo "Runnin setup on Ubuntu"
        # Variable setup
        sudo apt update
        sudo apt install $PACKAGE -y > /dev/null

        # Use the variables in the script
        systemctl enable --now $SVC
        mkdir -p $TMP_DIR
        cd $TMP_DIR
        wget $URL > /dev/null
        unzip $ARTIFACT.zip > /dev/null
        cp -r $ARTIFACT/* /var/www/html
        systemctl restart $SVC
        rm -rf $TEMPDIR
        systemctl status $SVC
        ls /var/www/html
fi 
```
Test script locally:-
```bash
./multios_websetup.sh
```
Now let us put the script `multios_websetup.sh` in remote machines. But before that let us see `scp` command.
```bash
echo "testfile" > testfile.txt
scp testfile.txt devops@web01:/tmp
```
But we can't logged in as devops user and try putting the script in the root directory of remote machines.

```bash
[root@scriptbox ~]# scp testfile.txt devops@web01:/root/
devops@web01's password:
dest open("/root/testfile.txt"): Permission denied
failed to upload file testfile.txt to /root/testfile.txt
```
Now let us put the script `multios_websetup.sh` in remote machines. Create a file `webdeploy.sh` and put the script in it.

```bash
#!/bin/bash

USR='devops'

for host in `cat remotehosts`; do
        echo "==========================="
        echo "Connecting to $host"
        scp multios_websetup.sh $USR@$host:/tmp/
        echo "Executing Script on $host"
        ssh $USR@$host /tmp/multios_websetup.sh
        ssh $USR@$host -rf /tmp/multios_websetup.sh
        echo "==========================="
        echo
done  
```
Modify the file permission:
```bash
chmod +x webdeploy.sh
```
Execute the file:-
```bash
./webdeploy.sh
```

---
