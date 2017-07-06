require 'test_helper'

class RamPostsControllerTest < ActionController::TestCase
  setup do
    @ram_post = ram_posts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ram_posts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ram_post" do
    assert_difference('RamPost.count') do
      post :create, ram_post: { words: @ram_post.words }
    end

    assert_redirected_to ram_post_path(assigns(:ram_post))
  end

  test "should show ram_post" do
    get :show, id: @ram_post
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ram_post
    assert_response :success
  end

  test "should update ram_post" do
    patch :update, id: @ram_post, ram_post: { words: @ram_post.words }
    assert_redirected_to ram_post_path(assigns(:ram_post))
  end

  test "should destroy ram_post" do
    assert_difference('RamPost.count', -1) do
      delete :destroy, id: @ram_post
    end

    assert_redirected_to ram_posts_path
  end
end
