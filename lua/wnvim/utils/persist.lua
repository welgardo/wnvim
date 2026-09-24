--[[
Persistent JSON key/value store for wnvim user state.

Everything is stored under:
    <stdpath("data")>/wnvim/state.json

which lives OUTSIDE the cloned repo, so `git pull` updates never lose
the user's theme selection or other settings. The data directory itself
is derived from XDG at runtime — nothing is hardcoded to one machine.
]]

local M = {}

function M.dir()
  return vim.fn.stdpath('data') .. '/wnvim'
end

function M.file()
  return M.dir() .. '/state.json'
end

local cache = nil

local function load()
  if cache then return cache end
  cache = {}
  local f = io.open(M.file(), 'r')
  if f then
    local raw = f:read('*a')
    f:close()
    local ok, decoded = pcall(vim.json.decode, raw)
    if ok and type(decoded) == 'table' then
      cache = decoded
    end
  end
  return cache
end

local function save()
  -- Ensure the directory exists (Neovim creates stdpath dirs lazily).
  vim.fn.mkdir(M.dir(), 'p')
  local f = io.open(M.file(), 'w')
  if not f then
    return false
  end
  f:write(vim.json.encode(cache or {}) .. '\n')
  f:close()
  return true
end

function M.get(key, default)
  local v = load()[key]
  if v == nil then return default end
  return v
end

function M.set(key, value)
  load()[key] = value
  return save()
end

return M
