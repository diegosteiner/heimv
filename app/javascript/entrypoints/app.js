import "~/services/i18n";
import "bootstrap/dist/js/bootstrap.bundle";
import Rails from "@rails/ujs";
import { createRoot } from "react-dom/client";

function csrfForm() {
  const csrfToken = document.querySelector("meta[name=csrf-token]")?.content;
  if (!csrfToken) return;

  const authTokenInput = document.querySelector("input[name=authenticity_token]");
  if (authTokenInput) authTokenInput.value = csrfToken;
}

function toggleDisable() {
  for (const element of document.querySelectorAll('[data-bs-toggle="disable"]')) {
    const handler = () => {
      for (const target of document.querySelectorAll(element.dataset.bsTarget)) {
        target.disabled = !element.checked;
      }
    };
    element.addEventListener("change", (event) => {
      event.preventDefault;
      handler();
    });
    handler();
  }
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
  for (const baseElement of Array.from(document.getElementsByClassName("occupiables-select"))) {
    const selectElement = baseElement.querySelector("select");
    const handler = () => {
      const homeId = selectElement.value;
      const occupiablesCheckboxesElement = baseElement.querySelector(".occupiables-checkboxes");
      const allCheckboxElements = occupiablesCheckboxesElement.querySelectorAll(".form-check");
      const currentOccupiableCheckboxes = occupiablesCheckboxesElement.querySelectorAll(
        `.form-check[data-home-id="${homeId}"] input[type="checkbox"]`,
      );

      for (const checkboxWrapperElement of allCheckboxElements) {
        const checkboxElement = checkboxWrapperElement.querySelector('input[type="checkbox"]');

        if (checkboxWrapperElement.dataset.homeId === homeId) {
          checkboxElement.removeAttribute("disabled");
          checkboxWrapperElement.classList.remove("d-none");
          if (currentOccupiableCheckboxes.length === 1 || checkboxElement.value === homeId)
            checkboxElement.checked = true;
        } else {
          checkboxElement.setAttribute("disabled", true);
          checkboxWrapperElement.classList.add("d-none");
        }
      }
    };
    selectElement.addEventListener("change", () => handler());
    handler();
  }
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

function setupSubmit() {
  for (const element of document.querySelectorAll("[data-submit='change']")) {
    element.addEventListener("change", () => element.form.submit());
  }
}

function setupCopyToClipboard() {
  for (const element of document.querySelectorAll("[data-copy-to-clipboard]")) {
    element.addEventListener("click", (event) => {
      event.preventDefault();
      navigator.clipboard
        .writeText(element.dataset.copyToClipboard)
        .then(() => element.classList.add("text-success"))
        .catch(() => element.classList.add("text-danger"));
    });
  }
}

function setupUsageForms() {
  for (const usageElement of document.querySelectorAll("[data-usage-type='Tarifs::OvernightStay::Usage']")) {
    const summaryInput = usageElement.querySelector("input[name$='[summary]']");
    const detailsInputs = usageElement.querySelectorAll("input[data-usage-detail]");
    const sumOutput = usageElement.querySelector("output");
    const calculateSummary = () => {
      const values = Array.from(detailsInputs).map((input) => {
        if (!input.value) return null;
        const value = Number(input.value);
        return Number.isNaN(value) ? 0 : value;
      });

      sumOutput.innerText =
        values.filter((value) => value).length === 0 ? "" : values.reduce((sum, value) => sum + value || 0, 0);
      switch (new Set(values).size) {
        case 0:
          summaryInput.value = "";
          break;
        case 1:
          summaryInput.value = Array.from(values)[0];
          break;
        default:
          summaryInput.value = `${Math.min(...values)} … ${Math.max(...values)}`;
      }
    };

    calculateSummary();
    for (const input of detailsInputs) input.addEventListener("change", calculateSummary);

    summaryInput.addEventListener("focus", () => summaryInput.select());
    summaryInput.addEventListener("change", () => {
      const value = Number(summaryInput.value);
      if (Number.isNaN(value)) return;
      for (const input of detailsInputs) input.value = value;
      calculateSummary();
    });
  }
}

// Rails.start();
document.addEventListener("DOMContentLoaded", () => {
  csrfForm();
  setupReact();
  toggleDisable();
  setupRichTextArea();
  setupBookingAgentBookingButton();
  setupOccupiableSelect();
  setupOrgChangeSelect();
  setupSubmit();
  setupUsageForms();
  setupCopyToClipboard();
  Rails.start();
});

function setupReact() {
  const componentsRequireContext = import.meta.glob("~/components/rails/*.{ts,tsx}", { eager: true });
  for (const element of document.querySelectorAll("[data-component]")) {
    const component = componentsRequireContext[`/components/rails/${element.dataset.component}.tsx`];
    if (!component) continue;

    const props = JSON.parse(element.dataset.props || "{}");
    createRoot(element).render(component.default({ ...props }));
  }
}
