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
             update=function(self)
                 --start with assumption
                 --that not a new press.
                 self.is_pressed=false
                 if btn(5) then
                     if not self.is_down then
                         self.is_pressed=true
                     end
                     self.is_down=true
                     self.ticks_down+=1
                 else
                     self.is_down=false
                     self.is_pressed=false
                     self.ticks_down=0
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
            walk = { ticks=1, frames={180,181,182,183,184,185,186,187}},
            slide= { ticks=1, frames={164,165,166,167,168,169,170,171}},
            jump = { ticks=1, frames={141}},
            climb = { ticks=2, frames={144,145,146,147}},

            prone = { ticks=1, frames={32}},
            crouching = { ticks=1, frames={51}},
            jump_idle = { ticks=1, frames={14,15}},
            jumpdown = { ticks=1, frames={15,14,13,12,11}},
            dropdown = { ticks=1, frames={44,45,46,47,48,33,32}},
            dropdown_gun = { ticks=1, frames={60,61,62,63,50,49,48}},
            equip = { ticks=1, frames={1,2,3,4}},
            unequip = { ticks=1, frames={4,3,2,1}},
            standup = { ticks=1, frames={32,33,34,35,1}},
            laydown = { ticks=1, frames={1,35,34,33,32}},
            standup_gun = { ticks=1, frames={48,49,50,51,3}},
            laydown_gun = { ticks=1, frames={3,51,50,49,48}},
         },
         --request new animation to play.
         set_anim=function(self,anim)
             if(anim==self.curanim) return--early out.
             local a=self.anims[anim]
             self.animtick=a.ticks--ticks count down.
             self.curanim=anim
             self.curframe=1
         end,
         --call once per tick.
         update=function(self)
             --todo: kill enemies.
             --track button presses
             local bl=btn(0) --left
             local br=btn(1) --right
             --move left/right
             if bl==true then
                 self.dx-=self.acc
                 br=false--handle double press
             elseif br==true then
                 self.dx+=self.acc
             else
                 if self.grounded then
                     self.dx*=self.dcc
                 else
                     self.dx*=self.air_dcc
                 end
             end
             if not self.climbing then
               --limit walk speed
               self.dx=mid(-self.max_dx,self.dx,self.max_dx)
               --mve in x
               self.x+=self.dx
             end
             --hit walls
             collide_side(self)
             --jump buttons
             self.jump_button:update()
             --jump is complex.
             --we allow jump if:
             --    on ground
             --    recently on ground
             --    pressed btn right before landing
             --also, jump velocity is
             --not instant. it applies over
             --multiple frames.
             if self.jump_button.is_down then
                 --is player on ground recently.
                 --allow for jump right after 
                 --walking off ledge.
                 local on_ground=(self.grounded or self.airtime<5)
                 --was btn presses recently?
                 --allow for pressing right before
                 --hitting ground.
                 local new_jump_btn=self.jump_button.ticks_down<10
                 --is player continuing a jump
                 --or starting a new one?
                 if (on_ground and new_jump_btn) then
                     --if(self.jump_hold_time==0)sfx(snd.jump)--new jump snd
                     self.jump_hold_time+=1
                     --keep applying jump velocity
                     --until max jump time.
                     if self.jump_hold_time<self.max_jump_press then
                         self.dy=self.jump_speed--keep going up while held
                     end
                 end
             else
                 self.jump_hold_time=0
             end
             local can_ascend, can_descend, ladder_mid= collide_ladder(self)
             if can_ascend or can_descend then
               printh("can_ascend = "..(can_ascend and "true" or "false")..", can_descend = "..(can_descend and "true" or "false")..", ladder_mid"..ladder_mid)
               --see if climbing
               if self.climbing then
                 --has grabbed the ladder and is moving up and down or staying still
                 self.x = ladder_mid
                 self.dx = 0
                 if btn(2) then--up
                   printh("ascending "..self.curanim)
                   self:set_anim("climb")
                   self.dy=0
                   self.y-=1
                 elseif btn(3) then--down
                   printh("descending"..self.curanim)
                   self:set_anim("climb")
                   self.dy=0
                   self.y+=1
                   collide_roof(self)
                 --elseif btn(5) then--X button: trying to jump off
                   --TODO doesn't allow jumping off ladder atm
                   --self.climbing = false
                 else
                   printh("holding")
                   --move in y
                   self.dy=0
                   self.y+=0
                 end
               else
                 --might be trying to start climb
                 if (btn(2) and can_ascend) or (btn(3) and can_descend) then
                   printh("grabbing")
                   self.climbing = true
                   self:set_anim("climb")
                 else
                   printh("nexting")
                   self.nexting = true
                 end
               end
             else
               self.climbing = false
               self.nexting = false
               --move in y
               self.dy+=self.grav
               self.dy=mid(-self.max_dy,self.dy,self.max_dy)
               self.y+=self.dy
               collide_floor(self)
             end
             if not self.climbing then
               --floor
               if not collide_floor(self) and not self.nexting then
                   printh("falling")
                   self:set_anim("jump")
                   self.grounded=false
                   self.airtime+=1
               elseif not collide_floor(self) and self.nexting then
                 self:set_anim("stand")
                 self.grounded=false
                 self.airtime+=1
                 collide_floor(self)
               end
               --roof
               collide_roof(self)
             end
             --handle playing correct animation when on the ground.
             if self.grounded and not self.climbing then
                 if br then
                     if self.dx<0 then
                         --pressing right but still moving left.
                         self:set_anim("slide")
                     else
                         self:set_anim("walk")
                     end
                 elseif bl then
                     if self.dx>0 then
                         --pressing left but still moving right.
                         self:set_anim("slide")
                     else
                         self:set_anim("walk")
                     end
                 else
                     self:set_anim("stand")
                 end
             end
             --flip
             if br then
                 self.flipx=false
             elseif bl then
                 self.flipx=true
             end
             --anim tick
             self.animtick-=1
             if self.animtick<=0 then
                 self.curframe+=1
                 local a=self.anims[self.curanim]
                 self.animtick=a.ticks--reset timer
                 if self.curframe>#a.frames then
                     self.curframe=1--loop
                 end
             end
         end,
         --draw the player
         draw=function(self)
             local a=self.anims[self.curanim]
             local frame=a.frames[self.curframe]
             palt(0,true)
             spr(frame,
                 self.x-(self.w/2),
                 self.y-(self.h/2),
                 self.w/8,self.h/8,
                 self.flipx,
                 false)
             pal()

         end,
     }

     --Add attributes
     for k,v in pairs(attributes) do
       p[k] = v
     end
 
     return p
 end
 
 --p8 functions
 --------------------------------
 --[[
 
 function _init()
     reset()
 end
 
 function _update60()
     ticks+=1
     p1:update()
     cam:update()
     --demo camera shake
     if(btnp(4))cam:shake(15,2)
 end
 
 function _draw()
 
     cls(0)
     
     camera(cam:cam_pos())
     
     map(0,0,0,0,128,128)
     
     p1:draw()
     
     --hud
     camera(0,0)
 
     printc("adv. micro platformer",64,4,7,0,0)
 
 end
 --]]
