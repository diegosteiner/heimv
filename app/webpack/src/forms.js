export default class {
  static start() {
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
  }
}
