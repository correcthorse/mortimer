require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  
  def setup
    @root  = create_root_user
    @admin = create_admin_user
  end

  context "Relationships:" do 
    should belong_to(:group)
  end

  context "Validations:" do
    should validate_presence_of(:group)
    should validate_presence_of(:title)
    
    should ensure_length_of(:username).is_at_least(1).is_at_most(110)
    should validate_presence_of(:password)
    min = Settings.entries.min_password_length
    should ensure_length_of(:password).is_at_least(min).is_at_most(40)
    should ensure_length_of(:title).is_at_least(2).is_at_most(110)
  end  
  
  context "With three users, " do 
    setup do 
      @group = Factory(:group, :admin_user => @root, :admin_password => CRYPTED_ADMIN_PASSWORD)
      @joe_user = Factory(:user)
      @bob_user = Factory(:user)
      @user3 = Factory(:user) 
      @new_admin = create_admin_user
    end

    context "Two of whom have permissions to the test group - " do 
      setup do 
        @joe_user.permissions.create(:group => @group, :mode => "WRITE", 
          :admin_user => @root, :admin_password => CRYPTED_ADMIN_PASSWORD)
        @bob_user.permissions.create(:group => @group, :mode => "READ",
          :admin_user => @root, :admin_password => CRYPTED_ADMIN_PASSWORD)
        @entry = Factory(:entry, :title => "MAIN", :group => @group)
      end

      should "create a password entry for the first user" do 
        assert @entry.decrypt_attributes_for(@joe_user, CRYPTED_USER_PASSWORD)
      end

      should "create a password entry for the second user" do 
        assert @entry.decrypt_attributes_for(@bob_user, CRYPTED_USER_PASSWORD)
      end

      should "create a password entry for the root user" do 
        assert @entry.decrypt_attributes_for(@root, CRYPTED_ADMIN_PASSWORD)
      end

      should "create a password entry for the admin user" do 
        assert @entry.decrypt_attributes_for(@new_admin, CRYPTED_ADMIN_PASSWORD)
      end

      should "raise a Permissions error if the third user tries to decrypt" do 
        assert_raises ::PermissionsError do
          @entry.decrypt_attributes_for(@user3, CRYPTED_USER_PASSWORD)
        end
      end
    end

    context "A new entry is created: " do
      setup do 
        @entry = Factory(:entry, :title => "WEB", :group => @group)
        reload_activerecord_instances
      end

      should "grant access to admin" do 
        @entry.decrypt_attributes_for(@admin, CRYPTED_ADMIN_PASSWORD)
        assert_equal "crypted!", @entry.password       
      end

      should "grant access to admin 2" do
        @entry.decrypt_attributes_for(@new_admin, CRYPTED_ADMIN_PASSWORD)
        assert_equal "crypted!", @entry.password        
      end

      should "grant access to root" do
        @entry.decrypt_attributes_for(@root, CRYPTED_ADMIN_PASSWORD)
        assert_equal "crypted!", @entry.password    
      end
    end

    context "Two users with access to a group" do 
      setup do 
        @joe_user.permissions.create(:group => @group, :mode => "WRITE",
          :admin_user => @root, :admin_password => CRYPTED_ADMIN_PASSWORD)
        @bob_user.permissions.create(:group => @group, :mode => "READ",
          :admin_user => @root, :admin_password => CRYPTED_ADMIN_PASSWORD)
        @entry = Factory(:entry, :title => "MAIN", :group => @group)
      end

      should "decrypt for the first user" do 
        @entry.decrypt_attributes_for(@joe_user, CRYPTED_USER_PASSWORD)
        assert_equal "crypted!", @entry.password
      end

      should "not decrypt if a bad password is entered" do 
        assert_raises PermissionsError do
          @entry.decrypt_attributes_for(@joe_user, SessionPasswordEncryptor.encrypt("wrong_pass"))
        end
      end

      should "decrypt for the second user" do 
        @entry.decrypt_attributes_for(@bob_user, CRYPTED_USER_PASSWORD)
        assert_equal "crypted!", @entry.password
      end

      context "when the password changes" do
        setup do 
          @entry.update_attributes(:password => "Vault@@@", 
                                   :password_confirmation => "Vault@@@")
        end

        should "decrypt for the first user" do 
          @entry.decrypt_attributes_for(@joe_user, CRYPTED_USER_PASSWORD)
          assert_equal "Vault@@@", @entry.password
        end

        should "decrypt for the second user" do 
          @entry.decrypt_attributes_for(@bob_user, CRYPTED_USER_PASSWORD)
          assert_equal "Vault@@@", @entry.password
        end
      end
    end
  end
end
