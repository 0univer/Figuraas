local TarotPg = action_wheel:newPage(TarotPg)
local BaralhoPos = vec(0, 0, 0)
local BaralhoAlt = {}
local CartasMesa = {}
local CartasIndex = { 
  vec(105, 91), --"O Louco", 
   vec(34, 0), --"O Mago", 
   vec(505, 91), --"A Sacerdotisa", 
   vec(605, 91), --"A Imperatriz", 
   vec(105, 244), --"O Imperador", 
   vec(205, 244), --"O Papa", 
   vec(305, 244), --"Os Enamorados", 
   vec(405, 244), --"O Carro", 
   vec(505, 244), --"A Força", 
   vec(605, 244), --"O Eremita", 
   vec(105, 397), --"A Roda da Fortuna", 
   vec(205, 397), --"A Justiça", 
   vec(305, 397), --"O Enforcado", 
   vec(405, 397), --"A Morte", 
   vec(505, 397), --"A Temperança", 
   vec(605, 397), --"O Diabo", 
   vec(105, 550), --"A Torre", 
   vec(205, 550), --"A Estrela", 
   vec(305, 550), --"A Lua", 
   vec(405, 550), --"O Sol", 
   vec(505, 550), --"O Julgamento",
   vec(605, 550) --"O Mundo"
} 
local McartasUv = {
    models.Tarot.WorldTarot.Cartas.Carta1.Simbol1,
    models.Tarot.WorldTarot.Cartas.Carta2.Simbol2,
    models.Tarot.WorldTarot.Cartas.Carta3.Simbol3,
    models.Tarot.WorldTarot.Cartas.Carta4.Simbol4,
    models.Tarot.WorldTarot.Cartas.Carta5.Simbol5,
    models.Tarot.WorldTarot.Cartas.Carta6.Simbol6,
    models.Tarot.WorldTarot.Cartas.Carta7.Simbol7,
    models.Tarot.WorldTarot.Cartas.Carta8.Simbol8,
    models.Tarot.WorldTarot.Cartas.Carta9.Simbol9
}
local McartasGr = {
    models.Tarot.WorldTarot.Cartas.Carta1,
    models.Tarot.WorldTarot.Cartas.Carta2,
    models.Tarot.WorldTarot.Cartas.Carta3,
    models.Tarot.WorldTarot.Cartas.Carta4,
    models.Tarot.WorldTarot.Cartas.Carta5,
    models.Tarot.WorldTarot.Cartas.Carta6,
    models.Tarot.WorldTarot.Cartas.Carta7,
    models.Tarot.WorldTarot.Cartas.Carta8,
    models.Tarot.WorldTarot.Cartas.Carta9
}
local CartasPos = {}
local CartasEscolhidas = {}
local Escolhidas = 0
local MAX_CARTAS = 3
---Baralho Aleatorio----

function GerarBaralho(cartas, quantidade)
    local disponiveis = {}

    for i, carta in ipairs(cartas) do
        disponiveis[i] = carta
    end

    local resultado = {}

    for i = 1, math.min(quantidade, #disponiveis) do
        local idx = math.random(1, #disponiveis)

        resultado[i] = disponiveis[idx]
        table.remove(disponiveis, idx)
    end

    return resultado
end

function Reembaralhar()
    if not host:isHost() then return end

    local novoBaralho = GerarBaralho(CartasIndex, 9)

    for i, carta in ipairs(novoBaralho) do
        pings.SincronizarCarta(i, carta)
    end
end

function pings.SincronizarCarta(i, carta)
    BaralhoAlt[i] = carta
    log(BaralhoAlt[i], "-", i)
end
----Selecioanar cartas e colocar-----

function pings.ColocarBaralho(x, y, z)
     BaralhoPos = vec(x, y, z)

    models.Tarot.WorldTarot:setPos(
        x * 16,
        y * 16,
        z * 16
)
end

function pings.MostrarCartas()

    local raio = 1,5      -- distância das cartas ao centro
    local anguloInicial = -65
    local anguloFinal = 65

    for i = 1, 9 do
    local t = (i - 1) / 8
    local angulo = math.rad(anguloInicial + (anguloFinal - anguloInicial) * t)

   local deslocamento = 0.1 --Distancia do baralho do meio

    local pos = vec(
    math.sin(angulo) * raio,
    math.cos(angulo) * raio - deslocamento,
    0
    )
    CartasPos[i] = BaralhoPos + pos

    McartasGr[i]:setPos(
        pos.x * 16,
        pos.y * 16,
        pos.z * 16
    )

    McartasGr[i]:setRot(0, 0, -math.deg(angulo))
    McartasGr[i]:setVisible(true)
    end
end

function EscolherCarta(i)

    if CartasEscolhidas[i] then
        return
    end

    if Escolhidas >= MAX_CARTAS then
        return
    end

    Escolhidas = Escolhidas + 1
    CartasEscolhidas[i] = true

    local pos = CartasPos[i]

    McartasGr[i]
        :setScale(1.15)
        :setPos(
            (pos.x-BaralhoPos.x)*16,
            (pos.y-BaralhoPos.y)*16+2,
            (pos.z-BaralhoPos.z)*16
        )

    sounds:playSound("minecraft:block.amethyst_block.hit")

end

events.useItem:register(function()

    if action_wheel:isEnabled() then
        return
    end

    local eye = player:getPos() + vec(0,player:getEyeHeight(),0)
    local dir = player:getLookDir()

    local melhor
    local menor = 0.22

    for i=1,9 do

        if CartasPos[i] and not CartasEscolhidas[i] then

            local centro = CartasPos[i]

            local t = (centro-eye):dot(dir)

            if t > 0 then

                local ponto = eye + dir*t

                local dist = (centro-ponto):length()

                if dist < menor then
                    menor = dist
                    melhor = i
                end

            end

        end

    end

    if melhor then
        EscolherCarta(melhor)
        return true
    end

end)
----Modelo Cartas----
function pings.CartasUv(Cart,Cm)
    local invertida = math.random(1,2) == 2

    McartasUv[Cart]:setUVPixels(CartasMesa[Cm])

    if invertida then
        McartasGr[Cart]:setRot(90, 180, 0) -- gira 180°
    else
        McartasGr[Cart]:setRot(90, 0, 0) -- normal
    end
end

----ActionWheel------
local function init()
   local page = action_wheel:getCurrentPage()
   if not page then
      page = action_wheel:newPage()
      action_wheel:setPage(page)
   end
   page:newAction()
    :title("Tarot")
    :item("purple_wool")
    :onLeftClick(
        function()
          action_wheel:setPage(TarotPg)
        end  
    )
    TarotPg:newAction(4)
    :title("Voltar e tirar baralho")
    :item("minecraft:barrier")
    :onLeftClick(function()

    end
)


   events.TICK:remove(init)
end
events.TICK:register(init)

TarotPg:newAction(5)
    :title("Randomizar")
    :item("red_wool")
    :onLeftClick(
        function()
          Reembaralhar()
        end  
    )
TarotPg:newAction(6)
    :title("Revelar")
    :item("magenta_wool")
    :onLeftClick(
        function()
          
        end  
    )

TarotPg:newAction(7)
    :title("Colocar Baralho")
    :item("minecraft:book")
    :onLeftClick(function()
        local eye = player:getPos() + vec(0, player:getEyeHeight(), 0)
        local dir = player:getLookDir()

    local block, hitPos, side = raycast:block(eye, eye + dir * 10)

    if block then
      pings.ColocarBaralho(
    math.floor(hitPos.x) + 0.5,
    math.floor(hitPos.y),
    math.floor(hitPos.z) + 0.5
)
    end

    

    end)
TarotPg:newAction(8)
    :title("Distribuir")
    :item("minecraft:paper")
    :onLeftClick(function()

        if not host:isHost() then return end

        pings.MostrarCartas()

    end)
