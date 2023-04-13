jQuery(function() {
  return $("#find_user").on('click', function() {
    var user_id;
    user_id = $('#quick_user_id').val();
    if (user_id === "") return;
    window.location.href = `/users/${user_id}`;
  });
});