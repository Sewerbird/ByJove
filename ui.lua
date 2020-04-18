function talk_interface()
  -- A talk dialog 
  local slf = interface()
  slf._current_splat='pay_customs'
  slf._splats = {
    ['text_area']=splat('text_area',{text="tHERE IS A \nDOCKING FEE\nTO ENTER THE\nSTARPORT.",at_x=2,at_y=2,x=30,y=30,w=64,h=64,c_f=1,c_b=13}),
    ['pay_customs']= splat('pay_customs',{x=62,y=30+64-11,a_x=20,w=40,h=9,c_f=1,c_b=13,text="Pay $100",t_center=true,active=true}),
  }
  slf.draw = function(me)
    me._splats.text_area:draw()
    me._splats.pay_customs:draw()
  end
  slf.update = function(me)
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
    if btnp(5) then 
      --TODO remove cash
      gs[gs.cs]:pop_interface()
    end
  end
  return slf
end

function wandering_interface()
  local slf = interface()
  slf._current_splat='player'
  --TODO the list of actors really needs to come from somewhere else...
  slf.actors = {'player','customs','trader','fueler'}
  slf._splats = {
    ['player']= splat('player',{ref='player',w=8,h=8}),
    ['customs']= splat('customs',{ref='customs',text='customs',t_center=true,at_y=8,w=8,h=8}),
    ['trader']= splat('trader',{ref='trader',text='trader',t_center=true,at_y=8,w=8,h=8}),
    ['fueler']= splat('fueler',{ref='fueler',text='fueler',t_center=true,at_y=8,w=8,h=8}),
    ['a_prompt']= splat('a_prompt',{ref='a_prompt',t_center=true,a_y=8,w=8,h=8})
  }
  slf.draw = function(me)
    me._splats.player:draw()
    me._splats.customs:draw()
    me._splats.trader:draw()
    me._splats.fueler:draw()
    me._splats.a_prompt:draw()
  end
  slf.update = function(me)
    --Handle Motion
    local x = gs['player'].x
    local y = gs['player'].y
    local dx = 0
    local dy = 0
    if btn(0) then dx -= 1 end
    if btn(1) then dx += 1 end
    if btn(2) then dy -= 1 end
    if btn(3) then dy += 1 end
    --Check collision with actors
    local bumped = false
    local player = {
      x = gs['player'].x + dx,
      y = gs['player'].y + dy,
      w = gs['player'].w,
      h = gs['player'].h,
    }
    for actor in all(me.actors) do
      local obj = gs[actor]
      if actor ~= 'player' and rects_intersect(obj,player) then
        bumped = true
      end
    end
    --Check collision with map
    if 
      not bumped and
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
    --Handle player being near an NPC
    local target_npc = nil
    for k in all(me.actors) do
      if k != 'player' then
        if dsto(gs[me._splats[k].ref], gs['player']) < 12 then
          target_npc = k
        end
      end
    end
    me.target_npc = target_npc
    if me.target_npc then
      gs['a_prompt'].x = gs[me.target_npc].x
      gs['a_prompt'].y = gs[me.target_npc].y
    else
      gs['a_prompt'].x = -100
      gs['a_prompt'].y = -100
    end
    --Handle pressing 'A' to activate an NPC
    if me.target_npc and btnp(5) then
      gs[gs.cs]:push_interface('talking')
    end
    --Update sub elements
    for _,splat in pairs(me._splats) do
      splat:update()
    end
  end
  return slf
end

function starport_scene()
  --TODO this is gamestate stuff, shouldn't end up living here
  gs['player'].x = 76
  gs['player'].y = 64
  gs['customs'].x = 43
  gs['customs'].y = 64
  gs['trader'].x = 23
  gs['trader'].y = 24
  gs['fueler'].x = 100
  gs['fueler'].y = 64
  gs['a_prompt'] = {x=100,y=100,sprite=9}
  local mx0,my0,mx1,my1 = 0,0,20,20

  --Actual Starport Scene code
  local slf = scene()
  slf.draw = function(me)
    srand(0)
    ticker+=1
    for i=0,300 do
      circ(mod(ticker+rnd()*127,127),sin(ticker/500)*10+rnd()*127,0,7)
    end
    palt(0,false)
    palt(14,true)
    map(mx0,my0,0,0,mx1,my1)
    palt()
    for k in all(me._interfaces) do
      me[k]:draw()
    end
  end
  -- Player wandering a map, able to bump into walls and interact with Things
  slf.wandering = wandering_interface()
  slf.talking = talk_interface()
  slf:push_interface("wandering")

  return slf
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
  return result
end
