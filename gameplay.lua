local gameplay = {}

function gameplay.load()
    -- โหลดภาพผี
    ghostImage = love.graphics.newImage("pic/Ghost1.png")

    local screenWidth, screenHeight = love.graphics.getDimensions()
    local imgWidth, imgHeight = ghostImage:getDimensions()
    scale = (screenWidth / 4) / imgWidth


    button = {
        x = screenWidth - 120,
        y = screenHeight - 60,
        width = 100,
        height = 40,
        text = "card"
    }

    local aspectRatio = 1.414

    boxWidth = screenWidth / 12
    boxHeight = boxWidth * aspectRatio
    boxSpacing = 10
    boxOffset = 20

    boxes = {}
    for i = 1, 5 do
        table.insert(boxes, {
            x = button.x - (boxWidth + boxSpacing) * (6 - i) - boxOffset,
            y = button.y + button.height - boxHeight,
            width = boxWidth,
            height = boxHeight,
            card = nil
        })
    end

    cardPool = {
        "pic/bee1.png", "pic/flower1.png", "pic/sun1.png", "pic/people1.png", "pic/water1.png",
        "pic/bee2.png", "pic/flower2.png", "pic/sun2.png", "pic/people2.png", "pic/water2.png",
        "pic/bee3.png", "pic/flower3.png", "pic/sun3.png", "pic/people3.png", "pic/water3.png"
    }
    specialCardPool = {
        "pic/bee0.png", "pic/flower0.png", "pic/sun0.png", "pic/people0.png", "pic/water0.png"
    }

    cardImages = {}
    for _, path in ipairs(cardPool) do
        cardImages[path] = love.graphics.newImage(path)
    end

    verticalBoxWidth = screenWidth / 8
    verticalBoxHeight = verticalBoxWidth * aspectRatio
    verticalBoxSpacing = 10
    verticalBoxes = {}

    local ghostX = 50 + ghostImage:getWidth() * scale
    local firstBoxY = 10  -- ปรับตำแหน่งช่องแนวตั้งให้ห่างจากขอบจอ 10 พิกเซล

    for i = 0, 2 do
        local boxY = firstBoxY + (verticalBoxHeight + verticalBoxSpacing) * i
        table.insert(verticalBoxes, {
            x = ghostX,
            y = boxY,
            width = verticalBoxWidth,
            height = verticalBoxHeight,
            card = nil
        })
    end
end


function gameplay.addCard()
    local isFull = true
    for i = 5, 1, -1 do
        if boxes[i].card == nil then
            isFull = false
            break
        end
    end

    if isFull then
        print("เต็มแล้ว! โปรดเลือกการ์ดออกก่อน")
        return
    end

    local usedCards = {}
    for _, box in ipairs(boxes) do
        if box.card then
            usedCards[box.card] = true
        end
    end
    for _, vbox in ipairs(verticalBoxes) do
        if vbox.card then
            usedCards[vbox.card] = true
        end
    end

    local availableCards = {}
    for _, card in ipairs(cardPool) do
        if not usedCards[card] then
            table.insert(availableCards, card)
        end
    end

    if #availableCards == 0 then
        print("ไม่มีการ์ดให้สุ่มแล้ว!")
        return
    end

    local randomIndex = love.math.random(1, #availableCards)
    local newCard = availableCards[randomIndex]

    for i = 5, 1, -1 do
        if boxes[i].card == nil then
            boxes[i].card = newCard
            print("สุ่มได้:", newCard)
            break
        end
    end
end

function gameplay.addToVerticalBoxAndRemoveFromHorizontal(card, boxIndex)
    -- หาช่องแนวตั้งที่ว่าง
    for i = 1, 3 do
        if verticalBoxes[i].card == nil then
            verticalBoxes[i].card = card
            print("ย้ายไปช่องแนวตั้ง:", card)

            -- ลบการ์ดออกจากแนวนอน
            boxes[boxIndex].card = nil
            return
        end
    end

    print("ช่องแนวตั้งเต็มแล้ว!")
end

function gameplay.draw()
    local screenWidth, screenHeight = love.graphics.getDimensions()

    for i = 0, screenHeight do
        local colorFactor = i / screenHeight
        love.graphics.setColor(0.3 * (1 - colorFactor), 0, 0.5 * (1 - colorFactor))
        love.graphics.rectangle("fill", 0, i, screenWidth, 1)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(ghostImage, 50, screenHeight / 2 - (ghostImage:getHeight() * scale) / 2, 0, scale, scale)

    for _, box in ipairs(boxes) do
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", box.x, box.y, box.width, box.height)

        if box.card then
            local cardImage = cardImages[box.card]
            if cardImage then
                local imgW, imgH = cardImage:getDimensions()
                local scale = math.min(box.width / imgW, box.height / imgH)
                local drawW = imgW * scale
                local drawH = imgH * scale
                local drawX = box.x + (box.width - drawW) / 2
                local drawY = box.y + (box.height - drawH) / 2

                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(cardImage, drawX, drawY, 0, scale, scale)
            end
        end
    end

    for _, vbox in ipairs(verticalBoxes) do
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", vbox.x, vbox.y, vbox.width, vbox.height)

        if vbox.card then
            local cardImage = cardImages[vbox.card]
            if cardImage then
                local imgW, imgH = cardImage:getDimensions()
                local scale = math.min(vbox.width / imgW, vbox.height / imgH)
                local drawW = imgW * scale
                local drawH = imgH * scale
                local drawX = vbox.x + (vbox.width - drawW) / 2
                local drawY = vbox.y + (vbox.height - drawH) / 2

                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(cardImage, drawX, drawY, 0, scale, scale)
            end
        end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)

    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(button.text, button.x, button.y + 10, button.width, "center")
end

function gameplay.mousepressed(x, y, buttonType, istouch, presses)
    if buttonType == 1 then
        if x >= button.x and x <= button.x + button.width and
           y >= button.y and y <= button.y + button.height then
            gameplay.addCard()
        else
            for index, box in ipairs(boxes) do
                if box.card and
                   x >= box.x and x <= box.x + box.width and
                   y >= box.y and y <= box.y + box.height then
                    gameplay.addToVerticalBoxAndRemoveFromHorizontal(box.card, index)
                    break
                end
            end
        end
    end
end

return gameplay
