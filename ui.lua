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
    x=c_x,y=t_y+h,w=40,h=9,t_center=true,text="$"..player_business.balance,c_b=13,c_f=1,c_t=11
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
        printh("Selling "..good)
        local amount = btn(0) and 5 or 1
        if gs['player'].business[good].stock >= amount then
          gs['player'].business[good].stock -= amount
          gs['player'].business.cargo_free += amount*trade_good_info[good].bulk
          gs['player'].business.cargo_used -= amount*trade_good_info[good].bulk
          gs['player'].business.balance += gs['trader'].business[good].buy_price * amount
          gs['trader'].business[good].stock += amount
          reevaluate_price('trader',good)
          gs[gs.cs].trading = trading_interface(slf._current_splat)
        else
          --TODO bzzt
          printh("Not enough money")
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
        printh("Buying "..good)
        local amount = btn(1) and 5 or 1
        if gs['player'].business.balance > gs['trader'].business[good].sell_price * amount 
          and gs['player'].business.cargo_free >= trade_good_info[good].bulk * amount
          and gs['trader'].business[good].stock >= amount then
          gs['player'].business[good].stock += amount
          gs['player'].business.cargo_free -= amount*trade_good_info[good].bulk
          gs['player'].business.cargo_used += amount*trade_good_info[good].bulk
          gs['player'].business.balance -= gs['trader'].business[good].sell_price * amount
          gs['trader'].business[good].stock -= amount
          reevaluate_price('trader',good)
          gs[gs.cs].trading = trading_interface(slf._current_splat)
        end
      end})
    slf._splats['amt_'..good] = splat('amt_'..good,
    {x=l_x+70,y=t_y+i*10,w=20,h=9,text=""..player_business[good].stock,t_center=true
    })
    if i > 1 then 
      slf._splats['buy_'..good].up='buy_'..trade_goods[i-1] 
      slf._splats['buy_'..good].left='sell_'..trade_goods[i] 
      slf._splats['sell_'..good].up='sell_'..trade_goods[i-1] 
      slf._splats['sell_'..good].right='buy_'..trade_goods[i] 
    end
    if i < #trade_goods then 
      slf._splats['buy_'..good].down='buy_'..trade_goods[i+1] 
      slf._splats['buy_'..good].left='sell_'..trade_goods[i] 
      slf._splats['sell_'..good].down='sell_'..trade_goods[i+1] 
      slf._splats['sell_'..good].right='buy_'..trade_goods[i] 
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
    if player_business.balance >= 100 then
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
      x=64,y=94,w=20,h=9,t_center=true,text="$"..player_business.balance,c_b=13,c_f=1,c_t=11
    })
  }
  slf.draw = function(me)
    me._splats.text_area:draw()
    me._splats.pay_customs:draw()
    me._splats.wallet:draw()
  end
  slf.update = function(me)
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
      if gs['customs'].is_blocking and gs['player'].business.balance >= 100 then
        gs['player'].business.balance -= 100
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
  slf.actors = {'player','customs','trader','fueler','armsdealer'}
  slf._splats = {
    ['player']= splat('player',{ref='player',w=8,h=8}),
    ['customs']= splat('customs',{ref='customs',text='customs',t_center=true,at_y=8,w=8,h=8}),
    ['trader']= splat('trader',{ref='trader',text='trader',t_center=true,at_y=8,w=8,h=8}),
    ['fueler']= splat('fueler',{ref='fueler',text='fueler',t_center=true,at_y=8,w=8,h=8}),
    ['armsdealer']= splat('armsdealer',{ref='armsdealer',text='armsdealer',t_center=true,at_y=8,w=8,h=8}),
    ['a_prompt']= splat('a_prompt',{ref='a_prompt',t_center=true,a_y=8,w=8,h=8})
  }
  slf.draw = function(me)
    me._splats.player:draw()
    me._splats.customs:draw()
    me._splats.trader:draw()
    me._splats.fueler:draw()
    me._splats.armsdealer:draw()
    me._splats.a_prompt:draw()
  end
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
        gs[gs.cs]:push_interface('talking')
      end
      if me.target_npc == "trader" then
        gs[gs.cs]:push_interface('trading')
      end
    end
    --Update sub elements
    for _,splat in pairs(me._splats) do
      splat:update()
    end
  end
  return slf
end

function starport_scene()
  --TODO this is gamestate stuff, shouldn't end up living here
  gs['player'].x = 36
  gs['player'].y = 24
  gs['player'].business = {
    tax_rate = 0,
    balance = 10000,
    cargo_space = 100,
    cargo_used = 0,
    cargo_free = 100,
    medicine = {base_price = 10, desired_stock = 64, stock = 0, buy_price = 20, sell_price = 10},
    parcels = {base_price = 10, desired_stock = 64, stock = 0, buy_price = 20, sell_price = 10},
    machinery = {base_price = 10, desired_stock = 64, stock = 0, buy_price = 20, sell_price = 10},
    electronics = {base_price = 10, desired_stock = 64, stock = 0, buy_price = 20, sell_price = 10},
  }
  gs['customs'].x = 43
  gs['customs'].y = 64
  gs['customs'].is_blocking = true
  gs['trader'].x = 20
  gs['trader'].y = 24
  gs['trader'].business = {
    tax_rate = 50,
    medicine = {base_price = 10, desired_stock = 64, stock = 127, buy_price = 20, sell_price = 10},
    parcels = {base_price = 10, desired_stock = 64, stock = 10, buy_price = 20, sell_price = 10},
    machinery = {base_price = 10, desired_stock = 64, stock = 10, buy_price = 20, sell_price = 10},
    electronics = {base_price = 10, desired_stock = 64, stock = 10, buy_price = 20, sell_price = 10},
  }
  gs['armsdealer'].x = 40
  gs['armsdealer'].y = 24
  gs['fueler'].x = 100
  gs['fueler'].y = 64
  gs['a_prompt'] = {x=100,y=100,sprite=9}
  local mx0,my0,mx1,my1 = 0,0,20,20

  --Actual Starport Scene code
  local slf = scene()
  slf.draw = function(me)
    srand(0)
    ticker+=1
    for i=0,300 do
      circ(mod(ticker+rnd()*127,127),sin(ticker/500)*10+rnd()*127,0,7)
    end
    palt(0,false)
    palt(14,true)
    map(mx0,my0,0,0,mx1,my1)
    palt()
    for k in all(me._interfaces) do
      me[k]:draw()
    end
  end
  -- Player wandering a map, able to bump into walls and interact with Things
  slf.wandering = wandering_interface()
  slf.talking = talk_interface()
  slf.trading = trading_interface()
  slf:push_interface("wandering")

  return slf
end

function start_scene()
  local result = scene()
  result.update = function(me)
    if btnp(4) then me:pop_interface() end
    if btnp(5) then me[me:interface()]:execute() end
    for k in all(me._interfaces) do
      me[k]:update()
    end
  end
  return result
end
