# Bash BDD spec

This is a simple script where will enable you to right some BDD tests for scripts.

```bdd
# Load the bash spec
source bash_spec.sh

# Load your script
source script_with_functions.sh

# Write scenarios
Describe my_function
    Given I have 'BRANCH=master'
    When I use with the arguments 'arg1 arg2 arg3'
    Then It should be valid '[[ $DEFINED_VARIABLE =~ ^some?value.*regex$ ]]'
    Then It should be valid '[ -f someNewFile.log ]'
```

It is initial, and it could be unclear for some folks how to use it. Scripts are hard to handle and will depend on how organized it is. If you have a script with functions, source it. Otherwise, create functions to wrap your bash script to have the same behavior.

> That is it, a big script file. I have plans to split it later and use a ci pipeline to merge in a big file like the current one. It will be easier to load one file, but breaking it will give a better organization to maintain the code. We could have both =D 

# How to use?

* Download the file and put in your project, or write your script test to download it.
  ```bash
  wget https://raw.githubusercontent.com/voiski/bash_spec/master/bash_spec.sh
  ```
* Create a script file to run your tests, it should source the `bash_spec.sh`.
  ```bash
  #!/bin/bash
  # Load bash bdd spec
  source bash_spec.sh
  ```
* Source the target script to test or write internal functions to execute your script. Ex:
  ```bash
  source my_script_with_functions.sh
  # Use this method in the describe(I got it from rspec idea instead of use scenarios)
  Describe some_function
    ...
    
  # or
  
  function test_my_script(){
    touch some_dependency.file
    bash my_script.sh $*
  }
  Describe test_my_script
    ...
  ```
* Add some scenarios to it.
  ```bash
    Describe my_function
        Given I have 'BRANCH=master'
        When I use with the arguments 'arg1 arg2 arg3'
        Then It should be valid '[[ $DEFINED_VARIABLE =~ ^some?value.*regex$ ]]'
        Then It should be valid '[ -f someNewFile.log ]'
  ```

## Available steps

It is just a initial and very generic steps, each one will basically evaluate the values.

* **Given** 
  * `I have '(.*)'` evaluate the content in the regex group `(.*)`;
  * `I run '(.*)'` evaluate the content in the regex group `(.*)` hiding the stdout.
* **When**
  * `I use with the arguments '(*.)'` run the function defined in the `Describe` function with the arguments of the regex group `(.*)`;
  * `I use without arguments` run the function defined in the `Describe` without arguments;
  * `I run` alias to without arguments step.
* **Then**
  * `It should be valid '(.*)'` evaluate the content in the regex group `(.*)`.


# How To extend?

## Initilization

You may need to initialize some variables or even clean results from the last scenario. We have a init method called `init_script_data` that you can override. It is generic, but you can redefine it in the middle of your code if you want to keep it isolated by a group of scenarios.

```bash
function init_script_data(){
    MY_VAR=0
    COUT_SOMETHING=0
    unset IT_WILL_BE_CREATED
    rm -f some.file
    echo "etc"
}
```

## Steps

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

And use it:

```bash
Describe my_function
    Given I have 'BRANCH=master'
    Given I have the number 00992 of something
    When I use with the arguments 'arg1 arg2 arg3'
    Then It should be valid '[[ $DEFINED_VARIABLE =~ ^some?value.*regex$ ]]'
    Then It should be valid '[ -f someNewFile.log ]'
```
