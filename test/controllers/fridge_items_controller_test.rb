require "test_helper"

class FridgeItemsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get fridge_items_new_url
    assert_response :success
  end

  test "should get create" do
    get fridge_items_create_url
    assert_response :success
  end

  test "should get edit" do
    get fridge_items_edit_url
    assert_response :success
  end

  test "should get update" do
    get fridge_items_update_url
    assert_response :success
  end

  test "should get destroy" do
    get fridge_items_destroy_url
    assert_response :success
  end
end
