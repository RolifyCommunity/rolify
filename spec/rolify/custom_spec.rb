require "spec_helper"
require "rolify/shared_examples/shared_examples_for_roles"
require "rolify/shared_examples/shared_examples_for_dynamic"

describe "Using Rolify with custom User and Role class names" do
  it_behaves_like Rolify::Role do
    let(:user_cname) { "Customer" }
    let(:role_cname) { "Privilege" }
  end

  it_behaves_like Rolify::Dynamic do
    let(:user_cname) { "Customer" } 
    let(:role_cname) { "Privilege" }
  end
end