require "spec_helper"
require "rolify/shared_examples/shared_examples_for_roles"
require "rolify/shared_examples/shared_examples_for_dynamic"
require "rolify/shared_examples/shared_examples_for_scopes"
require "rolify/shared_examples/shared_examples_for_callbacks"

describe Rolify do
  it_behaves_like Rolify::Role do
    let(:user_class) { User } 
    let(:role_class) { Role }
  end

  it_behaves_like "Role.scopes" do
    let(:user_class) { User } 
    let(:role_class) { Role }
  end

  it_behaves_like Rolify::Dynamic do
    let(:user_class) { User } 
    let(:role_class) { Role }
  end

  it_behaves_like "Rolify.callbacks" do
    let(:user_class) { User }
    let(:role_class) { Role }
  end
end
