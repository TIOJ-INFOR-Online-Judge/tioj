import { Toast } from 'bootstrap';

export function copyButtonSetup() {

  $('.copy-group').each(function() {
    const btn = $(this).find('.copy-group-btn').first();
    const code = $(this).find('.copy-group-code').first();

    btn.on('click', () => {
      const text = code.text();
      if (navigator.clipboard) {
        navigator.clipboard.writeText(text).then(showSuccessToast).catch(showFailureToast);
      } else { // old deprecated method
        try {
          const tmp = $('<textarea>');
          $('body').append(tmp);
          tmp.val(text).trigger('select');
          if (document.execCommand('copy')) {
            showSuccessToast();
          } else {
            showFailureToast();
          }
          tmp.remove();
        } catch (err) {
          showToast(err, 'danger');
        }
      }
    });
  });

  function showToast(message, type) {
    const toastContainer = document.getElementById('notification-toast-container');
    if (!toastContainer) {
      console.error('Toast container not found!');
      return;
    }

    const toastTemplate = document.getElementById('notification-toast-template');
    if (!toastTemplate) {
      console.error('Toast template not found!');
      return;
    }

    const toastEl = toastTemplate.cloneNode(true); // true for a deep clone of all descendants
    toastEl.removeAttribute('id');

    // TODO color here
    toastEl.classList.add(`panel-${type}`);
    toastEl.classList.add('animate__animated', 'animate__fadeInLeft');

    const toastBody = toastEl.querySelector('.toast-body');
    if (!toastBody) {
      console.error('Toast body not found!');
      return;
    }
    toastBody.innerHTML = message;

    toastContainer.appendChild(toastEl);

    toastEl.addEventListener('hide.bs.toast', (event) => {
      event.preventDefault();
      toastEl.classList.remove('animate__fadeInLeft');
      toastEl.classList.add('animate__fadeOutRight');
      toastEl.addEventListener('animationend', () => {
        toastEl.remove();
      }, { once: true }); // The listener will automatically remove itself after being invoked
    });

    const toast = new Toast(toastEl, { animation: false, delay: 2000 });
    toast.show();
  }

  function showSuccessToast() {
    showToast("<strong>Oh Geez!</strong> Successfully copied.", 'success');
  }

  function showFailureToast() {
    showToast("<strong>Oh Geez!</strong> Copy failed!", 'danger');
  }

}
