-- MQTT
function MQMessage(c, t, m)
  if t == "WaferFrame/Mode" then
    ChangeMode(m)
  elseif t == "WaferFrame/Brightness" then
    MB = tonumber(m)
  end
end

function InitMQTT()
  Q = mqtt.Client("WaferFrame")
  Q:connect("mi_kasa", OnConnected)
end

function OnConnected()
  Q:subscribe("WaferFrame/+", 0)
  Q:on("message", MQMessage)
end