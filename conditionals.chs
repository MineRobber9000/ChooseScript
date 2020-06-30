input text "Type `foo`." "I didn't say \"type nothing\", I said \"type `foo`\"."
#`testequals` tests if a variable is equal to a value.#
#In this case, we're testing if the variable `text` is equal to the string "foo".#
testequals text "foo"
#`beq` will jump to the given target if the comparison is true.#
beq yes
#`bne` will jump to the given target if the comparison is false.#
bne no
print "This will never execute."

no:
print "You couldn't even follow that simple direction. Good job."
goto end

yes:
print "Congratulations! You actually listened to me!"

end:
