require "rubygems"
require "test/unit"

$: << "."
require "hackathon"

class TestStuff < Test::Unit::TestCase
 
  def test_sanity
    assert_equal("foo", Question.new({:question => "foo"}).question)
  end

  def test_add_player
    game = Game.new
    game.add_player "bob"
    game.add_player "bob"
    assert_equal ["bob"], game.players
  end
 
end
