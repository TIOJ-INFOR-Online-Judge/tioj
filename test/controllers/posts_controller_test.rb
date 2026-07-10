require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
  end

  test "author should update own post" do
    sign_in users(:userOne)
    patch post_url(@post), params: { post: { title: "Updated", content: "Updated content", post_type: "discuss" } }
    assert_redirected_to posts_path
    @post.reload
    assert_equal "Updated", @post.title
  end

  test "update should ignore user_id param" do
    sign_in users(:userOne)
    other_user = users(:userTwo)
    patch post_url(@post), params: { post: { title: "Hacked", user_id: other_user.id, post_type: "discuss" } }
    @post.reload
    assert_equal users(:userOne).id, @post.user_id
  end

  test "user should not update other users post" do
    sign_in users(:userTwo)
    patch post_url(@post), params: { post: { title: "Hijacked", post_type: "discuss" } }
    assert_no_permission
  end

  test "unauthenticated user should not update post" do
    patch post_url(@post), params: { post: { title: "Hijacked", post_type: "discuss" } }
    assert_login_needed
  end

  test "admin should update any post" do
    sign_in users(:adminOne)
    patch post_url(@post), params: { post: { title: "Admin Edit", post_type: "discuss" } }
    assert_redirected_to posts_path
    @post.reload
    assert_equal "Admin Edit", @post.title
  end
end
