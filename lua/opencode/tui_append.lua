---Append rendered range refs to the opencode TUI input, without submitting.
---
---Types the ref as keystrokes into the terminal running opencode
---(`nvim_chan_send` on its pty channel). No newline is sent, so nothing
---submits. HTTP cannot do this on daemon 2.0.18: the `POST /tui/append-prompt`
---endpoint exists only in later opencode source, and 2.0.18 serves no TUI
---routes (verified against tag `v2.0.18`). Keystrokes work on every version.
local M = {}

---Find the snacks terminal running `cmd`.
---@param cmd string Terminal command, as passed to `snacks.terminal.open`.
---@return snacks.win? terminal First valid match, if any.
local function find_terminal(cmd)
	for _, term in ipairs(require("snacks.terminal").list()) do
		if term.cmd == cmd and term:buf_valid() then
			return term
		end
	end
end

---Type `text` into the terminal running `cmd`.
---@param cmd string Terminal command, as passed to `snacks.terminal.open`.
---@param text string Text to type. No newline is appended.
---@return boolean False when the terminal is not open.
local function send_to_terminal(cmd, text)
	local term = find_terminal(cmd)
	if not term then
		return false
	end
	local chan = vim.b[term.buf].terminal_job_id
	if not chan then
		return false
	end
	vim.api.nvim_chan_send(chan, text)
	return true
end

---Render `prefix` for the operator range and type it into the TUI input.
---@param kind "char" | "line" | "block"
---@param prefix string Prompt prefix to render (e.g. `"@this "`).
---@param cmd string Terminal command running opencode.
local function append(kind, prefix, cmd)
	local from = vim.api.nvim_buf_get_mark(0, "[")
	local to = vim.api.nvim_buf_get_mark(0, "]")
	if from[1] > to[1] or (from[1] == to[1] and from[2] > to[2]) then
		from, to = to, from
	end

	require("opencode.server.discovery")
		.get()
		:next(function(server)
			local context = require("opencode.context").new(server, {
				from = { from[1], from[2] },
				to = { to[1], to[2] },
				kind = kind,
			})
			local ref = context:render(prefix).output:plaintext()
			context:clear()
			if not send_to_terminal(cmd, ref) then
				vim.notify("opencode terminal not open", vim.log.levels.WARN, { title = "opencode" })
			end
		end)
		:catch(function(err)
			vim.notify(tostring(err), vim.log.levels.ERROR, { title = "opencode" })
		end)
end

---Set `operatorfunc` so the pending motion types `prefix` into the TUI input.
---@param prefix string Prompt prefix to render (e.g. `"@this "`).
---@param cmd string Terminal command running opencode.
---@return string `g@` for `{expr}` keymaps.
function M.operator(prefix, cmd)
	_G.opencode_tui_append = function(kind)
		append(kind, prefix, cmd)
	end
	vim.o.operatorfunc = "v:lua.opencode_tui_append"
	return "g@"
end

return M
