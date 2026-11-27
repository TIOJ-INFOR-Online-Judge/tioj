require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
    @comment = @post.comments.create!(user: users(:userOne), title: "Hi", content: "First comment")
  end

  test "new comment page links back to the post list" do
    sign_in users(:userOne)
    get new_post_comment_url(@post)
    assert_response :success
    assert_select "a[href=?]", posts_path, text: "Back"
  end

  test "invalid comment re-renders the form with errors" do
    sign_in users(:userOne)
    assert_no_difference("Comment.count") do
      post post_comments_url(@post), params: { comment: { title: "x" * 31, content: "Too long a title" } }
    end
    assert_response :success
    assert_select "form[action=?]", post_comments_path(@post)
    assert_select "input[name='comment[title]'][value=?]", "x" * 31
  end

  test "user should not edit other users comment" do
    sign_in users(:userTwo)
    get edit_post_comment_url(@post, @comment)
    assert_no_permission
  end

  test "user should not update other users comment" do
    sign_in users(:userTwo)
    patch post_comment_url(@post, @comment), params: { comment: { content: "Hijacked" } }
    assert_no_permission
    assert_equal "First comment", @comment.reload.content
  end

  test "user should not delete other users comment" do
    sign_in users(:userTwo)
    assert_no_difference("Comment.count") do
      delete post_comment_url(@post, @comment)
    end
    assert_no_permission
  end

  test "author should update own comment" do
    sign_in users(:userOne)
    patch post_comment_url(@post, @comment), params: { comment: { content: "Edited" } }
    assert_redirected_to posts_path
    assert_equal "Edited", @comment.reload.content
  end
end
