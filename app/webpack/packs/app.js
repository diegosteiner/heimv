import 'stylesheets/application';
import 'images/logo.svg';
import Rails from 'rails-ujs';
import '../services/i18n';
import 'bootstrap/dist/js/bootstrap.bundle';
import ReactRailsUJS from 'react_ujs';

require.context('../images', true);

const csrfForm = () => {
  const csrfToken = document.querySelector('meta[name=csrf-token]').content;
  const authTokenInput = document.querySelector(
    'input[name=authenticity_token]',
  );
  if (authTokenInput) authTokenInput.value = csrfToken;
  document
    .querySelectorAll('.form-check-input')
    .forEach((input) => input.classList.add('form-check-control'));
  document
    .querySelectorAll('.form-group.is-invalid .form-control')
    .forEach((input) => input.classList.add('is-invalid'));
  document.querySelectorAll('.custom-file-input').forEach((input) => {
    input.addEventListener('change', function () {
      const fileName = this.value;
      this.nextElementSibling.innerText = fileName;
    });
  });
};

document.addEventListener('DOMContentLoaded', () => csrfForm());
Rails.start();
ReactRailsUJS.useContext(require.context('components', true));
