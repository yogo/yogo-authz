require File.join(File.dirname(__FILE__), "../spec_helpers")

module UserSpec
  
  describe User do
    
    describe "validations" do
      it "should not be valid without a login" do
        User.new.should_not be_valid
      end
      
      it "should not be valid without an email" do
        User.new(:login => 'robbie').should_not be_valid
      end 
      
    end
  end
end
