raise SkipTest unless $node["services"].include?("webapp")

class TestAWebapp < LeapTest
  depends_on "TestNetwork"

  def setup
  end

  def test_test
    assert false, 'hey, stop here'
  end

end
