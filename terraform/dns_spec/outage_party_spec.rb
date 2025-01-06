  require 'resolv'

  RSpec.describe 'DNS Configuration for outage.party' do
    let(:dns) do
      config = {}
      config[:nameserver] = ENV.fetch('NAMESERVER')
      Resolv::DNS.new(config)
    end

describe 'TXT records' do
  let(:records) { dns.getresources('outage.party', Resolv::DNS::Resource::IN::TXT) }

  it 'has the correct number of records' do
    expect(records.length).to eq(0)
  end

    end

  end
