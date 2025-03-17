local gameplay = {}
function gameplay.load()
    -- โหลดภาพผี
    ghostImage = love.graphics.newImage("pic/Ghost1.png")

    -- ปรับขนาดภาพผีให้เป็น 1/6 ของจอ
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local imgWidth, imgHeight = ghostImage:getDimensions()
    scale = (screenWidth / 4) / imgWidth

    -- ปุ่มสุ่มการ์ด
    button = {
        x = screenWidth - 120,
        y = screenHeight - 60,
        width = 100,
        height = 40,
        text = "card"
    }

    -- อัตราส่วน A4 (กว้าง : สูง)
    local aspectRatio = 1.414

    -- กำหนดความกว้างและสูงของช่องสี่เหลี่ยมแนวนอนให้เป็นอัตราส่วน A4
    boxWidth = screenWidth / 12
    boxHeight = boxWidth * aspectRatio
    boxSpacing = 10
    boxOffset = 20

    -- กล่องแนวนอน (เรียงซ้ายไปขวา)
    boxes = {}
    for i = 1, 5 do
        table.insert(boxes, {
            x = button.x - (boxWidth + boxSpacing) * (6 - i) - boxOffset,
            y = button.y + button.height - boxHeight,
            width = boxWidth,
            height = boxHeight,
            card = nil -- ยังไม่มีการ์ดในช่อง
        })
    end

    -- รายการการ์ดทั้งหมด (ใส่ภาพของคุณในโฟลเดอร์ pic/)
    cardPool = {
        "pic/bee.png",
        "pic/flower.png",
        "pic/sun.png",
        "pic/people.png",
        "pic/water.png"
    }

    -- โหลดภาพการ์ดทั้งหมดล่วงหน้า
    cardImages = {}
    for _, path in ipairs(cardPool) do
        cardImages[path] = love.graphics.newImage(path)
    end

    -- ช่องแนวตั้ง (ปรับให้ติดขวาของผี)
    verticalBoxWidth = screenWidth / 8
    verticalBoxHeight = verticalBoxWidth * aspectRatio
    verticalBoxSpacing = 10
    verticalBoxes = {}

    -- เลื่อนตำแหน่งของ verticalBoxes ให้ติดขอบขวาของผี
    local ghostX = 50 + ghostImage:getWidth() * scale  -- ทำให้ช่องเริ่มติดขวาของผี
    local targetBottomY = button.y + button.height - boxHeight  -- กำหนดตำแหน่ง Y ให้เป็นตำแหน่งเดียวกับปุ่ม
    local offsetY = 30
    local lastBoxBottomY = targetBottomY - offsetY
    local lastBoxY = lastBoxBottomY - verticalBoxHeight
    local totalHeight = verticalBoxHeight * 3 + verticalBoxSpacing * 2
    local firstBoxY = lastBoxY - totalHeight + verticalBoxHeight

    for i = 0, 2 do
        local boxY = firstBoxY + (verticalBoxHeight + verticalBoxSpacing) * i
        table.insert(verticalBoxes, {
            x = ghostX,  -- ตำแหน่ง X เริ่มจากขวาของผี
            y = boxY,
            width = verticalBoxWidth,
            height = verticalBoxHeight
        })
    end
end


-- ฟังก์ชันสุ่มการ์ดเพิ่มในกล่องแนวนอน
function gameplay.addCard()
    -- ตรวจสอบว่าช่องเต็มหรือยัง
    local isFull = true
    for i = 5, 1, -1 do
        if boxes[i].card == nil then
            isFull = false
            break
        end
    end

    if isFull then
        print("เต็มแล้ว! เคลียร์การ์ดก่อนสุ่มใหม่")
        return
    end

    -- สุ่มการ์ดใหม่จาก cardPool
    local randomIndex = love.math.random(1, #cardPool)
    local newCard = cardPool[randomIndex]

    -- ใส่การ์ดในช่องว่างขวาสุด
    for i = 5, 1, -1 do
        if boxes[i].card == nil then
            boxes[i].card = newCard
            print("สุ่มได้:", newCard)
            break
        end
    end
end

-- ฟังก์ชันลบการ์ดทั้งหมดใน boxes
function gameplay.clearCards()
    for i = 1, 5 do
        boxes[i].card = nil
    end
    print("เคลียร์การ์ดเรียบร้อย")
end

function gameplay.draw()
    local screenWidth, screenHeight = love.graphics.getDimensions()

    -- วาดพื้นหลังไล่สี
    for i = 0, screenHeight do
        local colorFactor = i / screenHeight
        love.graphics.setColor(0.3 * (1 - colorFactor), 0, 0.5 * (1 - colorFactor))
        love.graphics.rectangle("fill", 0, i, screenWidth, 1)
    end

    -- วาดรูปผี
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(ghostImage, 50, screenHeight / 2 - (ghostImage:getHeight() * scale) / 2, 0, scale, scale)

    -- วาดกล่องแนวนอนและรูปการ์ด
    for _, box in ipairs(boxes) do
        -- กล่อง
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", box.x, box.y, box.width, box.height)

        -- วาดการ์ดถ้ามีในกล่อง
        if box.card then
            local cardImage = cardImages[box.card]
            if cardImage then
                local imgW, imgH = cardImage:getDimensions()

                -- คำนวณอัตราขยาย (รักษาสัดส่วน A4 หรือรูปอะไรก็ตาม)
                local scale = math.min(box.width / imgW, box.height / imgH)

                -- ขนาดภาพหลังปรับ scale
                local drawW = imgW * scale
                local drawH = imgH * scale

                -- คำนวณตำแหน่งให้อยู่กลางกล่อง
                local drawX = box.x + (box.width - drawW) / 2
                local drawY = box.y + (box.height - drawH) / 2

                -- วาดการ์ด
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(cardImage, drawX, drawY, 0, scale, scale)
            end
        end
    end

    -- วาดกล่องแนวตั้ง
    for _, vbox in ipairs(verticalBoxes) do
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", vbox.x, vbox.y, vbox.width, vbox.height)
    end

    -- วาดปุ่มสุ่มการ์ด
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)

    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(button.text, button.x, button.y + 10, button.width, "center")
end

function gameplay.mousepressed(x, y, buttonType, istouch, presses)
    if buttonType == 1 then -- คลิกซ้าย
        if x >= button.x and x <= button.x + button.width and
           y >= button.y and y <= button.y + button.height then
            gameplay.addCard()
        end
    elseif buttonType == 2 then -- คลิกขวา
        gameplay.clearCards()
    end
end

return gameplay
