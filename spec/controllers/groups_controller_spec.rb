require File.join(File.dirname(__FILE__), "../spec_helpers")

module GroupsControllerSpec
  describe YogoAuthz::GroupsController, "Post create" do
  
    before(:each) do
      @group = mock_model(YogoAuthz::Group, :save => nil)
      YogoAuthz::Group.stub!(:new).and_return(@group)
    end
  
    it "should create a new group" do
      YogoAuthz::Group.should_receive(:new).
        with("name" => "test", "parent_id" => '').
        and_return(@group)
      post :create, :group => {"name" => "test", "parent_id" => ''}
    end
  
    it "should save the group" do
      @group.should_receive(:save).and_return(true)
      post :create, :group => {"name" => "test", "parent_id" => ''}
    end
    
    context "when the group save successfully" do
      before(:each) do
        @group.stub!(:save).and_return true
      end
      
      it "should set a flash[:notice] message" do
        post :create, :group => {"name" => "test", "parent_id" => ''}
        flash[:notice].should == "Group was successfully created."
      end
      
      it "should redirect somewhere" 
      
    end
  end
  
end
