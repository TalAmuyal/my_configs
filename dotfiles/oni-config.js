const activate = (oni) => {
    oni.input.unbind("<tab>")
    oni.input.unbind("<f3>")
    oni.input.unbind("<f4>")
    oni.input.unbind("<f5>")
    oni.input.unbind("<f12>")

    oni.input.bind("<enter>", "contextMenu.select")
    oni.input.bind("<tab>", "contextMenu.next")
    oni.input.bind("<S-Tab>", "contextMenu.previous")

    oni.input.bind("<f3>", "oni.editor.gotoDefinition")
    oni.input.bind("<f4>", "oni.editor.findAllReferences")
    oni.input.bind("<f5>", "language.formatter.formatDocument")

    oni.input.bind("<f8>", "markdown.togglePreview")
    oni.input.bind("<f9>", "sidebar.toggle")
};

module.exports = {
    activate,

    "autoClosingPairs.default": [
        { open: "{", close: "}" },
        { open: "[", close: "]" },
        { open: "(", close: ")" },
        { open: '"', close: '"' },
        { open: '\'', close: '\'' },
        { open: '`', close: '`' },
        { open: '<', close: '>' },
    ],

    "oni.useDefaultConfig": false,
    "oni.loadInitVim": true,
    "editor.fontSize": "14px",
    "editor.fontFamily": "Fira code",
    "oni.hideMenu": true,
    "tabs.mode": "tabs",
    "tabs.showIndex": true,
    "ui.colorscheme": "solarized",
    "sidebar.plugins.enabled": true,
    "sidebar.enabled": true,
    "editor.split.mode": "oni",

    /* Experimental features */
    "experimental.markdownPreview.enabled": true,
    "experimental.commandline.mode": true,
    "experimental.commandline.icons": true,

    "experimental.wildmenu.mode": true,
    "experimental.welcome.enabled": false,
}

