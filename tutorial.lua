function tutorial_interface()
  local slf = interface()
  slf._splat = nil
  slf._current_splat = "step_1"
  slf._splats = define_splats({
    tutorial_player = {ref='tutorial_player',w=8,h=8,sprite=7},
    tutorial_travel_console = {ref='tutorial_travel_console',x=80,y=50,w=8,h=8,sprite=12},
    step_1 = {x=64,y=40,text="Move around with your arrow keys"},
    step_2 = {x=64,y=40,text="Your goal is to\nmake $10,000 by\ntrading on the\nJovian moons.",t_lines=4},
    step_3 = {x=64,y=40,sprite=9,as_x=16,hidden=true,text="When you see '   ', \npress x to interact",t_lines=2,h=8},
    step_4 = {x=64,y=40,text="To exit a dialog,\npress o at any time.\n\nDo so now to begin!",t_lines=3},
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
      x = gs['tutorial_player'].x + (gs['tutorial_player'].y==50+40 and dx or 0),
      y = gs['tutorial_player'].y + dy,
      w = gs['tutorial_player'].w,
      h = gs['tutorial_player'].h,
    }
    gs['tutorial_player'].x = clamp(player.x,40,72)
    gs['tutorial_player'].y = clamp(player.y,50+40,player.x == 56 and 66+52 or 50+40)
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
    if console_distance > 30 then
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
    for v in all(stars) do
      circ(mod(ticker/10+v.x*255,255),sin(ticker/5000)*10+v.y*127,0,5)
    end
    palt(0,false)
    palt(14,true)
    map(64,0,32,42-40+40,8,12)
    pal()
  end
  slf.update = function(me)
    ticker+= 1
  end
  sfx(38)
  slf:push_interface("teaching",tutorial_interface())
  return slf
end

