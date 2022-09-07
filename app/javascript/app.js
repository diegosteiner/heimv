import "stylesheets/application";
import Rails from "rails-ujs";
import "services/i18n";
import "bootstrap/dist/js/bootstrap.bundle";
import ReactRailsUJS from "react_ujs";
import { setup as setupRichTextArea } from "./components/rich_text_area";

require.context("./images", true);

function csrfForm() {
  const csrfToken = document.querySelector("meta[name=csrf-token]")?.content;
  if (!csrfToken) return;

  const authTokenInput = document.querySelector(
    "input[name=authenticity_token]"
  );
  if (authTokenInput) authTokenInput.value = csrfToken;
}

function toggleDisable() {
  document.querySelectorAll('[data-bs-toggle="disable"]').forEach((element) => {
    const handler = () => {
      document.querySelectorAll(element.dataset.bsTarget).forEach((target) => {
        target.disabled = !element.checked;
      });
    };
    element.addEventListener("change", (event) => {
      event.preventDefault;
      handler();
    });
    handler();
  });
}

document.addEventListener("DOMContentLoaded", () => {
  csrfForm();
  toggleDisable();
  setupRichTextArea();
});

Rails.start();
ReactRailsUJS.useContext(require.context("components", true));
