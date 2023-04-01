#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"
#randomly generate number
RANDOM_NUM=$[ $RANDOM % 1000 + 1 ]
#tally tries
TRIES=0
#prompt for username
echo Enter  your username:
read USERNAME

USER=$($PSQL "SELECT * FROM users WHERE name='$USERNAME'")

#if username doesn't exist
if [[ -z $USER ]]
then
  #add it to database
  NEW_USER=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
  #greet new user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
#else user does exist
else
  #welcome back user with username, number of games played, and best game
  echo $USER | while read NAME SLASH ID SLASH GAMES_PLAYED SLASH BEST_GAME
  do
    echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

function MAKE_GUESS {
  echo $1
  #guess random number
  read GUESS
  #increment tries
  ((TRIES+=1))
  #check guess
  CHECK_GUESS
}

function CHECK_GUESS {
  #if guess isn't a number
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    MAKE_GUESS "That is not an integer, guess again:"
  else
    #if guess is lower than random number
    if [[ $GUESS -lt $RANDOM_NUM ]]
    then
      #message to guess higher
      MAKE_GUESS "It's higher than that, guess  again:"
    #else if guess is higher than random number
    elif [[ $GUESS -gt $RANDOM_NUM ]]
    then
      #message to guess lower
      MAKE_GUESS "It's lower than that, guess again:"
    else
      #message you win!!
      echo "You guessed it in $TRIES tries. The secret number was $RANDOM_NUM. Nice job!"
      #update database with user's tries(if it is less than best_game) and increment games_played
      UPDATE_USER=$($PSQL "UPDATE users SET games_played=(users.games_played + 1), best_game=least(users.best_game,$TRIES) WHERE name='$USERNAME'")
    fi
  fi
}

MAKE_GUESS "Guess the secret number between 1 and 1000:"
