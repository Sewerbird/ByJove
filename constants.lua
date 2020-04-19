get_xy = true
--Game State
gs = {
  ticker = 0,
  cs = "start_scene",
  player = {
    sprite=2,w=8,h=8,x=52,y=104,
    business = {
      tax_rate = 0,
      balance = 0.15,
      cargo_space = 100,
      cargo_used = 0,
      cargo_free = 100,
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
      tax_rate = 50,
      medicine = {base_price = 10, desired_stock = 64, stock = 127, buy_price = 20, sell_price = 10},
      parcels = {base_price = 10, desired_stock = 64, stock = 10, buy_price = 20, sell_price = 10},
      machinery = {base_price = 10, desired_stock = 64, stock = 10, buy_price = 20, sell_price = 10},
      electronics = {base_price = 10, desired_stock = 64, stock = 10, buy_price = 20, sell_price = 10},
    }
  },
  fueler = {sprite=10,text='fueler',w=8,h=8,x=40,y=104},
  armsdealer = {sprite=11,text='armsdealer',w=8,h=8,x=160,y=40},
  travel_console = {sprite=12,text='travel',w=8,h=8,x=80,y=104},
  tutorial_travel_console = {sprite=12,w=8,h=8,x=80,y=50},
  tutorial_player = { sprite=2,w=8,h=8,x=40,y=60 },
  a_prompt = {sprite=9,w=8,h=8,x=100,y=100},
  station_io = {
    mx0=0,my0=0,mx1=32,my1=16,
    actors={
      player = {x=52,y=104},
      travel = {x=88,y=104},
      customs = {x=40,y=64,is_blocking=true},
      trader = {x=28,y=24},
      fueler = {x=48,y=104},
      armsdealer = {x=168,y=40},
      a_prompt = {x=-100,y=-100},
      travel_console = {x=100,y=60},
    },
  },
  station_europa = {
    mx0=0,my0=0,mx1=32,my1=16,
    actors={
      player = {x=52,y=104},
      travel = {x=80,y=104},
      customs = {x=32,y=64,is_blocking=true},
      trader = {x=20,y=24},
      fueler = {x=40,y=104},
      armsdealer = {x=160,y=40},
      a_prompt = {x=-100,y=-100},
      travel_console = {x=100,y=60},
    },
  },
  station_ganymede = {
    mx0=0,my0=0,mx1=32,my1=16,
    actors={
      player = {x=52,y=104},
      travel = {x=80,y=104},
      customs = {x=32,y=64,is_blocking=true},
      trader = {x=20,y=24},
      fueler = {x=40,y=104},
      armsdealer = {x=160,y=40},
      a_prompt = {x=-100,y=-100},
      travel_console = {x=100,y=60},
    },
  },
  station_callisto = {
    mx0=0,my0=0,mx1=32,my1=16,
    actors={
      player = {x=52,y=104},
      travel = {x=80,y=104},
      customs = {x=32,y=64,is_blocking=true},
      trader = {x=20,y=24},
      fueler = {x=40,y=104},
      armsdealer = {x=160,y=40},
      a_prompt = {x=-100,y=-100},
      travel_console = {x=100,y=60},
    },
  }
}
ticker = 0
win_amount = 1000 --k$
customs_amount = 0.1 --k$
lose_amount = 100
trade_goods = {'medicine','parcels','machinery','electronics'}
trade_good_info = {
  medicine = {sprite_id = 64, base_price = 10, bulk = 1},
  parcels = {sprite_id = 65, base_price = 20, bulk = 2},
  machinery = {sprite_id = 66, base_price = 30, bulk = 3},
  electronics = {sprite_id = 67, base_price = 40, bulk = 4},
}
planets = {
  io= {sprite_id=110,s_w=2,s_h=2},
  europa= {sprite_id=108,s_w=2,s_h=2},
  ganymede= {sprite_id=106,s_w=2,s_h=2},
  callisto= {sprite_id=104,s_w=2,s_h=2}
}
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
