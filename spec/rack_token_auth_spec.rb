require 'rack'
require 'rack/token_auth'

describe Rack::TokenAuth do

  Endpoint = Rack::Response.new("OK")

  describe "parsing the authorization header" do

    let(:block) { lambda { |token| } }
    let(:app) { build_app(&block) }

    it "evaluates the block with token and options" do
      block.should_receive(:call).with("abc", "foo" => "bar")
      app.call("HTTP_AUTHORIZATION" => %(Token token="abc", foo="bar"))
    end

    it "handles absent header" do
      block.should_receive(:call).with(nil, {})
      app.call({})
    end

    it "handles other authorization header" do
      block.should_receive(:call).with(nil, {})
      app.call("HTTP_AUTHORIZATION" => %(Basic QWxhZGluOnNlc2FtIG9wZW4=))
    end

    it "handles misformed authorization header" do
      block.should_not_receive(:call)
      result = app.call("HTTP_AUTHORIZATION" => %(Token foobar))
      result.status.should eq 400
    end

    it "allows specifying the unprocessable header app" do
      unprocessable_header_app = mock :unprocessable_header_app
      app = build_app(:unprocessable_header_app => unprocessable_header_app)

      unprocessable_header_app.should_receive(:call)
      app.call("HTTP_AUTHORIZATION" => %(Token foobar))
    end

  end

  context "when block returns false" do

    let(:env) { mock :env, :[] => true }

    it "doesn't call the rest of the app" do
      app = build_app do false end
      Endpoint.should_not_receive(:call)
      app.call(env)
    end

    it "has a default response" do
      app = build_app do false end
      result = app.call(env)
      result.body.should eq ["Unauthorized"]
      result.status.should eq 401
    end

    it "is able to set the unauthorized app" do
      unauthorized_app = mock :unauthorized_app
      app = build_app :unauthorized_app => unauthorized_app do false end

      unauthorized_app.should_receive(:call).with(env)
      app.call(env)
    end

  end

  context "when the block returns true" do

    let(:env) { mock :env, :[] => true }

    it "calls the rest of your app" do
      app = build_app do true end
      Endpoint.should_receive(:call).with(env)
      app.call(env)
    end

  end

  def build_app(*args, &block)
    Rack::Builder.new {
      use Rack::TokenAuth, *args, &block
      run Endpoint
    }
  end

end
