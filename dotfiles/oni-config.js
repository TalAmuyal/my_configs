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
};

module.exports = {
    activate,
    "oni.useDefaultConfig": false,
    "oni.loadInitVim": true,
    "editor.fontSize": "14px",
    "editor.fontFamily": "Fira code",
    "oni.hideMenu": true,
    "tabs.mode": "hidden",
    "ui.colorscheme": "solarized"
}

