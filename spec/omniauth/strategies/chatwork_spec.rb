RSpec.describe OmniAuth::Strategies::Chatwork, type: :strategy do
  let(:strategy) do
    [OmniAuth::Strategies::Chatwork, client_id, client_secret, strategy_options.merge(provider_ignores_state: true)]
  end

  let(:strategy_options) { {} }
  let(:client_id)        { "test_client_id" }
  let(:client_secret)    { "test_client_secret" }
  let(:code)             { "test_authorization_code" }

  describe "callback phase" do
    before do
      basic_auth = OAuth2::Authenticator.encode_basic_auth(client_id, client_secret)

      stub_request(:post, "https://oauth.chatwork.com/token").
        with(body: {"code"=>code, "grant_type"=>"authorization_code", "redirect_uri"=>"http://example.org/auth/chatwork/callback"},
             headers: {"Authorization"=>basic_auth, "Content-Type"=>"application/x-www-form-urlencoded"}).
        to_return(status: 200, body: fixture("token.json"), headers: {"Content-Type" => "application/json"})

      stub_request(:get, "https://api.chatwork.com/v2/me").
        with(headers: {"Authorization"=>"Bearer #{access_token}"}).
        to_return(status: 200, body: fixture("me.json"), headers: {"Content-Type" => "application/json"})
    end

    subject!(:post_callback) { post "/auth/chatwork/callback", code: code, state: "aaaaaaaaaaaaa" }

    let(:access_token) { "ACCESS_TOKEN" }

    sets_an_auth_hash

    sets_provider_to "chatwork"

    sets_uid_to 123

    describe "info" do
      subject do
        post_callback
        last_request.env["omniauth.auth"]["info"]
      end

      # NOTE. see spec/support/fixtures/me.json
      its(["name"])            { should eq "John Smith" }
      its(["email"])           { should eq "account@example.com" }
      its(["description"])     { should eq "Self Introduction" }
      its(["image"])           { should eq "https://example.com/abc.png" }
      its(["urls", "profile"]) { should eq "http://mycompany.example.com" }
    end
  end

  describe "authorize phase" do
    subject { get "/auth/chatwork" }

    let(:location_params) do
      location = last_response.location
      uri = URI::parse(location)
      Hash[URI::decode_www_form(uri.query)]
    end

    shared_examples "redirect to authorize_url" do
      it { should be_redirect }
      its(:location) { should start_with "https://www.chatwork.com/packages/oauth2/login.php" }

      it "location contains common params" do
        subject

        aggregate_failures do
          expect(location_params["client_id"]).to eq client_id
          expect(location_params["redirect_uri"]).to eq "http://example.org/auth/chatwork/callback"
          expect(location_params["response_type"]).to eq "code"
          expect(location_params["state"]).not_to be_empty
        end
      end
    end

    context "with default option" do
      it_behaves_like "redirect to authorize_url"

      it "scope is '#{OmniAuth::Strategies::Chatwork::DEFAULT_SCOPE}'" do
        subject

        expect(location_params["scope"]).to eq OmniAuth::Strategies::Chatwork::DEFAULT_SCOPE
      end
    end

    context "when scope is passed to strategy options" do
      let(:strategy_options) { {scope: scope} }
      let(:scope) { %w(rooms.all:read_write contacts.all:read_write) }

      it_behaves_like "redirect to authorize_url"

      it "scope is 'rooms.all:read_write contacts.all:read_write'" do
        subject

        expect(location_params["scope"]).to eq scope.join(" ")
      end
    end
  end
end
