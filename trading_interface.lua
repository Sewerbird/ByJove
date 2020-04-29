function trading_interface(trader_tag,active_splat)
  -- A trade dialog
  local slf = interface()
  local w = 90
  local h = 50
  local c_x = 64+uix
  local l_x = c_x-w/2
  local t_y = 64-h/2+uiy
  local trader_business = gs[trader_tag].business
  local player_business = gs.player.business
  local my_trade_goods = {}
  for good in all(trade_goods) do
    if gs[trader_tag].business[good] ~= nil then
      add(my_trade_goods,good)
    end
  end
  slf.update = function(me)
    if btnp(4) then
      sfx(37)
    end
  end
  slf._current_splat=active_splat or 'buy_'..my_trade_goods[1]
  slf._splat = splat('trading_interface',{x=l_x-2,y=t_y,w=w,h=h,c_f=1,c_b=13})
  slf._splats = define_splats({
    nameplate = { x=l_x,y=t_y-10,w=40,h=9,text="Trade",c_b=13,c_f=1,c_t=11 },
    them_header = { x=l_x,y=t_y,w=20,h=9,text="them",c_t=9 },
    sell_header = { x=l_x+20,y=t_y,w=20,h=9,text="sell",c_t=11 },
    buy_header = { x=l_x+50,y=t_y,w=20,h=9,text="buy",c_t=8 },
    ship_header = { x=l_x+70,y=t_y,w=20,h=9,text="ship",c_t=9 },
    wallet_balance = { x=c_x,y=t_y+h,w=40,h=9,text="$"..flr(player_business.balance*1000),c_b=13,c_f=1,c_t=11 },
    tonnage_balance = { x=c_x,y=t_y+h+10,w=40,h=9,text=""..player_business.cargo_used.."/"..player_business.cargo_space.."t",c_b=13,c_f=1,c_t=11 },
  })
  local i = 1
  for good in all(my_trade_goods) do
    reevaluate_price(trader_tag,good)
    slf._splats['them_'..good] = splat('them_'..good,{x=l_x,y=t_y+i*10,w=20,h=9,text=""..trader_business[good].stock })
    slf._splats['sell_'..good] = splat('sell_'..good,
      {x=l_x+20,y=t_y+i*10,w=20,h=9,c_ba=7,
      text="$"..flr(trader_business[good].buy_price),active=("sell_"..good)==slf._current_splat,
      right='buy_'..my_trade_goods[i],up=i>1 and 'sell_'..my_trade_goods[i-1] or nil, down=i<#my_trade_goods and 'sell_'..my_trade_goods[i+1] or nil,
      execute=sell_to_trader_action(trader_tag,good)})
    slf._splats['tag_'..good] = splat('tag_'..good, {x=l_x+40,y=t_y+i*10,w=10,h=9,sprite=trade_good_info[good].sprite_id })
    slf._splats['buy_'..good] = splat('buy_'..good,
      {x=l_x+50,y=t_y+i*10,w=20,h=9,c_ba=7,
      text="$"..flr(trader_business[good].sell_price),active=("buy_"..good)==slf._current_splat,
      left='sell_'..my_trade_goods[i],up=i>1 and 'buy_'..my_trade_goods[i-1] or nil, down=i<#my_trade_goods and 'buy_'..my_trade_goods[i+1] or nil,
      execute=buy_from_trader_action(trader_tag,good)
    })
    slf._splats['amt_'..good] = splat('amt_'..good,{x=l_x+70,y=t_y+i*10,w=20,h=9,text=""..player_business[good].stock})
    i+=1
  end
  return slf
end

