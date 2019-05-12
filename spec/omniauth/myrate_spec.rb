RSpec.describe OmniAuth::Myrate do
  let(:app) do
    lambda do
      [200, {}, ['Hello.']]
    end
  end
  subject do
    OmniAuth::Strategies::Myrate.new(app, 'appid', 'secret', @options || {}).tap do |strategy|
      allow(strategy).to receive(:request) do
        request
      end
    end
  end

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  it 'has a version number' do
    expect(OmniAuth::Myrate::VERSION).not_to be nil
  end

  describe '#client_options' do
    it 'has correct name' do
      expect(subject.options.name).to eq('myrate')
    end

    it 'has correct site' do
      expect(subject.client.site).to eq('https://n-license.firebaseapp.com/')
    end

    it 'has correct authorize_url' do
      expect(subject.client.options[:authorize_url]).to eq('https://n-license.firebaseapp.com/oauth/login')
    end

    it 'has correct token_url' do
      expect(subject.client.options[:token_url]).to eq('/oauth/access_token')
    end
  end

  describe 'overrides options' do
    context 'as strings' do
      it 'allows overriding the site' do
        @options = { client_options: { 'site' => 'https://example.com' } }
        expect(subject.client.site).to eq('https://example.com')
      end

      it 'allows overriding the authorize_url' do
        @options = { client_options: { 'authorize_url' => 'https://example.com' } }
        expect(subject.client.options[:authorize_url]).to eq('https://example.com')
      end

      it 'allows overriding the token_url' do
        @options = { client_options: { 'token_url' => 'https://example.com' } }
        expect(subject.client.options[:token_url]).to eq('https://example.com')
      end
    end
  end

  describe 'info' do
    before do
      allow(subject).to receive(:raw_info).and_return(raw_info_hash)
    end

    it 'returns uid' do
      expect(subject.uid).to eq(raw_info_hash['uid'])
    end

    it 'returns the nickname' do
      expect(subject.info[:nickname]).to eq(raw_info_hash['displayName'])
    end

    it 'returns the email' do
      expect(subject.info[:email]).to eq(raw_info_hash['email'])
    end
  end

  describe 'callback_url' do
    it 'returns callback url' do
      allow(subject).to receive(:callback_url).and_return('http://redirect_uri')
      expect(subject.callback_url).to eq('http://redirect_uri')
    end

    it 'returns full_host and script_name and callback_path as callback_url' do
      allow(subject).to receive(:full_host).and_return('XXX')
      allow(subject).to receive(:script_name).and_return('YYY')
      allow(subject).to receive(:callback_path).and_return('ZZZ')
      expect(subject.callback_url).to eq('XXXYYYZZZ')
    end
  end

  describe 'request_phase' do
    context 'with no request params set and x_auth_access_type specified' do
      before do
        allow(subject).to receive(:callback_url).and_return('http://redirect_uri')
      end

      it 'should not break' do
        expect { subject.request_phase }.not_to raise_error
      end
    end
  end
end

private

def raw_info_hash
  {
    'uid' => '123',
    'displayName' => 'Foo Bar',
    'email' => 'foo@example.com'
  }
end
