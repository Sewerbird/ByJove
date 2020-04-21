function sgn(num)
  return(num>0 and 1 or (num<0 and -1 or 0))
end

function mod(num,range)
  return num-flr(num/range)*range
end

function dsto(a,b)
  local dx=a.x-b.x
  local dy=a.y-b.y
  return sqrt(dx*dx+dy*dy)
end

function clamp(x,a,b)
  return min(max(x,a),b)
end

function rects_intersect(a,b)
  return not(a.x+a.w<b.x or b.x+b.w<a.x or a.y+a.h<b.y or b.y+b.h<a.y)
end

function fmget(x,y,f)
  return fget(mget(x,y),f)
end

function cmap(o)
  local x1,x2=o.x/8,(o.x+7)/8
  local y1,y2=o.y/8,(o.y+7)/8
  return fmget(x1,y1,0) or fmget(x1,y2,0) or fmget(x2,y2,0) or fmget(x2,y1,0) 
end

-- Gamestate Support

function reevaluate_price(trader, trade_good)
  local in_stock = gs[trader].business[trade_good].stock
  local tax_rate = gs[trader].business.tax_rate --margin the trader wants sales to you
  local desired_stock = gs[trader].business[trade_good].desired_stock --quantity desired
  local base_price = gs[trader].business[trade_good].base_price --price when satisifed
  local f0 = 4 --base_price multiplier when none in stock. TODO Make this trader specific.... need a 'ln' function.
  local base_price_multiplier = f0*2.71828^((in_stock/desired_stock)*neg_ln[f0])
  local today_buy = base_price * base_price_multiplier * (1-tax_rate/100)
  local today_sell = base_price * base_price_multiplier * (1+tax_rate/100)
  gs[trader].business[trade_good].buy_price = today_buy
  gs[trader].business[trade_good].sell_price = today_sell
end

function run_trader_update(trader)
  for trade_good in all(trade_goods) do
    if gs[trader].business[trade_good] then
      gs[trader].business[trade_good].stock = flr(rnd()*(128))
    end
  end
end

function check_end_conditions()
  local end_condition = nil
  if gs.player.business.balance < customs_amount then
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

function load_station(destination)
  gs.cs = 'starport'
  --Load up station-specific attributes for the station actors
  local s = gs[destination]
  for key, spec in pairs(s.actors) do
    if gs[key] then
      gs[key].x = spec.x
      gs[key].y = spec.y
      gs[key].is_blocking = spec.is_blocking
      if spec.business then
        gs[key].business = spec.business
      end
      if gs[key].business ~= nil and gs[key].business.volatile and key ~= 'player' then
        run_trader_update(key)
      end
    end
  end
  --Load the station
  gs.starport = starport_scene(destination)
end

function buy_from_trader_action(trader_tag,good)
  return function(me)
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
      gs[gs.cs].trading = trading_interface(trader_tag,'buy_'..good)
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
      gs[gs.cs].trading = trading_interface(trader_tag,'buy_'..good)
      sfx(34)
    else
      sfx(32)
      printh("Not enough stock, space, and/or money")
    end
  end
end

function sell_to_trader_action(trader_tag,good)
  return function(me)
    local amount = btn(0) and 5 or 1
    if good == 'fuel' and gs['player'].business.fuel_tank_used >= amount then
      gs['player'].business.fuel.stock -= amount
      gs['player'].business.fuel_tank_free += amount*trade_good_info[good].bulk
      gs['player'].business.fuel_tank_used -= amount*trade_good_info[good].bulk
      gs['player'].business.balance += gs[trader_tag].business[good].buy_price * amount / 1000
      gs[trader_tag].business[good].stock += amount
      reevaluate_price(trader_tag,good)
      gs[gs.cs].trading = trading_interface(trader_tag,'sell_'..good)
      sfx(33)
    elseif good ~= 'fuel' and gs['player'].business[good].stock >= amount then
      gs['player'].business[good].stock -= amount
      gs['player'].business.cargo_free += amount*trade_good_info[good].bulk
      gs['player'].business.cargo_used -= amount*trade_good_info[good].bulk
      gs['player'].business.balance += gs[trader_tag].business[good].buy_price * amount / 1000
      gs[trader_tag].business[good].stock += amount
      reevaluate_price(trader_tag,good)
      gs[gs.cs].trading = trading_interface(trader_tag,'sell_'..good)
      sfx(33)
    else
      sfx(32)
      printh("Not enough stock")
    end
  end
end

-- UI Support
function scene()
  local slf = {
    _interfaces = {},
  }
  slf.interface = function(me)
    return me._interfaces[#me._interfaces]
  end
  slf.push_interface = function(me, interface_tag)
    add(me._interfaces, interface_tag)
  end
  slf.pop_interface = function(me,depth)
    depth = depth or 1
    for i =1,depth do
      if(#me._interfaces == 1) then return end
      del(me._interfaces, me._interfaces[#me._interfaces])
    end
  end
  slf._draw = function(me)
    if me.draw then me:draw() end
    for k in all(me._interfaces) do
      me[k]:_draw()
    end
  end
  slf._update = function(me)
    if me.update then me:update() end
    me[me:interface()]:_update()
  end
  slf.execute = function(me)
    me[me:interface()]:execute()
  end
  return slf
end

function interface()
  local slf = {
    _input_map = {},
    _splats = {},
    _splat = {},
    _current_splat = '',
  }
  slf.current_splat = function(me)
    return me._splats[me._current_splat]
  end
  slf._draw = function(me)
    if me._splat ~= nil then me._splat:draw() end
    if me.draw then me:draw() end
    for _,splat in pairs(me._splats) do
      splat:draw()
    end
  end
  slf._update = function(me)
    camera(0,0)
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
    if btnp(4) then gs[gs.cs]:pop_interface() end
    if btnp(5) then me:execute() end
    if me.update then me:update() end
    for _,splat in pairs(me._splats) do
      splat:update()
    end
  end
  slf.execute = function(me)
    me._splats[me._current_splat]:execute()
  end
  return slf
end

function splat(tag,o)
  local me = o
  for k,v in pairs({
    tag=tag, ref='',
    x=0,y=0,w=0,h=0,a_x=0,a_y=0, --box
    c_f=0,c_b=0,c_fa=nil,c_ba=14, --colors
    sprite=-1,as_x=0,as_y=0,at_x=0,at_y=0,s_w=1,s_h=1,s_f=false, --sprite
    text='',t_center=true,c_t=7, --text
    active=false,selectable=false,s_circle=false,r=0,
    down=nil,up=nil,left=nil,right=nil,
    update=function(me)
      if(gs[me.ref]) then
        me.text = gs[me.ref].text or me.text
        me.sprite = gs[me.ref].sprite or me.sprite
        me.x = gs[me.ref].x or me.x
        me.y = gs[me.ref].y or me.y
      end
    end,
    execute=function(me)printh("Executing tag "..me.tag)end
  }) do me[k] = o[k] or v end
  me.draw=function(me)
    if me.hidden then return end
    local c_f = me.active and me.c_fa or me.c_f
    local c_b = me.active and me.c_ba or me.c_b
    local l_x,t_y=me.x-me.a_x,me.y-me.a_y
    local r_x,b_y=l_x+me.w,t_y+me.h
    local t_lines=me.t_lines
    if t_lines == nil then t_lines = 1 end
    local txt_x=me.t_center and (l_x+(me.w/2)-#(me.text)/(t_lines)*2) or l_x
    local txt_y=me.t_center and (t_y+flr(me.h/2)-2) or t_y
    if c_f>0 then rectfill(l_x,t_y,r_x,b_y,me.active and me.c_fa or me.c_f) end
    if me.sprite then
      for i_x=0,me.s_w-1 do
        for i_y=0,me.s_h-1 do
          spr(me.sprite+i_x+(i_y*16),l_x+i_x*8+me.as_x,t_y+i_y*8+me.as_y)
        end
      end
    end
    if me.c_t>0 then print(me.text,txt_x+me.at_x,txt_y+me.at_y,me.c_t) end
    if me.active and me.s_circle then
      circ(l_x+me.w/2-1,t_y+me.w/2-1,me.r,me.c_ba) 
    end
    if not me.s_circle and not me.active and me.c_b > 0 then 
      rect(l_x,t_y,r_x,b_y,me.active and me.c_ba or me.c_b) 
    end
    if not me.s_circle and me.active and me.c_ba > 0 then 
      rect(l_x,t_y,r_x,b_y,me.active and me.c_ba or me.c_b) 
    end
  end
  return me
end

function define_splats(mapping)
  local splats = {}
  for k,v in pairs(mapping) do
    splats[k] = splat(k,v)
  end
  return splats
end
