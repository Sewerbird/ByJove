function mod(num,range)
  return num-flr(num/range)*range
end

function dsto(a,b)
  local dx=(a.x-b.x)/1000
  local dy=(a.y-b.y)/1000
  distance = sqrt(dx*dx + dy*dy)
  return distance*1000
end

function clamp(x,a,b)
  return min(max(x,a),b)
end

function fmget(x,y,f)
  return fget(mget(x,y),f)
end

function rndi(n)
  return flr(rnd() * n)
end

function sample(obj)
  local keys = {}
  for k,v in pairs(obj) do
    add(keys,k)
  end
  return obj[keys[rndi(#keys)+1]]
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
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
  if gs.player.business.balance > win_amount then
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
      gs[key].sprite = spec.sprite or gs[key].sprite
      if spec.business then
        gs[key].business = spec.business
      end
      if gs[key].business ~= nil and gs[key].business.volatile and key ~= 'player' then
        run_trader_update(key)
      end
      if gs[key].insider then
        gs[key].insider_event = generate_event(gs.current_station)
        gs[key].convo = gs[key].insider_event.rumor
      end
    end
  end
  --Load the station
  gs.starport = starport_scene(destination)
end

function generate_event(here)
  local planet = here
  while planet == here do
    planet = planet_keys[rndi(#planet_keys)+1]
  end
  local event = deepcopy(sample(event_templates))
  event.rumor.p = planet
  event.rumor.g = trade_goods[rndi(#trade_goods)+1]
  return event
end

function buy_from_trader_action(trader_tag,good)
  return function(me)
    p_bus = gs.player.business
    local amount = btn(1) and 5 or 1
    local total_bulk = amount*trade_good_info[good].bulk
    printh("I can buy "..p_bus.fuel_tank_free..' units of fuel')
    if p_bus.balance > gs[trader_tag].business[good].sell_price * amount / 1000
      and p_bus.cargo_free >= trade_good_info[good].bulk * amount
      and gs[trader_tag].business[good].stock >= amount then
      p_bus[good].stock += amount
      p_bus.cargo_free -= total_bulk
      p_bus.cargo_used += total_bulk
      p_bus.balance -= gs[trader_tag].business[good].sell_price * amount / 1000
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
    p_bus = gs.player.business
    local amount = btn(0) and 5 or 1
    local total_bulk = amount*trade_good_info[good].bulk
    if p_bus[good].stock >= amount then
      p_bus[good].stock -= amount
      p_bus.cargo_free += total_bulk
      p_bus.cargo_used -= total_bulk
      p_bus.balance += gs[trader_tag].business[good].buy_price * amount / 1000
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

-- Platforming
-- tile flag 0 == solid
-- tile flag 1 == walk_on_top

function collide_side(self)
  --check if pushing into side tile and resolve.
  --requires self.dx,self.x,self.y, and 
   local offset=self.w/3
   for i=-(self.w/3),(self.w/3),2 do
     if fget(mget((self.x+(offset))/8+moffx,(self.y+i)/8+moffy),0) then
         self.dx=0
         self.x=(flr(((self.x+(offset))/8))*8)-(offset)
         return true
     end
     if fget(mget((self.x-(offset))/8+moffx,(self.y+i)/8+moffy),0) then
         self.dx=0
         self.x=(flr((self.x-(offset))/8)*8)+8+(offset)
         return true
     end
   end
   --didn't hit a solid tile.
   return false
end

function collide_floor(self)
  --check if pushing into floor tile and resolve.
  --requires self.dx,self.x,self.y,self.grounded,self.airtime and 
   --only check for ground when falling.
   if self.dy<0 then
       return false
   end
   local landed=false
   --check for collision at multiple points along the bottom
   --of the sprite: left, center, and right.
   for i=-(self.w/3),(self.w/3),2 do
       local tile=mget((self.x+i)/8+moffx,(self.y+(self.h/2))/8+moffy)
       if fget(tile,0) or (fget(tile,1) and self.dy>=0 and not (btn(3))) then
           self.dy=0
           if(not fget(tile,3))then  self.y=(flr((self.y+(self.h/2))/8)*8)-(self.h/2) end
           self.grounded=true
           self.airtime=0
           landed=true
       end
   end
   return landed
end

function collide_ladder(self)
   --check for collision at multiple points along the bottom
   --of the sprite: left, center, and right.
   local can_ascend=false
   local can_descend=false
   local closest_ladder=100
   local ladder_mid = flr(flr(self.x)/8) * 8 + 4
   local i = 0
       local below=mget((self.x+i)/8+moffx,(self.y+(self.h/2))/8+moffy)
       local level=mget((self.x+i)/8+moffx,(self.y+(self.h/2-1))/8+moffy)
       if fget(level,2) then
         can_ascend = true
       end
       if fget(below,2) then
         can_descend = true
       end
   return can_ascend,can_descend,ladder_mid
end

function collide_roof(self)
  --check if pushing into roof tile and resolve.
  --requires self.dy,self.x,self.y, and 
  --assumes tile flag 0 == solid
   --check for collision at multiple points along the top
   --of the sprite: left, center, and right.
   for i=-(self.w/3),(self.w/3),2 do
       if fget(mget((self.x+i)/8+moffx,(self.y-(self.h/2))/8+moffy),0) then
           self.dy=0
           self.y=flr((self.y-(self.h/2))/8)*8+8+(self.h/2)
           self.jump_hold_time=0
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
  slf.push_interface = function(me, interface_tag, interface_object)
    add(me._interfaces, interface_tag)
    me[interface_tag] = interface_object
  end
  slf.pop_interface = function(me,depth)
    depth = depth or 1
    for i =1,depth do
      if(#me._interfaces == 1) then return end
      tag = me._interfaces[#me._interfaces]
      del(me._interfaces, tag)
      me[tag] = nil
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
    if btnp(4) then 
      o_uix, o_uiy = nil,nil
      gs[gs.cs]:pop_interface() 
    end
    if btnp(5) then me:execute() end
    if me.update then me:update() end
    for _,splat in pairs(me._splats) do
      splat:update()
    end
  end
  slf.execute = function(me)
    if(me._current_splat) me._splats[me._current_splat]:execute()
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
  }) do me[k] = o[k] == nil and v or o[k] end
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
