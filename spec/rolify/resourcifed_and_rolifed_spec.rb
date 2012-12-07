if ENV['ADAPTER'] == 'mongoid'
  require "spec_helper"

  describe "#add_role" do
    before(:all) do
      reset_defaults
      Role.delete_all
      SUser.delete_all
    end
    let!(:user) { user = SUser.new login: 'Samer'; user.save; user }
    context "when adapter is Mongoid" do
      context "and the resource is resourcifed and rolifed in the same time" do
        it "should add the role to the user" do
          expect{
            user.add_role :admin
          }.to change{user.roles.count}.by(1)
        end
        it "should create a role to the roles collection" do
          expect {
            user.add_role :moderator
          }.to change { Role.count }.by(1)
        end
      end
    end
  end
end
