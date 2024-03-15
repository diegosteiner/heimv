export function setup() {
  if (!document.querySelector(".rich-text-area")) return;

  loadEditor().then((tinymce) => {
    tinymce.init({
      selector: ".rich-text-area",
      skin: false,
      content_css: false,
      height: 500,
      menubar: false,
      convert_urls: false,
      allow_unsafe_link_target: true,
      fix_list_elements: false,
      forced_root_block: "div",
      extended_valid_elements: "liquid",
      plugins: "autolink link anchor lists image table template searchreplace code pagebreak",
      toolbar: "undo redo | blocks | bold italic removeformat | bullist numlist link image table pagebreak | code",
      // templates: [{ title: "Test", description: "Desc", content: "{{ booking.ref }}" }],
      content_style:
        'body { font-family:-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, ' +
        '"Noto Sans", "Liberation Sans", sans-serif, "Apple Color Emoji", "Segoe UI Emoji", ' +
        '"Segoe UI Symbol", "Noto Color Emoji"; font-size: 0.85em }' +
        "liquid { font-family: monospace; }",
    });
  });
}

function loadEditor() {
  return Promise.all([
    import(/* webpackChunkName: "tinymce" */ "tinymce"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/icons/default"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/models/dom"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/themes/silver"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/anchor"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/code"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/link"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/autolink"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/lists"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/image"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/searchreplace"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/template"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/table"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/pagebreak"),
  ]).then((imports) => imports[0].default);
}
