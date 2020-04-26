--advanced micro platformer
 --@matthughson
 
 --if you make a game with this
 --starter kit, please consider
 --linking back to the bbs post
 --for this cart, so that others
 --can learn from it too!
 --enjoy! 
 --@matthughson
 
 function create_player(attributes)
     local p=
     {
         x=0,y=0,w=8,h=8,
         dx=0, dy=0, 
         max_dx=1,--max x speed
         max_dy=2,--max y speed
         jump_speed=-1.15,--jump veloclity
         acc=0.5,--acceleration
         dcc=0.4,--decceleration
         air_dcc=1,--air decceleration
         grav=0.25,
         jump_hold_time=0,--how long jump is held
         min_jump_press=3,--min time jump can be held
         max_jump_press=6,--max time jump can be held
         jump_btn_released=true,--can we jump again?
         grounded=false,--on ground
         airtime=0,--time since grounded
         curanim="walking",--currently playing animation
         curframe=1,--curent frame of animation.
         animtick=0,--ticks until next frame should show.
         flipx=false,--show sprite be flipped.
         --helper for more complex
         --button press tracking.
         --todo: generalize button index.
         jump_button=
         {
           update=function(slf)
             --start with assumption
             --that not a new press.
             slf.is_pressed=false
             if btn(5) then
               if not slf.is_down then
                 slf.is_pressed=true
               end
               slf.is_down=true
               slf.ticks_down+=1
             else
               slf.is_down=false
               slf.is_pressed=false
               slf.ticks_down=0
             end
           end,
           --state
           is_pressed=false,--pressed this frame
           is_down=false,--currently down
           ticks_down=0,--how long down
         },
         --animation definitions.
         --use with set_anim()
         anims=
         {
           stand = { ticks=1, frames={130}},
           walk_gun = { ticks=1, frames={180,181,182,183,184,185,186,187}},
           slide= { ticks=1, frames={164,165,166,167,168,169,170,171}},
           walk= { ticks=1, frames={164,165,166,167,168,169,170,171}},
           jump = { ticks=1, frames={141}},
           climb = { ticks=2, frames={144,145,146,147}},
           hold = {ticks=1, frames={145}},
         },
         --request new animation to play.
         set_anim=function(slf,anim)
           if(anim==slf.curanim) return--early out.
           local a=slf.anims[anim]
           slf.animtick=a.ticks--ticks count down.
           slf.curanim=anim
           slf.curframe=1
         end,
         --call once per tick.
         update=function(slf)
           --todo: kill enemies.
           --track button presses
           local bl=btn(0) --left
           local br=btn(1) --right
           if bl==true then
               slf.dx-=slf.acc
               br=false--handle double press
           elseif br==true then
               slf.dx+=slf.acc
           else
               if slf.grounded then
                   slf.dx*=slf.dcc
               else
                   slf.dx*=slf.air_dcc
               end
           end
           if not slf.climbing then
             slf.dx=mid(-slf.max_dx,slf.dx,slf.max_dx)
             slf.x+=slf.dx
           end
           collide_side(slf)
           slf.jump_button:update()
           if slf.jump_button.is_down then
             local on_ground=(slf.grounded or slf.airtime<5)
             local new_jump_btn=slf.jump_button.ticks_down<10
             if (on_ground and new_jump_btn) then
               --if(slf.jump_hold_time==0)sfx(snd.jump)--new jump snd
               slf.jump_hold_time+=1
               if slf.jump_hold_time<slf.max_jump_press then
                 slf.dy=slf.jump_speed--keep going up while held
               end
             end
           else
             slf.jump_hold_time=0
           end
           local can_ascend, can_descend, ladder_mid= collide_ladder(slf)
           if can_ascend or can_descend then
             if slf.climbing then
               slf.x = ladder_mid
               slf.dx = 0
               if btn(2) then--up
                 slf:set_anim("climb")
                 slf.dy=0
                 slf.y-=1
               elseif btn(3) then--down
                 slf:set_anim("climb")
                 slf.dy=0
                 slf.y+=1
                 collide_roof(slf)
               else
                 slf:set_anim("hold")
                 slf.dy=0
                 slf.y+=0
               end
             else
               --might be trying to start climb
               if (btn(2) and can_ascend) or (btn(3) and can_descend) then
                 slf.climbing = true
                 slf:set_anim("climb")
               else
                 slf.nexting = true
               end
             end
           else
             slf.climbing = false
             slf.nexting = false
             slf.dy+=slf.grav
             slf.dy=mid(-slf.max_dy,slf.dy,slf.max_dy)
             slf.y+=slf.dy
             collide_floor(slf)
           end
           if not slf.climbing then
             --floor
             if not collide_floor(slf) and not slf.nexting then
               printh("falling")
               slf:set_anim("jump")
               slf.grounded=false
               slf.airtime+=1
             elseif not collide_floor(slf) and slf.nexting then
               slf.grounded=false
               if sqrt(slf.dx*slf.dx) < 0.1 then slf:set_anim("stand") end
               slf.airtime+=1
               collide_floor(slf)
             end
             --roof
             collide_roof(slf)
           end
           --handle playing correct animation when on the ground.
           if slf.grounded and not slf.climbing then
             local anim = "stand"
             local slide_left = br and slf.dx < 0
             local slide_right = bl and slf.x > 0
             if slide_left or slide_right then
               anim = "slide"
             elseif br or bl then
               anim = "walk"
             end
             slf:set_anim(anim)
           end
           --flip
           slf.flipx = bl and true or (not br and slf.flipx or false)
           --anim tick
           slf.animtick-=1
           if slf.animtick<=0 then
             slf.curframe+=1
             local a=slf.anims[slf.curanim]
             slf.animtick=a.ticks--reset timer
             if slf.curframe>#a.frames then
               slf.curframe=1--loop
             end
           end
         end,
         --draw the player
         draw=function(slf)
           local a=slf.anims[slf.curanim]
           local frame=a.frames[slf.curframe]
           palt(0,true)
           spr(frame, slf.x-(slf.w/2), slf.y-(slf.h/2), slf.w/8,slf.h/8, slf.flipx, false)
           pal()
         end,
     }

     --Add attributes
     for k,v in pairs(attributes) do
       p[k] = v
     end
 
     return p
 end
