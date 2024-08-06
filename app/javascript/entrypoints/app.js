import "~/services/i18n";
import "bootstrap/dist/js/bootstrap.bundle";
import Rails from "@rails/ujs";
import ReactRailsUJS from "react_ujs";

function csrfForm() {
  const csrfToken = document.querySelector("meta[name=csrf-token]")?.content;
  if (!csrfToken) return;

  const authTokenInput = document.querySelector("input[name=authenticity_token]");
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
  document.getElementById("agent-booking-button")?.addEventListener("click", (event) => {
    const form = event.target.form;
    form.action = "../agent_bookings/new";
    form.method = "GET";
    form.noValidate = true;
  });
}

function setupOccupiableSelect() {
  Array.from(document.getElementsByClassName("occupiables-select")).forEach((baseElement) => {
    const selectElement = baseElement.querySelector("select");
    const handler = () => {
      const homeId = selectElement.value;
      const occupiablesCheckboxesElement = baseElement.querySelector(".occupiables-checkboxes");
      const allCheckboxElements = occupiablesCheckboxesElement.querySelectorAll(".form-check");
      const currentOccupiableCheckboxes = occupiablesCheckboxesElement.querySelectorAll(
        `.form-check[data-home-id="${homeId}"] input[type="checkbox"]`,
      );

      allCheckboxElements.forEach((checkboxWrapperElement) => {
        const checkboxElement = checkboxWrapperElement.querySelector('input[type="checkbox"]');

        if (checkboxWrapperElement.dataset.homeId == homeId) {
          checkboxElement.removeAttribute("disabled");
          checkboxWrapperElement.classList.remove("d-none");
          if (currentOccupiableCheckboxes.length == 1 || checkboxElement.value == homeId)
            checkboxElement.checked = true;
        } else {
          checkboxElement.setAttribute("disabled", true);
          checkboxWrapperElement.classList.add("d-none");
        }
      });
    };
    selectElement.addEventListener("change", () => handler());
    handler();
  });
}

function setupOrgChangeSelect() {
  document.getElementById("change-org")?.addEventListener("change", (event) => {
    window.location = event.target.value;
  });
}

function setupRichTextArea() {
  if (!document.querySelector(".rich-text-area")) return;

  import("~/services/rich_text_area");
}

// Rails.start();
document.addEventListener("DOMContentLoaded", () => {
  csrfForm();
  toggleDisable();
  setupRichTextArea();
  setupBookingAgentBookingButton();
  setupOccupiableSelect();
  setupOrgChangeSelect();
  Rails.start();
});

// https://github.com/reactjs/react-rails/issues/1134#issuecomment-1415112288
function viteConstructorRequireContext(reqCtx) {
  const componentNameMatcher = (className) => {
    return (path) =>
      path.includes(`/${className}.js`) ||
      path.includes(`/${className}/index.js`) ||
      path.includes(`/${className}.ts`) ||
      path.includes(`/${className}.tsx`);
  };

  const fromRequireContext = function (reqCtx) {
    return function (className) {
      const componentPath = Object.keys(reqCtx).find(componentNameMatcher(className));
      const component = reqCtx[componentPath];
      return component.default;
    };
  };

  const fromCtx = fromRequireContext(reqCtx);
  return function (className) {
    let component;
    try {
      // `require` will raise an error if this className isn't found:
      component = fromCtx(className);
    } catch (firstErr) {
      console.error(firstErr);
    }
    return component;
  };
}
const componentsRequireContext = import.meta.glob("~/components/**/*.{ts,tsx}", { eager: true });
ReactRailsUJS.getConstructor = viteConstructorRequireContext(componentsRequireContext);
