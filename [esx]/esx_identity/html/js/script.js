$(document).ready(function () {
  $.post('http://esx_identity/ready', JSON.stringify({}));

  window.addEventListener('message', function (event) {
    if (event.data.type === 'enableui') {
      event.data.enable ? $(document.body).show() : $(document.body).hide();
    }
  });

  $('#register').submit(function (event) {
    event.preventDefault();

    const dofVal = $('#dateofbirth').val();
    if (!dofVal) return;

    const dateCheck = new Date(dofVal);

    const year = new Intl.DateTimeFormat('en', { year: 'numeric' }).format(dateCheck);
    const month = new Intl.DateTimeFormat('en', { month: '2-digit' }).format(dateCheck);
    const day = new Intl.DateTimeFormat('en', { day: '2-digit' }).format(dateCheck);

    const formattedDate = `${day}/${month}/${year}`;

    $.post(
      'http://esx_identity/register',
      JSON.stringify({
        firstname: $('#firstname').val(),
        lastname: $('#lastname').val(),
        dateofbirth: formattedDate,
        sex: $("input[type='radio'][name='sex']:checked").val(),
        height: $('#height').val(),
      })
    );

    $('#register').trigger('reset');
  });
});
