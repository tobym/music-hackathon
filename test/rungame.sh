curl localhost:4567/gamestate

echo ""
echo -n "Input turn ID: "
read turn_id

echo "DEBUG: register"
curl localhost:4567/register -d username=toby | python -m json.tool
echo "DEBUG: submit song"
curl localhost:4567/submit_song -d turn_id=$turn_id -d username=toby -d songname="a great song" | python -m json.tool
echo "DEBUG: register"
curl localhost:4567/register -d username=alex | python -m json.tool
echo "DEBUG: submit song"
curl localhost:4567/submit_song -d turn_id=$turn_id -d username=alex -d songname="other song" | python -m json.tool
echo "DEBUG: gamestate"
curl localhost:4567/gamestate | python -m json.tool
echo "DEBUG: vote"
curl localhost:4567/vote_for_song -d turn_id=$turn_id -d username=alex -d songname="a great song" | python -m json.tool
echo "DEBUG: gamestate"
curl localhost:4567/gamestate | python -m json.tool
echo "DEBUG: winner"
curl localhost:4567/winner | python -m json.tool
