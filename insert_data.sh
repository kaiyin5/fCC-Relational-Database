#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
    then
    # insert data to the teams table
    # get team_id of winner and opponent
    W_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    O_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # if winner team_id not found 
    if [[ -z $W_ID ]]
      then
      # insert team_id
      INSERT_W_ID_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
      if [[ $INSERT_W_ID_RESULT == "INSERT 0 1" ]]
        then
          echo Inserted into teams, $WINNER
      fi
      # get new team_id
      W_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi
    # if opponent team_id not found 
    if [[ -z $O_ID ]]
      then
      # insert team_id
      INSERT_O_ID_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
      if [[ $INSERT_O_ID_RESULT == "INSERT 0 1" ]]
        then
          echo Inserted into teams, $OPPONENT
      fi
      # get new team_id
      O_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi
    # insert data to the games table
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES ($YEAR,'$ROUND',$W_ID,$O_ID,$WINNER_GOALS,$OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into games, $YEAR - $ROUND
    fi
  fi
done