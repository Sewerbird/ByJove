get_xy = true
--Game State
gs = {
  player = {sprite=2,w=8,h=8},
  customs = {sprite=7,text='customs',w=8,h=8},
  trader = {sprite=8,text='trader',w=8,h=8},
  fueler = {sprite=10,text='fueler',w=8,h=8},
  armsdealer = {sprite=11,text='armsdealer',w=8,h=8},
  a_prompt = {sprite=9,w=8,h=8},
}
ticker = 0
win_amount = 100 --k$
lose_amount = 0
trade_goods = {'medicine','parcels','machinery','electronics'}
trade_good_info = {
  medicine = {sprite_id = 64, base_price = 10, bulk = 1},
  parcels = {sprite_id = 65, base_price = 20, bulk = 2},
  machinery = {sprite_id = 66, base_price = 30, bulk = 3},
  electronics = {sprite_id = 67, base_price = 40, bulk = 4},
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
