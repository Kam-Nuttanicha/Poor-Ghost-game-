-- main.lua
local gameplay = require("gameplay")
local state = "menu" -- เพิ่มตัวแปรสถานะ

function love.load()
    love.graphics.setBackgroundColor(0, 0, 0) -- พื้นหลังสีดำ
    button = {x = 300, y = 200, width = 200, height = 50, text = "Start"}
end

function love.update(dt)
    
end

function love.draw()
    if state == "menu" then
        -- วาดปุ่ม
        love.graphics.setColor(1, 1, 1) -- สีขาว
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
        
        -- วาดข้อความบนปุ่ม
        love.graphics.setColor(0, 0, 0) -- ตัวหนังสือสีดำ
        love.graphics.printf(button.text, button.x, button.y + 15, button.width, "center")
    elseif state == "gameplay" then
        gameplay.draw()
    end
end

function love.mousepressed(x, y, buttonType, istouch, presses)
    if state == "menu" and buttonType == 1 then -- ตรวจสอบว่าคลิกซ้าย
        if x >= button.x and x <= button.x + button.width and y >= button.y and y <= button.y + button.height then
            state = "gameplay"
            gameplay.load()
        end
    elseif state == "gameplay" then
        gameplay.mousepressed(x, y, buttonType, istouch, presses)
    end
end
