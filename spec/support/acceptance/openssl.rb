def normalize_openssl_subject(subject)
  return subject unless subject.start_with?('/')
  # openssl < 1.1
  subject[1..-1].split('/').join(', ').gsub('=', ' = ')
end

shared_examples 'certificate issuer' do |expected|
  it { expect(normalize_openssl_subject(subject.issuer)).to eq(expected) }
end

shared_examples 'certificate subject' do |expected|
  it { expect(normalize_openssl_subject(subject.subject)).to eq(expected) }
end
