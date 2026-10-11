--- In after/lsp/ so it wins over nvim-lspconfig's lsp/tailwindcss.lua, which forces file watching on;
--- on Linux nvim's fallback watcher scans the whole repo on the main thread.
return {
  capabilities = { workspace = { didChangeWatchedFiles = { dynamicRegistration = false } } },
}
