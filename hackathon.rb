require "json"

class Question
  attr_accessor :question, :keywords
  def initialize(options = {:question => nil, :keywords => []})
    @question = options[:question]
    @keywords = options[:keywords]
  end

  def to_hash
    {:question => @question, :keywords => @keywords}
  end

  def to_json
    to_hash.to_json
  end
end

# Maintains the game state
class Game
  attr_accessor :players, :current_question_idx, :turn_state, :turn_id

  def initialize(questions)
    @players = []
    @questions = questions
    @turn_id = rand
    next_turn!
  end

  # Returns the current question.
  def current_question
    @questions[current_question_idx]
  end

  # Changes the current question.
  # Eventually, make sure questions don't repeat.
  def next_turn!
    @current_question_idx = rand(@questions.length)
    @turn_state = new_turn_state
  end

  def add_player(username)
    @players << username unless @players.include? username
  end

  # FIXME what happens if two players submit the same song?
  def submit_song(songname, username)
    @turn_state[:submissions] << Submission.new(songname, username)
  end

  # FIXME is it really appropriate to have duplicate submissions?
  # ghetto error responses = true for success, an error message string if failure. Scala's Either would be nice here
  def vote_for_song(songname, username)
    # Only vote once per turn
    return "#{username} already voted" if @turn_state[:voters].include? username
    return "can't find '#{songname}'" unless submissions.map{|sub| sub.songname}.include? songname

    @turn_state[:voters] << username
    @turn_state[:submissions].select{|sub| sub.songname == songname}.each do |sub|
      if sub.submitter == username # can't vote for your own song! If you do, at the moment you just wasted your vote.
        return "#{username} can't vote for themselves"
      else
        sub.votes << username
        return true
      end
    end

    "wtf mate"
  end

  # Returns the submission(s) with the most votes.
  # (There can be ties, btw).
  # You can call this whenever; it's acceptable to have a "winner" even if not everyone has voted.
  def determine_winner
    sorted = @turn_state[:submissions].sort_by{|sub| sub.votes.length}.reverse
    top = sorted.first
    all_top = sorted.take_while{|sub| sub.votes.length == top.votes.length}
  end

  def submissions
    @turn_state[:submissions]
  end


  private

  def new_turn_state
    # submissions is a list of song submissions
    # voters is a list of players who have voted this turn
    {:submissions => [], :voters => [], :turn_id => (@turn_id = rand)}
  end

end

class Submission
  attr_accessor :songname, :submitter, :votes
  def initialize(songname, submitter)
    @songname = songname
    @submitter = submitter
    @votes = []
  end
end
