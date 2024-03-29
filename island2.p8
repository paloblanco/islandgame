pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- island adventure
-- palo banco games 2023
-- rocco panella ;)

-- no repeater
poke(0x5f5c,255)
-- use extended mem for map
poke(0x5f56,0x80)

reqs=[[
need:
- some level variation
- falling into pits

nice to have:
- powerups
- end of level gimmick
- level generation 
- better player sprite
- bosses?
]]

function starter_up()
	if time_start==1 then
		start_title()
		return
	else
		time_start += 1
	end
end

function _init()
	time_start=0
	--start_gameplay()
	_update60 = starter_up
	_draw = function() cls() end
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
	for b in all(bads) do
		if (abs(b.x-p1.x) < 120) b:update()
	end
	update_hammers()
	energy -= denergy
	check_fruits()
	check_bads()
	-- pit
	if (p1.y > 128) energy = 0
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
				kill_bad(b)
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
		return
	end
end

function level_end()
	sfx(0)
	level_ix += 1
	for _=1,30,1 do
		flip()
	end
	if level_ix < 9 then
		start_map()
	else
		start_gamewin()
	end
end

function draw_gameplay()
	cls(12)
	palt(0,false)
	palt(13,true)
	update_cam(p1,lvl,cam)
	map2()
	draw_p1(p1)
	--local flicker = flr(t()*30)%2
	--pset(p1.x,p1.y,7*flicker)
	for f in all(fruits) do
		spr(f.ix,f.x-f.w\2,f.y-f.h\2,2,2)
	end
	for b in all(bads) do
		spr(b.ix,b.x-b.w\2,b.y-b.h\2,2,2,b.faceleft)
	end
	for h in all(hammers) do
		spr(11,h.x-h.w\2,h.y-h.h\2,2,2)
	end
	-- overlay
	camera()
	draw_status()
	palt()
end

function kill_bad(b)
	del(bads,b)
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
	hammers = {}
	_update60 = update_gameplay
	_draw = draw_gameplay
	_update60() -- call once so graphics work
	camera()
	cls()
	menuitem(1,"skip level",level_end)
	fade_in()
end

-- title methods
function start_title()
	init_globals()
	_update60 = update_title
	_draw = draw_title
	--game_start=false
	fade_in()	
end

function update_title()
	if btnp(4) or btnp(5) then
		start_map()
	end
end

function draw_title()
	cls(12)
	cprint("island adventure",20,0,9)
	cprint("press x, c, or z",40,0,9)
end

function init_globals()
	lives = 3
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
	while r < 100 do
		circfill(64,64,r,0)
		flip()
		r += 3
	end
	--cls(0)
end

function fade_in()
	camera()
	local r = 100
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
		start_gameplay()
	end
end

function draw_map()
	cls(12)
	print(level_ix,1,1,0)
end


-- gameover methods
function start_gameover()
	fade_out()
	_update60 = update_gameover
	_draw = draw_gameover
	fade_in()
end

function update_gameover()
	if btnp(4) or btnp(5) then
		fade_out()
		start_title()
		return
	end
end

function draw_gameover()
	map()
	cls(1)
	cprint("game over",60,0,6)
end

-- gamewin methods
function start_gamewin()
	fade_out()
	_update60 = update_gamewin
	_draw = draw_gamewin
	fade_in()
end

function update_gamewin()
	if btnp(4) or btnp(5) then
		fade_out()
		start_title()
		return
	end
end

function draw_gamewin()
	map()
	cls(14)
	cprint("you win!",60,0,9)
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
	p1.w = 16
	p1.h = 24
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
	
	-- hammer time
	if btnp(4) and hammer and #hammers < 2 then
		if p1.left then
			make_hammer(-1,p1.x-4,p1.y-4)
		else
			make_hammer(1,p1.x-4,p1.y-4)
		end
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
	if btnp(5) and p1.jump==0 and p1.ground then
		p1.dy = -2.5
		p1.ground=false
		p1.jump += 1
	elseif p1.jump < p1.jumpmax and btn(5) and not p1.ground then
		p1.jump += 1
		p1.dy = -2.5
	else
		p1.dy+= 0.2
		p1.jump=p1.jumpmax
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
	p1.drawx = p1.x-p1.w\2
	p1.drawy = p1.y-p1.h\2
	p1.sp = 1+2*p1.offset
end

function downcheck(p)
	-- solid ground
	local c1 = fget(mget2((p.x-3)\8,(p.y-1+p.h\2)\8),0)
	local c2 = fget(mget2((p.x+3)\8,(p.y-1+p.h\2)\8),0)
	if (c1 or c2) return true
	
	-- slope right
	if (downsloper(p)) return true
	
	-- ground only 
	if (downonly(p)) return true
	
	-- slope left
	if (downslopel(p)) return true
	
	-- pass through
	if (downonlypass(p)) return true
	
	-- all passing
	return false
end

function downsloper(p)
	local c1 = fget(mget2((p.x)\8,(p.y-1+p.h\2)\8),1)
	if c1 then
		local xc = (p.x)%8
		local yc = (p.y-1+p.h\2)%8
		return (8-yc) < xc
	end
	return false
end

function downslopel(p)
	local c1 = fget(mget2((p.x)\8,(p.y-1+p.h\2)\8),3)
	if c1 then
		local xc = (p.x)%8
		local yc = (p.y-1+p.h\2)%8
		return yc > xc
	end
	return false
end


function downonly(p)
	local c1 = fget(mget2((p.x)\8,(p.y-1+p.h\2)\8),2)
	return c1
end

function downonlypass(p)
	local ycheck = p.y-1+p.h\2
	if (p.dy<0) return false
	if (ycheck%8 > 4) return false
	local c1 = fget(mget2((p.x)\8,(ycheck)\8),4)
	return c1
end

function rcheck(p)
	local c1 = fget(mget2((p.x+p.w\4)\8,(p.y+3)\8),0)
	local c2 = fget(mget2((p.x+p.w\4)\8,(p.y-3)\8),0)
	return c1 or c2
end

function lcheck(p)
	local c1 = fget(mget2((p.x-p.w\4)\8,(p.y+3)\8),0)
	local c2 = fget(mget2((p.x-p.w\4)\8,(p.y-3)\8),0)
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
	local px = p.x
	local py = p.y
	return abs(px-a.x)<rx and abs(py-a.y)<ry
end

function make_hammer(dx,x,y)
	local h = {}
	h.dx = dx*2
	h.x = x
	h.y = y-6
	h.w = 16
	h.h = 16
	add(hammers,h)
end

function update_hammers()
	for h in all(hammers) do
		h.x += h.dx
		h.y += .5
		
		for b in all(bads) do
			if collide(h,b,10) then
				hurt_bad(b)
				del(hammers,h)
			end
		end
		
		if mget2((h.x)\8,(h.y)\8) > 0 or
		abs(h.x-p1.x)>100 then
			del(hammers,h)
		end
	end
end
-->8
-- levels

-- map functions to handle wrapping
function mget2(x,y)
	local yadd = (x\128)*16
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
		map(0,16*i, -- map xy
		    128*8*i,0, -- screen xy
		    128,16) -- mapdxdy
	end
end


function return_level()
	poke(0x5f56,0x80) -- keep width as 128
	local rom0 = 0x2000
	local ram0 = 0x8000
	local rooms = 32
	local level = {}
	level.x0 = 0
	level.y0 = 0
	level.x1 = rooms*16
	level.y1 = 16
	level.rooms = rooms
	--clear mem, must be a better way
	for i=level.x0,level.x1-1,1 do
		for j=0,15,1 do
			mset2(i,j,0)
		end
	end
	for r=0,rooms-1,1 do
		xstart = r*16
		xfetch = (r%5)*16
		ystart = 0
		for xx = xstart,xstart+15,1 do
			for yy = ystart,ystart+7,1 do
				poke(0x5f56,0x20)
				val = mget2(xx%16+xfetch,yy)
				poke(0x5f56,0x80)
				mset2(xx,yy+8,val)
			end		
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
	f.w = 16 -- sprite width
	f.h = 16 -- sprite height
	return f 
end


function return_fruits(lvl)
	local x,y,q
	local fruits={}
	local rooms = lvl.rooms
	for q = 0,rooms-1,1 do
		while true do
			if rnd() < .5 then
				y = flr(rnd(8))+1
				x = flr(rnd(15)) + 16*q
				while mget2(x,y+1)>0 do
					y -= 1
				end
				x *= 8
				x += 8 
				y *= 8
				y += 8
				add(fruits,make_fruit(9,x,y))
			else
				break
			end
		end
	end
	x=lvl.x1 - 2
	y=14
	-- flag
	while mget2(x,y+1)>0 do
		y -= 1
	end
	y *= 8
	x *= 8
	y += 8
	x += 8
	add(fruits,make_fruit(7,x,y))
	--hammer
	x=96
	y=64
	add(fruits,make_fruit(11,x,y))
	return fruits
end
-->8
-- bads

function update_snail(b)
	b.dy += .05
	b.y += b.dy
	local floor = false
	while downcheck(b) do
		b.y -= 1
		b.y = flr(b.y)
		b.dy = 0
		floor = true
	end
	if (b.dx==0) b.dx = -0.25
	if b.dx < 0 then
		if mget2((b.x-b.w\2)\8,(b.y+6)\8)>0 then
			b.dx *= -1
		elseif floor and mget2((b.x-b.w\2)\8,(b.y+8)\8)==0 then
			b.dx *= -1
		end
	else
		if mget2((b.x+b.w\2)\8,(b.y+6)\8)>0 then
			b.dx *= -1
		elseif floor and mget2((b.x+b.w\2)\8,(b.y+8)\8)==0 then
			b.dx *= -1
		end
	end
	b.faceleft = b.dx < 0
	b.x += b.dx
end

function update_bird(b)
end

function make_bad(ix,x,y)
 local b = {}
	b.ix = ix
	b.name = bad_kinds[ix][1]
	b.health = bad_kinds[ix][2]
	b.damage = bad_kinds[ix][3]
	b.points = bad_kinds[ix][4]
	b.update = bad_kinds[ix][5]
	
	b.faceleft=false
	b.x = x
	b.y = y
	b.w = 16
	b.h = 16
	b.dx = 0
	b.dy = 0
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
			y += 8
			add(bads,make_bad(snail,x,y))
		end
	end
	return bads
end

function hurt_bad(h,dmg)
	local dmg = dmg or 1
	h.health += -dmg
	if h.health <= 0 then
		kill_bad(h)
	end
end

bad_kinds = {}
-- ix,      name,health,damage,points,updater
bad_kinds[39]={"snail",1,20,100,update_snail}
snail = 39
bad_kinds[43]={"bird",1,20,100,update_bird}
bird = 43

__gfx__
77000000dddddddddddddddddddd00000000dddd0000000000000000ddd0dddddddddddddddddddddddddddddddddddddddddddd000000000000000000000000
00000000dddd00000000dddddd00444444440ddd3333333333343334dd070ddddddd0dddddddddddd0dddddddddddddd00dddddd000000000000000000000000
00700700dd00444444440dddd0444444444440ddb3b3b3b343344334ddd000ddddd070dddddddddd0dddddddddddddd0640ddddd000000000000000000000000
00077000d0444444444440ddd0444ff444ff440d3b3b3b3b44444444ddd07700dd0770dddddd000d0d00dddddddddd066460dddd000000000000000000000000
00077000d0444ff444ff440d0444ff0444f0440dbbbbbbbb44444444ddd07777007770ddddd0888000880dddddddd06664660ddd000000000000000000000000
007007000444ff0444f0440d044fff0f4ff040dd3bbb3bbbd44dd44dddd07777777770dddd087888088780ddddddd066646660dd000000000000000000000000
00000000044fff0f4ff040dd044fff0ffff0f0ddb3bbb3bbddddddddddd07777777770ddd08788888888780ddddddd044444440d000000000000000000000000
00000000044fff0ffff0f0dd0444fffffffff0ddbbbbbbbbddddddddddd07777777700ddd08888888888880dddddddd06466660d000000000000000000000000
000000000444fffffffff0ddd0444444444440ddbbbbbbbbbbbbbbb3ddd000777770ddddd08888888888880ddddddd04046660dd000000000000000000000000
00000000d0444444444440dddd0444f00ff40dddb3bbb3bbb3bbb3bbddd0dd00770dddddd08888888888880dddddd040d0660ddd000000000000000000000000
00000000dd0444f00ff40dddddd044444440ddddbb3bbb3bbb3bbb3bddd0dddd00ddddddd08888888888880dddd0040ddd00dddd000000000000000000000000
00000000ddd044444440dddddddd0ff4400dddddbbbbbbbbbbbbbbbbddd0dddddddddddddd088888888880dddd0660dddddddddd000000000000000000000000
00000000dddd0ff4400ddddddd00fffffff0ddddbbbbbbbbbbbbbbbbddd0ddddddddddddddd0888888880ddddd0660dddddddddd000000000000000000000000
00000000dd00fffffff0ddddd0ffffffffff0ddd3bbb3bbb3bbb3bbbddd0dddddddddddddddd08800880ddddddd00ddddddddddd000000000000000000000000
00000000d0ffffffffff0ddd0fff00ffffff0dddb3bbb3bbb3bbb3bbddd0ddddddddddddddddd00dd00ddddddddddddddddddddd000000000000000000000000
000000000fff00ffffff0ddd0fffff0fffff00ddbbbbbbbbbbbbbbbbddd0dddddddddddddddddddddddddddddddddddddddddddd000000000000000000000000
000000000fffff0fffff00dd0ffff0fff0ff0f0dddddddd00ddddddddddddddddddddddd0000000000000000dddddddddddddddddddddddddddddddd00000000
000000000ffff0fff0ff0f0dd0000000000000dddddddd0330dddddddddd00000ddddddd3333333033333333ddd0ddddddd000dddddddddddddddddd00000000
00000000d0000000000000dd044444444444440dddddd03bb30dddddddd0777770ddddddb3b3b3b033b3b3b3dd060ddddd06660ddddddddd00d00ddd00000000
00000000044444444444440d040004440000040ddddd03b33b30dddddd077777770ddddd3b3b3b303b3b3b3bd06660dd0060060ddddddd00660660dd00000000
00000000040004440000040d00fff000d0fff0ddddd03bbbb3b30dddd07777007770ddddbbbbbbb03bbbbbbb06666600660660dddddd0060600600dd00000000
0000000000fff000d0fff0dddd0000ddd0fff0dddd03b3bbbb3b30dd0777707707770ddd3bbb3bb03bbb3bbb06666660600600ddddd0666600a00ddd00000000
00000000d0ffff0ddd000dddddddddddd0ffff0dd03bbbbbbbb3b30d0777077770770dddb3bbb3b033bbb3bbd066666600a00dddddd0666666aaa0dd00000000
00000000dd00000ddddddddddddddddddd00000d03b3bbbbbbbb3b300777070770770dddbbbbbbb03bbbbbbbd066666666aaa0dddd0666666aaaaa0d00000000
00000000d444444dddd00000000000000000dddd3b3bbbbb00000000077770770007000dbbbbbbb03bbbbbbbdd0666666aaaaa0ddd0666666000006000000000
000000004f0ff0f4ddd43334333433343334ddddb3bbb3bb3333333307777770eee0eee0b3bbb3b033bbb3bbdd066666600000ddd0666666660d060d00000000
000000004f0ff0f4ddd44334433443344334dddd3b3bbb3bb3b3b3b3d077777070707070bb3bbb303b3bbb3bddd06666660dddddd066660660ddd0dd00000000
00000000d444444ddddd4444444444444444ddddbbbbbbbb3b3b3b3bdd07770077707770bbbbbbb03bbbbbbbdddd060660dddddd066660000d00dddd00000000
00000000ffffffffdddd444444444444444dddddbbbbbbbbbbbbbbbbddd07077000e000dbbbbbbb03bbbbbbbddddd0000d00ddddd0660dd00d0a0ddd00000000
00000000dffffffdddddd44dd44dd44dd44ddddd3bbb3bbb3bbb3bbbdddd00000eee0ddd3bbb3bb03bbb3bbbddddddd00d0a0ddddd00ddd0a0d0dddd00000000
00000000d444444dddddddddddddddddddddddddb3bbb3bbb3bbb3bbddd0eeeeeeeee0ddb3bbb3b033bbb3bbddddddd0a0d0dddddddddddd0ddddddd00000000
00000000ddfddfddddddddddddddddddddddddddbbbbbbbbbbbbbbbbdd0000000000000dbbbbbbb03bbbbbbbdddddddd0ddddddddddddddddddddddd00000000
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
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccc99999999999c999999999999cccc9999999999999999999999999999999999999cccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccc90009900909c9000900990099ccc9000900990909000900990009090900090009cccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccc99099099909c9090909090909ccc9090909090909099909099099090909090999cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc9099000909c9000909090909ccc900090909090900990909909909090099009ccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccc9909999090999090909090909ccc9090909090009099909099099090909090999cccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccc9000900990009090909090009ccc9090900099099000909099099900909090009cccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccc9999999999999999999999999ccc999999999999999999999999c999999999999cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccc999999999999999999999ccc99999cccccccc9999cccccccc99999999ccc99999cccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccc900090009000990099009ccc90909ccccccc99009ccccccc990090009ccc90009cccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccc909090909099909990999ccc90909ccccccc90999ccccccc909090909ccc99909cccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccc900090099009900090009ccc99099999cccc909cc999cccc909090099ccc99099cccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccc909990909099999099909ccc90909909cccc90999909cccc909090909ccc90999cccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccc909c90909000900990099ccc90909099cccc99009099cccc900990909ccc90009cccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccc999c9999999999999999cccc9999999cccccc999999ccccc999999999ccc99999cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

__gff__
0000000000010400000000000000000000000000000104000000000000000000000000000002080000010100000000000000101010040400000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000002505050505050526000000000000000032333333333333340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000253515151515151516260000000000000000000000000000000000000000000000000032333334000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000002505050505260000000000000025351515151515151515162600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000253515151515162600000000002535151515151515151515151626000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000025351515151515151626000000253515151515151515151515151516260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050505050505050505050505050505050505053515151515151515151605050535151515151515151515151515151516050505050505050505050505050505050505052900000000000000002a050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515153900000000000000003a151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a05050505050505050505050505052900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3a15151515151515151515151515153900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01080000270561f056220561805622056180561d05618056270561f05622056180560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
