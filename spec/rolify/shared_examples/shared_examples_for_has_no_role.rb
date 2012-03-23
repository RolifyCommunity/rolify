shared_examples_for "#has_no_role_examples" do
  context "with a global role", :scope => :global do
    #it "should remove a global role of a user" do
    #  expect { @admin.has_no_role("admin") }.to change{ @admin.roles.size }.by(-1)
    #  @admin.has_role?("admin").should be(false)
    #  @admin.has_role?("staff").should be(true)
    #  @admin.has_role?("moderator", Forum.first).should be(true)
    #  @admin.has_role?("manager", Group).should be(true)
    #end
    #
    #it "should remove a class scoped role of a user" do
    #  expect { @admin.has_no_role("manager") }.to change{ @admin.roles.size }.by(-1)
    #  @admin.has_role?("staff").should be(true)
    #  @admin.has_role?("moderator", Forum.first).should be(true)
    #  @admin.has_role?("manager", Group).should be(false)
    #end
    #
    #it "should remove two instance scoped roles of a user" do
    #  expect { @admin.has_no_role("moderator") }.to change{ @admin.roles.size }.by(-2)
    #  @admin.has_role?("staff").should be(true)
    #  @admin.has_role?("moderator", Forum.first).should be(false)
    #  @admin.has_role?("moderator", Forum.where(:name => "forum 2").first).should be(false)
    #  @admin.has_role?("manager", Group).should be(true)
    #end
    #
    #it "should not remove another global role" do 
    #  expect { @admin.has_no_role("global") }.not_to change{ @admin.roles.size }
    #end
  end
  
  context "with a class scoped role", :scope => :class do
    #  it "should not remove a global role of a user" do 
    #    expect { @manager.has_no_role("warrior", Forum) }.not_to change{ @manager.roles.size }
    #  end
    #
    #  it "should remove a class scoped role of a user" do 
    #    expect { @manager.has_no_role("manager", Forum) }.to change{ @manager.roles.size }.by(-1)
    #    @manager.has_role?("manager", Forum).should be(false)
    #    @manager.has_role?("moderator", Forum.first).should be(true)
    #    @manager.has_role?("moderator", Forum.last).should be(true)
    #    @manager.has_role?("warrior").should be(true)
    #  end
    #  
    #  it "should remove two instance scoped roles of a user" do 
    #    expect { @manager.has_no_role("moderator", Forum) }.to change{ @manager.roles.size }.by(-2)
    #    @manager.has_role?("manager", Forum).should be(true)
    #    @manager.has_role?("moderator", Forum.first).should be(false)
    #    @manager.has_role?("moderator", Forum.last).should be(false)
    #    @manager.has_role?("warrior").should be(true)
    #  end
    #
    #  it "should not remove another scoped role" do
    #    expect { @manager.has_no_role("visitor", Forum.first) }.not_to change{ @manager.roles.size }
    #  end
  end
  
  context "with a instance scoped role", :scope => :instance do
    #  it "should not remove a global role of a user" do 
     #    expect { @moderator.has_no_role("soldier", Forum.first) }.not_to change{ @moderator.roles.size }
     #  end
     #
     #  it "should remove a scoped role of a user" do 
     #    expect { @moderator.has_no_role("moderator", Forum.first) }.to change{ @moderator.roles.size }.by(-1)
     #    @moderator.has_role?("moderator", Forum.first).should be(false)
     #    @moderator.has_role?("soldier").should be(true)
     #  end
     #
     #  it "should not remove another scoped role" do
     #    expect { @moderator.has_no_role("visitor", Forum.first) }.not_to change{ @moderator.roles.size }
     #  end
  end
end