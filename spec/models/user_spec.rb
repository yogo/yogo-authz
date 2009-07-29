require File.join(File.dirname(__FILE__), "../spec_helpers")

module UserSpec
  
  describe YogoAuthz::User do
    
    describe "validations" do
      it "should not be valid without a login" do
        YogoAuthz::User.new.should_not be_valid
      end
      
      it "should not be valid without an email" do
        YogoAuthz::User.new(:login => 'robbie').should_not be_valid
      end 
      
    end
  end
end
