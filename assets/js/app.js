// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import Sortable from "../vendor/sortable";

const Hooks = {
  Sortable: {
    mounted() {
      const sorter = new Sortable(this.el, {
        animation: 150,
        dragClass: "drag-item",
        ghostClass: "drag-ghost",
        handle: "[data-handle]",
        forceFallback: true,
        // TODO what does this do?!
        onEnd: (e) => {
          this.el
            .closest("form")
            .querySelector("input")
            .dispatchEvent(new Event("input", { bubbles: true }));
        },
      });
    },
  },
  TinyMDE: {
    mounted() {
      const textareaId = this.el.id;
      const commandBarId = `${this.el.id}_command_bar`;
      const tinyMDE = new TinyMDE.Editor({textarea: textareaId});
      console.log(textareaId)
      console.log(commandBarId)
      new TinyMDE.CommandBar({element: commandBarId, editor: tinyMDE});
    }
  }
};

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
const liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
