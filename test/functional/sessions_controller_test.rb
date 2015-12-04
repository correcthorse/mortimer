require 'test_helper'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < ActionController::TestCase

  context "RESTful Authentication Tests:" do 
    setup do 
      @quentin = Factory(:user, :login => 'quentin', :is_admin => true)
    end

    should "login and redirect" do
      post :create, :login => 'quentin', :password => 'Secret@@12345$%'
      assert session[:user_id]
      assert_response :redirect
    end
  
    should "fail login and not redirect" do
      post :create, :login => 'quentin', :password => 'bad password'
      assert_nil session[:user_id]
      assert_response :success
    end
  
    should "logout" do
      login_as @quentin, "Secret@@"
      get :destroy
      assert_nil session[:user_id]
      assert_response :redirect
    end
    
  end
      
end
