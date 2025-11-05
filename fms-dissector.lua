yesno_types = {
  [0] = "No",
  [1] = "Yes"
}

mode_types = {
  [0] = "TeleOp",
  [1] = "Test",
  [2] = "Autonomous"
}

ds_to_fms_udp_protocol = Proto("ds_to_fms_udp",  "Driver Station to FMS UDP")

sequence_num = ProtoField.uint16("ds_to_fms_udp.sequence_num", "Sequence Number", base.DEC)
comm_version = ProtoField.uint8("ds_to_fms_udp.comm_version", "Comm Version", base.HEX)
status_byte = ProtoField.uint8("ds_to_fms_udp.status_byte", "Status Byte", base.HEX)
estop = ProtoField.uint8("ds_to_fms_udp.status_byte.estop", "E-Stop", base.DEC, yesno_types, 0x80)
robot_comms = ProtoField.uint8("ds_to_fms_udp.status_byte.robot_comms", "Robot Comms Active", base.DEC, yesno_types, 0x20)
radio_ping = ProtoField.uint8("ds_to_fms_udp.status_byte.radio_ping", "Radio Ping", base.DEC, yesno_types, 0x10)
rio_ping = ProtoField.uint8("ds_to_fms_udp.status_byte.io_ping", "Rio Ping", base.DEC, yesno_types, 0x08)
enabled = ProtoField.uint8("ds_to_fms_udp.status_byte.enabled", "Enabled", base.DEC, yesno_types, 0x04)
mode = ProtoField.uint8("ds_to_fms_udp.status_byte.mode", "Mode", base.DEC, mode_types, 0x03)
team_num = ProtoField.uint16("ds_to_fms_udp.team_num", "Team Num", base.DEC)
battery = ProtoField.float("ds_to_fms_udp.battery", "Battery Voltage", base.DEC)
ds_to_fms_udp_protocol.fields = { 
  sequence_num,
  comm_version,
  status_byte,
  estop,
  robot_comms,
  radio_ping,
  rio_ping,
  enabled,
  mode,
  team_num,
  battery
 }

function ds_to_fms_udp_protocol.dissector(buffer, pinfo, tree)
  local length = buffer:len()
  if length == 0 then return end

  pinfo.cols.protocol = ds_to_fms_udp_protocol.name

  local subtree = tree:add(ds_to_fms_udp_protocol, buffer(), "Driver Station to FMS Data")

  subtree:add(sequence_num, buffer(0,2))
  subtree:add(comm_version, buffer(2,1))

  local statbytTree = subtree:add(status_byte, buffer(3,1))
  local staybyt = buffer(3,1):uint()
  statbytTree:add(estop, buffer(3,1), bit.band(bit.rshift(staybyt, 7), 0x01))
  statbytTree:add(robot_comms, buffer(3,1), bit.band(bit.rshift(staybyt, 5), 0x01))
  statbytTree:add(radio_ping, buffer(3,1), bit.band(bit.rshift(staybyt, 4), 0x01))
  statbytTree:add(rio_ping, buffer(3,1), bit.band(bit.rshift(staybyt, 3), 0x01))
  statbytTree:add(enabled, buffer(3,1), bit.band(bit.rshift(staybyt, 2), 0x01))
  statbytTree:add(mode, buffer(3,1), bit.band(staybyt, 0x03))

  subtree:add(team_num, buffer(4,2))
  batValue = buffer(6,2):uint()
  batWhole = batValue >> 8
  batDecimal = (batValue & 0xFF) / 0xFF
  subtree:add(battery, buffer(6,2), batWhole+batDecimal)

end

local udp_port = DissectorTable.get("udp.port")
udp_port:add(1160, ds_to_fms_udp_protocol)





station_types = {
  [0] = "Red 1",
  [1] = "Red 2",
  [2] = "Red 3",
  [3] = "Blue 1",
  [4] = "Blue 2",
  [5] = "Blue 3"
}

tournament_level_types = {
  [0] = "Match Test",
  [1] = "Practice",
  [2] = "Qualification",
  [3] = "Playoff"
}

fms_to_ds_udp_protocol = Proto("fms_to_ds_udp",  "FMS to Driver Station UDP")

sequence_num = ProtoField.uint16("fms_to_ds_udp.sequence_num", "Sequence Number", base.DEC)
comm_version = ProtoField.uint8("fms_to_ds_udp.comm_version", "Comm Version", base.HEX)
control_byte = ProtoField.uint8("fms_to_ds_udp.control_byte", "Control Byte", base.HEX)
estop = ProtoField.uint8("fms_to_ds_udp.control_byte.estop", "E-Stop", base.DEC, yesno_types, 0x80)
enabled = ProtoField.uint8("fms_to_ds_udp.control_byte.enabled", "Enabled", base.DEC, yesno_types, 0x04)
mode = ProtoField.uint8("fms_to_ds_udp.control_byte.mode", "Mode", base.DEC, mode_types, 0x03)
alliance_station = ProtoField.uint8("fms_to_ds_udp.alliance_station", "Alliance Station", base.DEC, station_types)
tournament_level = ProtoField.uint8("fms_to_ds_udp.tournament_level", "Tournament Level", base.DEC, tournament_level_types)
match_num = ProtoField.uint16("fms_to_ds_udp.match_num", "Match Number", base.DEC)
play_num = ProtoField.uint8("fms_to_ds_udp.play_num", "Play Number", base.DEC)
date = ProtoField.string("fms_to_ds_udp.status_byte.date", "Date")
time_remaining = ProtoField.uint16("fms_to_ds_udp.time_remaining", "Remaining Time", base.DEC)

ds_to_fms_udp_protocol.fields = { 
  sequence_num,
  comm_version,
  control_byte,
  estop,
  enabled,
  mode,
  alliance_station,
  tournament_level,
  match_num,
  play_num,
  date,
  time_remaining
 }

function fms_to_ds_udp_protocol.dissector(buffer, pinfo, tree)
  local length = buffer:len()
  if length == 0 then return end

  pinfo.cols.protocol = fms_to_ds_udp_protocol.name

  local subtree = tree:add(fms_to_ds_udp_protocol, buffer(), "FMS to Driver Station Data")

  subtree:add(sequence_num, buffer(0,2))
  subtree:add(comm_version, buffer(2,1))

  local controlbytTree = subtree:add(control_byte, buffer(3,1))
  local controlbyt = buffer(3,1):uint()
  controlbytTree:add(estop, buffer(3,1), bit.band(bit.rshift(controlbyt, 7), 0x01))
  controlbytTree:add(enabled, buffer(3,1), bit.band(bit.rshift(controlbyt, 2), 0x01))
  controlbytTree:add(mode, buffer(3,1), bit.band(controlbyt, 0x03))

  subtree:add(alliance_station, buffer(5,1))
  subtree:add(tournament_level, buffer(6,1))
  subtree:add(match_num, buffer(7,2))
  subtree:add(play_num, buffer(9,1))
  local microseconds = buffer(10,4):uint()
  local second = buffer(14,1):uint()
  local minute = buffer(15,1):uint()
  local hour = buffer(16,1):uint()
  local day = buffer(17,1):uint()
  local month = buffer(18,1):uint()
  local year = buffer(19,1):uint() + 1900
  subtree:add(date, buffer(10,10), string.format("%02d/%02d/%04d %d:%02d:%02d:%07d", month, day, year, hour, minute, second, microseconds))
  subtree:add(time_remaining, buffer(20,2))

end

local udp_port = DissectorTable.get("udp.port")
udp_port:add(1121, fms_to_ds_udp_protocol)
udp_port:add(1120, fms_to_ds_udp_protocol)




tag_types = {
  [0x00] = "WPILib Version",
  [0x01] = "RIO Version",
  [0x02] = "DS Version",
  [0x03] = "PDP Version",
  [0x04] = "PCM Version",
  [0x05] = "CANJag Version",
  [0x06] = "CANTalon Version",
  [0x07] = "Third Party Device Version",
  [0x14] = "Event Code",
  [0x15] = "Usage Report",
  [0x16] = "Log Data",
  [0x17] = "Error and Event Data",
  [0x18] = "Team Number",
  [0x19] = "Station Info",
  [0x1a] = "Challenge Question",
  [0x1b] = "Challenge Response",
  [0x1c] = "Game Data"
}

fms_tcp_protocol = Proto("fms_to_ds_tcp",  "FMS TCP")

size = ProtoField.uint16("fms_to_ds_tcp.size", "Size", base.DEC)
tag_type = ProtoField.uint8("fms_to_ds_tcp.tag_type", "Tag Type", base.HEX, tag_types)
team_num = ProtoField.uint16("fms_to_ds_tcp.team_num", "Team Num", base.DEC)

fms_tcp_protocol.fields = {
  size,
  tag_type,
  team_num
}

function fms_tcp_protocol.dissector(buffer, pinfo, tree)

  local length = buffer:len()
  if length == 0 then return end
  if length ~= buffer:reported_len() then return 0 end
  if length > 100 then return 0 end

  local sizeInt = buffer(0, 2):uint()
  if (sizeInt > length) then
    pinfo.desegment_len = size - length
    pinfo.desegment_offset = 0
    return length
  end

  pinfo.cols.protocol = fms_tcp_protocol.name

  local subtree = tree:add(fms_tcp_protocol, buffer(), "FMS to Driver Station Data")
  subtree:add(size, buffer(0,2))
  local tagId = buffer(2,1)
  subtree:add(tag_type, tagId)

  if (tagId == 0x18) then
    subtree:add(team_num, buffer(3,2))
  end

end

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(1750, fms_tcp_protocol)