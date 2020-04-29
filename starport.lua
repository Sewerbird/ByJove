function starport_scene(station_tag)
  local s = gs[station_tag]
  --Actual Starport Scene code
  local slf = scene()
  slf.current_station = station_tag
  -- Starport methods
  slf.draw = function(me)
    uix = o_uix or clamp(gs.player.x-64,0,s.mx1*8-127)
    uiy = o_uiy or clamp(gs.player.y-64,0,s.my1*8-127)
    camera(uix, uiy)
    for v in all(stars) do
      circ(mod(ticker/10+v.x*255,s.mx1*8),sin(ticker/5000)*10+v.y*s.my1*8,0,5)
    end
    palt(0,false)
    palt(14,true)
    pal(5,s.wall_color)
    map(s.mx0,s.my0,0,0,s.mx1,s.my1)
    gs.player:draw()
    pal()
  end
  slf.update = function(me)
    ticker+=1
    music_ticker += 1
    if music_ticker > 5000 then
      music_ticker = 0
    elseif music_ticker == 1150 then
    end
  end
  -- Player wandering a map, able to bump into walls and interact with Things
  moffx = s.mx0
  moffy = s.my0
  slf:push_interface("wandering", wandering_interface(station_tag))

  return slf
end


