#Name prompt, to show off the `input` command.                                                              #
#`input` has an optional third argument, where it's a string to print if the user doesn't provide any input.#
nameprompt:
input name "What's your name?" "You need a name to continue. It doesn't even have to be yours!"

top:
print "Well, {{name}}, you find yourself at the top of the mountain."
print "How do you get down?"
#The `choose` command takes a string and stem for each choice.#
#The string is a label, describing the choice, while the stem is the goto target if that choice is chosen.#
choose "Cause an avalanche" avalanche "Hike down the mountain like a normal person" hike
#If the user doesn't input a valid choice, it falls through, allowing you to handle an invalid choice on your own.#
print "That's not a choice!"
goto top

avalanche:
print "As the avalanche begins, you very quickly realize that you have no real way of outrunning the avalanche."
print "You suffocate to death beneath the snow."
print "You failed."
goto end

hike:
print "You hike down the mountain like a normal person, and you make it to the bottom unscathed."
print "You succeeded."

end:
