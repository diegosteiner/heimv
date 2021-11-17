import "stylesheets/application";
import Rails from "rails-ujs";
import "../services/i18n";
import "bootstrap/dist/js/bootstrap.bundle";
import ReactRailsUJS from "react_ujs";

require.context("../images", true);

function csrfForm() {
  const csrfToken = document.querySelector("meta[name=csrf-token]")?.content;
  if (!csrfToken) return;

  const authTokenInput = document.querySelector(
    "input[name=authenticity_token]"
  );
  if (authTokenInput) authTokenInput.value = csrfToken;
}

function setupRichTextArea() {
  if (!document.querySelector(".rich-text-area")) return;

  loadEditor().then((tinymce) => {
    tinymce.init({
      selector: ".rich-text-area",
      skin: false,
      content_css: false,
      height: 500,
      menubar: false,
      plugins: [
        "advlist autolink lists link image anchor",
        "searchreplace code table help",
      ],
      toolbar:
        "undo redo | formatselect | " +
        "bold italic | bullist numlist table | " +
        "removeformat | code help",
      content_style:
        'body { font-family:-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, ' +
        '"Noto Sans", "Liberation Sans", sans-serif, "Apple Color Emoji", "Segoe UI Emoji", ' +
        '"Segoe UI Symbol", "Noto Color Emoji"; font-size: 0.85em }',
    });
  });
}

async function loadEditor() {
  return Promise.all([
    import(/* webpackChunkName: "tinymce" */ "tinymce"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/icons/default"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/themes/silver"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/advlist"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/anchor"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/code"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/link"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/autolink"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/lists"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/image"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/help"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/paste"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/searchreplace"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/table"),
  ]).then((imports) => imports[0].default);
}

function toggleDisable() {
  document.querySelectorAll('[data-bs-toggle="disable"]').forEach((element) => {
    element.onclick = (ev) => {
      const target = document.querySelector(element.getAttribute("href"));
      if (target) target.disabled = false;
      ev.preventDefault();
    };
  });
}

document.addEventListener("DOMContentLoaded", () => {
  csrfForm();
  toggleDisable();
  setupRichTextArea();
});

Rails.start();
ReactRailsUJS.useContext(require.context("components", true));
