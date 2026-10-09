-- Loaded by Neovim automatically after the existing Crylia config/plugins.
local ok, theme = pcall(require, "amber.theme")
if ok then
  theme.setup()
else
  vim.schedule(function()
    vim.notify("Amber Neovim: " .. tostring(theme), vim.log.levels.ERROR)
  end)
end
