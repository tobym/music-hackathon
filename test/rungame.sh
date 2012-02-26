#!/bin/bash

# This resets the game and sets the turn_id to 42
curl backend:4567/debug_reset -d ''

curl backend:4567/gamestate | python -m json.tool

# echo ""
# echo -n "Input turn ID: "
# read turn_id
turn_id=42

echo "DEBUG: register"
curl backend:4567/register -d username=toby | python -m json.tool
echo "DEBUG: submit song"
curl backend:4567/submit_song -d turn_id=$turn_id -d username=toby -d songname="ghosts n stuff" | python -m json.tool

echo "DEBUG: register"
curl backend:4567/register -d username=alex | python -m json.tool
echo "DEBUG: submit song"
curl backend:4567/submit_song -d turn_id=$turn_id -d username=alex -d songname="vida tombola" | python -m json.tool
echo "DEBUG: vote"
curl backend:4567/vote_for_song -d turn_id=$turn_id -d username=alex -d songname="ghosts n stuff" | python -m json.tool

echo "DEBUG: register"
curl backend:4567/register -d username=tal | python -m json.tool
echo "DEBUG: submit song"
curl backend:4567/submit_song -d turn_id=$turn_id -d username=tal -d songname="lights" | python -m json.tool
echo "DEBUG: vote"
curl backend:4567/vote_for_song -d turn_id=$turn_id -d username=tal -d songname="ghosts n stuff" | python -m json.tool

echo "DEBUG: register"
curl backend:4567/register -d username=jeff | python -m json.tool
echo "DEBUG: submit song"
curl backend:4567/submit_song -d turn_id=$turn_id -d username=jeff -d songname="la grange" | python -m json.tool
echo "DEBUG: vote"
curl backend:4567/vote_for_song -d turn_id=$turn_id -d username=jeff -d songname="ghosts n stuff" | python -m json.tool


echo "DEBUG: vote"
curl backend:4567/vote_for_song -d turn_id=$turn_id -d username=toby -d songname="lights" | python -m json.tool


echo "DEBUG: gamestate"
curl backend:4567/gamestate | python -m json.tool
echo "DEBUG: winner"
curl backend:4567/winner | python -m json.tool
