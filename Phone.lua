
local connectionURL = "192.168.1.13:3000"
local ws, err = http.websocket(connectionURL)
local loop = false
local pp = require "cc.pretty"
local command
local input
if not ws then
  return printError(err)
end
ws.send("Phone connected on version 1.1b")
function menu()
	ws.send("request-date")
	local _, url, resp , isBin = os.pullEvent("websocket_message")
	term.clear()
	term.setCursorPos(1,1)
	term.write(string.format("Phone OS									%s",resp))
	term.setCursorPos(1,2)
	term.write("1) Commandline")
	term.setCursorPos(1,3)
	term.write("2) Appstore")
	term.setCursorPos(1,4)
	term.write("3) Messages")
	term.setCursorPos(1,5)
	term.write("4) My Apps")
	term.setCursorPos(1,6)
	term.write("5) quit")
	term.setCursorPos(1,7)
	input = read()
	if input == "1" then
		CLine()
	end
	if input == "2" then
		appMenu()
	end
	if input == "3" then
		menu()
	end
	if input == "4" then
		myApps()
	end
	if input == "5" then
		ws.close()
		os.shutdown()
	end
	
end
function sendmsg()
	local input = read()
end
function getmsg()
	local _, url, resp , isBin = os.pullEvent("websocket_message")
	print(resp)
end
function message()
	ws.send("request-msg")
	term.clear()
	term.setCursorPos(1,1)
	local sendto = read()
	ws.send("MSG_"..sendto)
	local _, url, resp , isBin = os.pullEvent("websocket_message")
	if resp == "CONNECTED" then
		print("Connected to "..sendto)
	end
	if resp == "ERROR" then
		print("There was an error please contact an admin if the problem persists")
	end
	paralell.waitForAny(sendmsg, getmsg)
end

function appMenu()
	local apptable = {}
	term.setCursorPos(1,1)
	term.clear()
	ws.send("request-listapps")
	local index = 1
	while true do
		local _, url, response , isBin = os.pullEvent("websocket_message")
		if response == "LISTEND" then
			break
		end
		apptable[index] = response
		index = index + 1
	end
	print(textutils.pagedTabulate(apptable))
	print("type the name of the app to install: ")
	input = read()
	if input == quit then
		menu()
	end
	ws.send(string.format('request-app+%s', input))
	local _, url, resp , isBin = os.pullEvent("websocket_message")
	if isBin then -- only writes if the server is sending binary data
		filepath = './Apps/'.. input
		application = io.open(filepath,'w')
		application:write(resp)
		application:close()
	end
	term.write(string.format('File is at [./Apps/%s]', input))
	menu()
end
function CLine()
	term.clear()
	term.setCursorPos(1,1)
	term.write("Phone OS 1.0")
	term.setCursorPos(1,2)
	while true do
		command = read()
		if command == "shell.quit" then
			menu()
		end
		if command ~= "shell.quit" then
			ws.send(command)
			local _, url, resp , isBin = os.pullEvent("websocket_message")
			if(resp) then
				print(resp)
			end
		end

	end
end
function myApps()
	term.clear()
	term.setCursorPos(1,1)
	print(shell.execute("ls","./Apps"))
	print("Enter to continue or type run to run a program ")
	pause = read()
	if pause == "run" then
		term.clear()
		term.setCursorPos(1,1)
		shell.execute("ls","./Apps")
		print("Select program")
		local programname = read()
		shell.run("./Apps/"..programname)
	end
	if pause ~= "run" then
		local back = true
		if back == true then
			menu()
		end
	end
end
menu()
