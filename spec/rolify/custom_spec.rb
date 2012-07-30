require "spec_helper"
require "rolify/shared_examples/shared_examples_for_roles"
require "rolify/shared_examples/shared_examples_for_dynamic"
require "rolify/shared_examples/shared_examples_for_scopes"
require "rolify/shared_examples/shared_examples_for_callbacks"  

describe "Using Rolify with custom User and Role class names" do
  it_behaves_like Rolify::Role do
    let(:user_class) { Customer }
    let(:role_class) { Privilege }
  end

  it_behaves_like "Role.scopes" do
    let(:user_class) { Customer } 
    let(:role_class) { Privilege }
  end

  it_behaves_like Rolify::Dynamic do
    let(:user_class) { Customer } 
    let(:role_class) { Privilege }
  end

  it_behaves_like "Rolify.callbacks" do
    let(:user_class) { Customer }
    let(:role_class) { Privilege }
  end
end