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

function setupBookingAgentBookingButton() {
  document
    .getElementById("agent-booking-button")
    ?.addEventListener("click", (event) => {
      const form = event.target.form;
      form.action = "../agent_bookings/new";
      form.method = "GET";
      form.noValidate = true;
    });
}

function setupOccupiableSelect() {
  Array.from(document.getElementsByClassName("occupiables-select")).forEach(
    (baseElement) => {
      const selectElement = baseElement.querySelector("select");

      // includes blank
      if (selectElement.getElementsByTagName("option").length <= 2) {
        selectElement.setAttribute("readonly", true);
        return;
      }

      const allCheckboxElements =
        baseElement.getElementsByClassName("form-check");
      const handler = () => {
        const homeId = selectElement.value;
        const visibleCheckboxElements = baseElement.querySelectorAll(
          `.form-check[data-home-id='${homeId}']`
        );
        Array.from(allCheckboxElements).forEach((checkboxWrapperElement) => {
          checkboxWrapperElement
            .querySelector('input[type="checkbox"]')
            .setAttribute("disabled", true);
          // checkboxElement.classList.add('d-none')
        });

        Array.from(visibleCheckboxElements).forEach(
          (checkboxWrapperElement) => {
            const checkboxElement = checkboxWrapperElement.querySelector(
              'input[type="checkbox"]'
            );
            checkboxElement.removeAttribute("disabled");
            if (visibleCheckboxElements.length <= 1) {
              checkboxElement.checked = true;
            } else {
              checkboxWrapperElement.classList.remove("d-none");
            }
          }
        );
      };
      selectElement.addEventListener("change", handler);
      handler();
    }
  );
}

document.addEventListener("DOMContentLoaded", () => {
  csrfForm();
  toggleDisable();
  setupRichTextArea();
  setupBookingAgentBookingButton();
  setupOccupiableSelect();
});

Rails.start();
ReactRailsUJS.useContext(require.context("components", true));
