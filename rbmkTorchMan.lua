require("term").clear()
print("Connect first RoR torch (transmitter)")
local transmitterAdd
repeat
    local _,add,ct=require("event").pull("component_added")
    if ct=="radio_torch" then transmitterAdd=add end
until transmitterAdd
print("Connected!")
print("\nConnect second RoR torch (reciever)")
local recieverAdd
repeat
    local _,add,ct=require("event").pull("component_added")
    if ct=="radio_torch" then recieverAdd=add end
until recieverAdd
print("Connected!")
print("\nWriting...")
local fh = io.open("/rbmk/torches.add","w")
fh:write(transmitterAdd.."\n"..recieverAdd)
fh:close()
print("Done!")