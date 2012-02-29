require "spec_helper"
require_relative "shared_examples"
require_relative "dynamic"

describe Rolify do
  context "using custom User and Role class names" do 
    it_behaves_like "Rolify module" do
      let(:user_cname) { "Customer" }
      let(:role_cname) { "Privilege" }
    end
    
    it_behaves_like Rolify::Dynamic do
      let(:user_cname) { "Customer" } 
      let(:role_cname) { "Privilege" }
    end
  end
end