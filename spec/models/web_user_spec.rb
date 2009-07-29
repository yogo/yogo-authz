require File.join(File.dirname(__FILE__), "../spec_helpers")

module WebUserSpec
  
  describe WebUser do
    
    describe "making a new user" do
      it "should fail" do
        WebUser.new.should_not(be_valid)
      end
    end
    
    
  end
  
end