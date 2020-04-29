get_xy = false
skip_tutorial = true

--Game State
gs = {
  ticker = 0, --TODO: there is a global ticker too...
  cs = "start_scene",
  current_station = "station_ganymede",
  player = create_player({
    sprite=2,w=8,h=8,x=52,y=64,
    business = {
      tax_rate = 0,
      balance = 1,
      fuel_tank_space = 120,
      fuel_tank_used = 120,
      fuel_tank_free = 0,
      cargo_space = 100,
      cargo_used = 0,
      cargo_free = 100,
      fuel = {stock = 100},
      medicine = {stock = 0},
      parcels = {stock = 0},
      machinery = {stock = 0},
      electronics = {stock = 0},
    }
  }),
  trader = {
    sprite=8,text='trader',w=8,h=8,x=20,y=24,
    business = {
      volatile = true,
      tax_rate = 0,
      medicine = {base_price = 10, desired_stock = 64, stock = 64, buy_price = 20, sell_price = 10},
      parcels = {base_price = 10, desired_stock = 64, stock = 64, buy_price = 20, sell_price = 10},
      machinery = {base_price = 10, desired_stock = 64, stock = 64, buy_price = 20, sell_price = 10},
      electronics = {base_price = 10, desired_stock = 64, stock = 64, buy_price = 20, sell_price = 10},
    }
  },
  fueler = {
    sprite=10,text='fueler',w=8,h=8,x=40,y=104,
    business = {
      volatile = true,
      tax_rate = 50,
      fuel = {base_price = 5, desired_stock = 64, stock = 127, buy_price = 20, sell_price = 2},
    }
  },
  travel_console = {sprite=12,text='travel',w=8,h=8,x=80,y=104},
  armsdealer = {sprit=9,w=8,h=8,x=164,y=40},
  npc_1 = {sprite=9,w=8,h=8,insider=true},
  npc_2 = {sprite=14,w=8,h=8,x=94,y=64,insider=true},
  npc_3 = {sprite=9,w=8,h=8,insider=true},
  npc_4 = {sprite=47,w=8,h=8,x=222,y=40,insider=true},
  tutorial_travel_console = {sprite=12,w=8,h=8,x=80,y=50+40},
  tutorial_player = { sprite=2,w=8,h=8,x=80-8-16,y=127-8 },
  a_prompt = {sprite=9,w=8,h=8,x=100,y=100},
  player_ship = {
    mx0=64,my0=0,mx1=24,my1=24,
    wall_color = 5,
    planet = 'ganymede',
    actors={
      player = {x=20,y=48},
      a_prompt = {x=-100,y=-100},
    }
  },
  station_io = {
    mx0=32,my0=0,mx1=16,my1=32,
    wall_color = 4,
    planet="io",
    fuel_cost= {
      station_io = 0,
      station_europa = 3,
      station_ganymede = 6,
      station_callisto = 9,
    },
    actors={
      player = {x=80,y=184},
      trader = {ref="trader",x=96,y=120,at_y=8,w=8,h=8,text="trader"},
      fueler = {ref="fueler",x=96,y=184,at_y=8,w=8,h=8,text="fueler"},
      npc_1 = {ref="npc_1",x=16,y=90,sprite=14,at_y=8,w=8,h=8,text="cera"},
      npc_2 = {ref="npc_2",x=105,y=90,sprite=47,at_y=8,w=8,h=8,text="edward"},
      npc_3 = {ref="npc_3",x=105,y=50,sprite=14,at_y=8,w=8,h=8,text="ian"},
      npc_4 = {ref="npc_4",x=32,y=120,sprite=14,at_y=8,w=8,h=8,text="sandy"},
      a_prompt = {ref="a_prompt",x=-100,y=-100,at_y=8,w=8,h=8,text=""},
      travel_console = {ref="travel_console",x=64,y=184,sprite=13,at_y=8,w=8,h=8,text="travel"},
    },
  },
  station_europa = {
    mx0=48,my0=0,mx1=16,my1=32,
    wall_color=3,
    planet="europa",
    fuel_cost= {
      station_io = 3,
      station_europa = 0,
      station_ganymede = 3,
      station_callisto = 6,
    },
    actors={
      player = {x=80,y=32},
      trader = {ref="trader",x=16,y=96,at_y=8,w=8,h=8,text="trader"},
      fueler = {ref="fueler",x=96,y=32,at_y=8,w=8,h=8,text="fueler"},
      npc_1 = {ref="npc_1",x=74,y=144,sprite=14,at_y=8,w=8,h=8,text="mike"},
      npc_2 = {ref="npc_2",x=88,y=152,sprite=47,at_y=8,w=8,h=8,text="louis"},
      npc_3 = {ref="npc_3",x=108,y=152,sprite=14,at_y=8,w=8,h=8,text="samya"},
      a_prompt = {ref="a_prompt",x=-100,y=-100,at_y=8,w=8,h=8,text=""},
      travel_console = {ref="travel_console",x=64,y=32,sprite=13,at_y=8,w=8,h=8,text="travel"},
    },
  },
  station_ganymede = {
    mx0=0,my0=0,mx1=32,my1=16,
    wall_color=5,
    planet="ganymede",
    fuel_cost= {
      station_io = 6,
      station_europa = 3,
      station_ganymede = 0,
      station_callisto = 3,
    },
    actors={
      player = {x=52,y=64},
      trader = {ref="trader",x=20,y=24,at_y=8,w=8,h=8,text="trader"},
      fueler = {ref="fueler",x=40,y=104,at_y=8,w=8,h=8,text="fueler"},
      armsdealer = {ref="armsdealer",x=164,y=44,sprite=11,at_y=8,w=8,h=8,text="gunner"},
      npc_2 = {ref="npc_2",x=94,y=30,sprite=14,at_y=8,w=8,h=8,text="kashka"},
      npc_4 = {ref="npc_4",x=222,y=44,sprite=47,at_y=8,w=8,h=8,text="morris"},
      a_prompt = {ref="a_prompt",x=-100,y=-100,at_y=8,w=8,h=8,text=""},
      travel_console = {ref="travel_console",x=80,y=104,sprite=12,at_y=8,w=8,h=8,text="travel"},
    },
  },
  station_callisto = {
    mx0=0,my0=16,mx1=32,my1=16,
    wall_color=2,
    planet="callisto",
    fuel_cost= {
      station_io = 9,
      station_europa = 6,
      station_ganymede = 3,
      station_callisto = 0,
    },
    actors={
      player = {x=104,y=88},
      trader = {ref="trader",x=144,y=32,at_y=8,w=8,h=8,text="trader"},
      fueler = {ref="fueler",x=80,y=88,at_y=8,w=8,h=8,text="fueler"},
      npc_1 = {ref="npc_1",x=14,y=88,sprite=14,at_y=8,w=8,h=8,text="noisa"},
      npc_2 = {ref="npc_2",x=40,y=88,sprite=47,at_y=8,w=8,h=8,text="sam"},
      npc_3 = {ref="npc_3",x=100,y=48,sprite=14,at_y=8,w=8,h=8,text="odie"},
      npc_4 = {ref="npc_4",x=176,y=32,sprite=47,at_y=8,w=8,h=8,text="mags"},
      a_prompt = {ref="a_prompt",x=-100,y=-100,at_y=8,w=8,h=8,text=""},
      travel_console = {ref="travel_console",x=120,y=88,sprite=12,at_y=8,w=8,h=8,text="travel"},
    },
  }
}
uix = nil
uiy = nil
o_uix = nil
o_uiy = nil
moffx = 0
moffy = 0
ticker = 0
ticks = 0 --TODO: adv_micro_platformer. Remove
music_ticker = 10000
win_amount = 10 --k$
lose_amount = 0
trade_goods = {'medicine','parcels','machinery','electronics','fuel'}
trade_good_info = {
  medicine = {sprite_id = 43, base_price = 10, bulk = 1},
  parcels = {sprite_id = 44, base_price = 20, bulk = 2},
  machinery = {sprite_id = 45, base_price = 30, bulk = 3},
  electronics = {sprite_id = 46, base_price = 40, bulk = 4},
  fuel = {sprite_id=42, base_price = 10, bulk = 1}
}
planet_keys = {'io','europa','ganymede','callisto'}
planets = {
  io= { sprite_id=110,s_w=2,s_h=2,x=64-8-0,y=64-45 },
  europa= {sprite_id=78,s_w=2,s_h=2,x=64-8-30,y=64-25},
  ganymede= {sprite_id=108,s_w=2,s_h=2,x=64-8-40,y=64+10},
  callisto= {sprite_id=76,s_w=2,x=64-8-35,y=64+40,s_h=2},
}
event_templates = {
  evt_glut = { 
    rumor = { begin = {text ="I heard there is a huge shipment of %g on its way to %p. Could gutpunch the price there."}},
    apply = function(event)
      gs[event.station].trader.business[event.good].stock = 127
    end
  },
  evt_drop = { 
    rumor = { begin = {text ="They're running low on %g over on %p. They could really use some more."}},
    apply = function(event)
      gs[event.station].trader.business[event.good].stock = 0
    end
  },
  evt_stab = { 
    rumor = { begin = {text ="I heard the market for %g over at %p is about to stabilize. Things are settling down."}},
    apply = function(event)
      gs[event.station].trader.business[event.good].stock = 64
    end
  },
  evt_exp = { 
    rumor = { begin = {text ="I got robbed by the trader back at %p. He's really squeezing the margin out of everything."}},
    duration = 30,
    apply = function(event)
      gs[event.station].trader.business[event.good].tax_rate = 150
    end
  },
  evt_lax = { 
    rumor = { begin = {text ="The trader at %p station must be distracted: I've been getting killer deals with him lately."}},
    duration = 30,
    apply = function(event)
      gs[event.station].trader.business[event.good].tax_rate = 50
    end
  },
  evt_oil_strike = { 
    rumor = { begin = {text ="There's gonna be a miner's strike on %p this week. Gonna spike the cost of fuel there I bet."}},
    apply = function(event)
      gs[event.station].fueler.business.fuel.stock = 3
    end
  },
  evt_oil_boon = { 
    rumor = { begin = {text ="I heard EnerCo found another dylithium deposit on %p."}},
    apply = function(event)
      gs[event.station].fueler.business.fuel.stock = 50
    end
  }
}
conversation_templates = {
  test = {
    begin = {"want", "to", "hear", "more", text="A conversation can have branches based on yes no questions. Do you % % % %?",y="more",n="done"},
    more = {text= "Okay, here is more. Want more?",y="more",n="done",on=function(result)
      if result=='y' then
        printh("In a loop again")
      else
        printh("Exiting loop")
      end
    end},
    done = {text= "Okay, all done."}
  }
}
--Creates 500 x,y pairs to be reused for star effects, with a random color
stars = {}
for i=1,500 do
  add(stars,{x= rnd(), y= rnd(), c = flr(rnd()*8)})
end
neg_ln = {
[1]= 0,
[2]=-0.6931471806,
[3]=-1.0986122887,
[4]=-1.3862943611,
[5]=-1.6094379124,
[6]=-1.7917594692,
[7]=-1.9459101491,
[8]=-2.0794415417,
[9]=-2.1972245773,
[10]=-2.302585093,
[20]=-2.9957322736
}
