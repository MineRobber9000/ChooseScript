# ChooseScript Specification v0.1.1

## Abstract

ChooseScript is a simple scripting language for Choose Your Own Adventure-style 
stories. It has facilities to handle rudimentary state, take input, give 
output, make choices, and direct the story.

The reference implementation of ChooseScript was written in about a day in 
Python. It should not be taken as a be-all-end-all guide for implementing 
ChooseScript in any other context. Rather, when this doc and the reference 
implementation contradict each other, this doc should be followed.

ChooseScript files SHOULD be stored with the extension "chs". They MAY be 
stored with the extension "txt".

## 1. Lexer

### 1.1. Tokens

There are 6 types of tokens. They are as follows. (Note that each token name 
can be used in a sentence to refer to a token of that type; for instance, a 
`STEM` token may be referred to as simply "a stem".)

 - `STEM` - A stem is defined as "a string of alphanumeric characters, starting 
with a letter of either case, and without quotes."
 - `BOOLEAN` - The literal stems `true` and `false`.
 - `COMMAND` - A command. (See section 1.2 for commands.) All commands are 
valid stems.
 - `TARGET` - A stem, followed by a colon. This MUST NOT be the same as a 
command, and it SHOULD be unique. Targets are used as jumping places for 
`goto`, `beq`, and `bne` commands.
 - `NUMBER` - An integer.
 - `STRING` - A series of characters contained in double quotes. Double quotes 
can be escaped in the string by the literal `\"`. Newlines and whitespace 
inside strings are taken as literal.

### 1.2. Command stems

The following literal stems are commands. They MUST NOT be used as targets.

 - `print` - see section 2.1
 - `goto` - see section 2.2
 - `beq` - see section 2.2.1
 - `bne` - see section 2.2.2
 - `choose` - see section 2.3
 - `set` - see section 2.4
 - `input` - see section 2.4.1
 - `testequals` - see section 2.5
 - `check` - see section 2.5.1

## 2. Commands

The current version of the ChooseScript spec implements 9 commands. Commands 
can take 0 or more arguments (in practice, they each take at least one).

### 2.1. `print <STRING>`

Prints the argument string to an output. The argument string MUST expand 
variables (see section 3.1, "Expanding variables in strings").

### 2.2. `goto <STEM>`

Execution resumes from the target corresponding to the argument stem. If there 
is no target corresponding to the argument stem, an error MUST be thrown.

#### 2.2.1. `beq <STEM>`

If the flag is set (see section 3.2, "Comparison flag"), then this acts as a 
`goto` command. Otherwise, execution MUST fall through to the next command.

#### 2.2.1. `bne <STEM>`

If the flag is clear, then this acts as a `goto` command. Otherwise, execution 
MUST fall through to the next command.

### 2.3. `choose <STRING> <STEM> [<STRING> <STEM> ...]`

Allows the user to choose between 1 or more options. Each argument string 
corresponds to an argument stem. If the option corresponding to an argument 
string is chosen, that string's respective argument stem is used as the target 
to resume execution at. If an invalid option is chosen, execution MUST fall 
through to the next command. This allows the script to display a prompt to 
choose again, or take a default action if possible.

### 2.4. `set <STEM> <STRING>` OR `set <STEM> <NUMBER>` OR `set <STEM> 
<BOOLEAN>`

Sets the variable represented by the argument stem to the argument string, 
number, or boolean.

#### 2.4.1 `input <STEM> <STRING> [<STRING>]`

Takes input from the user, and stores it in the variable represented by the 
argument stem. The first argument string is used as the prompt, while the 
second argument string is the error message to provide if no input is given.

If the user doesn't provide any input, the second argument string is shown, and 
the user is prompted again. If the second argument string is not provided, a 
message similar in intent to "You must provide a value!" MUST be used instead.

### 2.5. `testequals <STEM> <STRING>` OR `testequals <STEM> <NUMBER>` OR 
`testequals <STEM> <BOOLEAN>`

Compares the variable represented by the argument stem to the argument string, 
number, or boolean, and stores the result in the flag (see section 3.2, 
"Comparison flag").

An undefined variable MUST fail all comparisons.

#### 2.5.1. `check <STEM>`

A shorthand for `testequals <STEM> true`. If the variable represented by the 
argument stem is not a boolean value, an error MUST be thrown.

## 3. Implementation details

The following are details of the implementation. These are meant to be 
generically-described concepts that describe a given function.

### 3.1. Expanding variables in strings

When a string is printed to an output, it must expand any variables in the 
string. Variables are inserted into a string by surrounding the variable name 
in double-curly brackets (like `{{so}}`).

If a variable is undefined, the insertion statement MUST remain unchanged. This 
allows a script writer to notice when a variable hasn't been set.

If a variable is defined, the insertion statement MUST be replaced by the 
string representation of the variable value. Booleans MUST be represented as 
literal `true` and `false`.

### 3.2. Comparison flag

The `testequals` and `check` commands test a variable value. If that test 
succeeds (i.e; the variable is equal to the given value, or the boolean 
variable is true), the comparison flag MUST be set. If the test fails (i.e; the 
variable is *not* equal to the given value, the boolean variable is false, or 
the variable is undefined), the comparison flag MUST be cleared.

If the comparison flag is set, then `beq` will branch, and `bne` will allow 
execution to fall through to the next command. If the comparison flag is clear, 
the opposite occurs.

The comparison flag MUST start as false.
