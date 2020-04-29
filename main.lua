if not require then 
  require = function() end
end
require("adv_micro_platformer")
require("constants")
require("lib")
-- Starport scene
require("travelling_interface")
require("trading_interface")
require("talking_interface")
require("wandering_interface")
require("starport")
-- Other scenes
require("startgame")
require("tutorial")
require("endgame")

function _init()
  printh("Starting game")
  gs.starport_scene = starport_scene('station_ganymede')
  gs.start_scene = start_scene()
  gs.cs = skip_tutorial and 'starport_scene' or 'start_scene'
  gs.player:set_anim("walk")
end

function _update()
  if get_xy then printh(gs.player.x..","..gs.player.y) end
  check_end_conditions()
  gs[gs.cs]:_update()
end

function _draw()
  cls()
  gs[gs.cs]:_draw()
end
