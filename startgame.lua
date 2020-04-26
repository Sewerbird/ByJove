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
  slf:push_interface("starting",starting_interface())
  return slf
end
