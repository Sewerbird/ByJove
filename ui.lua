function travel_dialog(here,destination)
  local slf = interface()
  local w = 64
  local h = 64
  local l_x = 32
  local t_y = 32
  local c_x = 64
  local fuel_need = gs[here].fuel_cost[destination]
  local trip_time = fuel_need/6
  local has_the_fuel =gs['player'].business.fuel_tank_used >= fuel_need 
  slf._current_splat= has_the_fuel and 'ok_button' or 'cancel_button'
  local text = "Travelling to\n"..gs[destination].planet.."\nFuel needed:"..fuel_need.."\nDays: "..flr(trip_time).." days"
  slf._splat = splat('background',{ x=l_x,y=t_y,w=w,h=h,c_b=13,c_f=1,text = text,t_center=false, at_x=2, at_y=2})
  slf._splats = define_splats({
    header = { x=c_x-32,y=t_y-10,w=30,h=10,text="Travel?",c_b=13,c_f=1 },
    no_fuel = { hidden=has_the_fuel,x=c_x,y=t_y+h/2,text="Not enough fuel",c_t=8},
    ok_button = { right = 'cancel_button', x=c_x-32,y=t_y+h,w=30,h=10,text="okay",c_b=13,c_f=1,active=has_the_fuel,hidden=not has_the_fuel,
      execute = function() 
        sfx(38)
        gs[gs.cs]:pop_interface(2) --pop dialog and map interface
        --TODO go to ship scene instead
        gs['player'].business.fuel_tank_used -= fuel_need
        gs['player'].business.fuel_tank_free += fuel_need
        load_station(destination)
      end
    },
    cancel_button = { left = 'ok_button', x=c_x+2,y=t_y+h,w=30,h=10,text="cancel",c_b=13,c_f=1,active=not has_the_fuel,
      execute = function() 
        sfx(37)
        gs[gs.cs]:pop_interface() 
      end
    }
  })
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
  local planet = planets[gs[current_station].planet]
  slf._current_splat='planet_'..gs[current_station].planet
  slf.draw = function(me)
    camera(0,0)
    cls()
    for v in all(stars) do
      circ(v.x*127,v.y*127,0,5)
    end
    circfill(127,-64,128,15)
    circfill(120,-70,128,4)
    print("Travel to where?", 60,4,12)
  end
  ask_travel = function(tgt)
    return function()
      if tgt == current_station then
        sfx(37)
        gs[gs.cs]:pop_interface()
      else
        sfx(38)
        gs[gs.cs].destination_planet = tgt
        gs[gs.cs].travel_dialog = travel_dialog(current_station,tgt)
        gs[gs.cs]:push_interface('travel_dialog')
      end
    end
  end
  slf._splat = splat('background',{ x=l_x,y=t_y,w=w,h=h,c_f=0 })
  slf._splats = define_splats({
    planet_io = {s_circle=true,r=10,down="planet_europa",x=planets.io.x,y=planets.io.y,sprite=planets.io.sprite_id,text='io',at_y=12,s_w=2,s_h=2,c_ba=12,w=16,h=16,execute=ask_travel('station_io')},
    planet_europa = {s_circle=true,r=10,down="planet_ganymede",up="planet_io",x=planets.europa.x,y=planets.europa.y,sprite=planets.europa.sprite_id,text='europa',at_y=12,s_w=2,s_h=2,c_ba=12,w=16,h=16,execute=ask_travel('station_europa')},
    planet_ganymede = {s_circle=true,r=10,up="planet_europa",down="planet_callisto",x=planets.ganymede.x,y=planets.ganymede.y,sprite=planets.ganymede.sprite_id,text='ganymede',at_y=12,s_w=2,s_h=2,c_ba=12,w=16,h=16,execute=ask_travel('station_ganymede')},
    planet_callisto = {s_circle=true,r=10,up="planet_ganymede",x=planets.callisto.x,y=planets.callisto.y,sprite=planets.callisto.sprite_id,text='callisto',at_y=12,s_w=2,s_h=2,c_ba=12,w=16,h=16,execute=ask_travel('station_callisto')},
    ur_here = {sprite=112,x=planet.x+20,y=planet.y+8,at_x=10,at_y=8,c_t=11,text="yOU ARE\nhERE",t_center=false},
  })
  slf._splats[slf._current_splat].active = true
  return slf
end

function trading_interface(trader_tag,active_splat)
  -- A trade dialog
  local slf = interface()
  local w = 90
  local h = 50
  local c_x = 64+uix
  local l_x = 64-w/2
  local t_y = 64-h/2+uiy
  local trader_business = gs[trader_tag].business
  local player_business = gs['player'].business
  local my_trade_goods = {}
  for good in all(trade_goods) do
    if gs[trader_tag].business[good] ~= nil then
      add(my_trade_goods,good)
    end
  end
  slf.update = function(me)
    if btnp(4) then
      sfx(37)
    end
  end
  slf._current_splat=active_splat or 'buy_'..my_trade_goods[1]
  slf._splat = splat('trading_interface',{x=l_x-2,y=t_y,w=w,h=h,c_f=1,c_b=13})
  slf._splats = define_splats({
    nameplate = { x=l_x,y=t_y-10,w=40,h=9,text="Trade",c_b=13,c_f=1,c_t=11 },
    them_header = { x=l_x,y=t_y,w=20,h=9,text="them",c_t=9 },
    sell_header = { x=l_x+20,y=t_y,w=20,h=9,text="sell",c_t=11 },
    buy_header = { x=l_x+50,y=t_y,w=20,h=9,text="buy",c_t=8 },
    ship_header = { x=l_x+70,y=t_y,w=20,h=9,text="ship",c_t=9 },
    wallet_balance = { x=c_x,y=t_y+h,w=40,h=9,text="$"..flr(player_business.balance*1000),c_b=13,c_f=1,c_t=11 },
    tonnage_balance = { x=c_x,y=t_y+h+10,w=40,h=9,text=""..player_business.cargo_used.."/"..player_business.cargo_space.."t",c_b=13,c_f=1,c_t=11 },
  })
  local i = 1
  for good in all(my_trade_goods) do
    reevaluate_price(trader_tag,good)
    slf._splats['them_'..good] = splat('them_'..good,{x=l_x,y=t_y+i*10,w=20,h=9,text=""..trader_business[good].stock })
    slf._splats['sell_'..good] = splat('sell_'..good,
      {x=l_x+20,y=t_y+i*10,w=20,h=9,c_ba=7,
      text="$"..flr(trader_business[good].buy_price),active=("sell_"..good)==slf._current_splat,
      right='buy_'..my_trade_goods[i],up=i>1 and 'sell_'..my_trade_goods[i-1] or nil, down=i<#my_trade_goods and 'sell_'..my_trade_goods[i+1] or nil,
      execute=sell_to_trader_action(trader_tag,good)})
    slf._splats['tag_'..good] = splat('tag_'..good, {x=l_x+40,y=t_y+i*10,w=10,h=9,sprite=trade_good_info[good].sprite_id })
    slf._splats['buy_'..good] = splat('buy_'..good,
      {x=l_x+50,y=t_y+i*10,w=20,h=9,c_ba=7,
      text="$"..flr(trader_business[good].sell_price),active=("buy_"..good)==slf._current_splat,
      left='sell_'..my_trade_goods[i],up=i>1 and 'buy_'..my_trade_goods[i-1] or nil, down=i<#my_trade_goods and 'buy_'..my_trade_goods[i+1] or nil,
      execute=buy_from_trader_action(trader_tag,good)
    })
    slf._splats['amt_'..good] = splat('amt_'..good,{x=l_x+70,y=t_y+i*10,w=20,h=9,text=good=='fuel' and ""..gs['player'].business.fuel_tank_used or ""..player_business[good].stock})
    i+=1
  end
  return slf
end

function tolling_interface()
  -- A tolling dialog to bar/allow entrance to station
  local slf = interface()
  local player_business = gs['player'].business
  local prompt = ""
  if gs['customs'].is_blocking then
    if player_business.balance >= 0.1 then --k$
      prompt = "tHERE IS A \nDOCKING FEE\nTO ENTER THE\nSTARPORT.\n\nIT IS 100$"
    else
      prompt = "yOU DON'T SEEM\nTO BE ABLE\nTO AFFORD\nTHE DOCKING\nFEE of $100"
    end
  else
    prompt = "yOU ARE FREE \nTO PASS.\n\ncARRY ON,\nCITIZEN"
  end
  slf._current_splat='pay_customs'
  slf._splat = splat('text_area', {text=prompt,at_x=2,at_y=2,x=30+uix,y=30+uiy,w=64,h=64,c_f=1,c_b=13,t_center=false})
  slf._splats = define_splats({
    pay_customs= {x=62+uix,y=uiy+94-11,a_x=20,w=40,h=9,c_f=1,c_b=13,text="ok",active=true},
    wallet= { x=64+uix,y=94+uiy,w=20,h=9,text="$"..(player_business.balance*1000),c_b=13,c_f=1,c_t=11 },
  })
  slf.update = function(me)
    if btnp(4) then
      sfx(37)
      gs[gs.cs]:pop_interface()
    end
    if btnp(5) then 
      if gs['customs'].is_blocking and gs['player'].business.balance >= customs_amount then
        gs['player'].business.balance -= customs_amount
        gs['customs'].is_blocking = false
        gs[gs.cs].tolling = tolling_interface()
        sfx(38)
      else
        sfx(37)
      end
      gs[gs.cs]:pop_interface()
    end
  end
  return slf
end

function wandering_interface(moffx, moffy)
  local slf = interface()
  slf._current_splat='player'
  --TODO the list of actors really needs to come from somewhere else...
  slf.actors = {'player','customs','trader','fueler','travel_console'}
  slf._splat = nil
  slf._splats = define_splats({
    player= {ref='player',w=8,h=8},
    customs= {ref='customs',text='customs',at_y=8,w=8,h=8},
    trader= {ref='trader',text='trader',at_y=8,w=8,h=8},
    fueler= {ref='fueler',text='fueler',at_y=8,w=8,h=8},
    travel_console= {ref='travel_console',text='travel',at_y=8,w=8,h=8},
    a_prompt= {ref='a_prompt',a_y=8,w=8,h=8},
  })
  slf.update = function(me)
    --Handle Motion
    local dx = 0
    local dy = 0
    if btn(0) then dx -= 1 end
    if btn(1) then dx += 1 end
    if btn(2) then dy -= 1 end
    if btn(3) then dy += 1 end
    --Check collision with actors
    local bumped = false
    local player = {
      x = moffx*8 + gs['player'].x + dx,
      y = moffy*8 + gs['player'].y + dy,
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
    if not bumped then
      --Check collision with map
      if not cmap(player) then
        gs['player'].x += dx
        gs['player'].y += dy
      else
        player.x -= dx
        if not cmap(player) then
          gs['player'].y+= dy
        else
          player.x += dx
          player.y -= dy
          if not cmap(player) then
            gs['player'].x+= dx
          end
        end
      end
    end
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
      sfx(35)
      if me.target_npc == "customs" then
        gs[gs.cs].tolling = tolling_interface(slf._current_splat)
        sfx(38)
        gs[gs.cs]:push_interface('tolling')
      end
      if me.target_npc == "trader" then
        gs[gs.cs].trading = trading_interface(me.target_npc)
        sfx(38)
        gs[gs.cs]:push_interface('trading')
      end
      if me.target_npc == "fueler" then
        gs[gs.cs].trading = trading_interface(me.target_npc)
        sfx(38)
        gs[gs.cs]:push_interface('trading')
      end
      if me.target_npc == "travel_console" then
        gs[gs.cs].travelling = travelling_interface(slf._current_splat)
        sfx(38)
        gs[gs.cs]:push_interface('travelling')
      end
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
    uix = clamp(gs['player'].x-64,0,s.mx1*8-127)
    uiy = clamp(gs['player'].y-64,0,s.my1*8-127)
    camera(uix, uiy)
    for v in all(stars) do
      circ(mod(ticker/10+v.x*255,s.mx1*8),sin(ticker/5000)*10+v.y*s.my1*8,0,5)
    end
    palt(0,false)
    palt(14,true)
    pal(5,s.wall_color)
    map(s.mx0,s.my0,0,0,s.mx1,s.my1)
    pal()
  end
  slf.update = function(me)
    ticker+=1
    music_ticker += 1
    if music_ticker > 5000 then
      music(0,300)
      music_ticker = 0
    elseif music_ticker == 1150 then
      music(8)
    end
  end
  -- Player wandering a map, able to bump into walls and interact with Things
  slf.wandering = wandering_interface(s.mx0,s.my0)
  slf:push_interface("wandering")

  return slf
end

function game_over_interface(condition, text)
  local slf = interface()
  slf._splat = nil
  slf._current_splat = "done"
  slf._splats = define_splats({
    done = {x=70,y=10,text=text,t_lines=9}
  })
  slf.draw = function(me)
    for v in all(stars) do
      circ(v.x*255,v.y*255,0,5)
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
  text = "bANKRUPT...\n\nunable to muster\nany funds from\nyour coffers\nyou find yourself\nunable to continue\n\nreset to try again"
  slf.losing = game_over_interface('bankruptcy',text)
  sfx(37)
  slf:push_interface("losing")
  return slf
end

function victory_scene()
  local slf = scene()
  gs.ticker = 0
  text = "yOU wON!\n\nhaving amassed\n$1,000,000\nyou are wealthy\nenough to\nretire\n\ncongratulations!"
  slf.winning = game_over_interface('wealthy',text)
  sfx(38)
  slf:push_interface("winning")
  return slf
end

function tutorial_interface()
  local slf = interface()
  slf._splat = nil
  slf._current_splat = "step_1"
  slf._splats = define_splats({
    tutorial_player = {ref='tutorial_player',w=8,h=8,sprite=7},
    tutorial_travel_console = {ref='tutorial_travel_console',x=80,y=50,w=8,h=8,sprite=12},
    step_1 = {x=64,y=80,text="Move around with your arrow keys"},
    step_2 = {x=64,y=80,text="Your goal is to\nmake $10,000 by\ntrading on the\nJovian moons.",t_lines=4},
    step_3 = {x=64,y=80,sprite=9,as_x=16,hidden=true,text="When you see '   ', \npress x to interact",t_lines=2,h=8},
    step_4 = {x=64,y=80,text="To exit a dialog,\npress o at any time.\n\nDo so now to begin!",t_lines=3},
    a_prompt = {ref='a_prompt',a_y=8,w=8,h=8},
  })
  slf.update = function(me)
    --Handle Motion
    local dx = 0
    local dy = 0
    if btn(0) then dx -= 1 end
    if btn(1) then dx += 1 end
    if btn(2) then dy -= 1 end
    if btn(3) then dy += 1 end
    --Check collision with actors and fake walls
    local player = {
      x = gs['tutorial_player'].x + (gs['tutorial_player'].y==50 and dx or 0),
      y = gs['tutorial_player'].y + dy,
      w = gs['tutorial_player'].w,
      h = gs['tutorial_player'].h,
    }
    gs['tutorial_player'].x = clamp(player.x,40,76)
    gs['tutorial_player'].y = clamp(player.y,50,player.x == 40 and 66 or 50)
    slf._splats.step_1.hidden = true
    slf._splats.step_2.hidden = true
    slf._splats.step_3.hidden = true
    slf._splats.step_4.hidden = true
    --Show travel console prompt
    local console_distance = dsto(player,gs['tutorial_travel_console'])
    if console_distance > 10 then
      gs['a_prompt'].x = -100
      gs['a_prompt'].y = -100
    else
      gs['a_prompt'].x = gs['tutorial_travel_console'].x
      gs['a_prompt'].y = gs['tutorial_travel_console'].y
    end
    --Handle tutorial messages
    if console_distance > 40 then
      slf._current_splat = "step_1"
      slf._splats['step_1'].hidden = false
    elseif console_distance > 10 then
      slf._current_splat = "step_2"
      slf._splats['step_2'].hidden = false
    elseif (slf._current_splat == "step_3" and not btnp(5)) or (slf._current_splat == "step_2" and console_distance <= 10) then
      slf._current_splat = "step_3"
      slf._splats['step_3'].hidden = false
    elseif (slf._current_splat == "step_4" and not btnp(4)) or (slf._current_splat == "step_3" and btnp(5)) then
      slf._current_splat = "step_4"
      slf._splats['step_4'].hidden = false
    elseif slf._current_splat == "step_4" and btnp(4) then
      gs.starport_scene = starport_scene("station_ganymede")
      gs.cs = "starport_scene"
    else
    end
  end
  return slf
end

function tutorial_scene()
  local slf = scene()
  slf.draw = function(me)
    map(64,0,32,42-8,8,5)
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
  slf._splats = define_splats({
    subtitle = {x=64,y=80,text="bY jOVE"},
    continue = {down="new_game",x=80,y=96,at_x=2,at_y=2,text="cONTINUE",w=34,h=8,c_ba=7,c_t=6,t_center=false},
    new_game = {x=80,y=110,at_x=2,at_y=2,text="nEW gAME",w=34,h=8,c_ba=7,active=true,t_center=false,execute=function()
      gs.tutorial_scene = tutorial_scene()
      gs.cs = "tutorial_scene"
    end}
  })
  return slf
end

function start_scene()
  local slf = scene()
  slf.draw = function(me)
    srand(0)
    for i=0,300 do
      circ(mod(ticker/10+rnd()*256,256),sin(ticker/5000)*10+rnd()*127,0,7)
    end
    circfill(64,120,64,15)
    circfill(64,127,64,4)
  end
  slf.starting = starting_interface()
  slf:push_interface("starting")
  return slf
end

