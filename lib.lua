function mod(num,range)
  return num - flr(num/range)*range
end

function dsto(a,b)
  local dx = a.x-b.x
  local dy = a.y-b.y
  return sqrt(dx*dx + dy*dy)
end

function rects_intersect(a,b)
  --Note: Both a and b must have x,y,w,h
  return not (a.x+a.w<b.x or b.x+b.w<a.x or a.y+a.h<b.y or b.y+b.h<a.y)
end

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
    for k in all(me._interfaces) do
      me[k]:draw()
    end
  end
  slf.update = function(me)
    me[me:interface()]:update()
  end
  slf.execute = function(me)
    me:interface():execute()
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
    c_f=8,c_b=8,c_fa=nil,c_ba=14, --colors
    sprite=-1,as_x=0,as_y=0,at_x=0,at_y=0,s_w=1,s_h=1,s_f=false, --sprite
    text='',t_center=false,c_t=7, --text
    active=false,selectable=false,
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
    local l_x,t_y=me.x-me.a_x,me.y-me.a_y
    local r_x,b_y=l_x+me.w,t_y+me.h
    local txt_x=me.t_center and (l_x+(me.w/2)-#me.text*2) or l_x
    local txt_y=me.t_center and (t_y+flr(me.h/2)-2) or t_y
    if me.c_f>0 then rectfill(l_x,t_y,r_x,b_y,me.active and me.c_fa or me.c_f) end
    if me.sprite then
      for i_x=0,me.s_w-1 do
        for i_y=0,me.s_h-1 do
          spr(me.sprite+i_x+(i_y*16),l_x+i_x*8+me.as_x,t_y+i_y*8+me.as_y)
        end
      end
    end
    if me.c_t>0 then print(me.text,txt_x+me.at_x,txt_y+me.at_y,me.c_t) end
    if me.c_f>0 then rect(l_x,t_y,r_x,b_y,me.active and me.c_ba or me.c_b) end
  end
  return me
end
