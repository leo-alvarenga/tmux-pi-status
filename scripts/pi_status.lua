#!/usr/bin/env lua

local REPORT = "/tmp/pi-status-broadcaster/status.json"

local ICON = { IDLE = "󰔟", BUSY = "󰑮", TMUX = "" }
local COLOR = { IDLE = "\27[33m", BUSY = "\27[32m", RESET = "\27[0m", DIM = "\27[2m", BOLD = "\27[1m" }

local function sessions_via_jq()
	local f = io.popen(
		"jq -r 'to_entries[] | select(.value.finished != true)"
			.. " | [.value.status, (.value.name // .key), .value.cwd,"
			.. " (.value.tmux.session // \"\"), (.value.tmux.window // \"\"),"
			.. " (.value.tmux.windowName // \"\"), (.value.tmux.pane // \"\")] | @tsv' "
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
	return #out > 0 and out or nil
end

local function sessions_via_python()
	local f = io.popen([[python3 -c "
import json
try:
    data = json.load(open('/tmp/pi-status-broadcaster/status.json'))
    for k, v in data.items():
        if not v.get('finished'):
            t = v.get('tmux') or {}
            print('\t'.join([v.get('status','IDLE'), v.get('name', k), v.get('cwd',''),
                t.get('session',''), t.get('window',''), t.get('windowName',''), t.get('pane','')]))
except Exception: pass
" 2>/dev/null]])
	if not f then
		return {}
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
	local sessions = sessions_via_jq() or sessions_via_python()

	io.write("\n")
	io.write(COLOR.BOLD .. "  Pi Sessions" .. COLOR.RESET .. "\n")
	io.write(COLOR.DIM .. string.rep("─", 28) .. COLOR.RESET .. "\n")

	if #sessions == 0 then
		io.write(COLOR.DIM .. "  no active sessions" .. COLOR.RESET .. "\n")

		os.exit(0)
	end

	for i, s in ipairs(sessions) do
		local icon = ICON[s.status] or "?"
		local color = COLOR[s.status] or COLOR.RESET

		io.write(color .. icon .. " " .. s.name .. "  " .. COLOR.DIM .. s.status .. COLOR.RESET .. "\n")

		if s.tmux then
			local t = s.tmux
			io.write(COLOR.DIM .. "  " .. ICON.TMUX .. " " .. t.session .. ":" .. t.window .. "." .. t.pane .. " · " .. t.windowName .. COLOR.RESET .. "\n")
		end

		if i < #sessions then
			io.write("\n")
		end
	end

	io.write("\n")
end

main()
