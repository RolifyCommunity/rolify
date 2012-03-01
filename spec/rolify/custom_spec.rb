require "spec_helper"
require "rolify/shared_examples"
require "rolify/dynamic"

describe "Using Rolify with custom User and Role class names" do
  it_behaves_like "Rolify module" do
    let(:user_cname) { "Customer" }
    let(:role_cname) { "Privilege" }
  end

  it_behaves_like Rolify::Dynamic do
    let(:user_cname) { "Customer" } 
    let(:role_cname) { "Privilege" }
  end
end