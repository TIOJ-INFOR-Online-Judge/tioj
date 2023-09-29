function updateGotoUser() {
  var user_id = $(this).val();
  var link = '#';
  if (user_id !== '') link = `/users/${user_id}`;
  $('#goto_user').attr('href', link);
}

$(function() {
  $('#goto_user_id').on('input', updateGotoUser);
  $('#goto_user_id').trigger('input');
});