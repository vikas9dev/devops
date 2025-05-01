# Bash Scripting

Bash scripting is a powerful way to automate tasks, streamline workflows, and manage system configurations in Unix-like operating systems. With a simple text file containing a series of commands, you can perform complex tasks quickly and efficiently.

## VM Setup

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

## Intro to Bash Scripting

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

## Bash Variables

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

## Understanding Command Line Arguments in Bash Scripts

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

## Exploring System Variables in Bash Scripts

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

## Understanding Quotes in Bash: Single vs Double Quotes

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
