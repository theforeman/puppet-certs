RSpec::Matchers.define :match_without_whitespace do |expected|
  match do |actual|
    actual.gsub(/\s*/, '').match?(Regexp.new(expected.source, Regexp::EXTENDED))
  end

  failure_message do |actual|
    "Actual:\n\n\s\s#{actual.gsub(/\s*/, '')}\n\nExpected:\n\n\s\s#{expected.source}"
  end
end
