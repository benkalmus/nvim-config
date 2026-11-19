local M = {}

local state = {}
local WIDTH_RATIO = 0.45

local function valid_win(win)
	return win and vim.api.nvim_win_is_valid(win)
end

local function valid_buf(buf)
	return buf and vim.api.nvim_buf_is_valid(buf)
end

local function notify(message, level)
	vim.notify("omp: " .. message, level or vim.log.levels.INFO, { title = "omp" })
end

local function width()
	return math.max(20, math.floor(vim.o.columns * WIDTH_RATIO))
end

local function reset(tab, st)
	if st.buf and valid_buf(st.buf) then
		pcall(vim.api.nvim_buf_delete, st.buf, { force = true })
	end
	state[tab] = nil
end

-- Follow output only while the panel is at the bottom, even when another window is current.
local function follow(st)
	if not valid_buf(st.buf) then
		return
	end
	local count = vim.api.nvim_buf_line_count(st.buf)
	if valid_win(st.win) and vim.api.nvim_get_current_win() ~= st.win then
		local info = vim.fn.getwininfo(st.win)[1]
		if info and info.botline >= st.last_count - 1 then
			vim.api.nvim_win_set_cursor(st.win, { count, 0 })
		end
	end
	st.last_count = count
end

function M.open()
	local tab = vim.api.nvim_get_current_tabpage()
	local st = state[tab]

	if st and st.exited then
		if st.job and st.job > 0 then
			pcall(vim.fn.jobstop, st.job)
		end
		reset(tab, st)
		st = nil
	end

	if not st then
		st = { tab = tab }
		state[tab] = st
	end

	if valid_win(st.win) then
		vim.api.nvim_set_current_win(st.win)
		vim.cmd("startinsert")
		return st
	end

	if not valid_buf(st.buf) then
		st.buf = vim.api.nvim_create_buf(false, false)
		vim.bo[st.buf].bufhidden = "hide"
		vim.bo[st.buf].swapfile = false
		st.last_count = 1
		vim.api.nvim_buf_attach(st.buf, false, {
			on_lines = function()
				if st.follow_pending then
					return
				end
				st.follow_pending = true
				vim.schedule(function()
					st.follow_pending = false
					follow(st)
				end)
			end,
		})
	end

	st.win = vim.api.nvim_open_win(st.buf, true, {
		split = "right",
		win = -1,
		width = width(),
	})
	st.last_count = vim.api.nvim_buf_line_count(st.buf)
	vim.api.nvim_win_set_cursor(st.win, { st.last_count, 0 })

	if not st.job or st.job <= 0 then
		local job = vim.fn.jobstart({ "omp" }, {
			term = true,
			cwd = vim.fn.getcwd(),
			on_exit = function(_, code)
				st.exited = true
				vim.schedule(function()
					if state[tab] == st then
						notify("exited (" .. code .. ")", vim.log.levels.WARN)
					end
				end)
			end,
		})
		if job <= 0 then
			notify("failed to start", vim.log.levels.ERROR)
			return st
		end
		st.job = job
		vim.bo[st.buf].bufhidden = "hide"
	end

	vim.cmd("startinsert")
	return st
end

function M.toggle()
	local st = state[vim.api.nvim_get_current_tabpage()]
	if st and valid_win(st.win) then
		vim.api.nvim_win_close(st.win, true)
		st.win = nil
		return
	end
	M.open()
end

local function send(text)
	local st = M.open()
	if not st or not st.job or st.job <= 0 then
		return
	end
	if vim.fn.chansend(st.job, text) == 0 then
		notify("not running", vim.log.levels.WARN)
		return
	end
	if valid_win(st.win) then
		vim.api.nvim_set_current_win(st.win)
		vim.cmd("startinsert")
	end
end

function M.mention(path, from, to)
	local rel = vim.fn.fnamemodify(path, ":.")
	local ref = "@" .. rel .. "#L" .. from
	if to ~= from then
		ref = ref .. "-" .. to
	end
	send(ref .. " ")
end

function M.setup()
	if vim.g.omp_terminal_setup then
		return
	end
	vim.g.omp_terminal_setup = true

	vim.keymap.set({ "n", "v", "t", "i" }, "<C-.>", M.toggle, { desc = "Toggle omp" })

	vim.keymap.set("n", "<leader>ac", function()
		local path = vim.api.nvim_buf_get_name(0)
		if path == "" or vim.bo.buftype ~= "" then
			notify("current buffer is not a file", vim.log.levels.WARN)
			return
		end
		local line = vim.api.nvim_win_get_cursor(0)[1]
		M.mention(path, line, line)
	end, { desc = "Mention cursor line to omp" })

	vim.keymap.set("v", "<leader>av", function()
		local path = vim.api.nvim_buf_get_name(0)
		if path == "" or vim.bo.buftype ~= "" then
			notify("current buffer is not a file", vim.log.levels.WARN)
			return
		end
		local from = vim.fn.line("v")
		local to = vim.fn.line(".")
		if from > to then
			from, to = to, from
		end
		M.mention(path, from, to)
	end, { desc = "Mention selection to omp" })

	vim.api.nvim_create_autocmd("TabClosed", {
		callback = function()
			vim.schedule(function()
				for tab, st in pairs(state) do
					if not vim.api.nvim_tabpage_is_valid(tab) then
						if st.job and st.job > 0 then
							pcall(vim.fn.jobstop, st.job)
						end
						state[tab] = nil
					end
				end
			end)
		end,
	})
end

return M
