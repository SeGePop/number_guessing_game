#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=game -t --no-align -c"

# Define the game function
function GAME () {
    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
        echo -e "\nThat is not an integer, guess again:"
    else
        if [[ $GUESS -gt $NUMBER ]]; then
            NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
            echo -e "\nIt's lower than that, guess again:"
            read GUESS
            GAME
        elif [[ $GUESS -lt $NUMBER ]]; then
            NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
            echo -e "\nIt's higher than that, guess again:"
            read GUESS
            GAME
        else
            echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"
            if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
                UPDATE_USER=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
            fi
            exit 0  # Finish running after successful guess
        fi
    fi
}

# Generate a random secret number
NUMBER=$((1 + RANDOM % 1000))

# For testing
echo "Secret number: $NUMBER"

# Prompt for username
echo -e "\nEnter your username:"
read USERNAME

# Check if existing user
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
if [[ -z $USER_ID ]]; then
    # If not, welcome message
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
    NEW_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 1, 1000)")
    GAMES_PLAYED=1
    BEST_GAME=10000
else
    # If existing user
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USER_ID")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    # Increment GAMES_PLAYED by 1 and update database
    GAMES_PLAYED=$((GAMES_PLAYED + 1))
    DATABASE_UPDATE=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE user_id = $USER_ID")
fi

# Prompt for guessing the secret number
echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS

# Reset best game
NUMBER_OF_GUESSES=1

# Start the game
GAME
