import $ from 'jquery';
import { gaPromise as ga } from '../services/link_track.js';

const emailRegex = /^.+@.+\..+$/;

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
  let $this = $(this);
  let $form = $this.find('form');
  let $input = $this.find('input');
  let $btn = $this.find('button');
  let $errorMsg = $this.find('.error-msg');
  let $successMsg = $this.find('.success-msg');
  let url = $form.attr('action');

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

      ga('send', 'event', {
        eventCategory: 'joinSlack',
        eventAction: 'button_click',
        eventLabel: 'slackButton'
      });
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

export default function setupForms() {
  let $forms = $('.slack-form');
  $.each($forms, setupForm);
}
