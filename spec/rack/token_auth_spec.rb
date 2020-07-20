# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rack::TokenAuth do

  describe "parsing the authorization header" do

    let(:block) { lambda { |token| } }
    let(:app) { build_app(&block) }

    it "evaluates the block with token and options" do
      env = { "HTTP_AUTHORIZATION" => %(Token token="abc", foo="bar") }
      expect(block).to receive(:call).with("abc", { "foo" => "bar" }, env)
      app.call(env)
    end

    it "handles absent header" do
      env = {}
      expect(block).to receive(:call).with(nil, {}, env)
      app.call(env)
    end

    it "handles other authorization header" do
      env = { "HTTP_AUTHORIZATION" => %(Basic QWxhZGluOnNlc2FtIG9wZW4=) }
      expect(block).to receive(:call).with(nil, {}, env)
      app.call(env)
    end

    it "handles misformed authorization header" do
      expect(block).not_to receive(:call)
      result = app.call("HTTP_AUTHORIZATION" => %(Token foobar))
      expect(result.first).to eq 400
    end

    it "allows specifying the unprocessable header app" do
      unprocessable_header_app = double :unprocessable_header_app
      app = build_app(unprocessable_header_app: unprocessable_header_app)

      expect(unprocessable_header_app).to receive(:call)
      app.call("HTTP_AUTHORIZATION" => %(Token foobar))
    end

  end

  context "when block returns false" do

    let(:env) { double :env, :[] => true }

    it "doesn't call the rest of the app" do
      app = build_app do false end
      expect(Endpoint).not_to receive(:call)
      app.call(env)
    end

    it "has a default response" do
      app = build_app do false end
      result = app.call(env)
      expect(result.last).to eq ["Unauthorized"]
      expect(result.first).to eq 401
    end

    it "is able to set the unauthorized app" do
      unauthorized_app = double :unauthorized_app
      app = build_app unauthorized_app: unauthorized_app do false end

      expect(unauthorized_app).to receive(:call).with(env)
      app.call(env)
    end

  end

  context "when the block returns true" do

    let(:env) { double :env, :[] => true }

    it "calls the rest of your app" do
      app = build_app do true end
      expect(Endpoint).to receive(:call).with(env)
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
