require 'test_helper'

class EntriesControllerTest < ActionController::TestCase

  context "When viewing an entry" do 
   setup do 
     @root  = create_root_user 
     @admin = create_admin_user  
     @user  = Factory(:user)
     @group, @entry = create_group_with_entry(@admin, CRYPTED_ADMIN_PASSWORD)
   end

    context "A user with access" do 
      setup do
        @user.permissions.create(:group => @group, :mode => "READ",
          :admin_user => @admin, :admin_password => CRYPTED_ADMIN_PASSWORD)                          
        login_as @user, USER_PASSWORD
        xhr :get, :show, :id => @entry
      end
      should render_template('show')
    end 

    context "A user without access" do 
      setup do 
        login_as @user, "secret@@"
      end   

      should "render access denied" do 
        xhr :get, :show, :id => @entry
        assert_match /401/, @response.status
      end  
    end  

    context "and attempting to view without an xhr request" do
      setup do
        login_as @user, "secret@@" 
        get :show, :id => @entry
      end 
      should_redirect_to('home') { home_path }
      should set_the_flash.to(/sorry/i)
    end  

  end

  context "Basic actions:" do 
    setup do 
      @admin = create_admin_user
      @user  = Factory(:user)
      @group, @entry = create_group_with_entry(@admin, CRYPTED_ADMIN_PASSWORD)
    end  

    context "on get new" do
      setup do 
        login_as @admin, ADMIN_PASSWORD
        get :new
      end

      should render_template('new')
    end

    context "on post create" do 
      setup do 
        login_as @admin, ADMIN_PASSWORD
      end
      should 'create entry' do
        assert_difference 'Entry.count' do
          post :create, :entry => Factory.attributes_for(:entry).merge(:group_id => @group.id.to_s) 
        end
      end
    end  

    context "on get edit" do 
      setup do 
        login_as @admin, ADMIN_PASSWORD
        get :edit, :id => @entry
      end

      should render_template('edit')
    end  

    context "on put update" do
      setup do 
        login_as @admin, ADMIN_PASSWORD
        put :update, :id => @entry, :entry => {:title => "System"}
      end

      should "change the entry's title" do
      end
    end

    context "on destroy" do
      setup do 
        login_as @admin, ADMIN_PASSWORD
      end
      should 'delete entry' do
        assert_difference 'Entry.count', -1 do
          delete :destroy, :id => @entry
        end
      end
    end  
  end  

  context "Authorization for basic users" do
    setup do
      @admin = create_admin_user
      @user  = Factory(:user)
      @group, @entry = create_group_with_entry(@admin, CRYPTED_ADMIN_PASSWORD)
    end

    context "with read permissions:" do
      setup do 
        @user.permissions.create(:group => @group, :mode => "READ",
          :admin_user => @admin, :admin_password => CRYPTED_ADMIN_PASSWORD)
        login_as @user, "Secret@@12345$%"
      end
   
      should "not access new" do
        get :new, :entry => {:group_id => @group.id}
        assert_access_denied
      end

      should "not access create" do
        post :create, :entry => {:group_id => @group.id}
        assert_access_denied
      end

      should "not access edit" do
        get :edit, :id => @entry
        assert_access_denied
      end

      should "not access update" do
        put :update, :id => @entry
        assert_access_denied
      end

      should "not access destroy" do
        delete :destroy, :id => @entry
        assert_access_denied
      end  
    end

    context "with write permissions:" do
      setup do 
        @user.permissions.create(:group => @group, :mode => "WRITE",
          :admin_user => @admin, :admin_password => CRYPTED_ADMIN_PASSWORD)
        login_as @user, "Secret@@12345$%"
      end

      should "access new" do
        get :new, :entry => {:group_id => @group.id}
        assert_access_granted
      end

      should "access create" do
        post :create, :entry => @entry.attributes
        assert_access_granted 
      end

      should "access edit" do
        get :edit, :id => @entry
        assert_access_granted
      end

      should "access update" do
        put :update, :id => @entry, :entry => {:title => "BLAH"}
        assert_access_granted
      end

      should "not access destroy" do
        delete :destroy, :id => @entry
        assert_access_denied
      end  
    end  
  end  
end
