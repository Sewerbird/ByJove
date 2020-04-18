--Game State
gs = {
  player = {sprite=2,w=8,h=8},
  customs = {sprite=7,text='customs',w=8,h=8},
  trader = {sprite=8,text='trader',w=8,h=8},
  fueler = {sprite=10,text='fueler',w=8,h=8},
  a_prompt = {sprite=9,w=8,h=8},
}
ticker = 0
win_amount = 100 --k$
lose_amount = 0
trade_good_keys = {"medicine","fuel","food","steel","weapons","robotics","tools","artwork"}
trade_goods = {
  medicine = {sprite_id = 10, base_price = 10, bulk = 1},
  fuel = {sprite_id = 6, base_price = 5, bulk = 3},
  food = {sprite_id = 3, base_price = 4, bulk = 3},
  steel = {sprite_id = 5, base_price = 6, bulk = 2},
  weapons = {sprite_id = 9, base_price = 10, bulk = 2},
  robotics = {sprite_id = 7, base_price = 8, bulk = 2},
  tools = {sprite_id = 8, base_price = 10, bulk = 2},
  artwork = {sprite_id = 2, base_price = 20, bulk = 2},
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
