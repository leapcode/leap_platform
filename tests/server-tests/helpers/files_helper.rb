class LeapTest

  #
  # Matches the regexp in the file, and returns the first matched string (or fails if no match).
  #
  def file_match(filename, regexp)
    if match = File.read(filename).match(regexp)
      match.captures.first
    else
      fail "Regexp #{regexp.inspect} not found in file #{filename.inspect}."
    end
  end

  #
  # Matches the regexp in the file, and returns array of matched strings (or fails if no match).
  #
  def file_matches(filename, regexp)
    if match = File.read(filename).match(regexp)
      match.captures
    else
      fail "Regexp #{regexp.inspect} not found in file #{filename.inspect}."
    end
  end

  #
  # checks to make sure the given property path exists in $node (e.g. hiera.yaml)
  # and returns the value
  #
  def assert_property(property)
    latest = $node
    property.split('.').each do |segment|
      latest = latest[segment]
      fail "Required node property `#{property}` is missing." if latest.nil?
    end
    return latest
  end

  #
  # a handy function to get the value of a long property path
  # without needing to test the existance individually of each part
  # in the tree.
  #
  # e.g. property("stunnel.clients.couch_client")
  #
  def property(property)
    latest = $node
    property.split('.').each do |segment|
      latest = latest[segment]
      return nil if latest.nil?
    end
    return latest
  end

end