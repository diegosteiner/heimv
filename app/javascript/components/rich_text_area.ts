export function setup() {
  if (!document.querySelector(".rich-text-area")) return;

  loadEditor().then((froala) => {
    new froala(".rich-text-area", {
      charCounterCount: false,
      imagePaste: false,
      imageUpload: false,
      // enter: 1,
      htmlUntouched: true,
      toolbarInline: false,
      // attribution: false,
      toolbarVisibleWithoutSelection: false,
      toolbarBottom: false,
      quickInsertEnabled: false,
      toolbarButtons: {
        moreText: {
          buttons: [
            "bold",
            "italic",
            // "underline",
            // "fontFamily",
            // "fontSize",
            "paragraphFormat",
            // "strikeThrough",
            // "subscript",
            // "superscript",
            // "textColor",
            // "backgroundColor",
            "inlineClass",
            "inlineStyle",
            "clearFormatting",
          ],
          buttonsVisible: 4,
        },
        moreParagraph: {
          buttons: [
            // "alignLeft",
            // "alignCenter",
            "formatOLSimple",
            // "alignRight",
            // "alignJustify",
            // "formatOL",
            "formatUL",
            // "paragraphStyle",
            // "lineHeight",
            // "outdent",
            // "indent",
          ],
          buttonsVisible: 3,
        },
        moreRich: {
          buttons: ["insertImage", "insertTable", "insertLink", "specialCharacters"],
          buttonsVisible: 4,
        },
        moreMisc: {
          buttons: ["undo", "redo", "fullscreen", "html"],
          align: "right",
          buttonsVisible: 4,
        },
      },
      pluginsEnabled: [
        // 'align',
        "codeBeautifier",
        "codeView",
        // 'colors',
        // 'fontFamily',
        // 'fontSize',
        "lineBreaker",
        // 'lineHeight',
        "link",
        "lists",
        "paragraphFormat",
        "paragraphStyle",
        "quickInsert",
        // 'save',
        "table",
        "url",
        "image",
        // 'imageManager',
        "draggable",
        // 'WPlaceholdersPlugin'
        "wordPaste",
        "specialCharacters",
        "trackChanges",
      ],
      // paragraphFormatSelectiont: true,
    });
  });
}

function loadEditor() {
  return Promise.all([
    import(/* webpackChunkName: "froala" */ "froala-editor/js/froala_editor.pkgd.min.js"),
    import(/* webpackChunkName: "froala" */ "froala-editor/css/froala_editor.pkgd.min.css"),
  ]).then((imports) => imports[0].default);
}
