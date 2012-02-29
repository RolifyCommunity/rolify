require "spec_helper"
require_relative "shared_examples"
require_relative "dynamic"

describe Rolify do
  context "using default Role and User" do 
    it_behaves_like "Rolify module" do
      let(:user_cname) { "User" } 
      let(:role_cname) { "Role" }
    end
    
    it_behaves_like Rolify::Dynamic do
      let(:user_cname) { "User" } 
      let(:role_cname) { "Role" }
    end
  end
end
