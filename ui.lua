function travel_dialog(destination)
  local slf = interface()
  local w = 64
  local h = 64
  local l_x = 32
  local t_y = 32
  local c_x = 64
  slf._current_splat='ok_button'
  slf._splat = splat('background',{ x=l_x,y=t_y,w=w,h=h,c_b=13,c_f=1 })
  slf._splats = {
    header = splat('header',{
      x=c_x-32,y=t_y-10,w=30,h=10,text="Travel?",c_b=13,c_f=1,t_center=true,
    }),
    explain = splat('explain',{
      x=c_x-32,y=t_y,at_x=2,at_y=2,w=w,text = "Travelling to\n"..destination.."\nCosts: $100\nDays: 3 days",h=h,c_b=13,c_f=1,
    }),
    ok_button = splat('ok_button',{
      right = 'cancel_button', x=c_x-32,y=t_y+h,w=30,h=10,text="okay",c_b=13,c_f=1,active=true,t_center=true,
      execute = function() 
        gs[gs.cs]:pop_interface(2) --pop dialog and map interface
        --TODO go to ship scene instead
        gs.cs = 'starport'
        --Load up station-specific attributes for the station actors
        local s = gs['station_'..destination]
        for key, spec in pairs(s.actors) do
          if gs[key] then
            gs[key].x = spec.x
            gs[key].y = spec.y
            gs[key].is_blocking = spec.is_blocking
            if spec.business then
              gs[key].business = spec.business
            end
          end
        end
        --Load the station
        gs.starport = starport_scene('station_'..destination)
      end
    }),
    cancel_button = splat('cancel_button',{
      left = 'ok_button', x=c_x+2,y=t_y+h,w=30,h=10,text="cancel",c_b=13,c_f=1,t_center=true,
      execute = function() 
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
  local l_x = 0
  local t_y = 0
  local c_x = 64 -8
  slf._current_splat='planet_io'
  slf.draw = function(me)
    cls()
    srand(0)
    for i=1,200 do
      circ(rnd()*127,rnd()*127,0,5)
    end
    circfill(127,-64,128,15)
    circfill(120,-70,128,4)
    if me._splat ~= nil then me._splat:draw() end
    for _,splat in pairs(me._splats) do
      splat:draw()
    end
  end
  slf._splat = splat('background',{ x=l_x,y=t_y,w=w,h=h,c_b=1,c_f=0 })
  ask_travel = function(tgt)
    return function()
      gs[gs.cs].destination_planet = tgt
      gs[gs.cs].travel_dialog = travel_dialog(tgt)
      gs[gs.cs]:push_interface('travel_dialog')
    end
  end
  slf._splats = {
    planet_io = splat('planet_io',{down="planet_europa",x=c_x,y=64-45,sprite=planets['io'].sprite_id,text='io',t_center=true,at_y=12,s_w=2,s_h=2,c_ba=13,w=16,h=16,execute=ask_travel('io')}),
    planet_europa = splat('planet_europa',{down="planet_ganymede",up="planet_io",x=c_x-30,y=64-25,sprite=planets['europa'].sprite_id,text='europa',t_center=true,at_y=12,s_w=2,s_h=2,c_ba=13,w=16,h=16,execute=ask_travel('europa')}),
    planet_ganymede = splat('planet_ganymede',{up="planet_europa",down="planet_callisto",x=c_x-40,y=64+10,sprite=planets['ganymede'].sprite_id,text='ganymede',t_center=true,at_y=12,s_w=2,s_h=2,c_ba=13,w=16,h=16,execute=ask_travel('ganymede')}),
    planet_callisto = splat('planet_callisto',{up="planet_ganymede",x=c_x-25,y=64+40,sprite=planets['callisto'].sprite_id,text='callisto',t_center=true,at_y=12,s_w=2,s_h=2,c_ba=13,w=16,h=16,execute=ask_travel('callisto')}),
  }
  slf._splats[slf._current_splat].active = true
  return slf
end

function trading_interface(active_splat)
  --TODO make this based on merchant business object
  local trader_business = gs['trader'].business
  local player_business = gs['player'].business
  -- A trade dialog
  local slf = interface()
  local w = 90
  local h = 50
  local l_x = 64-w/2
  local t_y = 64-h/2
  local c_x = 64
  slf._current_splat=active_splat or 'buy_'..trade_goods[1]
  slf.update = function(me)
    if btnp(4) then
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
  slf._splat = splat('trading_interface',{x=l_x-2,y=t_y,w=w,h=h,c_f=1,c_b=13})
  local i = 1
  slf._splats['nameplate'] = splat('nameplate', {
    x=l_x,y=t_y-10,w=40,h=9,t_center=true,text="Trade",c_b=13,c_f=1,c_t=11
  })
  slf._splats['them_header'] = splat('them_header',{
    x=l_x,y=t_y,w=20,h=9,text="them",t_center=true,c_t=9
  })
  slf._splats['sell_header'] = splat('sell_header',{
    x=l_x+20,y=t_y,w=20,h=9,text="sell",t_center=true,c_t=11
  })
  slf._splats['buy_header'] = splat('buy_header',{
    x=l_x+50,y=t_y,w=20,h=9,text="buy",t_center=true,c_t=8
  })
  slf._splats['ship_header'] = splat('ship_header',{
    x=l_x+70,y=t_y,w=20,h=9,text="ship",t_center=true,c_t=9
  })
  slf._splats['wallet_balance'] = splat('wallet_balance', {
    x=c_x,y=t_y+h,w=40,h=9,t_center=true,text="$"..flr(player_business.balance*1000),c_b=13,c_f=1,c_t=11
  })
  slf._splats['tonnage_balance'] = splat('tonnage_balance', {
    x=c_x,y=t_y+h+10,w=40,h=9,t_center=true,text=""..player_business.cargo_used.."/"..player_business.cargo_space.."t",c_b=13,c_f=1,c_t=11
  })
  for good in all(trade_goods) do
    reevaluate_price('trader',good)
    slf._splats['them_'..good] = splat('them_'..good,
    {x=l_x,y=t_y+i*10,w=20,h=9,text=""..trader_business[good].stock,t_center=true
    })
    slf._splats['sell_'..good] = splat('sell_'..good,
      {x=l_x+20,y=t_y+i*10,w=20,h=9,c_ba=7,
      text="$"..flr(trader_business[good].buy_price),t_center=true,active="sell_"..good==slf._current_splat,
      execute=function(me)
        local amount = btn(0) and 5 or 1
        if gs['player'].business[good].stock >= amount then
          gs['player'].business[good].stock -= amount
          gs['player'].business.cargo_free += amount*trade_good_info[good].bulk
          gs['player'].business.cargo_used -= amount*trade_good_info[good].bulk
          gs['player'].business.balance += gs['trader'].business[good].buy_price * amount / 1000
          gs['trader'].business[good].stock += amount
          reevaluate_price('trader',good)
          gs[gs.cs].trading = trading_interface(slf._current_splat)
        else
          --TODO bzzt
          printh("Not enough stock")
        end
      end
      })
    slf._splats['tag_'..good] = splat('tag_'..good,
    {x=l_x+40,y=t_y+i*10,w=10,h=9,sprite=trade_good_info[good].sprite_id
    })
    slf._splats['buy_'..good] = splat('buy_'..good,
      {x=l_x+50,y=t_y+i*10,w=20,h=9,c_ba=7,
      text="$"..flr(trader_business[good].sell_price),t_center=true,active="buy_"..good==slf._current_splat,
      execute=function(me)
        local amount = btn(1) and 5 or 1
        if gs['player'].business.balance > gs['trader'].business[good].sell_price * amount / 1000
          and gs['player'].business.cargo_free >= trade_good_info[good].bulk * amount
          and gs['trader'].business[good].stock >= amount then
          gs['player'].business[good].stock += amount
          gs['player'].business.cargo_free -= amount*trade_good_info[good].bulk
          gs['player'].business.cargo_used += amount*trade_good_info[good].bulk
          gs['player'].business.balance -= gs['trader'].business[good].sell_price * amount / 1000
          gs['trader'].business[good].stock -= amount
          reevaluate_price('trader',good)
          gs[gs.cs].trading = trading_interface(slf._current_splat)
        else
          --TODO bzzt
          printh("Not enough stock, space, and/or money")
        end
      end})
    slf._splats['amt_'..good] = splat('amt_'..good,
    {x=l_x+70,y=t_y+i*10,w=20,h=9,text=""..player_business[good].stock,t_center=true
    })
    slf._splats['buy_'..good].left='sell_'..trade_goods[i] 
    slf._splats['sell_'..good].right='buy_'..trade_goods[i] 
    if i > 1 then 
      slf._splats['buy_'..good].up='buy_'..trade_goods[i-1] 
      slf._splats['sell_'..good].up='sell_'..trade_goods[i-1] 
    end
    if i < #trade_goods then 
      slf._splats['buy_'..good].down='buy_'..trade_goods[i+1] 
      slf._splats['sell_'..good].down='sell_'..trade_goods[i+1] 
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
    ['text_area']=splat('text_area',{text=prompt,at_x=2,at_y=2,x=30,y=30,w=64,h=64,c_f=1,c_b=13}),
    ['pay_customs']= splat('pay_customs',{x=62,y=30+64-11,a_x=20,w=40,h=9,c_f=1,c_b=13,text="ok",t_center=true,active=true}),
    ['wallet'] = splat('wallet_balance', {
      x=64,y=94,w=20,h=9,t_center=true,text="$"..(player_business.balance*1000),c_b=13,c_f=1,c_t=11
    })
  }
  slf.draw = function(me)
    me._splats.text_area:draw()
    me._splats.pay_customs:draw()
    me._splats.wallet:draw()
  end
  slf.update = function(me)
    if btnp(4) then
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
  slf.actors = {'player','customs','trader','fueler','armsdealer','travel_console'}
  slf._splat = nil
  slf._splats = {
    ['player']= splat('player',{ref='player',w=8,h=8}),
    ['customs']= splat('customs',{ref='customs',text='customs',t_center=true,at_y=8,w=8,h=8}),
    ['trader']= splat('trader',{ref='trader',text='trader',t_center=true,at_y=8,w=8,h=8}),
    ['fueler']= splat('fueler',{ref='fueler',text='fueler',t_center=true,at_y=8,w=8,h=8}),
    ['armsdealer']= splat('armsdealer',{ref='armsdealer',text='armsdealer',t_center=true,at_y=8,w=8,h=8}),
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
    if 
      not bumped and
      not fget(mget((x+dx+7)/8, y/8),0) and
      not fget(mget((x+dx)/8, y/8),0) and
      not fget(mget((x+dx+7)/8, (y+7)/8),0) and
      not fget(mget((x+dx)/8, (y+7)/8),0) then
      gs['player'].x += dx
    end
    x = gs['player'].x
    if 
      not fget(mget(x/8, (y+dy+7)/8),0) and
      not fget(mget(x/8, (y+dy)/8),0) and
      not fget(mget((x+7)/8, (y+dy+7)/8),0) and
      not fget(mget((x+7)/8, (y+dy)/8),0) then
      gs['player'].y += dy
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
      if me.target_npc == "customs" then
        gs[gs.cs].talking = talk_interface(slf._current_splat)
        gs[gs.cs]:push_interface('talking')
      end
      if me.target_npc == "trader" then
        gs[gs.cs].trading = trading_interface(slf._current_splat)
        gs[gs.cs]:push_interface('trading')
      end
      if me.target_npc == "travel_console" then
        gs[gs.cs].travelling = travelling_interface(slf._current_splat)
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
  -- Starport methods
  slf.draw = function(me)
    srand(0)
    for i=0,300 do
      circ(mod(ticker/10+rnd()*256,256),sin(ticker/5000)*10+rnd()*127,0,7)
    end
    palt(0,false)
    palt(14,true)
    map(s.mx0,s.my0,0,0,s.mx1,s.my1)
    palt()
    for k in all(me._interfaces) do
      me[k]:draw()
    end
    print("Welcome to "..station_tag,0,0,8)
  end
  slf.update = function(me)
    ticker+=1
    camera(clamp(min(gs['player'].x-64,s.mx1*8-127),s.mx0*8,s.mx1*8),clamp(gs['player'].y-64),s.my0*8,s.my1*8)
    me[me:interface()]:update()
  end
  -- Player wandering a map, able to bump into walls and interact with Things
  slf.wandering = wandering_interface()
  slf.talking = talk_interface()
  slf.trading = trading_interface()
  slf.travelling = travelling_interface()
  slf.travel_dialog = travel_dialog('io')
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
    srand(0)
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
    srand(0)
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
    exit_btn = splat("exit_btn", {x=64,y=80,text="To exit a dialog,\npress o at any time",t_lines=2,t_center=true,hidden=true}),
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
    gs['tutorial_player'].y = clamp(player.y,50,player.x == 40 and 64 or 50)
    if dsto(player,gs['tutorial_travel_console']) < 10 then
      gs['a_prompt'].x = gs['tutorial_travel_console'].x
      gs['a_prompt'].y = gs['tutorial_travel_console'].y
      if not slf._splats.exit_btn.hidden and btnp(4) then
        gs.starport_scene = starport_scene("station_ganymede")
        gs.cs = "starport_scene"
      end
      if slf._splats.exit_btn.hidden then
        slf._splats.dpad.hidden = true
        slf._splats.act_btn.hidden = false
        if btnp(5) then
          slf._splats.dpad.hidden = true
          slf._splats.act_btn.hidden = true
          slf._splats.exit_btn.hidden = false
        end
      end
    else
      gs['a_prompt'].x = -100
      gs['a_prompt'].y = -100
      slf._splats.dpad.hidden = false
      slf._splats.exit_btn.hidden = true
      slf._splats.act_btn.hidden = true
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
    map(0,32,32,42,8,4)
    for k in all(me._interfaces) do
      me[k]:draw()
    end
  end
  slf.teaching = tutorial_interface()
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
    srand(0)
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
    if btnp(4) then me:pop_interface() end
    if btnp(5) then me[me:interface()]:execute() end
    for k in all(me._interfaces) do
      me[k]:update()
    end
  end
  slf.starting = starting_interface()
  slf:push_interface("starting")
  return slf
end

function check_end_conditions()
  local end_condition = nil
  --if player can't afford to get into a station
  if gs.player.business.balance < customs_amount then
    --and player is locked out
    if gs.customs.is_blocking then
      printh("Player has lost via lockout")
      end_condition = "Refugee"
      gs.bankruptcy_scene = bankruptcy_scene()
      gs.cs = "bankruptcy_scene"
    end
  elseif gs.player.business.balance > win_amount then
    printh("Player has won via cash")
    end_condition = "Victory"
    gs.victory_scene = victory_scene()
    gs.cs = "victory_scene"
  end
  return end_condition
end
