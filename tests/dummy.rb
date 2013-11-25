# only run in the dummy case where there is no hiera.yaml file.
raise SkipTest unless $node["dummy"]

class Robot
  def can_shoot_lasers?
    "OHAI!"
  end

  def can_fly?
    "YES!"
  end
end

class TestDummy < LeapTest
  def setup
    @robot = Robot.new
  end

  def test_lasers
    assert_equal "OHAI!", @robot.can_shoot_lasers?
    pass
  end

  def test_fly
    refute_match /^no/i, @robot.can_fly?
    pass
  end

  def test_blah
    assert false
    pass
  end

  def test_that_will_be_skipped
    skip "test this later"
    pass
  end

  def test_err
    12/0
    pass
  end

end
