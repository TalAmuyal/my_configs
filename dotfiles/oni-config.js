const activate = (oni) => {
    oni.input.unbind("<Tab>")
    oni.input.unbind("<c-p>")
    oni.input.unbind("<f3>")
    oni.input.unbind("<f12>")

    oni.input.bind("<Tab>", "completion.next")
    oni.input.bind("<S-Tab>", "completion.previous")
    oni.input.bind("<CR>", "completion.complete")

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
    "editor.completions.enabled": true,
    "oni.hideMenu": true,
    "tabs.enabled": false,
    "tabs.showVimTabs": false
}

