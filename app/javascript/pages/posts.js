$(() => {
  $('div.new_comment_form').hide();
  $('button.new_comment').click(function() {
    $(this).siblings("div").toggle();
    if ($(this).text() === "New Comment") {
      $(this).text("Hide Form");
    } else {
      $(this).text("New Comment");
    }
  });
});