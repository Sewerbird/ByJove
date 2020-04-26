function travel_dialog(here,destination)
  local slf = interface()
  local w = 64
  local h = 64
  local l_x = 32
  local t_y = 32
  local c_x = 64
  local fuel_need = gs[here].fuel_cost[destination]
  local trip_time = fuel_need/6
  local has_the_fuel =gs['player'].business.fuel_tank_used >= fuel_need 
  slf._current_splat= has_the_fuel and 'ok_button' or 'cancel_button'
  local text = "Travelling to\n"..gs[destination].planet.."\nFuel needed:"..fuel_need.."\nDays: "..flr(trip_time).." days"
  slf._splat = splat('background',{ x=l_x,y=t_y,w=w,h=h,c_b=13,c_f=1,text = text,t_center=false, at_x=2, at_y=2})
  slf._splats = define_splats({
    header = { x=c_x-32,y=t_y-10,w=30,h=10,text="Travel?",c_b=13,c_f=1 },
    no_fuel = { hidden=has_the_fuel,x=c_x,y=t_y+h/2,text="Not enough fuel",c_t=8},
    ok_button = { right = 'cancel_button', x=c_x-32,y=t_y+h,w=30,h=10,text="okay",c_b=13,c_f=1,active=has_the_fuel,hidden=not has_the_fuel,
      execute = function() 
        sfx(38)
        gs[gs.cs]:pop_interface(2) --pop dialog and map interface
        --TODO go to ship scene instead
        gs['player'].business.fuel_tank_used -= fuel_need
        gs['player'].business.fuel_tank_free += fuel_need
        load_station(destination)
        --load_station('player_ship')
      end
    },
    cancel_button = { left = 'ok_button', x=c_x+2,y=t_y+h,w=30,h=10,text="cancel",c_b=13,c_f=1,active=not has_the_fuel,
      execute = function() 
        sfx(37)
        gs[gs.cs]:pop_interface() 
      end
    }
  })
  return slf
end

function travelling_interface(active_splat)
  local slf = interface()
  local w = 127
  local h = 127
  local l_x = 0+uix
  local t_y = 0+uiy
  local c_x = 64 -8
  local scene = gs.cs
  local current_station = gs[scene].current_station
  local planet = planets[gs[current_station].planet]
  slf._current_splat='planet_'..gs[current_station].planet
  slf.draw = function(me)
    camera(0,0)
    cls()
    for v in all(stars) do
      circ(v.x*127,v.y*127,0,5)
    end
    circfill(127,-64,128,15)
    circfill(120,-70,128,4)
    print("Travel to where?", 60,4,12)
  end
  ask_travel = function(tgt)
    return function()
      if tgt == current_station then
        sfx(37)
        gs[gs.cs]:pop_interface()
      else
        sfx(38)
        gs[gs.cs].destination_planet = tgt
        gs[gs.cs]:push_interface('travel_dialog',travel_dialog(current_station,tgt))
      end
    end
  end
  slf._splat = splat('background',{ x=l_x,y=t_y,w=w,h=h,c_f=0 })
  slf._splats = define_splats({
    planet_io = {s_circle=true,r=10,down="planet_europa",x=planets.io.x,y=planets.io.y,sprite=planets.io.sprite_id,text='io',at_y=12,s_w=2,s_h=2,c_ba=12,w=16,h=16,execute=ask_travel('station_io')},
    planet_europa = {s_circle=true,r=10,down="planet_ganymede",up="planet_io",x=planets.europa.x,y=planets.europa.y,sprite=planets.europa.sprite_id,text='europa',at_y=12,s_w=2,s_h=2,c_ba=12,w=16,h=16,execute=ask_travel('station_europa')},
    planet_ganymede = {s_circle=true,r=10,up="planet_europa",down="planet_callisto",x=planets.ganymede.x,y=planets.ganymede.y,sprite=planets.ganymede.sprite_id,text='ganymede',at_y=12,s_w=2,s_h=2,c_ba=12,w=16,h=16,execute=ask_travel('station_ganymede')},
    planet_callisto = {s_circle=true,r=10,up="planet_ganymede",x=planets.callisto.x,y=planets.callisto.y,sprite=planets.callisto.sprite_id,text='callisto',at_y=12,s_w=2,s_h=2,c_ba=12,w=16,h=16,execute=ask_travel('station_callisto')},
    ur_here = {sprite=41,x=planet.x+20,y=planet.y+8,at_x=10,at_y=8,c_t=11,text="yOU ARE\nhERE",t_center=false},
  })
  slf._splats[slf._current_splat].active = true
  return slf
end

