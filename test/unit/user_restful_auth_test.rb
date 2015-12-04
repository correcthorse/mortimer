require 'test_helper'

# These tests were added by the Restful Authentication Plugin,
# and modified to take advantage of factories instead of fixtures.
# They have also been slightly tailored to only test the functionality of
# the RestfulAuth plugin that's actually used by this app.
class UserRestfulAuthTest < ActiveSupport::TestCase

  context "Tests added by RESTful Authentication Plugin" do
    setup do 
      setup_restful_auth_user
    end

    should "create user" do
      assert_difference 'User.count' do
        user = create_user
        assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
      end
    end
 
    should "require login" do
      assert_no_difference 'User.count' do
        u = create_user(:login => nil)
        assert !u.errors[:login].empty?
      end
    end
  
    should "require password" do
      assert_no_difference 'User.count' do
        u = create_user(:password => nil)
        assert !u.errors[:password].empty?
      end
    end
  
    should "require password confirmation" do
      assert_no_difference 'User.count' do
        u = create_user(:password_confirmation => nil)
        assert !u.errors[:password_confirmation].empty?
      end
    end
  
    should "require email" do
      assert_no_difference 'User.count' do
        u = create_user(:email => nil)
        assert !u.errors[:email].empty?
      end
    end
  
    should "not rehash password" do
      old_password = SessionPasswordEncryptor.encrypt('Monkey$$12345')
      @quentin.update_attributes(:login => 'quentin2', :old_password => old_password) 
      assert_equal @quentin, User.authenticate('quentin2', 'Monkey$$12345')
    end
  
    should "authenticate user" do
      assert_equal @quentin, User.authenticate('quentin', 'Monkey$$12345')
    end
  
  end

  protected

  def create_user(options = {})
    record = Factory.build(:user, {:login => 'quire', :email => 'quire@example.com', 
      :password => 'Secret@@12345', :password_confirmation => 'Secret@@12345'}.merge(options))
    record.save if record.valid?
    record
  end

  def setup_restful_auth_user
    @quentin = Factory(:user, :login => "quentin", :email => "quentin@example.com",
      :password => "Monkey$$12345", :password_confirmation => "Monkey$$12345")
  end

end
