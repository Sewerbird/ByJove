function talking_interface(interlocutor, conversation)
  -- A talking dialog to display a conversation object
  local slf = interface()
  local text = conversation.begin.text
  local npc_x = gs[interlocutor].x
  local npc_y = gs[interlocutor].y+16
  o_uix = npc_x -64 +8
  o_uiy = npc_y -64 -8
  slf.currtext = ""
  slf.spoke = false
  slf.convo_node = "begin"
  printh(slf.convo_node..":-> ")
  slf.tgttext = conversation[slf.convo_node].text
  --Process parameters
  local i = 0
  local builtup = ""
  local skip = false
  for i = 1, #slf.tgttext do
    local nc = sub(slf.tgttext,i,i)
    if nc == '%' then
      local code = sub(slf.tgttext,i+1,i+1)
      builtup = builtup..conversation[code]
      skip = true
    elseif skip then
      skip = false
    else
      builtup = builtup..nc
    end
  end
  slf.tgttext = builtup
  printh("Gonna show " .. slf.tgttext)
  --Finish up
  slf._current_splat='feed'
  --Takes up bottom half of screen, and pans Y to end up under the interlocutor
  slf._splat = splat('text_area', {at_x=2,at_y=2,x=o_uix,y=npc_y,w=127,h=55,c_f=1,c_b=13,t_center=false})
  --Spits out the text piecemeal
  slf.param = 1 --which string parameter we're on
  slf.cursor = 1
  slf.currline_width = 0
  slf.ticker_speed = 2 --letters to reveal per tick
  slf._splats = define_splats({
    yes = {text="Yes",down="no",x=o_uix+103,y=o_uiy+109,w=24,h=8,hidden=true,execute=function(me)
      slf:next("y")
    end},
    no = {text="No",up="yes",x=o_uix+103,y=o_uiy+117,w=24,h=8,hidden=true,execute=function(me)
      slf:next("n")
    end},
    ok = {text="ok",x=o_uix+103,y=o_uiy+117,w=24,h=8,hidden=true,execute=function(me)
      slf:next("k")
    end},
    feed = {text="...",x=o_uix+103,y=o_uiy+117,w=24,h=8,c_f=0,c_b=0,c_fa=0,c_ba=0}
  })
  slf.next = function(me,next)
    if conversation[me.convo_node].on then
      conversation[me.convo_node].on(next)
    end
    me.convo_node = conversation[me.convo_node][next]
    if me.convo_node then
      me.tgttext = conversation[me.convo_node].text
      me.currtext = ""
      me.currline_width = 0
      me.cursor = 0
      me.spoke = false
      me._splats.feed.hidden = false
      me._splats.ok.hidden = true
      me._splats.yes.hidden = true
      me._splats.no.hidden = true
    else
      o_uix, o_uiy = nil,nil
      gs[gs.cs]:pop_interface()
    end
  end
  slf.update = function(me)
    for i=1,slf.ticker_speed do
      if me.cursor <= #me.tgttext then
        sfx(35,3,flr(rnd()*10),1)
        me._current_splat = "feed"
        me.currline_width += 1
        if me.currline_width / 31 > 1 then
          me.currtext = me.currtext.."\n"
          me.currline_width = 1
        end
        local nc = sub(me.tgttext,me.cursor,me.cursor)
        --reveal more
        printh("Curr text is now '"..me.currtext.."'")
        me.currtext = me.currtext..nc
        me._splat.text = me.currtext
        me.cursor += 1
      elseif not me.spoke then
        --transition to spoke state
        me._splats.feed.hidden = true
        if conversation[me.convo_node].k then
          me._splats.ok.hidden = false
          me._splats.ok.active = true
        elseif conversation[me.convo_node].y then
          me._splats.yes.hidden = false
          me._splats.yes.active = true
          me._splats.no.hidden = false
        end
        me.spoke = true
        me._current_splat = conversation[me.convo_node].y and "yes" or "ok"
      end
    end
  end
  return slf
end

