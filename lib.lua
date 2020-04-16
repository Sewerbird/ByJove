create = function(tag,o)
  gs[tag] = splat(tag,o)
end

splat = function(tag,o)
  local me = {}
  for k,v in pairs({
    tag=tag,x=0,y=0,
    frames={0},frame=1,timer=0,
    a_x=0,a_y=0,as_x=0,as_y=0,
    w=0,h=0,s_w=1,s_h=1,
    c_f=-1,c_b=-1,c_fa=-1,c_ba=8,c_t=7,
    text='',t_align='left',active=false,selectable=false,
    update=function(me)end,execute=function(me)end
  }) do me[k] = o[k] or v end
  me.draw=function(me)
    local l_x,t_y=me.x-me.a_x,me.y-me.a_y
    local r_x,b_y=l_x+me.w,t_y+me.h
    local txt_x=me.t_align=='left' and l_x or(l_x+(me.w/2)-#me.text*2)
    local txt_y=me.t_align=='left' and t_y or(t_y+flr(me.h/2)-2)
    if me.c_f>0 then rectfill(l_x,t_y,r_x,b_y,me.active and me.c_fa or me.c_f) end
    for i_x=0,me.s_w-1 do
      for i_y=0,me.s_h-1 do
        spr(me.frames[me.frame]+i_x+(i_y*16),l_x+i_x*8+me.as_x,t_y+i_y*8+me.as_y)
      end
    end
    if me.c_t>0 then print(me.text,txt_x,txt_y,me.c_t) end
    if me.c_f>0 then rect(l_x,t_y,r_x,b_y,me.active and me.c_ba or me.c_b) end
  end
  return me
end

function rndi(z)
  return flr(rnd() * z)
end

