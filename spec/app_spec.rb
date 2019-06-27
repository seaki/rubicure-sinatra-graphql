require 'spec_helper'

describe "rubicure-sinatra-graphql Application" do
  it "should allow accessing the home page" do
    get '/'
    expect(last_response).to be_ok
  end

  it "should allow accessing the /graphql endpoint" do
    post '/graphql'
    expect(last_response).to be_ok
  end
end
