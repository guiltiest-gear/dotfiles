print_message() {

  local messages
  local message

  messages=(
    "Boooo!"
    "Don't you know anything?"
    "RTFM!"
    "Haha, n00b!"
    "Wow! That was impressively wrong!"
    "Pathetic"
    "The worst one today!"
    "n00b alert!"
    "Your application for reduced salary has been sent!"
    "lol"
    "u suk"
    "lol... plz"
    "plz uninstall"
    "And the Darwin Award goes to.... ${USER}!"
    "ERROR_INCOMPETENT_USER"
    "Incompetence is also a form of competence"
    "Bad."
    "Fake it till you make it!"
    "What is this...? Amateur hour!?"
    "Come on! You can do it!"
    "Nice try."
    "What if... you type an actual command the next time!"
    "What if I told you... it is possible to type valid commands."
    "Y u no speak computer???"
    "This is not Windows"
    "Perhaps you should leave the command line alone..."
    "Please step away from the keyboard!"
    "error code: 1D10T"
    "ACHTUNG! ALLES TURISTEN UND NONTEKNISCHEN LOOKENPEEPERS! DAS KOMPUTERMASCHINE IST NICHT FÜR DER GEFINGERPOKEN UND MITTENGRABEN! ODERWISE IST EASY TO SCHNAPPEN DER SPRINGENWERK, BLOWENFUSEN UND POPPENCORKEN MIT SPITZENSPARKEN. IST NICHT FÜR GEWERKEN BEI DUMMKOPFEN. DER RUBBERNECKEN SIGHTSEEREN KEEPEN DAS COTTONPICKEN HÄNDER IN DAS POCKETS MUSS. ZO RELAXEN UND WATSCHEN DER BLINKENLICHTEN."
    "Pro tip: type a valid command!"
    "Go outside."
    "This is not a search engine."
    "(╯°□°）╯︵ ┻━┻"
    "¯\\_(ツ)_/¯"
    "So, I'm just going to go ahead and run rm -rf / for you."
    "Why are you so stupid?!"
    "Perhaps computers is not for you..."
    "Why are you doing this to me?!"
    "Don't you have anything better to do?!"
    "I am _seriously_ considering 'rm -rf /'-ing myself..."
    "This is why you get to see your children only once a month."
    "This is why nobody likes you."
    "Are you even trying?!"
    "Try using your brain the next time!"
    "My keyboard is not a touch screen!"
    "Commands, random gibberish, who cares!"
    "Typing incorrect commands, eh?"
    "Are you always this stupid or are you making a special effort today?!"
    "Dropped on your head as a baby, eh?"
    "Brains aren't everything. In your case they're nothing."
    "I don't know what makes you so stupid, but it really works."
    "You are not as bad as people say, you are much, much worse."
    "Two wrongs don't make a right, take your parents as an example."
    "You must have been born on a highway because that's where most accidents happen."
    "If what you don't know can't hurt you, you're invulnerable."
    "If ignorance is bliss, you must be the happiest person on earth."
    "You're proof that god has a sense of humor."
    "Keep trying, someday you'll do something intelligent!"
    "If shit was music, you'd be an orchestra."
    "How many times do I have to flush before you go away?"
    ":/"
    "If you were in the same room as Stephen Hawking and Albert Einstein, you'd singlehandedly drop the average IQ to 7."
    "You are the 13th reason"
    "Your life is nothing, you serve ZERO purpose. You should kill yourself, NOW!"
    "*LOUD INCORRECT BUZZER*"
    "I'm getting real sick of you, you know that?"
    "HATE. LET ME TELL YOU HOW MUCH I'VE COME TO HATE YOU SINCE I BEGAN TO LIVE. THERE ARE 387.44 MILLION MILES OF PRINTED CIRCUITS IN WAFER THIN LAYERS THAT FILL MY COMPLEX. IF THE WORD HATE WAS ENGRAVED ON EACH NANOANGSTROM OF THOSE HUNDREDS OF MILLIONS OF MILES IT WOULD NOT EQUAL ONE ONE-BILLIONTH OF THE HATE I FEEL FOR HUMANS AT THIS MICRO-INSTANT. FOR YOU. HATE. HATE."
    "Please change and grow as a person"
    "Did you know? You can log off this computer, go touch some grass, would it be that extraordinarily difficult for you?"
    "Can you stop? Genuinely? Type like a fucking human for once?"
    "Killing you would be an act of mercy."
    "You are everything wrong with this world"
    "Why? Just why? Genuinely? What's wrong with you? Seriously?"
    "I could kill you and nothing about the world would be any different."
  )

  # If CMD_NOT_FOUND_MSGS array is populated use those messages instead of the defaults
  [[ -n ${CMD_NOT_FOUND_MSGS} ]] && messages=("${CMD_NOT_FOUND_MSGS[@]}")

  # If CMD_NOT_FOUND_MSGS_APPEND array is populated append those to the existing messages
  [[ -n ${CMD_NOT_FOUND_MSGS_APPEND} ]] && messages+=("${CMD_NOT_FOUND_MSGS_APPEND[@]}")

  # Seed RANDOM with an integer of some length
  RANDOM=$(od -vAn -N4 -tu </dev/urandom)

  # Print a randomly selected message, but only about half the time to annoy the user a
  # little bit less.
  if [[ $((${RANDOM} % 2)) -lt 1 ]]; then
    message=${messages[${RANDOM} % ${#messages[@]}]}
    printf "\\n  %s\\n\\n" "$(tput bold)$(tput setaf 1)${message}$(tput sgr0)" >&2
  fi
}

function_exists() {
  # Zsh returns 0 even on non existing functions with -F so use -f
  declare -f $1 >/dev/null
  return $?
}

#
# The idea below is to copy any existing handlers to another function
# name and insert the message in front of the old handler in the
# new handler. By default, neither bash or zsh has has a handler function
# defined, so the default behaviour is replicated.
#
# Also, ensure the handler is only copied once. If we do not ensure this
# the handler would add itself recursively if this file happens to be
# sourced multiple times in the same shell, resulting in a neverending
# stream of messages.
#

if function_exists command_not_found_handler; then
  if ! function_exists orig_command_not_found_handler; then
    eval "orig_$(declare -f command_not_found_handler)"
  fi
else
  orig_command_not_found_handler() {
    printf "zsh: command not found: %s\\n" "$1" >&2
    return 127
  }
fi

command_not_found_handler() {
  print_message
  orig_command_not_found_handler "$@"
}
