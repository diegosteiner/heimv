export function setup() {
  if (!document.querySelector(".rich-text-area")) return;

  loadEditor().then((tinymce) => {
    tinymce.init({
      selector: ".rich-text-area",
      skin: false,
      content_css: false,
      height: 500,
      menubar: false,
      plugins: ["advlist autolink lists link image anchor table", "searchreplace code table help template"],
      toolbar:
        "undo redo | formatselect | " + "bold italic | bullist numlist table | template " + "removeformat | code help",
      // templates: [{ title: "Test", description: "Desc", content: "{{ booking.ref }}" }],
      content_style:
        'body { font-family:-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, ' +
        '"Noto Sans", "Liberation Sans", sans-serif, "Apple Color Emoji", "Segoe UI Emoji", ' +
        '"Segoe UI Symbol", "Noto Color Emoji"; font-size: 0.85em }',
    });
  });
}

function loadEditor() {
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
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/template"),
    import(/* webpackChunkName: "tinymce" */ "tinymce/plugins/table"),
  ]).then((imports) => imports[0].default);
}
