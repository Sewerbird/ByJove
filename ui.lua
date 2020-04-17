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
  slf.pop_interface = function(me)
    if(#me._interfaces == 1) then return end
    del(me._interfaces, me:interface())
  end
  slf.draw = function(me)
    map(0,0,0,0,6,8)
    for k in all(me._interfaces) do
      me[k]:draw()
    end
  end
  slf.update = function(me)
    for k in all(me._interfaces) do
      me[k]:update()
    end
  end
  slf.execute = function(me)
    me.interface:execute()
  end
  return slf
end

function interface()
  local slf = {
    _input_map = {},
    _splats = {},
    _current_splat = '',
  }
  slf.current_splat = function(me)
    return me._splats[me._current_splat]
  end
  slf.draw = function(me)
    for _,splat in pairs(me._splats) do
      splat:draw()
    end
  end
  slf.update = function(me)
    for _,splat in pairs(me._splats) do
      splat:update()
    end
  end
  slf.execute = function(me)
    me:current_splat():execute()
  end
  return slf
end

function splat(tag,o)
  local me = o
  for k,v in pairs({
    tag=tag, ref='',
    x=0,y=0,w=0,h=0,a_x=0,a_y=0, --box
    c_f=-1,c_b=-1,c_fa=nil,c_ba=14, --colors
    sprite=-1,as_x=0,as_y=0,s_w=1,s_h=1,s_f=false, --sprite
    text='',t_center=false,c_t=7, --text
    active=false,selectable=false,
    down=nil,up=nil,left=nil,right=nil,
    update=function(me)
      if(gs[me.ref]) then
        me.x = gs[me.ref].x
        me.y = gs[me.ref].y
      end
    end,
    execute=function(me)printh("Executing tag "..me.tag)end
  }) do me[k] = o[k] or v end
  me.draw=function(me)
    local l_x,t_y=me.x-me.a_x,me.y-me.a_y
    local r_x,b_y=l_x+me.w,t_y+me.h
    local txt_x=me.t_center and (l_x+(me.w/2)-#me.text*2) or l_x
    local txt_y=me.t_center and (t_y+flr(me.h/2)-2) or t_y
    if me.c_f>0 then rectfill(l_x,t_y,r_x,b_y,me.active and me.c_fa or me.c_f) end
    if me.sprite >= 0 then
      for i_x=0,me.s_w-1 do
        for i_y=0,me.s_h-1 do
          spr(me.sprite+i_x+(i_y*16),l_x+i_x*8+me.as_x,t_y+i_y*8+me.as_y)
        end
      end
    end
    if me.c_t>0 then print(me.text,txt_x,txt_y,me.c_t) end
    if me.c_f>0 then rect(l_x,t_y,r_x,b_y,me.active and me.c_ba or me.c_b) end
  end
  return me
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
  -- Player wandering a map, able to bump into walls and interact with Things
  gs['player'] = {x=9,y=9}
  result.wandering = interface()
  result.wandering._current_splat='player'
  result.wandering._splats = {
    ['player']= splat('player',{ref='player',w=8,h=8,sprite=0,active=true})
  }
  result.wandering.update = function(me)
    local x = gs['player'].x
    local y = gs['player'].y
    local dx = 0
    local dy = 0
    if btn(0) then dx -= 1 end
    if btn(1) then dx += 1 end
    if btn(2) then dy -= 1 end
    if btn(3) then dy += 1 end
    if 
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
    printh(gs['player'].x..","..gs['player'].y)
    for _,splat in pairs(me._splats) do
      splat:update()
    end
  end
  result:push_interface("wandering")

  -- A purchase dialog
  result.purchasing = interface()
  result.purchasing._current_splat='buy_psytek'
  result.purchasing._splats = {
    ['buy_psytek']= splat('buy_psytek',{down='buy_drugs',x=10,y=100,w=80,h=9,c_f=1,c_b=13,text="psytek",t_center=true,active=true}),
    --['buy_drugs']= splat('buy_drugs',{up='buy_psytek',down='buy_arms',x=10,y=20,w=80,h=9,c_f=1,c_b=13,text="drugs",t_center=true}),
    --['buy_arms']= splat('buy_arms',{up='buy_drugs',down='buy_slaves',x=10,y=30,w=80,h=9,c_f=1,c_b=13,text="arms",t_center=true}),
    --['buy_slaves']= splat('buy_slaves',{up='buy_arms',x=10,y=40,w=80,h=9,c_f=1,c_b=13,text="slaves",t_center=true}),
  }
  result.purchasing.update = function(me)
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
  end
  return result
end
