require "spec_helper"
require "rolify/shared_examples"
require "rolify/dynamic"

describe Rolify::Role do
  it_behaves_like "Rolify module" do
    let(:user_cname) { "User" } 
    let(:role_cname) { "Role" }
  end

  it_behaves_like Rolify::Dynamic do
    let(:user_cname) { "User" } 
    let(:role_cname) { "Role" }
  end
end
