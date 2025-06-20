return {
    "saghen/blink.cmp",
    opts = {
        completion = {
            list = {
                selection = {
                    preselect = true,
                    auto_insert = false,
                },
            },
        },
        keymap = {
            preset = "default",
            ["<C-y>"] = { "select_and_accept", "fallback" },
            ["<C-m>"] = { "select_and_accept", "fallback" },
            ["<Tab>"] = { "select_and_accept", "fallback" },
        },
        -- experimental, signature help
        signature = {
            enabled = false,
            window = { show_documentation = false },
        },
    },
}
