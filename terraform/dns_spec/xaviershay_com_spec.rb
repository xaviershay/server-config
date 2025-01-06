  require 'resolv'

  RSpec.describe 'DNS Configuration for xaviershay.com' do
    let(:dns) do
      config = {}
      config[:nameserver] = ENV.fetch('NAMESERVER')
      Resolv::DNS.new(config)
    end

describe 'MX records' do
  let(:records) { dns.getresources('xaviershay.com', Resolv::DNS::Resource::IN::MX) }

  it 'has the correct number of records' do
    expect(records.length).to eq(2)
  end

it 'includes MX record with preference 10 and exchange in1-smtp.messagingengine.com' do
  matching_record = records.find do |r|
    r.preference == 10 && r.exchange.to_s == 'in1-smtp.messagingengine.com'
  end
  expect(matching_record).not_to be_nil
end

it 'includes MX record with preference 20 and exchange in2-smtp.messagingengine.com' do
  matching_record = records.find do |r|
    r.preference == 20 && r.exchange.to_s == 'in2-smtp.messagingengine.com'
  end
  expect(matching_record).not_to be_nil
end
    end


describe 'TXT records' do
  let(:records) { dns.getresources('xaviershay.com', Resolv::DNS::Resource::IN::TXT) }

  it 'has the correct number of records' do
    expect(records.length).to eq(1)
  end

it 'includes TXT record "v=spf1 include:spf.messagingengine.com ~all"' do
  expect(records.map(&:strings).map { |s| s.join('') }).to include('v=spf1 include:spf.messagingengine.com ~all')
end
    end

  end
