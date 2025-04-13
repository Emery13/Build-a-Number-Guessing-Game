#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

START() {
  # prompt the user for a username
  echo "Enter your username:"
  read USERNAME
  
  # check if user already exists
  RETURNING_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
  if [[ -z $RETURNING_USER ]]
  then
    # if first time user, welcome them
    echo "Welcome, $USERNAME! It looks like this is your first time here."

  else
    # if returning user, get number of games_played and best_game then print these data
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  # generate a random number
  RANDOM_NUMBER=$(( 1 + RANDOM % 1000 ))

  # initiate variable storing the number of guesses
  NUMBER_OF_GUESSES=0

  # ask user for input
  echo "Guess the secret number between 1 and 1000:"
  read USER_GUESS
 (( NUMBER_OF_GUESSES++ ))

  # check if input is a valid entry, ie integer
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    # if input is not an integer, prompt for an integer until the user enters an integer
    while [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    do
      echo "That is not an integer, guess again:"
      read USER_GUESS
      (( NUMBER_OF_GUESSES++ ))
    done
  fi

  # if input is valid, check if it is equal to random number
  if [[ ! $USER_GUESS == $RANDOM_NUMBER ]]
  then
    # if user guess is not equal to random number
    while [[ ! $USER_GUESS == $RANDOM_NUMBER ]]
    do
      if [[ $USER_GUESS -lt $RANDOM_NUMBER ]]
      then
        # if lower than the number to guess
        echo "It's higher than that, guess again:"
        read USER_GUESS
      else
        # if lower than the number to guess
        echo "It's lower than that, guess again:"
        read USER_GUESS
      fi
      (( NUMBER_OF_GUESSES++ ))
    done
    # if guessed number is equal to random number
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
  else
    # if guessed number is equal to random number
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
  fi

  # input player data to database
  if [[ -z $RETURNING_USER ]]
  then
    # if fist time user, input their username, number of games played and best game data
    INPUT_FIRSTIME_USER_DATA=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 1, $NUMBER_OF_GUESSES)")
  else
    # if returning user, increase their number of games played counter by 1 and update data
    GAMES_PLAYED=$GAMES_PLAYED+1
    UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")
    
    if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
    then
      # if this game's number of guesses is lower than their best score, make it their new best game and update data
      BEST_GAME=$NUMBER_OF_GUESSES
      UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$BEST_GAME WHERE username='$USERNAME'")
    fi
  fi
}

START