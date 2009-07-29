require File.join(File.dirname(__FILE__), "../spec_helpers")

module WebUserSpec
  
  describe YogoAuthz::WebUser do
    
    describe "making a new user" do
      it "should fail" do
        YogoAuthz::WebUser.new.should_not(be_valid)
      end
    end
    
    
  end
  
end