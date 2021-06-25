require 'spec_helper'

describe 'certs::certificate_subject' do
  let(:test_cert) do
    <<~CERT
      -----BEGIN CERTIFICATE-----
      MIIC+TCCAeGgAwIBAgIUetO+zvwJ4nLNrxe9lcrT4h0noCMwDQYJKoZIhvcNAQEL
      BQAwHjEcMBoGA1UEAwwTVGVzdCBTZWxmLVNpZ25lZCBDQTAeFw0yMDExMTgwMjMw
      NDNaFw0zMDExMTYwMjMwNDNaMB4xHDAaBgNVBAMME2ZvcmVtYW4uZXhhbXBsZS5j
      b20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDcEtPd1uKX0hct7+qe
      gOEy72VB93cBGuEJis6yD7uJfdjnbBtiFwkxUqmQlsDmUsqcuh6106yDkaW6tyzT
      I6R0Xx8OJkT4bxOsgkr3xqZSrAQJvn/NmV4j6egckJlgYnSbkrOFvy5iO1A/Dc/m
      OrC6TJVGe/YvMCU6IYPU1f/acNucRZGopa7yfhyTd8nzArq1BCSrjqtCl8m9NPJZ
      IP8+06wQ6MCjyd+kjnm+Tq/P+mKEsXVDBQCQAyWFpZdUcu4zbL+UV2+O7QUtndEh
      k2nf4w3Rx70XvMwagfo3hE5cJ8rNXEynphhDzdJqzRDpPYItZauMDxmK+4oHOn0g
      90t5AgMBAAGjLzAtMAsGA1UdDwQEAwIFIDAeBgNVHREEFzAVghNmb3JlbWFuLmV4
      YW1wbGUuY29tMA0GCSqGSIb3DQEBCwUAA4IBAQBlIEA2CfZIa8LtUYlDwa5v+5Wf
      1ktmYTRtgEI+922T/eTB8uH1//VxpfK5ynljao7SNVcX+74Q+YH/4Ci4OfZvE5vA
      1IJXog5bfE4mVc1qXhH7TokBQx1L6vtUh9OaTGpBAVnS3J5jLw6+Tdi9FOeZdKHZ
      FvMnyZ7MQ6VjbLZsTy49o87Nstqkle48ivwSFrDU1cDN+6S/DUdHQnh8XtPB1PMh
      7WCxGGtzmw5s5SxBkyY/buGDr+kx52yULl6ZrnJD6PfR30X+8G3ltvmaCQllYadX
      eprUs5H2WDnTUUE78+cf1JK29Zs9it/l4t2uLc5Z94oXosFLkTKw6ZSB3X9J
      -----END CERTIFICATE-----
    CERT
  end

  it 'should exist' do
    is_expected.not_to eq(nil)
  end

  it 'should return a certificate subject in RFC2253 format' do
    file = class_double("File")
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with("/tmp/client_cert.crt").and_return(test_cert)

    is_expected.to run.with_params('/tmp/client_cert.crt').and_return("CN=foreman.example.com")
  end

  it 'should handle a bad certificate' do
    file = class_double("File")
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with("/tmp/client_cert.crt").and_return('aab32433adfad')

    is_expected.to run.with_params('/tmp/client_cert.crt').and_return(nil)
  end

  it 'should handle a non-existent file' do
    is_expected.to run.with_params('/tmp/client_cert.crt').and_return(nil)
  end
end
