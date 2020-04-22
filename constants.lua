get_xy = true
skip_tutorial = false
--Game State
gs = {
  ticker = 0,
  cs = "start_scene",
  current_station = "station_ganymede",
  player = {
    sprite=2,w=8,h=8,x=52,y=104,
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
  },
  customs = {sprite=7,text='customs',w=8,h=8,x=32,y=64,is_blocking=true},
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
  tutorial_travel_console = {sprite=12,w=8,h=8,x=80,y=50+40},
  tutorial_player = { sprite=2,w=8,h=8,x=80-8-16,y=127-8 },
  a_prompt = {sprite=9,w=8,h=8,x=100,y=100},
  station_io = {
    mx0=32,my0=0,mx1=16,my1=32,
    wall_color = 4,
    planet="io",
    fuel_cost= {
      station_io = 0,
      station_europa = 30,
      station_ganymede = 60,
      station_callisto = 90,
    },
    actors={
      player = {x=80,y=184},
      customs = {x=61,y=152,is_blocking=true},
      trader = {x=96,y=120},
      fueler = {x=96,y=184},
      a_prompt = {x=-100,y=-100},
      travel_console = {x=64,y=184,sprite=13},
    },
  },
  station_europa = {
    mx0=48,my0=0,mx1=16,my1=32,
    wall_color=3,
    planet="europa",
    fuel_cost= {
      station_io = 30,
      station_europa = 0,
      station_ganymede = 30,
      station_callisto = 60,
    },
    actors={
      player = {x=80,y=32},
      customs = {x=80,y=96,is_blocking=true},
      trader = {x=16,y=96},
      fueler = {x=96,y=32},
      a_prompt = {x=-100,y=-100},
      travel_console = {x=64,y=32,sprite=13},
    },
  },
  station_ganymede = {
    mx0=0,my0=0,mx1=32,my1=16,
    wall_color=5,
    planet="ganymede",
    fuel_cost= {
      station_io = 60,
      station_europa = 30,
      station_ganymede = 0,
      station_callisto = 30,
    },
    actors={
      player = {x=52,y=104},
      customs = {x=32,y=64,is_blocking=true},
      trader = {x=20,y=24},
      fueler = {x=40,y=104},
      a_prompt = {x=-100,y=-100},
      travel_console = {x=80,y=104,sprite=12},
    },
  },
  station_callisto = {
    mx0=0,my0=16,mx1=32,my1=16,
    wall_color=2,
    planet="callisto",
    fuel_cost= {
      station_io = 90,
      station_europa = 60,
      station_ganymede = 30,
      station_callisto = 0,
    },
    actors={
      player = {x=104,y=88},
      customs = {x=86,y=48,is_blocking=true},
      trader = {x=144,y=32},
      fueler = {x=80,y=88},
      a_prompt = {x=-100,y=-100},
      travel_console = {x=120,y=88,sprite=12},
    },
  }
}
ticker = 0
music_ticker = 10000
win_amount = 10 --k$
customs_amount = 0.1 --k$
lose_amount = 0
trade_goods = {'medicine','parcels','machinery','electronics','fuel'}
trade_good_info = {
  medicine = {sprite_id = 43, base_price = 10, bulk = 1},
  parcels = {sprite_id = 44, base_price = 20, bulk = 2},
  machinery = {sprite_id = 45, base_price = 30, bulk = 3},
  electronics = {sprite_id = 46, base_price = 40, bulk = 4},
  fuel = {sprite_id=42, base_price = 10, bulk = 1}
}
planets = {
  io= { sprite_id=110,s_w=2,s_h=2,x=64-8-0,y=64-45 },
  europa= {sprite_id=78,s_w=2,s_h=2,x=64-8-30,y=64-25},
  ganymede= {sprite_id=108,s_w=2,s_h=2,x=64-8-40,y=64+10},
  callisto= {sprite_id=76,s_w=2,x=64-8-35,y=64+40,s_h=2},
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
