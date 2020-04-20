function travel_dialog(here,destination)
  local slf = interface()
  local w = 64
  local h = 64
  local l_x = 32
  local t_y = 32
  local c_x = 64
  local fuel_need = calculate_fuel_need(here,destination)
  local trip_time = fuel_need/6
  local has_the_fuel =gs['player'].business.fuel_tank_used >= fuel_need 
  slf._current_splat= has_the_fuel and 'ok_button' or 'cancel_button'
  slf._splat = splat('background',{ x=l_x,y=t_y,w=w,h=h,c_b=13,c_f=1 })
  slf._splats = {
    header = splat('header',{
      x=c_x-32,y=t_y-10,w=30,h=10,text="Travel?",c_b=13,c_f=1,t_center=true,
    }),
    explain = splat('explain',{
      x=c_x-32,y=t_y,at_x=2,at_y=2,w=w,text = "Travelling to\n"..destination.."\nFuel needed:"..fuel_need.."\nDays: "..flr(trip_time).." days",h=h,c_b=13,
    }),
    no_fuel = splat('no_fuel',{
      hidden=has_the_fuel,x=c_x,y=t_y+h/2,text="Not enough fuel",c_t=8,t_center=true
    }),
    ok_button = splat('ok_button',{
      right = 'cancel_button', x=c_x-32,y=t_y+h,w=30,h=10,text="okay",c_b=13,c_f=1,active=has_the_fuel,hidden=not has_the_fuel,t_center=true,
      execute = function() 
        sfx(38)
        gs[gs.cs]:pop_interface(2) --pop dialog and map interface
        --TODO go to ship scene instead
        gs['player'].business.fuel_tank_used -= fuel_need
        gs['player'].business.fuel_tank_free += fuel_need
        load_station(destination)
      end
    }),
    cancel_button = splat('cancel_button',{
      left = 'ok_button', x=c_x+2,y=t_y+h,w=30,h=10,text="cancel",c_b=13,c_f=1,t_center=true,active=not has_the_fuel,
      execute = function() 
        sfx(37)
        gs[gs.cs]:pop_interface() 
      end
    })
  }
  return slf
end

function travelling_interface(active_splat)
  local slf = interface()
  local w = 127
  local h = 127
  local l_x = 0+uix
  local t_y = 0+uiy
  local c_x = 64 -8
  local scene = gs.cs
  local current_station = gs[scene].current_station
  slf._current_splat='planet_'..gs[current_station].planet
  slf.draw = function(me)
    cls()
    srand(ticker)
    for i=1,200 do
      circ(rnd()*127,rnd()*127,0,5)
    end
    circfill(127,-64,128,15)
    circfill(120,-70,128,4)
    if me._splat ~= nil then me._splat:draw() end
    for _,splat in pairs(me._splats) do
      splat:draw()
    end
    print("Travel to where?", 60,4,12)
  end
  slf._splat = splat('background',{ x=l_x,y=t_y,w=w,h=h,c_f=0 })
  ask_travel = function(tgt)
    return function()
      if tgt == gs[gs[gs.cs].current_station].planet then
        sfx(37)
        gs[gs.cs]:pop_interface()
      else
        sfx(38)
        gs[gs.cs].destination_planet = tgt
        gs[gs.cs].travel_dialog = travel_dialog(gs[current_station].planet,tgt)
        gs[gs.cs]:push_interface('travel_dialog')
      end
    end
  end
  local station = gs[gs[gs.cs].current_station]
  printh(station.planet)
  local planet = planets[station.planet]
  printh(planet.x..","..planet.y)
  local io = planets.io
  local europa = planets.europa
  local ganymede = planets.ganymede
  local callisto = planets.callisto
  slf._splats = {
    planet_io = splat('planet_io',{s_circle=true,r=10,down="planet_europa",x=io.x,y=io.y,sprite=planets['io'].sprite_id,text='io',t_center=true,at_y=12,s_w=2,s_h=2,c_ba=12,w=16,h=16,execute=ask_travel('io')}),
    planet_europa = splat('planet_europa',{s_circle=true,r=10,down="planet_ganymede",up="planet_io",x=europa.x,y=europa.y,sprite=planets['europa'].sprite_id,text='europa',t_center=true,at_y=12,s_w=2,s_h=2,c_ba=12,w=16,h=16,execute=ask_travel('europa')}),
    planet_ganymede = splat('planet_ganymede',{s_circle=true,r=10,up="planet_europa",down="planet_callisto",x=ganymede.x,y=ganymede.y,sprite=planets['ganymede'].sprite_id,text='ganymede',t_center=true,at_y=12,s_w=2,s_h=2,c_ba=12,w=16,h=16,execute=ask_travel('ganymede')}),
    planet_callisto = splat('planet_callisto',{s_circle=true,r=10,up="planet_ganymede",x=callisto.x,y=callisto.y,sprite=planets['callisto'].sprite_id,text='callisto',t_center=true,at_y=12,s_w=2,s_h=2,c_ba=12,w=16,h=16,execute=ask_travel('callisto')}),
    ur_here = splat('ur_here',{sprite=112,x=planet.x+20,y=planet.y+8,at_x=10,at_y=8,c_t=11,text="yOU ARE\nhERE"})
  }
  printh(slf._current_splat)
  printh(slf._splats[slf._current_splat])
  slf._splats[slf._current_splat].active = true
  return slf
end

function trading_interface(trader_tag,active_splat)
  --TODO make this based on merchant business object
  local trader_business = gs[trader_tag].business
  local player_business = gs['player'].business
  -- A trade dialog
  local slf = interface()
  local w = 90
  local h = 50
  local l_x = 64-w/2
  local t_y = 64-h/2
  local c_x = 64
  local my_trade_goods = {}
  for good in all(trade_goods) do
    if gs[trader_tag].business[good] ~= nil then
      add(my_trade_goods,good)
    end
  end
  printh(my_trade_goods[1])
  slf._current_splat=active_splat or 'buy_'..my_trade_goods[1]
  slf.update = function(me)
    if btnp(4) then
      sfx(37)
      gs[gs.cs]:pop_interface()
    end
    local dir = nil
    if btnp(0) then dir = 'left' end
    if btnp(1) then dir = 'right' end
    if btnp(2) then dir = 'up' end
    if btnp(3) then dir = 'down' end
    if dir and me._current_splat and me._splats[me._current_splat][dir] != nil then
      me._splats[me._current_splat].active = false
      me._current_splat = me._splats[me._current_splat][dir]
      me._splats[me._current_splat].active = true
    end
    if btnp(5) then me:execute() end
    for _,splat in pairs(me._splats) do
      splat:update()
    end
  end
  slf._splats = {}
  slf._splat = splat('trading_interface',{x=uix+l_x-2,y=uiy+t_y,w=w,h=h,c_f=1,c_b=13})
  local i = 1
  slf._splats['nameplate'] = splat('nameplate', {
    x=uix+l_x,y=uiy+t_y-10,w=40,h=9,t_center=true,text="Trade",c_b=13,c_f=1,c_t=11
  })
  slf._splats['them_header'] = splat('them_header',{
    x=uix+l_x,y=uiy+t_y,w=20,h=9,text="them",t_center=true,c_t=9
  })
  slf._splats['sell_header'] = splat('sell_header',{
    x=uix+l_x+20,y=uiy+t_y,w=20,h=9,text="sell",t_center=true,c_t=11
  })
  slf._splats['buy_header'] = splat('buy_header',{
    x=uix+l_x+50,y=uiy+t_y,w=20,h=9,text="buy",t_center=true,c_t=8
  })
  slf._splats['ship_header'] = splat('ship_header',{
    x=uix+l_x+70,y=uiy+t_y,w=20,h=9,text="ship",t_center=true,c_t=9
  })
  slf._splats['wallet_balance'] = splat('wallet_balance', {
    x=uix+c_x,y=uiy+t_y+h,w=40,h=9,t_center=true,text="$"..flr(player_business.balance*1000),c_b=13,c_f=1,c_t=11
  })
  slf._splats['tonnage_balance'] = splat('tonnage_balance', {
    x=uix+c_x,y=uiy+t_y+h+10,w=40,h=9,t_center=true,text=""..player_business.cargo_used.."/"..player_business.cargo_space.."t",c_b=13,c_f=1,c_t=11
  })
  for good in all(my_trade_goods) do
    reevaluate_price(trader_tag,good)
    slf._splats['them_'..good] = splat('them_'..good,
    {x=uix+l_x,y=uiy+t_y+i*10,w=20,h=9,text=""..trader_business[good].stock,t_center=true
    })
    slf._splats['sell_'..good] = splat('sell_'..good,
      {x=uix+l_x+20,y=uiy+t_y+i*10,w=20,h=9,c_ba=7,
      text="$"..flr(trader_business[good].buy_price),t_center=true,active=("sell_"..good)==slf._current_splat,
      execute=function(me)
        local amount = btn(0) and 5 or 1
        if good == 'fuel' and gs['player'].business.fuel_tank_used >= amount then
          gs['player'].business.fuel.stock -= amount
          gs['player'].business.fuel_tank_free += amount*trade_good_info[good].bulk
          gs['player'].business.fuel_tank_used -= amount*trade_good_info[good].bulk
          gs['player'].business.balance += gs[trader_tag].business[good].buy_price * amount / 1000
          gs[trader_tag].business[good].stock += amount
          reevaluate_price(trader_tag,good)
          gs[gs.cs].trading = trading_interface(trader_tag,slf._current_splat)
          sfx(33)
        elseif good ~= 'fuel' and gs['player'].business[good].stock >= amount then
          gs['player'].business[good].stock -= amount
          gs['player'].business.cargo_free += amount*trade_good_info[good].bulk
          gs['player'].business.cargo_used -= amount*trade_good_info[good].bulk
          gs['player'].business.balance += gs[trader_tag].business[good].buy_price * amount / 1000
          gs[trader_tag].business[good].stock += amount
          reevaluate_price(trader_tag,good)
          gs[gs.cs].trading = trading_interface(trader_tag,slf._current_splat)
          sfx(33)
        else
          sfx(32)
          printh("Not enough stock")
        end
      end
      })
    slf._splats['tag_'..good] = splat('tag_'..good,
    {x=uix+l_x+40,y=uiy+t_y+i*10,w=10,h=9,sprite=trade_good_info[good].sprite_id
    })
    slf._splats['buy_'..good] = splat('buy_'..good,
      {x=uix+l_x+50,y=uiy+t_y+i*10,w=20,h=9,c_ba=7,
      text="$"..flr(trader_business[good].sell_price),t_center=true,active=("buy_"..good)==slf._current_splat,
      execute=function(me)
        local amount = btn(1) and 5 or 1
        printh("I can buy "..gs['player'].business.fuel_tank_free..' units of fuel')
        if good == 'fuel' 
          and gs['player'].business.balance > gs[trader_tag].business[good].sell_price * amount / 1000
          and gs['player'].business.fuel_tank_free >= trade_good_info[good].bulk * amount
          and gs[trader_tag].business[good].stock >= amount then
          gs['player'].business.fuel_tank_used += amount*trade_good_info[good].bulk
          gs['player'].business.fuel_tank_free -= amount*trade_good_info[good].bulk
          gs['player'].business.balance -= gs[trader_tag].business[good].sell_price * amount / 1000
          gs[trader_tag].business[good].stock -= amount
          reevaluate_price(trader_tag,good)
          gs[gs.cs].trading = trading_interface(trader_tag,slf._current_splat)
          sfx(34)
        elseif good ~= 'fuel' 
          and gs['player'].business.balance > gs[trader_tag].business[good].sell_price * amount / 1000
          and gs['player'].business.cargo_free >= trade_good_info[good].bulk * amount
          and gs[trader_tag].business[good].stock >= amount then
          gs['player'].business[good].stock += amount
          gs['player'].business.cargo_free -= amount*trade_good_info[good].bulk
          gs['player'].business.cargo_used += amount*trade_good_info[good].bulk
          gs['player'].business.balance -= gs[trader_tag].business[good].sell_price * amount / 1000
          gs[trader_tag].business[good].stock -= amount
          reevaluate_price(trader_tag,good)
          gs[gs.cs].trading = trading_interface(trader_tag,slf._current_splat)
          sfx(34)
        else
          sfx(32)
          printh("Not enough stock, space, and/or money")
        end
      end})
    slf._splats['amt_'..good] = splat('amt_'..good,
    {x=uix+l_x+70,y=uiy+t_y+i*10,w=20,h=9,text=good=='fuel' and ""..gs['player'].business.fuel_tank_used or ""..player_business[good].stock,t_center=true
    })
    slf._splats['buy_'..good].left='sell_'..my_trade_goods[i] 
    slf._splats['sell_'..good].right='buy_'..my_trade_goods[i] 
    if i > 1 then 
      slf._splats['buy_'..good].up='buy_'..my_trade_goods[i-1] 
      slf._splats['sell_'..good].up='sell_'..my_trade_goods[i-1] 
    end
    if i < #my_trade_goods then 
      slf._splats['buy_'..good].down='buy_'..my_trade_goods[i+1] 
      slf._splats['sell_'..good].down='sell_'..my_trade_goods[i+1] 
    end
    i+=1
  end
  return slf
end

function talk_interface()
  -- A talk dialog 
  local slf = interface()
  local player_business = gs['player'].business
  slf._current_splat='pay_customs'
  local prompt = ""
  if gs['customs'].is_blocking then
    if player_business.balance >= 0.1 then
      prompt = "tHERE IS A \nDOCKING FEE\nTO ENTER THE\nSTARPORT.\n\nIT IS 100$"
    else
      prompt = "yOU DON'T SEEM\nTO BE ABLE\nTO AFFORD\nTHE DOCKING\nFEE of $100"
    end
  else
    prompt = "yOU ARE FREE \nTO PASS.\n\ncARRY ON,\nCITIZEN"
  end
  slf._splats = {
    ['text_area']=splat('text_area',{text=prompt,at_x=2,at_y=2,x=30+uix,y=30+uiy,w=64,h=64,c_f=1,c_b=13}),
    ['pay_customs']= splat('pay_customs',{x=62+uix,y=uiy+30+64-11+uix,a_x=20,w=40,h=9,c_f=1,c_b=13,text="ok",t_center=true,active=true}),
    ['wallet'] = splat('wallet_balance', {
      x=64+uix,y=94+uiy,w=20,h=9,t_center=true,text="$"..(player_business.balance*1000),c_b=13,c_f=1,c_t=11
    })
  }
  slf.draw = function(me)
    me._splats.text_area:draw()
    me._splats.pay_customs:draw()
    me._splats.wallet:draw()
  end
  slf.update = function(me)
    if btnp(4) then
      sfx(37)
      gs[gs.cs]:pop_interface()
    end
    local dir = nil
    if btnp(0) then dir = 'left' end
    if btnp(1) then dir = 'right' end
    if btnp(2) then dir = 'up' end
    if btnp(3) then dir = 'down' end
    local current_splat = me:current_splat()
    if dir and current_splat and current_splat[dir] then
      me:current_splat().active = false
      me._current_splat = current_splat[dir]
      me:current_splat().active = true
    end
    if btnp(5) then 
      --TODO remove cash
      if gs['customs'].is_blocking and gs['player'].business.balance >= customs_amount then
        gs['player'].business.balance -= customs_amount
        gs['customs'].is_blocking = false
        gs[gs.cs].talking = talk_interface()
        sfx(38)
      else
        sfx(37)
      end
      gs[gs.cs]:pop_interface()
    end
  end
  return slf
end

function wandering_interface()
  local slf = interface()
  slf._current_splat='player'
  --TODO the list of actors really needs to come from somewhere else...
  slf.actors = {'player','customs','trader','fueler','travel_console'}
  slf._splat = nil
  slf._splats = {
    ['player']= splat('player',{ref='player',w=8,h=8}),
    ['customs']= splat('customs',{ref='customs',text='customs',t_center=true,at_y=8,w=8,h=8}),
    ['trader']= splat('trader',{ref='trader',text='trader',t_center=true,at_y=8,w=8,h=8}),
    ['fueler']= splat('fueler',{ref='fueler',text='fueler',t_center=true,at_y=8,w=8,h=8}),
    ['travel_console']= splat('travel_console',{ref='travel_console',text='travel',t_center=true,at_y=8,w=8,h=8}),
    ['a_prompt']= splat('a_prompt',{ref='a_prompt',t_center=true,a_y=8,w=8,h=8}),
  }
  slf.update = function(me)
    --Handle Motion
    local x = gs['player'].x
    local y = gs['player'].y
    local dx = 0
    local dy = 0
    if btn(0) then dx -= 1 end
    if btn(1) then dx += 1 end
    if btn(2) then dy -= 1 end
    if btn(3) then dy += 1 end
    --Check collision with actors
    local bumped = false
    local player = {
      x = gs['player'].x + dx,
      y = gs['player'].y + dy,
      w = gs['player'].w,
      h = gs['player'].h,
    }
    --Check collision with sprites
    for actor in all(me.actors) do
      local obj = gs[actor]
      if actor ~= 'player' and rects_intersect(obj,player) and obj.is_blocking then
        bumped = true
      end
    end
    --Check collision with map
    my_mx = x/8+moffx
    my_dmx = (4*sgn(dx)+4)/8
    my_my = y/8+moffy-1/8
    my_dmy = (4*sgn(dy)+4)/8
    my_tx1 = my_mx + my_dmx
    my_ty1 = my_my+0.5
    my_tx2 = my_mx + 0.5
    my_ty2 = my_my+my_dmy
    printh("==========")
    printh("I think I am at mget = ("..my_mx..","..my_my..")")
    printh("==========")
    if not bumped and not fget(mget(my_tx1,my_ty1),0) then
      gs['player'].x += dx
    end
    if not bumped and not fget(mget(my_tx2,my_ty2),0) then
      gs['player'].y += dy
    end
    --Check walking sound
    if dx > 0 or dx < 0 then 
      if not gs['player'].is_walking then
        gs['player'].is_walking = true
        sfx(36,60) 
      end
    end
    if dx == 0 and gs['player'].is_walking then
      gs['player'].is_walking = false
      sfx(-1,60) 
    end
    --Handle player being near an NPC
    local target_npc = nil
    for k in all(me.actors) do
      if k != 'player' then
        if dsto(gs[me._splats[k].ref], gs['player']) < 12 then
          target_npc = k
        end
      end
    end
    me.target_npc = target_npc
    if me.target_npc then
      gs['a_prompt'].x = gs[me.target_npc].x
      gs['a_prompt'].y = gs[me.target_npc].y
    else
      gs['a_prompt'].x = -100
      gs['a_prompt'].y = -100
    end
    --Handle pressing 'A' to activate an NPC
    if me.target_npc and btnp(5) then
      sfx(-1,1) 
      printh("Pressed a at "..me.target_npc)
      sfx(35)
      if me.target_npc == "customs" then
        printh("talkig to customs")
        gs[gs.cs].talking = talk_interface(slf._current_splat)
        sfx(38)
        gs[gs.cs]:push_interface('talking')
      end
      if me.target_npc == "trader" then
        printh("Talking to trader")
        gs[gs.cs].trading = trading_interface(me.target_npc)
        sfx(38)
        gs[gs.cs]:push_interface('trading')
      end
      if me.target_npc == "fueler" then
        printh("Talking to fueler")
        gs[gs.cs].trading = trading_interface(me.target_npc)
        sfx(38)
        gs[gs.cs]:push_interface('trading')
      end
      if me.target_npc == "travel_console" then
        printh("Tlaking to computer")
        gs[gs.cs].travelling = travelling_interface(slf._current_splat)
        sfx(38)
        gs[gs.cs]:push_interface('travelling')
      end
    end
    --Update sub elements
    for _,splat in pairs(me._splats) do
      splat:update()
    end
  end
  return slf
end

function starport_scene(station_tag)
  local s = gs[station_tag]
  --Actual Starport Scene code
  local slf = scene()
  slf.current_station = station_tag
  -- Starport methods
  slf.draw = function(me)
    srand(ticker)
    for i=0,500 do
      circ(mod(ticker/10+rnd()*256,256),sin(ticker/5000)*10+rnd()*256,0,7)
    end
    palt(0,false)
    palt(14,true)
    map(s.mx0,s.my0,0,0,s.mx1,s.my1)
    palt()
    for k in all(me._interfaces) do
      me[k]:draw()
    end
    --TODO
    if debug_collision and my_tx1 and my_ty1 then
      circ(my_tx1*8,my_ty1*8,0,8)
      circ(my_tx2*8,my_ty2*8,0,11)
    end
  end
  slf.update = function(me)
    ticker+=1
    music_ticker += 1
    if music_ticker > 5000 then
      --music(0,300)
      music_ticker = 0
    elseif music_ticker == 1150 then
      music(8)
    end
    uix = clamp(gs['player'].x-64,0,s.mx1*8-127)
    uiy = clamp(gs['player'].y-64,0,s.my1*8-127)
    camera( 
      uix,
      uiy
      )
    me[me:interface()]:update()
  end
  -- Player wandering a map, able to bump into walls and interact with Things
  slf.wandering = wandering_interface()
  --TODO this is terrible
  moffx = s.mx0
  moffy = s.my0
  slf:push_interface("wandering")

  return slf
end

function bankruptcy_interface()
  local slf = interface()
  slf._splat = nil
  slf._current_splat = "done"
  slf._splats = {
    done = splat("done", {x=70,y=10,text="bANKRUPT...",t_center=true}),
    line_1 = splat("line_1", {x=70,y=26,text="unable to muster",t_center=true}),
    line_2 = splat("line_2", {x=70,y=34,text="any funds from",t_center=true}),
    line_3 = splat("line_3", {x=70,y=42,text="your coffers",t_center=true}),
    line_4 = splat("line_4", {x=70,y=50,text="you find yourself",t_center=true}),
    line_5 = splat("line_5", {x=70,y=58,text="unable to continue",t_center=true}),
    line_7 = splat("line_7", {x=110,y=100,text="reset to try again",t_center=true})
  }
  slf.draw = function(me)
    srand(ticker)
    for i=0,300 do
      circ(mod(rnd()*256,256),rnd()*127,0,5)
    end
    circfill(120,7,3,10)
    circ(127,220,180,4)
    circfill(127,120,64,15)
    circfill(127,127,64,4)
    for _,splat in pairs(me._splats) do
      splat:draw()
    end
  end
  return slf
end

function bankruptcy_scene()
  local slf = scene()
  gs.ticker = 0
  slf.losing = bankruptcy_interface()
  sfx(37)
  slf:push_interface("losing")
  return slf
end

function victory_interface()
  local slf = interface()
  slf._splat = nil
  slf._current_splat = "done"
  slf._splats = {
    done = splat("done", {x=40,y=20,text="yOU wON!",t_center=true}),
    line_1 = splat("line_1", {x=40,y=36,text="having amassed",t_center=true}),
    line_2 = splat("line_2", {x=40,y=44,text="$1,000,000",t_center=true}),
    line_3 = splat("line_3", {x=40,y=52,text="you have proven",t_center=true}),
    line_4 = splat("line_4", {x=40,y=60,text="your mettle",t_center=true}),
    line_5 = splat("line_5", {x=40,y=68,text="as well as your",t_center=true}),
    line_6 = splat("line_6", {x=40,y=76,text="profitability.",t_center=true}),
    line_7 = splat("line_7", {x=100,y=100,text="congratuations!",t_center=true})
  }
  slf.draw = function(me)
    srand(ticker)
    for i=0,300 do
      circ(mod(rnd()*256,256),rnd()*127,0,5)
    end
    circfill(120,7,3,10)
    circ(127,220,180,4)
    circfill(127,120,64,15)
    circfill(127,127,64,4)
    for _,splat in pairs(me._splats) do
      splat:draw()
    end
  end
  return slf
end

function victory_scene()
  local slf = scene()
  gs.ticker = 0
  slf.winning = victory_interface()
  sfx(38)
  slf:push_interface("winning")
  return slf
end

function tutorial_interface()
  local slf = interface()
  slf._splat = nil
  slf._current_splat = "dpad"
  slf._splats = {
    dpad = splat("dpad", {x=64,y=80,text="Move around with your arrow keys",t_center=true}),
    tutorial_player = splat('tutorial_player',{ref='tutorial_player',w=8,h=8,sprite=7}),
    tutorial_travel_console = splat('tutorial_travel_console',{ref='tutorial_travel_console',x=80,y=50,w=8,h=8,sprite=12}),
    act_btn = splat("act_btn", {x=64,y=80,sprite=9,as_x=16,hidden=true,text="When you see '   ', \npress x to interact",t_center=true,t_lines=2,h=8}),
    goal_msg = splat("goal_msg", {x=64,y=80,text="Your goal is to\nmake $10,000 by\ntrading on the\nJovian moons.",t_center=true,t_lines=4,hidden=true}),
    exit_btn = splat("exit_btn", {x=64,y=80,text="To exit a dialog,\npress o at any time.\n\nDo so now to begin!",t_lines=3,t_center=true,hidden=true}),
    ['a_prompt']= splat('a_prompt',{ref='a_prompt',t_center=true,a_y=8,w=8,h=8}),
  }
  slf.update = function(me)
    --Handle Motion
    local x = gs['tutorial_player'].x
    local y = gs['tutorial_player'].y
    local dx = 0
    local dy = 0
    if btn(0) then dx -= 1 end
    if btn(1) then dx += 1 end
    if btn(2) then dy -= 1 end
    if btn(3) then dy += 1 end
    --Check collision with actors
    local player = {
      x = gs['tutorial_player'].x + (gs['tutorial_player'].y==50 and dx or 0),
      y = gs['tutorial_player'].y + dy,
      w = gs['tutorial_player'].w,
      h = gs['tutorial_player'].h,
    }
    gs['tutorial_player'].x = clamp(player.x,40,76)
    gs['tutorial_player'].y = clamp(player.y,50,player.x == 40 and 66 or 50)
    if dsto(player,gs['tutorial_travel_console']) < 10 then
      gs['a_prompt'].x = gs['tutorial_travel_console'].x
      gs['a_prompt'].y = gs['tutorial_travel_console'].y
      if not slf._splats.exit_btn.hidden and btnp(4) then
        gs.starport_scene = starport_scene("station_ganymede")
        gs.cs = "starport_scene"
      end
      if slf._splats.exit_btn.hidden then
        slf._splats.dpad.hidden = true
        slf._splats.goal_msg.hidden = true
        slf._splats.act_btn.hidden = false
        if btnp(5) then
          slf._splats.dpad.hidden = true
          slf._splats.act_btn.hidden = true
          slf._splats.exit_btn.hidden = false
        end
      end
    elseif dsto(player,gs['tutorial_travel_console']) < 40 then
      slf._splats.dpad.hidden = true
      slf._splats.act_btn.hidden = true
      slf._splats.exit_btn.hidden = true
      slf._splats.goal_msg.hidden = false
    else
      gs['a_prompt'].x = -100
      gs['a_prompt'].y = -100
      slf._splats.dpad.hidden = false
      slf._splats.exit_btn.hidden = true
      slf._splats.act_btn.hidden = true
      slf._splats.goal_msg.hidden = true
    end

    --Update sub elements
    for _,splat in pairs(me._splats) do
      splat:update()
    end
  end
  return slf
end

function tutorial_scene()
  local slf = scene()
  slf.draw = function(me)
    map(53,2,32,42,8,4)
    for k in all(me._interfaces) do
      me[k]:draw()
    end
  end
  slf.teaching = tutorial_interface()
  sfx(38)
  slf:push_interface("teaching")
  return slf
end

function starting_interface()
  local slf = interface()
  slf._splat = nil
  slf._current_splat = "new_game"
  slf._splats = {
    subtitle = splat("subtitle", {x=64,y=80,text="bY jOVE",t_center=true}),
    continue = splat("continue", {down="new_game",x=80,y=96,at_x=2,at_y=2,text="cONTINUE",w=34,h=8,c_ba=7,c_t=6}),
    new_game = splat("new_game", {x=80,y=110,at_x=2,at_y=2,text="nEW gAME",w=34,h=8,c_ba=7,active=true, execute=function()
      gs.tutorial_scene = tutorial_scene()
      gs.cs = "tutorial_scene"
    end}),
  }
  return slf
end

function start_scene()
  local slf = scene()
  slf.draw = function(me)
    srand(ticker)
    for i=0,300 do
      circ(mod(ticker/10+rnd()*256,256),sin(ticker/5000)*10+rnd()*127,0,7)
    end
    palt(0,false)
    palt(14,true)
    palt()
    circfill(64,120,64,15)
    circfill(64,127,64,4)
    for k in all(me._interfaces) do
      me[k]:draw()
    end
  end
  slf.update = function(me)
    if btnp(5) then me[me:interface()]:execute() end
    for k in all(me._interfaces) do
      me[k]:update()
    end
  end
  slf.starting = starting_interface()
  slf:push_interface("starting")
  return slf
end

