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
# Turn ID is a randomly generated ID. Eventually it should be a GUID or something.
# Turn Number is a sequential number, reminiscent of a boxing match.
class Game
  attr_accessor :players, :current_question_idx, :turn_state, :turn_id, :turn_number

  def initialize(questions)
    @players = []
    @questions = questions
    @turn_id = rand
    @turn_number = 0 # is incremented immediately by next_turn!
    next_turn!
  end

  # Returns the current question.
  def current_question
    @questions[current_question_idx]
  end

  # For debug purposes
  def set_turn_id(id)
    @turn_id = id
    @turn_state[:turn_id] = id
  end

  # Changes the current question.
  # Eventually, make sure questions don't repeat.
  def next_turn!
    @turn_number += 1
    @current_question_idx = rand(@questions.length)
    @turn_state = new_turn_state
  end

  def add_player(username)
    @players << username unless @players.include? username
  end

  def submit_song(songname, username, songuri)
    return "Submit a real song!" if songname.strip == ""

    if existing_idx = submissions.index{|sub| sub.submitter == username }
      submission = submissions[existing_idx]
      return "#{submission.submitter} already submitted #{submission.songname}"
    end

    if existing_idx = submissions.index{|sub| sub.songname == songname }
      submission = submissions[existing_idx]
      return "Too bad! Someone else already submitted #{submission.songname}"
    end

    @turn_state[:submissions] << Submission.new(songname, username, songuri)

    true
  end

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
  attr_accessor :songname, :submitter, :votes, :songuri
  def initialize(songname, submitter, songuri)
    @songname = songname
    @submitter = submitter
    @songuri = songuri
    @votes = []
  end
end
