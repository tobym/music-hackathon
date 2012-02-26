require "rubygems"
require "sinatra"
require "json"

$: << "."
require "hackathon"

configure do
  QUESTIONS = [
    Question.new({:question => "What is the best song to walk your dog to?", :keywords => ["dog"]}),
    Question.new({:question => "What is the best song to study to?", :keywords => ["study"]}),
    Question.new({:question => "What is the best song to work to?", :keywords => ["work"]}),
    Question.new({:question => "What is the best song to rage to?", :keywords => ["rage"]}),
    Question.new({:question => "What is the best song to relax to?", :keywords => ["relax"]}),
    Question.new({:question => "What is the best song to run to?", :keywords => ["run"]}),
    Question.new({:question => "What is the best song to work out to?", :keywords => ["work out", "exercise"]})
  ]

  @@game = Game.new(QUESTIONS)

  mime_type :json, "application/json"
end

before do
  content_type :json

  # If there is a turn_id in this request, and it doesn't match the game's current turn_id, the client should resync.
  if params[:turn_id]
    if params[:turn_id].to_s.strip != @@game.turn_id.to_s.strip
      halt [400, {:message => "Current turn is #{@@game.turn_id}, your submission was for turn #{params[:turn_id]}!", :action => "resync"}.to_json]
    end
  end
end

get "/gamestate" do
  [200, {
    :question => @@game.current_question.to_hash,
    :players => @@game.players.map{|name| {:username => name}},
    :turn_id => @@game.turn_state[:turn_id],
    :round => @@game.turn_number,
    :submissions => @@game.submissions.map { |sub|
      {
        :songname => sub.songname,
        :songuri => sub.songuri,
        :songid => sub.songname.hash.abs, # sub.songuri.split(":").reverse.first, # this gets the unique part of the URI
        :submitter => sub.submitter,
        :votes => sub.votes
      }
    }
  }.to_json]
end

# FIXME this needs safe access so bad clients can't screw with the gamestate.
post "/next_turn" do
  @@game.next_turn!
  [200, {:turn_id => @@game.turn_id}.to_json]
end

# Get one question for the next round.
get "/question" do
  response = @@game.current_question.to_hash
  response[:turn_id] = @@game.turn_state[:turn_id]
  response.to_json
end

# User signs up to play the game. At the moment, it's a global game.
# required params:
#   :username
post "/register" do
  @@game.add_player(params[:username])
  [200, {
    :message => "Welcome to the game, #{params[:username]}",
    :username => params[:username],
    :turn_id => @@game.turn_id
  }.to_json]
end

# User submits their answer to the current question.
# required params:
#   :username
#   :turn_id
#   :songname
post "/submit_song" do
  true_or_error_msg = @@game.submit_song params[:songname], params[:username], params[:songuri]
  if true == true_or_error_msg
    [200, {
      :message => "Thanks for submitting #{params[:songname]}, #{params[:username]}",
      :turn_id => @@game.turn_id,
      :songname => params[:songname]
    }.to_json]
  else
    [400, {
      :message => true_or_error_msg
    }.to_json]
  end
end

# User votes for a song.
# required params:
#   :username
#   :turn_id
#   :songname
post "/vote_for_song" do
  true_or_error_msg = @@game.vote_for_song(params[:songname], params[:username])
  if true == true_or_error_msg
    [200, {
      :songname => params[:songname],
      :message => "#{params[:username]} voted for #{params[:songname]}"
    }.to_json]
  else
    [400, {
      :message => true_or_error_msg
    }.to_json]
  end
end

# Returns the winner(s)
# required params:
#   :turn_id
get "/winner" do
  num_voted = @@game.turn_state[:voters].length
  [200, {
    :winners => @@game.determine_winner.map{|sub| {
      :songname => sub.songname,
      :votes => sub.votes.length,
      :submitter => sub.submitter
    }},
    :question => @@game.current_question.to_hash,
    :num_voted => num_voted,
    :num_not_voted => @@game.players.length - num_voted,
  }.to_json]
end

get "/debug" do
  [200, {:game => @@game.inspect}.to_json]
end

post "/debug_reset" do
  @@game = Game.new(QUESTIONS)
  @@game.set_turn_id(42)
end
