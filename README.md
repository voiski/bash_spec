# Bash BDD spec

This is a simple script where will enable you to right some BDD tests for scripts.

```bdd
# Load the bash spec
source bash_spec.sh

# Load my script
source script_with_functions.sh

Describe my_function
    When I use with the arguments 'arg1 arg2 arg3'
    Then It should be valid '[[ $DEFINED_VARIABLE =~ ^some?value.*regex$ ]]'
    Then It should be valid '[ -f someNewFile.log ]'
```

It is inittial and it could be unclear for some folks how to use it. Scripts are hard to handle and will depend of how it is organized.

# How to use?

* Download the file and put in your project, or write your script test to download it.
* Create a script file to run your tests, it should source the `bash_spec.sh`.
* Source the target script to test or write internal functions to execute your script. Ex:
  ```bash
  function test_my_script(){
    touch some_dependency.file
    bash my_script.sh
  }
  # Use this method in the describe(I got it from rspec idea instead of use scenarios)
  Describe test_my_script
    ...
  ```
* Add some scenarios to it.

# How To extend?

The steps are mapped in threee arrays with phrase as the key and function name as the value.
* **GIVEN_MAP** Steps that define the pre-conditions to the scenario;
* **WHEN_MAP** Steps related to some change trigger like executions, etc. It is when your function/script will run.
* **THEN_MAP** Validation steps to check the results of your test, like the assert methods.

Example:

```bash

# Keep the function name as the phrase to avoid conflicst
GIVEN_MAP["My given phrase"]=Given_My_given_phrase
Given_My_given_phrase(){
    define something
}

# You can reuse the function with other phrases, like an alias
GIVEN_MAP["Another phrase"]=Given_My_given_phrase

# You can work with regex groups too
GIVEN_MAP["I have the number ([0-9]*) of something"]=Given_I_have_the_number_of_something
Given_I_have_the_number_of_something(){
    echo "Number: $1"
    MY_NUMER=$1
}
```
