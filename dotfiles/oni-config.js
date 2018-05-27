const activate = (oni) => {
  // Free-up default bindings
  oni.input.unbind("<tab>")
  oni.input.unbind("<f4>")
  oni.input.unbind("<f5>")

  // Re-bind menu controls (like auto-completion)
  oni.input.bind("<enter>", "contextMenu.select")
  oni.input.bind("<tab>", "contextMenu.next")
  oni.input.bind("<S-Tab>", "contextMenu.previous")

  // Re-bind other specific functions
  oni.input.bind("<f8>", "markdown.togglePreview")
  oni.input.bind("<f9>", "sidebar.toggle")
};

module.exports = {
  activate, // A must for the above configs to be applied

  // Currently not functional, but when it will be, I want to update manually so I could update the configs to my liking
  "autoUpdate.enabled": false,

  // Don't use since it is geared towards Vim newbies
  "oni.useDefaultConfig": false,

  // Do use my own Vim configs
  "oni.loadInitVim": true,

  "autoClosingPairs.default": [
    { open: "{", close: "}" },
    { open: "[", close: "]" },
    { open: "(", close: ")" },
    //{ open: '"', close: '"' }, Interrupts with Pythgon's triple quote
    { open: "'", close: "'" },
    { open: '`', close: '`' },
  ],

  // Minimalism
  "editor.maximizeScreenOnStart": true, // Part of my minimalizm mantra
  "oni.hideMenu": true, // Save up space
  // "sidebar.enabled": false, // On for me since I prefer the pretty GUI
  "sidebar.default.open": false, // Start closed
  "tabs.height": "2.1em", // A bit smaller than the default

  //Completly subjective and personal pereference
  "editor.fontSize": "13px",
  "editor.fontFamily": "Fira code", // Recommended: A fornt with ligatures
  "ui.colorscheme": "solarized", // Personal preference
  "terminal.shellCommand": "zsh",

  // Pretty GUI
  "tabs.mode": "tabs", // For those who like window-tabs (like in FireFox and Chrome)
  "sidebar.plugins.enabled": true,

  "language.java.languageServer" : {
    command: "java-lsp",
  },
  "language.clojure.languageServer" : {
    command: "clojure-lsp",
  },

  /* Experimental features */
  "editor.quickInfo.delay": 100,
  "sidebar.marks.enabled": true,
  "experimental.markdownPreview.enabled": true,
  // "editor.split.mode": "oni",
}

