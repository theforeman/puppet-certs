require 'spec_helper'

describe 'certs::certificate_subject' do
  let(:certificate) do
    File.read('./fixtures/certificate_subject/certs/server.crt')
  end

  it 'should exist' do
    is_expected.not_to eq(nil)
  end

  it 'should return a certificate subject in RFC2253 format' do
    file = class_double("File")
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with("/tmp/client_cert.crt").and_return(true)
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with("/tmp/client_cert.crt").and_return(certificate)

    is_expected.to run.with_params('/tmp/client_cert.crt').and_return("CN=foreman.example.com,O=Test Org,C=US")
  end

  it 'should return a certificate subject in RFC2253 format with spaces' do
    file = class_double("File")
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with("/tmp/client_cert.crt").and_return(true)
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with("/tmp/client_cert.crt").and_return(certificate)

    is_expected.to run.with_params('/tmp/client_cert.crt', true).and_return("CN=foreman.example.com, O=Test Org, C=US")
  end

  it 'should handle a bad certificate' do
    file = class_double("File")
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with("/tmp/client_cert.crt").and_return(true)
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with("/tmp/client_cert.crt").and_return('aab32433adfad')

    is_expected.to run.with_params('/tmp/client_cert.crt').and_return(nil)
  end

  it 'should handle a non-existent file' do
    is_expected.to run.with_params('/tmp/client_cert.crt').and_return(nil)
  end

  it 'should exist' do
    is_expected.not_to eq(nil)
  end

end
