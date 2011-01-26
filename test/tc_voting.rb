require 'voting/voting'
require 'time_hack/time_moves'
require 'test/unit'

class VM < Bud
  include VotingMaster
  include TimeMoves
end

class VA < Bud
  include VotingAgent
  include TimeMoves
end

class VA2 < VA

  # override the default
  declare 
  def decide
    cast_vote <= waiting_ballots.map{|b| b if 1 == 2 }
  end
end

class TestVoting < Test::Unit::TestCase

  def start_kind(kind, port)
    t = nil
    assert_nothing_raised(RuntimeError) { eval "t = #{kind}.new('localhost', #{port})" } 
    return t
  end

  def start_three(one, two, three, kind)
    t = VM.new('localhost', one, {'dump' => true, 'visualize' => true})
    t2 = start_kind(kind, two)
    t3 = start_kind(kind, three)
    t.run_bg
    t2.run_bg
    t3.run_bg

    t.member << ["localhost:#{two.to_s}"]
    t.member << ["localhost:#{three.to_s}"]


    return [t, t2, t3]
  end
  
  def test_votingpair
  
    (t, t2, t3) = start_three(12346, 12347, 12348, "VA")

    t.begin_vote <+ [[1, 'me for king']]

    sleep 3

    assert_equal([1,'me for king', 'localhost:12346'], t2.waiting_ballots.first)
    assert_equal([1,'me for king', 'localhost:12346'], t3.waiting_ballots.first)
    
    assert_equal([1, 'yes', 2], t.vote_cnt.first)
    assert_equal([1, 'me for king', 'yes'], t.vote_status.first)
  end

  def test_votingpair2
  
    (t, t2, t3) = start_three(12316, 12317, 12318, "VA2")

    t.begin_vote <+ [[1, 'me for king']]

    sleep 3

    assert_equal([1,'me for king', 'localhost:12316'], t2.waiting_ballots.first)
    assert_equal([1,'me for king', 'localhost:12316'], t3.waiting_ballots.first)
    
    t2.cast_vote <+ [[1, "hell yes"]]

    sleep 2

    assert_equal([1, 'hell yes', 1], t.vote_cnt.first)
    assert_equal([1, 'me for king', 'in flight'], t.vote_status.first)

    t3.cast_vote <+ [[1, "hell yes"]]

    sleep 3

    assert_equal([1, 'hell yes', 2], t.vote_cnt.first)
    assert_equal([1, 'me for king', 'hell yes'], t.vote_status.first)
  end
    
    
end