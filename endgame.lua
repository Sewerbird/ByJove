function game_over_interface(condition, text)
  local slf = interface()
  slf._splat = nil
  slf._current_splat = "done"
  slf._splats = define_splats({
    done = {x=70,y=10,text=text,t_lines=9}
  })
  slf.draw = function(me)
    for v in all(stars) do
      circ(v.x*255,v.y*255,0,5)
    end
    circfill(120,7,3,10)
    circ(127,220,180,4)
    circfill(127,120,64,15)
    circfill(127,127,64,4)
  end
  return slf
end

function bankruptcy_scene()
  local slf = scene()
  gs.ticker = 0
  text = "bANKRUPT...\n\nunable to muster\nany funds from\nyour coffers\nyou find yourself\nunable to continue\n\nreset to try again"
  sfx(37)
  slf:push_interface("losing",game_over_interface('bankruptcy',text))
  return slf
end

function victory_scene()
  local slf = scene()
  gs.ticker = 0
  text = "yOU wON!\n\nhaving amassed\n$1,000,000\nyou are wealthy\nenough to\nretire\n\ncongratulations!"
  sfx(38)
  slf:push_interface("winning",game_over_interface('wealthy',text))
  return slf
end
