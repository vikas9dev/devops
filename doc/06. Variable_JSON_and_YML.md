# Variable, JSON and YML

Let's explore how JSON translates into YAML. Understanding this conversion is vital because, in DevOps, you'll encounter many tools and platforms that rely heavily on JSON and YAML for configuration and data exchange.

Although JSON and YAML aren't the only formats used in the DevOps world, they are among the most common. And as you progress through the course, their significance will become increasingly clear.

## Working with Variables and Data Structures in Bash and Python

Let’s get our hands dirty with some basic but essential programming concepts: **variables** and **data structures** in both **Bash** and **Python**. This section will serve as a stepping stone before we dive into JSON and YAML.

### Getting Started with Variables in Bash

To begin, if you're on **Windows**, use **Git Bash** (not PowerShell or Command Prompt). For **Mac users**, simply use the default **Terminal**.

Variables in Bash are temporary placeholders for data in your system's memory. For example:

```bash
skill="DevOps"
echo $skill
```

Here, `skill` is a variable storing the string "DevOps". We use `$skill` with the `echo` command to retrieve and display its value. It’s important to use **double quotes** when accessing variables within a string—single quotes will treat the variable as plain text:

```bash
echo "I am learning $skill"   # Correct. Output:- I am learning DevOps
echo 'I am learning $skill'   # Will print the literal text. Output:- I am learning $skill
```

You can also store integers:

```bash
num=123
echo $num
```

We'll go deeper into Bash scripting later in the course, but this gives you a taste of how variables work in shell environments.

### Jumping into Python

To follow along with Python, you can use any online Python editor. I recommend using **Brave Browser** for fewer ads, but any browser will work. You can also use **VS Code** or your preferred local editor. Or, simply use `python` in Bash to open a Python REPL (Read-Eval-Print Loop).

Python uses the `print()` function instead of `echo`. For example:

```python
print("This is my first Python string")
```

You can also store variables:

```python
skill = "DevOps"
print(skill)
```

Avoid using quotes around the variable name in `print()`, or it will just print the variable name as text.

### Python Data Types: Strings, Integers, Lists, Tuples

- **String**: Text data stored in quotes
  ```python
  skill = "DevOps"
  ```
- **Integer**: Numeric data

  ```python
  num = 123
  ```

- **List**: A collection of items in square brackets

  ```python
  tools = ["Jenkins", "Docker", "K8s", "Terraform", 90]
  print(tools)
  ```

  You can access elements using index numbers:

  ```python
  print(tools[0])   # Jenkins
  print(tools[-1])  # 90
  print(tools[1:4]) # Docker, K8s, Terraform, Here 1 including, 4 excluding
  ```

- **Tuple**: Similar to a list, but uses parentheses and is immutable ( it means it cannot be changed after it's created ).
  ```python
  tools_tuple = ("Jenkins", "Docker", "K8s", "Terraform", 90)
  print(tools_tuple)
  print(tools_tuple[1])  # Docker
  ```

### Python Dictionaries: Key-Value Storage

Dictionaries store data as key-value pairs inside curly braces:

```python
devops = {
    "skill": "DevOps",
    "year": 2026,
    "tech": "",
    "GitOps": ""
}
print(devops)
```

To retrieve values, use the key name:

```python
print(devops["skill"])   # DevOps
print(devops["year"])    # 2026
```

You can even slice the string values:

```python
print(devops["skill"][0])  # D
```

Dictionaries are incredibly useful and form the backbone of JSON structures—which we’ll explore next.

### Wrapping Up

This section covered:

- Creating and accessing variables in Bash and Python
- Understanding basic data types: string, integer, list, tuple, and dictionary
- Retrieving specific elements using indexing and slicing

Take some time to practice these examples. Play around with different variable types, print them out, and experiment with accessing values. This hands-on familiarity will be essential when we move on to working with **JSON** and **YAML**.

---

## From Python Data Structures to JSON and YAML: A Smooth Transition

By now, you’ve gained a solid understanding of **variables** and various **Python data structures** — a crucial foundation for working with modern tools and configurations. In this session, we’re going to bridge that knowledge into something even more practical: **JSON** and **YAML**.

Let’s begin by revisiting the dictionary we used earlier. Open a new tab, copy the dictionary, paste it in your Python environment, and print it. You’ll recognize it instantly as a dictionary — it’s enclosed in curly braces, with key-value pairs separated by commas. Simple enough.

Now, we’ll build on this. Instead of keeping values limited to strings and integers, we’ll create **more complex structures**. Take the `Tech` key, for example — we’ll assign it a dictionary as its value:

Let’s go further by adding a new key: `GitOps`, whose value will be a **list**:

```python
devops = {
    "skill": "DevOps",
    "year": 2026,
    "tech": {
        "Cloud": "AWS",
        "Containers": "K8s",
        "CICD": "Jenkins"
    }
    "GitOps": ["GitLab", "ArgoCD", "Tekton"]
}
```

Now, run the code again and observe the structure. Notice how a simple dictionary can grow to represent more complex, real-world data models. This structure is exactly what **JSON** (JavaScript Object Notation) is all about — it's just a way to format this kind of nested data in a universal, readable way.

Next, copy your Python dictionary and paste it into any online JSON editor. You’ll see the same keys and values neatly formatted, showing off the JSON structure: key-value pairs, nested dictionaries, lists — all clearly represented. This is **JSON**, and thanks to your understanding of Python structures, you can now read and write it with confidence.

Now, let’s talk about **YAML**. Open any online YAML editor. Take the same data, and let’s convert it step by step. Start by replacing equal signs with colons, remove curly braces and commas, and apply consistent indentation. YAML uses **spaces and hyphens** for structure — no brackets or braces. Here's a basic transformation:

```yaml
DevOps:
  Skill: Python
  Year: 2
  Tech:
    Cloud: AWS
    Containers: K8s
    CICD: Jenkins
    GitOps:
      - GitLab
      - ArgoCD
      - Tekton
```

Looks cleaner, right? That’s one of the reasons YAML is widely used for configuration files in tools like Kubernetes, Ansible, and more. Unlike JSON, YAML is more human-readable — but it’s very sensitive to indentation and spacing, so consistency is key.

To recap:

- **JSON** is ideal for data exchange — it’s strict, structured, and language-agnostic.
- **YAML** is perfect for configurations — cleaner and more readable.

As a **DevOps engineer**, you’ll often encounter both formats. Being able to **read JSON** and **write YAML** is an essential skill, and thanks to your foundation in Python data structures, you’re already well-equipped.

---
