import tinymce from "tinymce";
import "tinymce/icons/default";
import "tinymce/models/dom";
import "tinymce/themes/silver";
import "tinymce/plugins/anchor";
import "tinymce/plugins/code";
import "tinymce/plugins/link";
import "tinymce/plugins/autolink";
import "tinymce/plugins/lists";
import "tinymce/plugins/image";
import "tinymce/plugins/searchreplace";
import "tinymce/plugins/template";
import "tinymce/plugins/table";
import "tinymce/plugins/pagebreak";

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

export default tinymce;
