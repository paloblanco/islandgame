pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- island adventure
-- palo banco games 2023
-- rocco panella ;)

reqs=[[
must have:
- energy system
- baddies
- lives
- death
- status bar
- enemies
- getting stunned
- hammers
- beating the game
- some level variation
- falling into pits

nice to have:
- powerups
- end of level gimmick
- level generation 
- better player sprite
]]

function _init()
	--start_gameplay()
	start_title()
end

-- gameplay methods

function init_level()
	local p1 = return_p1()
	local lvl = return_level()
	local	cam = return_cam()
	local fruits = return_fruits(lvl)
	local bads = return_bads(lvl)
	reset_globals()
	return p1,lvl,cam,fruits,bads
end

function reset_globals()
	-- these are globals that get
	-- reset every level or life
	energy = 100
end

function update_gameplay()
	update_p1(p1,lvl)
	energy -= denergy
	check_fruits()
	check_bads()
	if energy <= 0 then
		die()
	end
end

function check_fruits()
	for f in all(fruits) do
		if collide_p1(p1,f,12,16) then
			if f.name == "flag" then
				level_end()
				return
			elseif f.name=="hammer" then
				score += f.points
				hammer=true
				del(fruits,f)
			else
				score += f.points
				energy += f.health
				energy = min(energy,100)
				del(fruits,f)
			end
		end
	end
end

function check_bads()
	for b in all(bads) do
		if collide_p1(p1,b,8,16) then
			energy -= b.damage
			if energy <= 0 then
				die()
			else
				hurt()
				del(bads,b)
			end
		end
	end
end

function hurt()
	for i=1,5,1 do
		flip()
	end
	p1.ground = false
	p1.dy = -2
	p1.dx = -4
	if (p1.left) p1.dx = 4 
end

function die()
	p1.ud = true
	for i=1,15,1 do
		_draw()
		flip()
	end
	local dy= -2.5
	for i=1,35,1 do
		p1.drawy += dy
		dy += .3
		_draw()
		flip()
	end
	lives += -1
	if lives >= 0 then
		start_gameplay()
	else
		start_gameover()
	end
end

function level_end()
	sfx(0)
	level_ix += 1
	for _=1,30,1 do
		flip()
	end
		start_map()
end

function draw_gameplay()
	cls(12)
	palt(0,false)
	palt(13,true)
	update_cam(p1,lvl,cam)
	map2()
	draw_p1(p1)
	local flicker = flr(t()*30)%2
	pset(p1.x,p1.y,7*flicker)
	for f in all(fruits) do
		spr(f.ix,f.x,f.y,2,2)
	end
	for b in all(bads) do
		spr(b.ix,b.x,b.y,2,2)
	end
	-- overlay
	camera()
	draw_status()
	palt()
end

function draw_status()
	rectfill(0,128-status_height,127,127,0)
	rect(0,128-status_height,127,127,6)
	spr(49,3,118)
	offprint(lives,14,120,7,2)
	local bars = energy\5
	local x = 28
	for i=1,bars,1 do
		line(x+i*3,118,x+i*3,125,7)
		line(x+i*3-1,119,x+i*3-1,124,2)
	end
	local scorewidth=6
	local zeropad = scorewidth - #(""..score)
	local scorestr = ""
	for i=1,zeropad,1 do
		scorestr = scorestr.."0"
	end
	scorestr = scorestr..score
	offprint(scorestr,100,120,7,2)
end

function start_gameplay()
	fade_out()
	p1,lvl,cam,fruits,bads = init_level()
	_update60 = update_gameplay
	_draw = draw_gameplay
	_update60() -- call once so graphics work
	menuitem(1,"skip level",level_end)
	fade_in()
end

-- title methods
function start_title()
	init_globals()
	_update60 = update_title
	_draw = draw_title
	game_start=false
end

function update_title()
	if btnp(4) or btnp(5) then
--		fade_out()
		start_map()
--		fade_in()
	end
	if not game_start then
		fade_in()
		game_start=true
	end
end

function draw_title()
	cls(12)
	cprint("island adventure",20,0,9)
	cprint("press x, c, or z",40,0,9)
end

function init_globals()
	lives = 0
	level_ix = 1
	status_height = 12
	score = 0
	denergy = 5/60
	hammer = false
	reset_globals()
end

function fade_out()
	camera()
	local r = 0
	while r < 90 do
		circfill(64,64,r,0)
		flip()
		r += 3
	end
end

function fade_in()
	camera()
	local r = 90
	while r >= 0 do
		_draw()
		circfill(64,64,r,0)
		flip()
		r -= 3
	end
end

-- map methods
function start_map()
--	init_globals()
	fade_out()
	_update60 = update_map
	_draw = draw_map
	fade_in()
end

function update_map()
	if btnp(4) or btnp(5) then
		--fade_out()
		start_gameplay()
		--fade_in()
	end
end

function draw_map()
	cls(12)
	print(level_ix,1,1,0)
end


-- gameovrt methods
function start_gameover()
--	init_globals()
	fade_out()
	_update60 = update_gameover
	_draw = draw_gameover
	fade_in()
end

function update_gameover()
	if btnp(4) or btnp(5) then
		fade_out()
		start_title()
	end
end

function draw_gameover()
	map()
	cls(1)
	cprint("game over",60,0,6)
end
-->8
-- player

function return_p1()
	local p1 = {}
	p1.x = 32
	p1.y = 64
	p1.dx = 0
	p1.dy = 0
	p1.jumpmax=15
	p1.jump=0
	p1.offset = 0
	p1.offtime_max = 10
	p1.offtime = 0
	p1.left = false
	p1.ud = false --upsidedown
	p1.run=false
	p1.move=false
	p1.ground=false
	return p1
end

function update_p1(p1,lvl)
	p1.offtime = (p1.offtime+1)%p1.offtime_max
	if (p1.offtime == p1.offtime_max-1) p1.offset = 1-p1.offset
	
	p1.run=false
	
	-- horizontal mvmt
	if btn(4) then
		p1.run=true
		p1.offtime += 1
		if (p1.offtime == p1.offtime_max-1) p1.offset = 1-p1.offset		
	end
	
	
	p1.move=false
	if btn(0) then
		p1.dx += -.2
		p1.move=true
		p1.left = true
		p1.offtime += 1
		if (p1.offtime == p1.offtime_max-1) p1.offset = 1-p1.offset
	end
	
	if btn(1) then
		p1.dx += .2
		p1.move = true
		p1.left = false
		p1.offtime += 1
		if (p1.offtime == p1.offtime_max-1) p1.offset = 1-p1.offset
	end
	
	local maxspeed = 1
	if (p1.run) maxspeed = 1.5
	if abs(p1.dx) > maxspeed then
		p1.dx -= 0.3*sgn(p1.dx)
	end
	
	if (not p1.move) then
		p1.dx -= 0.2*sgn(p1.dx)
		if (abs(p1.dx) <= 0.2) p1.dx=0
	end
	
	p1.x += p1.dx
	
	-- vertical mvmt
	if p1.jump < p1.jumpmax and btn(5) then
		p1.jump += 1
		p1.dy = -2.5
	else
		p1.dy+= 0.2
		p1.jump=p1.jumpmax
	end
	
	if btn(5) and p1.jump==0 and p1.ground then
		p1.dy = -2.5
		p1.ground=false
		p1.jump += 1
	end	
	
	while abs(p1.dy) > 2.5 do
		p1.dy -= sgn(p1.dy)*.1
	end
	p1.y += p1.dy
	
	-- collisions
	p1.ground=false
	while downcheck(p1) do
		p1.y += -1
		p1.y = flr(p1.y)
		p1.ground=true
		p1.jump=0
	end
	
	while rcheck(p1) or p1.x+8 > lvl.x1*8 do
		p1.x += -1
		p1.x = flr(p1.x)
		p1.dx = min(p1.dx,0)
	end

	while lcheck(p1) or p1.x < 0 do
		p1.x += 1
		p1.x = flr(p1.x)
		p1.dx = max(p1.dx,0)
	end		
	
	-- drawing
	p1.drawx = p1.x-4
	p1.drawy = p1.y-16
	p1.sp = 1+2*p1.offset
end

function downcheck(p)
	-- solid ground
	local c1 = fget(mget2((p.x+1)\8,(p.y+7)\8),0)
	local c2 = fget(mget2((p.x+6)\8,(p.y+7)\8),0)
	if (c1 or c2) return true
	
	-- slope right
	if (downsloper(p)) return true
	
	-- ground only 
	if (downonly(p)) return true
	
	-- slope left
	if (downslopel(p)) return true
	
	-- all passing
	return false
end

function downsloper(p)
	local c1 = fget(mget2((p.x+4)\8,(p.y+7)\8),1)
	if c1 then
		local xc = (p.x+4)%8
		local yc = (p.y+7)%8
		return (7-yc) < xc
	end
	return false
end

function downslopel(p)
	local c1 = fget(mget2((p.x+4)\8,(p.y+7)\8),3)
	if c1 then
		local xc = (p.x+4)%8
		local yc = (p.y+7)%8
		return yc > xc
	end
	return false
end


function downonly(p)
	local c1 = fget(mget2((p.x+4)\8,(p.y+7)\8),2)
	return c1
end

function rcheck(p)
	local c1 = fget(mget2((p.x+8)\8,(p.y+3)\8),0)
	local c2 = fget(mget2((p.x+8)\8,(p.y-3)\8),0)
	return c1 or c2
end

function lcheck(p)
	local c1 = fget(mget2((p.x-1)\8,(p.y+3)\8),0)
	local c2 = fget(mget2((p.x-1)\8,(p.y-3)\8),0)
	return c1 or c2
end


function draw_p1(p1)
	spr(p1.sp,p1.drawx,p1.drawy,2,3,p1.left,p1.ud)
end

-- collision methods

function collide(a1,a2,r)
	local r = r or 8
	return abs(a1.x-a2.x)<r and abs(a1.y-a2.y)<r
end

function collide_p1(p,a,rx,ry)
	local rx = rx or 16
	local ry = ry or 24
	local px = p.x-4
	local py = p.y-16
	return abs(px-a.x)<rx and abs(py-a.y)<ry
end
-->8
-- levels

-- map functions to handle wrapping
function mget2(x,y)
	yadd = (x\128)*16
	x = x%128
	y = y + yadd
	return mget(x,y)
end

function mset2(x,y,v)
	yadd = (x\128)*16
	x = x%128
	y = y + yadd
 mset(x,y,v)
end

function map2()
	for i=0,3,1 do
		map(128*i,16*i, -- map xy
		    128*8*i,0, -- screen xy
		    128,16) -- mapdxdy
	end
end

function return_level()
-- use extended memory
	poke(0x5f56,0x80) -- keep width as 128
	local level = {}
	level.x0 = 0
	level.y0 = 0
	level.x1 = 128
	level.y1 = 16
	--clear mem, must be a bettery way
	for i=level.x0,level.x1-1,1 do
		for j=0,15,1 do
			mset2(i,j,0)
		end
	end
		
	for i=level.x0,level.x1-1,1 do
		local starty=14
		if i%16 > 13 then
			starty=11
		end
		mset2(i,starty,5)
		if i%16 == 13 or i%16 == 15 then
			starty=11
			mset2(i,starty,54)
		end
		if i%16 == 12 then
			starty=11
			mset2(i,starty,37)
			starty += 1
			mset2(i,starty,53)
		end
		if i%16 == 0 then
			starty=11
			mset2(i,starty,38)
			starty += 1
			mset2(i,starty,22)
		end
		if i%16 == 11 then
			starty=12
			mset2(i,starty,37)
			starty += 1
			mset2(i,starty,53)
		end
		if i%16 == 1 then
			starty=12
			mset2(i,starty,38)
			starty += 1
			mset2(i,starty,22)
		end
		if i%16 == 10 then
			starty=13
			mset2(i,starty,37)
			starty += 1
			mset2(i,starty,53)
		end
		if i%16 == 2 then
			starty=13
			mset2(i,starty,38)
			starty += 1
			mset2(i,starty,22)
		end
		for yy=starty+1,15,1 do
			mset2(i,yy,21)
		end
	end
	return level
end
-->8
-- camera

function return_cam()
	local cam={}
	cam.x = 0
	cam.y = 0
	return cam
end

function update_cam(p1,lvl,cam)
	cam.x = max(lvl.x0*8,p1.x-60)
	cam.x = min(cam.x,(lvl.x1-16)*8)
	cam.y = status_height
	camera(cam.x,cam.y)
end
-->8
-- utils

function ospr(ix,x,y,co)
	--pal({0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
	for ii=0,15,1 do
		pal(ii,co)
	end
	pal(13,13)
	for xx=-1,1,1 do
		for yy =-1,1,1 do
			spr(ix,x+xx,y+yy)
		end
	end
	pal()
	palt(0,false)
	palt(13,true)
	spr(ix,x,y)
end

function oprint(str,x,y,c,co)
	for xx=-1,1,1 do
		for yy =-1,1,1 do
			print(str,x+xx,y+yy,co)
		end
	end
	print(str,x,y,c)
end

function offprint(str,x,y,c,co)
	print(str,x-1,y-1,co)
	print(str,x,y,c)
end

function cprint(str,y,c,co)
	local x = 64 - #str*2
	oprint(str,x,y,c,co)
end
-->8
-- map


-->8
-- items

fruit_kinds = {}
-- ix,      name,health,points
fruit_kinds[9]={"apple",10,20}
fruit_kinds[7]={"flag",0,1000}
fruit_kinds[11]={"hammer",0,2000} 


function make_fruit(ix,x,y)
 local f = {}
	f.ix = ix
	f.name = fruit_kinds[ix][1]
	f.health = fruit_kinds[ix][2]
	f.points = fruit_kinds[ix][3]
	f.x = x
	f.y = y
	return f 
end


function return_fruits(lvl)
	local x,y
	local fruits={}
	for x=lvl.x0,lvl.x1-1,1 do
		if rnd() < .04 then
			y = flr(rnd(16))
			while mget2(x,y+1)>0 do
				y -= 1
			end
			x *= 8
			y *= 8
			add(fruits,make_fruit(9,x,y))
		end
	end
	x=126
	y=14
	while mget2(x,y+1)>0 do
		y -= 1
	end
	y *= 8
	x *= 8
	add(fruits,make_fruit(7,x,y))
	return fruits
end
-->8
-- bads

function update_snail()
end

function make_bad(ix,x,y)
 local b = {}
	b.ix = ix
	b.name = bad_kinds[ix][1]
	b.health = bad_kinds[ix][2]
	b.damage = bad_kinds[ix][3]
	b.points = bad_kinds[ix][4]
	b.update = bad_kinds[ix][5]

	b.x = x
	b.y = y
	return b 
end

function return_bads(lvl)
	local x,y
	local bads={}
	for x=lvl.x0,lvl.x1-1,1 do
		if rnd() < .04 then
			y = 14
			while mget2(x,y+1)>0 do
				y -= 1
			end
			x *= 8
			y *= 8
			add(bads,make_bad(snail,x,y))
		end
	end
	return bads
end


bad_kinds = {}
-- ix,      name,health,damage,points,updater
bad_kinds[39]={"snail",1,20,100,update_snail}
snail=39
--bad_kinds[7]={"flag",0,1000}
--bad_kinds[11]={"hammer",0,2000} 


__gfx__
00000000dddddddddddddddddddd00000000dddd0000000000000000dddddddddddddddddddddddddddddddddddddddddddddddd000000000000000000000000
00000000dddd00000000dddddd00444444440ddd3333333300000000dddddddddddd0dddddddddddd0dddddddddddddd00dddddd000000000000000000000000
00700700dd00444444440dddd0444444444440ddbbb3bbb300000000ddd000ddddd070dddddddddd0dddddddddddddd0640ddddd000000000000000000000000
00077000d0444444444440ddd0444ff444ff440dbb3bbb3b00000000ddd07700dd0770dddddd000d0d00dddddddddd066460dddd000000000000000000000000
00077000d0444ff444ff440d0444ff0444f0440db3bbb3bb00000000ddd07777007770ddddd0888000880dddddddd06664660ddd000000000000000000000000
007007000444ff0444f0440d044fff0f4ff040ddbbbbbbbb00000000ddd07777777770dddd087888088780ddddddd066646660dd000000000000000000000000
00000000044fff0f4ff040dd044fff0ffff0f0ddbbbbbbbb00000000ddd07777777770ddd08788888888780ddddddd044444440d000000000000000000000000
00000000044fff0ffff0f0dd0444fffffffff0ddbbbbbbbb00000000ddd07777777700ddd08888888888880dddddddd06466660d000000000000000000000000
000000000444fffffffff0ddd0444444444440ddbbbbbbbbbbbbbbb3ddd000777770ddddd08888888888880ddddddd04046660dd000000000000000000000000
00000000d0444444444440dddd0444f00ff40dddbbbbbbbbbbbbbbbbddd0dd00770dddddd08888888888880dddddd040d0660ddd000000000000000000000000
00000000dd0444f00ff40dddddd044444440ddddbbb3bbb3bbb3bbb3ddd0dddd00ddddddd08888888888880dddd0040ddd00dddd000000000000000000000000
00000000ddd044444440dddddddd0ff4400dddddbb3bbb3bbb3bbb3bddd0dddddddddddddd088888888880dddd0660dddddddddd000000000000000000000000
00000000dddd0ff4400ddddddd00fffffff0ddddb3bbb3bbb3bbb3bbddd0ddddddddddddddd0888888880ddddd0660dddddddddd000000000000000000000000
00000000dd00fffffff0ddddd0ffffffffff0dddbbbbbbbbbbbbbbbbddd0dddddddddddddddd08800880ddddddd00ddddddddddd000000000000000000000000
00000000d0ffffffffff0ddd0fff00ffffff0dddbbbbbbbbbbbbbbbbddd0ddddddddddddddddd00dd00ddddddddddddddddddddd000000000000000000000000
000000000fff00ffffff0ddd0fffff0fffff00ddbbbbbbbbbbbbbbbbddd0dddddddddddddddddddddddddddddddddddddddddddd000000000000000000000000
000000000fffff0fffff00dd0ffff0fff0ff0f0dddddddd00ddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
000000000ffff0fff0ff0f0dd0000000000000dddddddd0330ddddddddddddd00000dddd00000000000000000000000000000000000000000000000000000000
00000000d0000000000000dd044444444444440dddddd03bb30ddddddddddd0777770ddd00000000000000000000000000000000000000000000000000000000
00000000044444444444440d040004440000040ddddd03bbbb30ddddddddd077777770dd00000000000000000000000000000000000000000000000000000000
00000000040004440000040d00fff000d0fff0ddddd03bbbbbb30ddddddd07770077770d00000000000000000000000000000000000000000000000000000000
0000000000fff000d0fff0dddd0000ddd0fff0dddd03bbbbbbbb30ddddd077707707777000000000000000000000000000000000000000000000000000000000
00000000d0ffff0ddd000dddddddddddd0ffff0dd03bbbbbbbbbb30dddd077077770777000000000000000000000000000000000000000000000000000000000
00000000dd00000ddddddddddddddddddd00000d03bbbbbbbbbbbb30ddd077077070777000000000000000000000000000000000000000000000000000000000
00000000d444444ddddddddddddddddddddddddd3bbbbbbb00000000d00070007707777000000000000000000000000000000000000000000000000000000000
000000004f0ff0f4ddddddddddddddddddddddddbbbbbbbb333333330eee0eee0777777000000000000000000000000000000000000000000000000000000000
000000004f0ff0f4ddddddddddddddddddddddddbbb3bbb3bbb3bbb3070707070777770d00000000000000000000000000000000000000000000000000000000
00000000d444444dddddddddddddddddddddddddbb3bbb3bbb3bbb3b07770777007770dd00000000000000000000000000000000000000000000000000000000
00000000ffffffffddddddddddddddddddddddddb3bbb3bbb3bbb3bbd000e00077070ddd00000000000000000000000000000000000000000000000000000000
00000000dffffffdddddddddddddddddddddddddbbbbbbbbbbbbbbbbddd0eee00000dddd00000000000000000000000000000000000000000000000000000000
00000000d444444dddddddddddddddddddddddddbbbbbbbbbbbbbbbbdd0eeeeeeeee0ddd00000000000000000000000000000000000000000000000000000000
00000000ddfddfddddddddddddddddddddddddddbbbbbbbbbbbbbbbbd0000000000000dd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd00000000000000000000000000000000000000000000000000000000
__gff__
0000000000010000000000000000000000000000000104000000000000000000000000000002080000000000000000000000000000040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151515151515151515151500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01080000270561f056220561805622056180561d05618056270561f05622056180560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
