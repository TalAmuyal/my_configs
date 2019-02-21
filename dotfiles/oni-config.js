const activate = (oni) => {

  const isMode = (mode) => {
    isMenuOpen = oni.menu.isMenuOpen()
    editorMode = oni.editors.activeEditor.mode
    return (mode === "menu") ? isMenuOpen : (editorMode === mode)
  }

  const visualMode  = () => isMode("visual")
  const normalMode  = () => isMode("normal")
  const insertMode  = () => isMode("insert")
  const commandMode = () => isMode("cmdline_normal")
  const menuMode    = () => isMode("menu")

  // Free-up default bindings
  oni.input.unbind("<tab>")

  // Re-bind menu controls (like auto-completion)
  oni.input.bind("<enter>", "contextMenu.select")
  oni.input.bind("<tab>",   "contextMenu.next")
  oni.input.bind("<S-Tab>", "contextMenu.previous")

  // Panes
  oni.input.bind("<f8>",    "markdown.togglePreview")
  oni.input.bind("<f9>",    "sidebar.toggle")

  // Command-line
  oni.input.bind("<c-s-p>", "commands.show",          normalMode)
  oni.input.bind("<c-v>",   "editor.clipboard.paste", commandMode)

  // Quick-open
  oni.input.bind("<c-p>", "quickOpen.show",               normalMode)
  oni.input.bind("<c-v>", "quickOpen.openFileVertical",   menuMode)
  oni.input.bind("<c-h>", "quickOpen.openFileHorizontal", menuMode)
  oni.input.bind("<c-t>", "quickOpen.openFileNewTab",     menuMode)

  oni.input.bind("<c-f>", "quickOpen.searchFileByContent", normalMode)
  oni.input.bind("<c-f>", "quickOpen.setToQuickFix",       menuMode)
};

module.exports = {
  activate, // A must for the above configs to be applied

  "oni.exclude": [
    "node_modules",
    ".git",
    "__pycache__",
  ],

  // Currently not functional, but when it will be, I want to update manually so I could update the configs to my liking
  "autoUpdate.enabled": false,

  // Don't use since it is geared towards Vim newbies
  "oni.useDefaultConfig": false,

  // Oni's clipboard-manager adds bugs and yields no benefits
  "editor.clipboard.enabled": false,

  // Do use my own Vim configs
  "oni.loadInitVim": true,

  "autoClosingPairs.default": [
    { open: "{", close: "}" },
    { open: "[", close: "]" },
    { open: "(", close: ")" },
    //{ open: '"', close: '"' }, Interrupts with Python's triple quote
    { open: "'", close: "'" },
    { open: '`', close: '`' },
  ],

  // Minimalism
  "editor.maximizeScreenOnStart": true, // Part of my minimalism mantra
  "oni.hideMenu": 'hidden', // Save up space
  "sidebar.enabled": false,
  "tabs.height": "2.1em", // A bit smaller than the default

  // Completely subjective and personal preference
  "editor.fontSize": "14px",
  "editor.fontFamily": "Fira code", // Recommended: A font with ligatures
  "ui.colorscheme": "solarized8_light", // Personal preference
  "terminal.shellCommand": "zsh",

  // Pretty GUI
  "tabs.mode": "tabs", // For those who like window-tabs (like in FireFox and Chrome)

  "language.java.languageServer" : {
    command: "java-lsp",
  },
  "language.clojure.languageServer" : {
    command: "clojure-lsp",
  },

  /* Experimental features */
  "editor.quickInfo.delay": 100,
}

