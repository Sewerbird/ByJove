function wandering_interface(station_tag)
  local slf = interface()
  slf._current_splat=nil
  slf._splat = nil
  slf._splats = {}
  for k,v in pairs(gs[station_tag].actors) do
    slf._splats[k] = splat(k,v)
  end
  slf.update = function(me)
    --Move player according to rules
    gs.player:update()
    --Handle player being near an NPC
    local target_npc = nil
    for k,v in pairs(gs[station_tag].actors) do
      if k != 'player' and k != 'a_prompt' then
        if dsto(v, gs['player']) < 12 then
          target_npc = k
        end
      end
    end
    gs['a_prompt'].x = not target_npc and -100 or gs[target_npc].x
    gs['a_prompt'].y = not target_npc and -100 or gs[target_npc].y-8
    --Handle pressing 'A' to activate an NPC
    if target_npc and btnp(5) then
      sfx(-1,1) 
      if target_npc == "trader" or target_npc == "fueler" then
        sfx(38)
        gs[gs.cs]:push_interface('trading',trading_interface(target_npc))
      elseif target_npc == "travel_console" then
        sfx(38)
        gs[gs.cs]:push_interface('travelling',travelling_interface(slf._current_splat))
      else
        sfx(38)
        gs[gs.cs]:push_interface('talking',talking_interface(target_npc,conversations.default))
      end
    end
  end
  return slf
end

