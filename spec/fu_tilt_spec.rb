require 'spec_helper'
require 'sinatra'
require 'rack/test'
require 'fu/tilt'

class FuApp < Sinatra::Base
  set :root, File.dirname(__FILE__)+"/fixtures"
  get "/list" do
    fu :list, :locals => {:children => [{:name => "Arne"}, {:name => "Bjarne"}]}
  end
end

describe "API v1 posts" do
  include Rack::Test::Methods

  def app
    FuApp
  end

  it "'s alive" do
    get "/list"
    last_response.body.should eq "<ul><li>Arne</li><li>Bjarne</li></ul>"
  end
end