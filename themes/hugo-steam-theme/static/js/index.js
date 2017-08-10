(function($) {
  var $forms = $('.slack-form');
  var emailRegex = /^.+@.+\..+$/;

  function invite(url, email) {
    return $.ajax({
      url: url,
      method: 'POST',
      dataType: 'json',
      data: JSON.stringify({
        email: email
      })
    });
  }

  function setupForm() {
    var $this = $(this);
    var $form = $this.find('form');
    var $input = $this.find('input');
    var $btn = $this.find('button');
    var $errorMsg = $this.find('.error-msg');
    var $successMsg = $this.find('.success-msg');
    var url = $form.attr('action');

    $input.on('keyup', function() {
      if (!emailRegex.test($input.val())) {
        $btn.attr('disabled', true);
      } else {
        $btn.attr('disabled', false);
      }
    });

    $form.on('submit', function(e) {
      e.preventDefault();

      $btn.attr('disabled', true);
      if (emailRegex.test($input.val())) {
        $input.attr('disabled', true);
        $errorMsg.hide();
        $successMsg.hide();

        invite(url, $input.val()).then(
          function() {
            $input.attr('disabled', false);
            $input.val('');
            $successMsg.show();
          },
          function() {
            $input.attr('disabled', false);
            $btn.attr('disabled', false);
            $errorMsg.show();
          }
        );
      }
    });
  }

  $.each($forms, setupForm);
})(jQuery);
