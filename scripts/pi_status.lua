#!/usr/bin/env lua

local REPORT = "/tmp/pi-status-broadcaster/status.json"

local ICON = { IDLE = "󰔟", BUSY = "󰑮" }
local COLOR = { IDLE = "\27[33m", BUSY = "\27[32m", RESET = "\27[0m", DIM = "\27[2m", BOLD = "\27[1m" }

local function indent(str, level)
	level = level or 1

	return string.rep("  ", level) .. str
end

local W = tonumber(os.getenv("PI_STATUS_W") or "") or 34
local CW = math.max(10, W - 2) -- popup border eats 1 column each side

-- ponytail: no wcwidth, byte-safe truncation only. Byte length is >= cell width, so a
-- line budgeted in bytes never overflows the popup; it may cut ~3 bytes early on a
-- multi-byte glyph. Call it only on plain text, never on a string with ANSI codes.
local function fit(s, w)
	w = math.max(4, w)
	if #s <= w then
		return s
	end

	local i = w - 1
	while i > 0 and s:byte(i + 1) >= 0x80 and s:byte(i + 1) < 0xC0 do
		i = i - 1
	end

	return s:sub(1, i) .. "…"
end

local function sessions_via_jq()
	local f = io.popen(
		"jq -r 'to_entries[] | select(.value.finished != true)"
			.. " | [.value.status, (.value.name // .key), .value.cwd,"
			.. ' (.value.tmux.session // ""), (.value.tmux.window // ""),'
			.. ' (.value.tmux.windowName // ""), (.value.tmux.pane // "")] | @tsv\' '
			.. REPORT
			.. " 2>/dev/null"
	)

	if not f then
		return nil
	end

	local out = {}
	for line in f:lines() do
		local status, name, cwd, tsess, twin, twname, tpane =
			line:match("^([^\t]+)\t([^\t]+)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t(.*)$")

		if status then
			local tmux = tsess ~= "" and { session = tsess, window = twin, windowName = twname, pane = tpane } or nil
			out[#out + 1] = { status = status, name = name, cwd = cwd, tmux = tmux }
		end
	end

	f:close()
	return out
end

local function main()
	local sessions = sessions_via_jq()

	if not sessions or #sessions == 0 then
		io.write(indent(COLOR.DIM .. "No active sessions" .. COLOR.RESET .. "\n", 2))

		os.exit(0)
	end

	for i, s in ipairs(sessions) do
		local icon = ICON[s.status] or "?"
		local color = COLOR[s.status] or COLOR.RESET

		io.write(
			indent(color .. icon .. " " .. fit(s.name, CW - 13) .. "  " .. COLOR.DIM .. s.status .. COLOR.RESET .. "\n")
		)

		if s.tmux then
			local t = s.tmux

			io.write(
				indent(
					COLOR.DIM
						.. "󱞩"
						.. " "
						.. fit(t.session .. ":" .. t.window .. "." .. t.pane .. " · " .. t.windowName, CW - 9)
						.. COLOR.RESET
						.. "\n",
					2
				)
			)
		end

		if i < #sessions then
			io.write("\n")
		end
	end

	io.write("\n")
end

main()
