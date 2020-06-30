#Ask for name#
input name "What's your name?" "Just put `Evan` if you don't want to give me your real name. Or maybe `Norman`. I like Norman."
#Variables in {{double curly brackets}} get expanded if they're set.#
print "Hello, {{name}}! Welcome to the ChooseScript demo."
print "This is just a simple example of a game in ChooseScript. There's not much to be said."
#Choices are implemented via the choose command. The string is a label, and the stem is the goto target for that choice.#
menu:
choose "New Game" start "Continue" continue
#If the choice isn't valid, it'll fall through, so you can handle that however you please.#
print "Invalid choice!"
goto menu

#A simple password system can be implemented by checking against a table of known passwords.#
#The `testequals` command tests if a variable is equal to a value. If it is, then it sets the flag to true.#
#`beq` jumps to the specified target if the flag is true, and falls through otherwise.#
continue:
input password "Enter password."
testequals password "1234"
beq start
testequals password "5142"
beq markread
testequals password "6245"
beq turn1
testequals password "9142"
beq markreadturn1
testequals password "9999"
beq turn2
testequals password "8888"
beq markreadturn2
print "Invalid password {{password}}!"
print "Starting new game..."

start:
print "{{name}} wakes up in a room with no recollection of how they got there."
print "A plaque in front of them reads as follows:"
print "+---------------------------+"
print "|    THE HALLWAY OF FATE    |"
print "|Choose wisely, or you shall|"
print "|  meet a death by endless  |"
print "|           abyss.          |"
print "+---------------------------+"
choice:
print "There's a map on the wall to the left, and a hallway to the right."
choose "Read the map" map "Go down the hallway" turn1 "Quit the game" quitstart

#Boolean flags can be implemented using the `check` and `set` commands.#
#The relevant bit here is to check a flag by using the `check` command.#
#`check <var>` is a shortcut for `testequals <var> true`.#
#Don't use `check <var>` if the variable in question isn't a boolean.#
#Unset variables are assumed to be false.#
map:
check readmap
beq skipmap
print "From reading the map, you know you have to make a right turn, then go straight."
markread:
#To set a flag, use `set <var> true`. (Or `set <var> false` to clear a flag.)#
set readmap true
goto choice
skipmap:
print "You already read the map. Just go down the hallway."
goto start

#The `markread<blah>` labels simply set the readmap flag and fall through to their respective label.#
markreadturn1:
set readmap true
turn1:
print "You come to a 3-way fork in the hallway. Do you:"
choose "Go left" fail "Go right" turn2 "Go straight" fail "Quit the game" quitturn1
print "Invalid choice!"
goto turn1

markreadturn2:
set readmap true
turn2:
print "You turn to the right, and breathe a sigh of relief as the floor doesn't drop out from under you."
check readmap
bne turn2choose
print "After all, that's what the map said to do."
turn2choose:
print "A ways down the hallway, you reach another 3-way fork. Do you:"
choose "Go left" fail "Go right" fail "Go straight" success "Quit the game" quitturn2
print "Invalid choice!"
goto turn2choose

#Generalized failure message. I could have a different failure message for each#
#possible wrong direction, but I don't feel like putting that much effort in.#
fail:
print "You pick your path. As you go to walk down it, you suddenly feel the floor drop out from under you. You fall into an endless abyss."
print "Game over."
goto end

#Success condition.#
success:
check readmap
bne skipendmap
print "The map said to go straight, and so straight you went."
skipendmap:
print "As you head straight down the hallway, you breathe a sigh of relief. The floor under you stays solid. Soon, you're blinded by a light."
print "When the light clears, you're back in front of your computer."
print "You did it! Congratulations, {{name}}!"
#The flag is still set to the value of `readmap` from earlier, so we don't need to `check` it again.#
beq end
print "You didn't even need the map! Did you cheat, or did you trial-and-error your way through it?"
print "Either way, most excellent!"
goto end

#Now for the password system.                                         #
#At every stage, you can quit out, and you'll receive a password.     #
#For each stage, the corresponding `quit<label>` checks if readmap    #
#is set, and if so, it jumps to `quit<label>read`. Otherwise, it spits#
#out the password for not having read the map and quits.              #
#If readmap is set, however, it'll spit out the password for having   #
#read the map instead.                                                #
quitstart:
check readmap
beq quitstartread
print "Your password is `1234`."
goto end
quitstartread:
print "Your password is `5142`."
goto end
quitturn1:
check readmap
beq quitturn1read
print "Your password is `6245`."
goto end
quitturn1read:
print "Your password is `9142`."
goto end
quitturn2:
check readmap
beq quitturn2read
print "Your password is `9999`."
goto end
quitturn2read:
print "Your password is `8888`."
goto end

#The end label is at the end of the file, and serves as a way to skip everything. #
#It doesn't necessarily have to be called `end`, but I call it that because that's#
#what it is; the end.                                                             #
end:
