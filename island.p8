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
- hammer system

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
	p1 = return_p1()
	
	-- following makes lvl, fruits,
	-- bads, spawners
	make_level()
	
	-- makes cam global
	make_cam() 
	reset_globals()
end

function reset_globals()
	-- these are globals that get
	-- reset every level or life
	energy = 100
end

function update_gameplay()
	update_p1(p1,lvl)
	for b in all(bads) do
		if (abs(b.x-p1.x) < 170) b:update()
		if (b.y > 138) kill_bad(b)
	end
	for s in all(spawners) do
		if (abs(s.x-p1.x) < 170) s:update()
	end
	update_hammers()
	energy -= denergy
	check_fruits()
	check_bads()
	check_balls()
	-- pit
	if (p1.y > 128) energy = 0
	if energy <= 0 then
		die()
	end
end

function check_balls()
	for b in all(balls) do
		b.dy += .05
		b.x += b.dx
		b.y += b.dy
		while mget2(b.x\8,b.y\8)>0 do
			b.y -= 1
			b.dy = -abs(b.dy)
		end
		local dx = b.x-p1.x
		local dy = b.y-p1.y
		if (abs(dx) > 120) or (abs(dy) > 100) then
			del(balls,b)
		end
		if collide_p1(p1,b,8,12) then
			hurt()
			del(balls,b)
		end
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
				hammer=min(4,hammer+1)
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
				--die()
				zz=1+1
			else
				hurt()
				--kill_bad(b)
				hurt_bad(b,1,true)
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
	--if (p1.left) p1.dx = 4 
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
	draw_bg()
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
	for s in all(spawners) do
		if (s.visible) spr(s.ix,s.x-8,s.y-8,2,2)
	end
	for b in all(bads) do
		spr(b.ix,b.x-b.w\2,b.y-b.h\2,b.sw,b.sh,b.faceleft)
	end
	for b in all(balls) do
		spr(79,b.x-4,b.y-4)
	end
	for h in all(hammers) do
		draw_hammer(h)
	end
	-- overlay
	camera()
	draw_fg()
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
	init_level()
	hammers = {}
	balls = {}
	--spawners = {}
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
	lives = 30
	level_ix = 1
	status_height = 12
	score = 0
	denergy = 5/60
	hammer = 0
	hammerfire = false
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
	circfill(64,64,50,3)
	local pos = level_ix-1
	local xp = 64+40*cos(.25-pos/8)
	local yp = 64+40*sin(.25-pos/8)
	palt(0,false)
	palt(13,true)
	spr(49,xp-4,yp-4)
	palt()
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

function draw_hammer(h)
	local fliph = tf()%12<6
	local flipv = (tf()+3)%12<6
	spr(11,h.x-h.w\2,h.y-h.h\2,2,2,fliph,flipv)
	if (rnd(4)<1) circ(h.x,h.y,h.w/2-2,7)
	if (h.fire and tf()%2==0) circfill(h.x,h.y,h.w/2-2,8)
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
	if btnp(4) and #hammers < min(hammer,3) then
		if p1.left then
			make_hammer(-1,p1.x-4,p1.y-4,hammer>3)
		else
			make_hammer(1,p1.x-4,p1.y-4,hammer>3)
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

function make_hammer(dx,x,y,fire)
	local h = {}
	h.dx = dx*2
	h.x = x
	h.y = y-6
	h.w = 16
	h.h = 16
	h.fire = fire or false
	add(hammers,h)
end

function update_hammers()
	for h in all(hammers) do
		h.x += h.dx
		h.y += .5
		
		for b in all(bads) do
			if collide(h,b,b.r+2) then
				local d = 1
				if (h.fire) d=2
				hurt_bad(b,2,h.fire)
				del(hammers,h)
				if (b.health <= 0) score += b.points
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
	pal(3,map_pal[1])
	pal(11,map_pal[2])
	for i=0,3,1 do
		map(0,16*i, -- map xy
		    128*8*i,0, -- screen xy
		    128,16) -- mapdxdy
	end
	pal()
	palt(0,false)
	palt(13,true)
end


function make_level()
	n = level_ix or 1
	if (n > #level_funcs) n = 1
	poke(0x5f56,0x80) -- keep width as 128
	rom0 = 0x2000
	ram0 = 0x8000
	--clear mem, must be a better way
	for i=0,16*32-1,1 do -- 16*32 is map2 width
		for j=0,15,1 do
			mset2(i,j,0)
		end
	end
	level_builder = level_funcs[n]
	
	-- global declarations for 
	-- new level
	lvl = level_builder(n)
end

level_funcs = {}

function build_greens(n)
	room_candidates = {
		{0,3}, --room_id, likelihood
		{1,1},
		{2,1},
		{3,1},
	}
	bad_candidates = {
		{snail,.01,5,16},
		{bird,.01,3,8},
		{shell,.01,5,16},
	}
	level = builder(room_candidates,n) 
	fruits = return_fruits(level)
	spawners = {}
	--add(spawners,make_spawner(spawner_bulbird,10,20,s_bulbird_update))
	--add(spawners,make_spawner(spawner_fish,10,20,s_fish_update))
	bads = generate_bads(bad_candidates)
	--add(bads,make_fatdaddy(8*level.x1-50,20))
	draw_bg = draw_bg_greens
	map_pal = {3,11}
	return level
end
add(level_funcs,build_greens)

function build_caves(n)
	room_candidates = {
		{0,2}, --room_id, likelihood
		{2,1},
		{4,1},
	}
	bad_candidates = {
		{rock,.02,5,16},
		{bat,.01,3,6},
		{frog,.01,5,16},
	}
	level = builder(room_candidates,n) 
	fruits = return_fruits(level)
	spawners = {}
	--add(spawners,make_spawner(spawner_bulbird,10,20,s_bulbird_update))
	--add(spawners,make_spawner(spawner_fish,10,20,s_fish_update))
	bads = generate_bads(bad_candidates)
	draw_bg = draw_bg_cave
	map_pal = {2,14}
	return level
end
add(level_funcs,build_caves)

function build_bridge(n)
	room_candidates = {
		{5,2}, --room_id, likelihood
		{6,1},
		{7,1},
	}
	bad_candidates = {
		{frog,.01,5,16},
	}
	level = builder(room_candidates,n) 
	fruits = return_fruits(level)
	spawners = {}
	--add(spawners,make_spawner(spawner_bulbird,10,20,s_bulbird_update))
	add(spawners,make_spawner(spawner_fish,10,20,s_fish_update))
	bads = generate_bads(bad_candidates)
	draw_bg = draw_bg_bridge
	map_pal = {3,11}
	return level
end
add(level_funcs,build_bridge)

function build_forest(n)
	room_candidates = {
		{0,2}, --room_id, likelihood
		{8,1},
		{9,1},
	}
	bad_candidates = {
		{bird,.01,5,16},
		{frog,.01,5,16},
	}
	level = builder(room_candidates,n,true) 
	fruits = return_fruits(level)
	spawners = {}
	--add(spawners,make_spawner(spawner_bulbird,10,20,s_bulbird_update))
	--add(spawners,make_spawner(spawner_fish,10,20,s_fish_update))
	make_cat_spawners(0.1)
	bads = generate_bads(bad_candidates)
	add(bads,make_fatdaddy(8*level.x1-50,20))
	draw_bg = draw_bg_forest
	map_pal = {5,15}
	return level
end
add(level_funcs,build_forest)

function build_cliffs(n)
	room_candidates = {
		{10,2}, --room_id, likelihood
		{4,1},
		{11,1},
	}
	bad_candidates = {
		{spike,.02,2,2},
		{rock,.02,5,16},
	}
	level = builder(room_candidates,n) 
	fruits = return_fruits(level)
	spawners = {}
	add(spawners,make_spawner(spawner_bulbird,10,20,s_bulbird_update))
	--add(spawners,make_spawner(spawner_fish,10,20,s_fish_update))
	--make_cat_spawners(0.1)
	bads = generate_bads(bad_candidates)
	draw_bg = draw_bg_cliffs
	map_pal = {1,14}
	return level
end
add(level_funcs,build_cliffs)

function build_swamps(n)
	room_candidates = {
		{3,2}, --room_id, likelihood
		{0,1},
		{10,1},
	}
	bad_candidates = {
		{spitter,.01,2,2},
		{frog,.01,5,16},
		{bat,.01,3,6},
	}
	level = builder(room_candidates,n) 
	fruits = return_fruits(level)
	spawners = {}
	--add(spawners,make_spawner(spawner_bulbird,10,20,s_bulbird_update))
	--add(spawners,make_spawner(spawner_fish,10,20,s_fish_update))
	--make_cat_spawners(0.1)
	bads = generate_bads(bad_candidates)
	draw_bg = draw_bg_swamps
	map_pal = {1,2}
	return level
end
add(level_funcs,build_swamps)

function build_beach(n)
	room_candidates = {
		{0,1}, --room_id, likelihood
		{7,1},
		{11,1},
	}
	bad_candidates = {
		{spitter,.005,2,2},
		{shell,.01,5,16},
		{bird,.01,3,6},
	}
	level = builder(room_candidates,n) 
	fruits = return_fruits(level)
	spawners = {}
	--add(spawners,make_spawner(spawner_bulbird,10,20,s_bulbird_update))
	add(spawners,make_spawner(spawner_fish,10,20,s_fish_update))
	--make_cat_spawners(0.1)
	bads = generate_bads(bad_candidates)
	draw_bg = draw_bg_beach
	map_pal = {9,15}
	return level
end
add(level_funcs,build_beach)

function build_volcano(n)
	room_candidates = {
		{10,1}, --room_id, likelihood
		{11,1},
		{2,1},
		{12,1},
	}
	bad_candidates = {
		{spike,.02,2,2},
		{rock,.02,5,16},
		{shell,.01,5,16},
	}
	level = builder(room_candidates,n,true) 
	fruits = return_fruits(level)
	spawners = {}
	add(spawners,make_spawner(spawner_bulbird,10,20,s_bulbird_update))
	--add(spawners,make_spawner(spawner_fish,10,20,s_fish_update))
	--make_cat_spawners(0.1)
	bads = generate_bads(bad_candidates)
	add(bads,make_fatdaddy(8*level.x1-50,20))
	draw_bg = draw_bg_volcano
	map_pal = {10,8}
	return level
end
add(level_funcs,build_volcano)

function builder(candidates,n,boss)
	local rooms = 16 + n
	local boss = boss or false
	local level = {}
	level.x0 = 0
	level.y0 = 0
	level.x1 = rooms*16
	level.y1 = 16
	level.rooms = rooms
	room_list = {}
	room_candidates=candidates
	-- should start with first
	add(room_list,candidates[1][1]) -- second number is map id
	room_pool = {}
	for each in all(room_candidates) do
		id = each[1]
		c = each[2]
		for ii=1,c,1 do
			add(room_pool,id)
		end
	end
	while #room_list < rooms do
		nextid = room_pool[flr(rnd(#room_pool)) + 1]
		add(room_list,nextid)
	end
	-- hard code boss room if needed
	if (boss) room_list[#room_list]=13
	for r=0,rooms-1,1 do
		xstart = r*16
		xfetch = (room_list[r+1]%8)*16
		ystart = 0
		yfetch = 8*(room_list[r+1]\8) -- correct later
		for xx = xstart,xstart+15,1 do
			for yy = ystart,ystart+7,1 do
				poke(0x5f56,0x20)
				val = mget2(xx%16+xfetch,yy+yfetch)
				poke(0x5f56,0x80)
				mset2(xx,yy+8,val)
			end		
		end	
	end
	return level
end
-->8
-- camera

function make_cam()
	cam={}
	cam.x = 0
	cam.y = 0
end

function update_cam(p1,lvl)
	cam.x = max(lvl.x0*8,p1.x-48)
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

local _fillp = fillp
local function fillp(p, x, y)
    p, x, y = p or 0, x or 0, y or 0 -- to maintain drop-in replacement compatibility with fillp(p)
    local p16, x = flr(p), band(x, 3)
    local f, p32 = flr(15 / shl(1,x)) * 0x1111, rotr(p16 + lshr(p16, 16), band(y, 3) * 4 + x)
    return _fillp(p - p16 + flr(band(p32, f) + band(rotl(p32, 4), 0xffff - f)))
end

function tf()
	return flr(60*t())%60
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
fix = {9,73,105,97,128,130,132,134}
for f in all(fix) do
	fruit_kinds[f] = {"apple",10,20}
end
lenfix = #fix

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


function return_fruits0(lvl)
	local x,y
	local fruits={}
	local rooms = lvl.rooms
	for r = 0,rooms-1,1 do
	local chance = 0.7
		while true do
			if rnd() < chance then
				y = flr(rnd(8))+1
				x = flr(rnd(16)) + 16*r
				while mget2(x,y+1)>0 do
					y -= 1
				end
				x *= 8
				x += 8
				y *= 8
				y += 8
				local f = make_fruit(9,x,y)
				local my_fix = flr(rnd(lenfix))+1
				f.ix = fix[my_fix]
				add(fruits,f)
				chance *= 0.5
			else
				chance = 0.7
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
	add(fruits,make_fruit(11,x+20,y))
	add(fruits,make_fruit(11,x+40,y))
	return fruits
end

function return_fruits(lvl)
	local fruits = {}
	local chance0 = .01
	local chance = .01
	for x=8,(lvl.rooms-1)*16,1 do
		if rnd() < chance then
			xx = x*8
			y = 2 + flr(rnd(10))
			while mget(x,y)>0 do
				y -= 1
			end
			yy = y*8
			local ix = rnd(fix)
			add(fruits,make_fruit(ix,xx,yy))
			chance=chance0
		else
			chance += .01
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
	add(fruits,make_fruit(11,x+20,y))
	add(fruits,make_fruit(11,x+40,y))
	return fruits
end
-->8
-- bads

function update_fish(b)
	b.ix = fish + 2*(flr(t()*10)%2)
	if b.timer==0 then
		b.dy = -2.6
		b.dx = p1.dx/2
		b.dx += (p1.x-b.x)/200
	end
	b.timer += 1
	b.dy += .03
	b.y += b.dy
	b.x += b.dx
	b.faceleft=true
	if (b.x<p1.x) b.faceleft = false
end

function update_spike(b)
	local d = abs(b.x-p1.x)
	if (d < 24)	b.timer += 1
	if (b.timer > 0)	b.dy += .04
	b.y += b.dy
end

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

function update_frog(b)
	b.dy += .075
	b.y += b.dy
	local floor = false
	while downcheck(b) do
		b.y -= 1
		b.y = flr(b.y)
		b.dy = 0
		floor = true
		b.ix = frog
		b.dx=0
	end
	if b.timer <= 0 then
		b.ix += 32
		b.dy = -2
		b.timer = 120
		b.faceleft = b.x > p1.x
		b.dx = 0.5
		if (b.faceleft) b.dx = -0.5
	end
	b.x += b.dx
	b.timer += -1
end

function update_spitter(b)
	b.dy += .075
	b.y += b.dy
	local floor = false
	while downcheck(b) do
		b.y -= 1
		b.y = flr(b.y)
		b.dy = 0
		floor = true
		b.ix = spitter
	end
	if b.timer <= 0 then
		b.ix += 32
		b.dy = -3
		b.timer = 180
	end
	b.timer += -1
	if (b.timer == 130) make_ball(b)
	b.faceleft = p1.x < b.x
end

function make_ball(b)
	local ball = {}
	ball.dx = 0.75
	if (b.faceleft) ball.dx = -0.75
	ball.dy = 0
	ball.x = b.x
	ball.y = b.y
	add(balls,ball)
end

function update_cat(b)
	b.ix = cat + 32*(flr(t()*15)%2)
	b.dy += .05
	b.y += b.dy
	local floor = false
	while downcheck(b) do
		b.y -= 1
		b.y = flr(b.y)
		b.dy = 0
		floor = true
		b.dx = 1.2
		if (b.faceleft) b.dx = -1.2
	end
	b.x += b.dx
end

function update_rock(b)
	b.dy += .05
	b.dx = -0.75
	b.y += b.dy
	b.x += b.dx
	local floor = false
	while downcheck(b) do
		b.y -= 1
		b.y = flr(b.y)
		b.dy = 0
		floor = true
	end
	if (floor) b.dy = -1
end


function update_bird(b)
	b.ix = bird + 2*(flr(t()*15)%2)
	if (b.dx==0) b.dx = -0.5
	b.timer += 1
	if b.timer >= 120 then
		b.timer = 0
		b.dx *= -1
	end
	b.faceleft = b.dx < 0
	b.x += b.dx
end

function update_bulbird(b)
	b.ix = bulbird + 2*(flr(t()*15)%2)
	b.dx = -1
	b.faceleft = true
	b.x += b.dx
end

function update_bat(b)
	local bix2 = 103
	b.ix = bat + 32*(flr(t()*15)%2)
	local dist = b.x-p1.x
	if b.timer > 0 then
		b.timer -= 1
		if b.timer > 60 then
			b.dy = 1
		else
			b.dy = -1
		end
		if dist < -8 then
			b.dx = 0.5
		elseif dist > 8 then
			b.dx = -0.5
		else
			b.dx = 0
		end
	else
		b.ix = bix2
		b.dx = 0
		b.dy = 0
		if abs(dist) < 32 then
			b.timer = 120
		end
	end
	b.x += b.dx
	b.y += b.dy
end

function update_empty(b)
	b.dy += .05
	b.y += b.dy
	local floor = false
	while downcheck(b) do
		b.y -= 1
		b.y = flr(b.y)
		b.dy = 0
		floor = true
	end
end

function update_fatdaddy(b)
	b.faceleft = p1.x < b.x
	b.dy += .075
	b.y += b.dy
	local floor = false
	while downcheck(b) do
		b.y -= 1
		b.y = flr(b.y)
		b.dy = 0
		floor = true
		b.ix = fatdaddy
	end
	if b.timer <= 0 then
		b.ix += 4
		b.dy = -3
		b.timer = 180
	end
	b.timer += -1
	if (b.timer == 130) make_ball(b)
	b.faceleft = p1.x < b.x
end

function make_bad(ix,x,y)
 local b = {}
	b.ix = ix
	b.name = bad_kinds[ix][1]
	b.health = bad_kinds[ix][2]
	b.damage = bad_kinds[ix][3]
	b.points = bad_kinds[ix][4]
	b.update = bad_kinds[ix][5]
	b.shield = bad_kinds[ix][6] or false
	b.faceleft=false
	b.x = x
	b.y = y
	b.w = 16
	b.h = 16
	b.sw = 2 --size in sprites
	b.sh = 2
	b.r	= 8 -- radius
	b.dx = 0
	b.dy = 0
	b.timer = 0
	return b 
end

function make_fatdaddy(x,y)
	local b = {}
	local ix = 136
	b.ix = 136
	b.name = bad_kinds[ix][1]
	b.health = bad_kinds[ix][2]
	b.damage = bad_kinds[ix][3]
	b.points = bad_kinds[ix][4]
	b.update = bad_kinds[ix][5]
	b.shield = bad_kinds[ix][6] or false
	b.faceleft=false
	b.x = x
	b.y = y
	b.w = 32
	b.h = 32
	b.sw = 4 --size in sprites
	b.sh = 4
	b.r	= 16 -- radius
	b.dx = 0
	b.dy = 0
	b.timer = 0
	return b 
end

chanceup = .005

function generate_bads(cands)
	-- for each in cands, generate.
	-- cands is a fourple:
	---- kind
	---- probability
	---- min y val
	---- max y val (20 is ceiling and min)
	bads = {}
	for c in all(cands) do
		kind = c[1]
		chance0 = c[2]
		chance = chance0
		ymax = c[4]
		ymin = c[3]
		for x=8,(level.rooms-1)*16,1 do
			if rnd() < chance then
				xx = x*8
				y = ymin + flr(rnd(ymax-1))
				yy = y*8
				add(bads,make_bad(kind,xx,yy))
				chance=chance0
			else
				chance += chanceup
			end
		end
	end
	return bads
end

function make_cat_spawners(chance0)
	if (chance0 == 0) return
	chance = chance0
	for x=14,(level.rooms-1)*16,1 do
		if rnd() < chance then
			local xx = x*8
			local yy = 40
			add(spawners,make_spawner(spawner_cat,xx,yy,s_cat_update))
			chance=chance0
		else
			chance += chanceup
		end
	end
end


function hurt_bad(h,dmg,shieldbrk)
	local sb = shieldbrk or false
	if (h.shield and not sb) return
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
bad_kinds[160]={"bulbird",1,20,100,update_bulbird}
bulbird = 160
bad_kinds[75]={"shell",1,20,100,update_empty,true}
shell = 75
bad_kinds[107]={"spike",1,20,100,update_spike,true}
spike = 107
bad_kinds[71]={"bat",1,20,100,update_bat}
bat = 71
bad_kinds[13]={"rock",1,20,100,update_rock,true}
rock = 13
bad_kinds[69]={"frog",1,20,100,update_frog}
frog = 69
bad_kinds[77]={"spitter",1,20,100,update_spitter}
spitter = 77
bad_kinds[67]={"cat",1,20,100,update_cat}
cat = 67
bad_kinds[164]={"fish",1,20,100,update_fish}
fish = 164
bad_kinds[136]={"fatdaddy",20,20,1000,update_fatdaddy}
fatdaddy = 136

-->8
-- spawners

function make_spawner(ix,x,y,func)
	local s = {}
	s.ix = ix
	s.x = x
	s.y = y
	s.dy= 0
	s.h = 16
	s.visible = false
	s.update = func or function() end
	return s
end

function s_cat_update(s)
	s.visible = true
	update_empty(s) -- cat flower needs gravity
	if s.x - p1.x < -40 then
		local c = make_bad(cat,s.x,s.y-3)
		c.dy = -1
		c.faceleft = false
		add(bads, c)
		del(spawners, s)
	end		
end

function s_bulbird_update(s)
	s.x = p1.x
	s.y = p1.y
	if flr(t()*60)%90==1 then
		local y = 20 + rnd(80)
		local b = make_bad(bulbird,s.x+100,y)
		add(bads,b)
	end
end

function s_fish_update(s)
	s.x = p1.x
	s.y = p1.y
	if flr(t()*60)%90==1 then
		local y = 128
		local x = s.x - 40 + 130*rnd()
		local b = make_bad(fish,x,y)
		add(bads,b)
	end
end

spawner_cat = 65
spawner_bulbird = 0
spawner_fish = 0
-->8
-- backgrounds
function draw_bg()
 cls(12)
end

function draw_fg()
end

bg_funcs = {}

function draw_bg_greens()
	cls(12)
	fillp(░-.5,t())
	circfill(96,24,22,0xca)
	fillp(▒-.5,t())
	circfill(96,24,18,0xca)
	fillp()
	circfill(96,24,12,10)
	camera()
end

add(bg_funcs,draw_bg_greens)

function draw_bg_cave()
	cls(2)
end

add(bg_funcs,draw_bg_cave)

function draw_bg_bridge()
	cls(9)
end

function draw_bg_forest()
	cls(6)
end

function draw_bg_cliffs()
	cls(7)
end

function draw_bg_swamps()
	cls(13)
end

function draw_bg_beach()
	cls(14)
end

function draw_bg_volcano()
	cls(1)
end

function bg_switch(n)
	b = n or 1
	if (b > #bg_funcs) b = 1
	draw_bg = bg_funcs[b]
end

__gfx__
77000000dddddddddddddddddddd00000000dddd0000000000000000ddd0ddddddddddddddddddddddddddddddddddddddddddddddddd00ddd0ddddd00000000
00000000dddd00000000dddddd00444444440ddd33333333bbb3bbb3dd070ddddddd0dddddddddddd0dddddddddddddd00ddddddddd0055000500ddd00000000
00700700dd00444444440dddd0444444444440dd333300003bb33bb3ddd000ddddd070dddddddddd0dddddddddddddd0640ddddddd055006660550dd00000000
00077000d0444444444440ddd0444ff444ff440d0000333333333333ddd07700dd0770dddddd000d0d00dddddddddd066460ddddd05555506055550d00000000
00077000d0444ff444ff440d0444ff0444f0440d3333333333333333ddd07777007770ddddd0888000880dddddddd06664660dddd05555550555550d00000000
007007000444ff0444f0440d044fff0f4ff040dd3bb33333d33dd33dddd07777777770dddd087888088780ddddddd066646660dd060550005055500d00000000
00000000044fff0f4ff040dd044fff0ffff0f0ddbbbbb33bddddddddddd07777777770ddd08788888888780ddddddd044444440d066005555505060d00000000
00000000044fff0ffff0f0dd0444fffffffff0ddbbbbbbbbddddddddddd07777777700ddd08888888888880dddddddd06466660dd00550555550605000000000
000000000444fffffffff0ddd0444444444440ddbbbbbbbbbbbbbb03ddd000777770ddddd08888888888880ddddddd04046660ddd05506055550055000000000
bbbbbbbbd0444444444440dddd0444f00ff40dddb33bbbbbb33bbbb0ddd0dd00770dddddd08888888888880dddddd040d0660ddd055066600050555000000000
dd3333dddd0444f00ff40dddddd044444440dddd33333bb333333bb3ddd0dddd00ddddddd08888888888880dddd0040ddd00dddd050666605505055000000000
33bbbb33ddd044444440dddddddd0ff4400ddddd3333333333333333ddd0dddddddddddddd088888888880dddd0660ddddddddddd06666605550600d00000000
3bbbbbb3dddd0ff4400ddddddd00fffffff0dddd3333333333333333ddd0ddddddddddddddd0888888880ddddd0660ddddddddddd06000050506660d00000000
3bbbbbb3dd00fffffff0ddddd0ffffffffff0ddd3bb333333bb33333ddd0dddddddddddddddd08800880ddddddd00ddddddddddddd055555506660dd00000000
33bbbb33d0ffffffffff0ddd0fff00ffffff0dddbbbbb33bbbbbb33bddd0ddddddddddddddddd00dd00dddddddddddddddddddddddd0055550600ddd00000000
dd3333dd0fff00ffffff0ddd0fffff0fffff00ddbbbbbbbbbbbbbbbbddd0ddddddddddddddddddddddddddddddddddddddddddddddddd000000ddddd00000000
dd3333dd0fffff0fffff00dd0ffff0fff0ff0f0dddddddd00ddddddddddddddddddddddd0000000000000000dddddddddddddddddddddddddddddddd00000000
d3bbbb3d0ffff0fff0ff0f0dd0000000000000dddddddd0330dddddddddd00000ddddddd3333333033333333ddd0ddddddd000dddddddddddddddddd00000000
3bbbbbb3d0000000000000dd044444444444440dddddd030030dddddddd0777770dddddd3333000033330000dd060ddddd06660ddddddddd00d00ddd00000000
3bbbbbb3044444444444440d040004440000040ddddd03033030dddddd077777770ddddd0000333000003333d06660dd0060060ddddddd00660660dd00000000
3bbbbbb3040004440000040d00fff000d0fff0ddddd0303333030dddd07777007770dddd333333303333333306666600660660dddddd0060600600dd00000000
3bbbbbb300fff000d0fff0dddd0000ddd0fff0dddd0303333bb030dd0777707707770ddd3bb333303bb3333306666660600600ddddd0666600a00ddd00000000
d3bbbb3dd0ffff0ddd000dddddddddddd0ffff0dd030b33bbbbb030d0777077770770dddbbbbb3303bbbb33bd066666600a00dddddd0666666aaa0dd00000000
dd3333dddd00000ddddddddddddddddddd00000d030bbbbbbbbbb0300777070770770dddbbbbbbb03bbbbbbbd066666666aaa0dddd0666666aaaaa0d00000000
00000000d444444dddd00000000000000000dddd30bbbbbb00000000077770770007000dbbbbbbb03bbbbbbbdd0666666aaaaa0ddd0666666000006000000000
000000004f0ff0f4ddd3bbb3bbb3bbb3bbb3dddd033bbbbb3333333307777770eee0eee0b33bbbb0333bbbbbdd066666600000ddd0666666660d060d00000000
000000004f0ff0f4ddd33bb33bb33bb33bb3dddd33333bb333330000d07777707070707033333bb033333bb3ddd06666660dddddd066660660ddd0dd00000000
00000000d444444ddddd3333333333333333dddd3333333300003333dd077700777077703333333033333333dddd060660dddddd066660000d00dddd00000000
00000000ffffffffdddd333333333333333ddddd3333333333333333ddd07077000e000d3333333033333333ddddd0000d00ddddd0660dd00d0a0ddd00000000
00000000dffffffdddddd33dd33dd33dd33ddddd3bb333333bb33333dddd00000eee0ddd3bb333303bb33333ddddddd00d0a0ddddd00ddd0a0d0dddd00000000
00000000d444444dddddddddddddddddddddddddbbbbb33bbbbbb33bddd0eeeeeeeee0ddbbbbb3303bbbb33bddddddd0a0d0dddddddddddd0ddddddd00000000
00000000ddfddfddddddddddddddddddddddddddbbbbbbbbbbbbbbbbdd0000000000000dbbbbbbb03bbbbbbbdddddddd0ddddddddddddddddddddddd00000000
00000000ddd00ddddddd00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0ddddddddddddddddddddddd0000dd
00000000ddd0e0dd0dd0e0ddddddddddddddddddddddddddddddddddddddd0dddd0dddddddddd000000dddddddddddddd0f0dddddddddd000dd00dddd0bbbb0d
00000000ddd0ee00e00ee0ddddd0ddddddddd0ddddddddddddddddddd0dd020dd020dd0dddd0099999900dddddddddd00ff0dddddddd00bbb00bb0dd0bbbbbb0
00000000ddd0ee0eee0ee0dddd0e0dd0000d0e0ddddddddddddddddd020d020dd020d020dd099999959990ddddddd00fffff0dddddd0bbb000b000dd0bbbbbb0
00000000ddd0eee0e0eee0dddd0ee00eeee0ee0ddddddddddddddddd0220222002220220dd099999555990dddddd0ffff0000ddddd0bbb070707070d0bbbbbb0
00000000ddd0eeeeeeeee0dddd0eeeeeeeee0e0dddddddd000d000dd0222000220002220d09995999599990ddddd0f000ffff0dddd0bbb070707070d0bbbbbb0
00000000dddd0eeeeeee0ddddd0eeeeeeeeee0dddddddd033303330d0220444004440220d09999999999990ddddd00ffffff0ddddd0bbbb000b000ddd0bbbb0d
00000000ddddd00eee00dddddd0ee0eeeeee0e0dddd000070707070d0220404004040220d09999999959990dddd0fffff000f0ddddd0bbbbbbbb00dddd0000dd
00000000ddddddd0b0ddddddd0eeee0eeee0ee0ddd033330003000ddd02044400444020dd09999599999990dddd0ff000fffff0dddd0bbbbbbbbbb0ddddddddd
00000000ddddddd0b000ddddd0eeeee0ee0eee0ddd033333333330ddd02200022000220dd09599999999590dddd000ffffff00dddddd0bbbbb0000dddddddddd
00000000dddddd0bb0bb0dddd0e00eeeeeeeee0dd03333333033330dd02222222222220dd09999999999990ddd0ffffff000ff0ddd0dd0bbbbbbbb0ddddddddd
00000000dddddd0b0d00dddddd0eeeeeeeeee0dd03330333330000dddd022000000220dddd099999999990dddd0fff000fffff0dd0b00bbb000000dddddddddd
00000000dddd000b0dddddddd0eeeeee00eeee0dd03330303333330dddd0220220220ddddd099959959990dddd0000fffff0000dd0b0bbb077770ddddddddddd
00000000ddd0bb0bb0dddddd0eee0000dd0eeee003330000030000dddddd02222220ddddddd0099999900dddd0fffffff0055550dd00bbbb00700ddddddddddd
00000000dddd00d0b0dddddd0ee0ee0dddd0000dd03330ddd030ddddddddd000000dddddddddd000000dddddd0ffffff05555550dddd0bbbbb0bb0dddddddddd
00000000ddddddd000ddddddd00d00dddddddddddd00000dd000dddddddddddddddddddddddddddddddddddddd0000000000000dddddd00000d00ddddddddddd
00000000ddddddddddddddddddddddddddddddddddddddddddddddddddddd0dddd0ddddddd000ddddddddddd0000000000000000dddddd000dd00ddd00000000
00000000ddddd00dd00dddddddd0ddddddddd0dddddddddddddddddddddd020dd020dddddd000000dddddddd0b333333333333b0dddd00bbb00bb0dd00000000
00000000dddd03300330dddddd0e0dd0000d0e0ddddddddd000d000ddddd020dd020dddddd00a0aa0dddddddd0b33b3333b3330dddd0bbb000b000dd00000000
00000000ddddd033330ddddddd0ee00eeee0ee0dddddddd033303330ddd0222002220dddd0aa0a0aa0ddddddd0b3b333333b330ddd0bbb070707070d00000000
00000000dddd00000000dddddd0eeeeeeeee0e0dddddd00070707070dd020002200020ddd0aa0aa0aa0ddddddd0b3333333330dddd0bbb070707070d00000000
00000000ddd0888888880ddddd0eeeeeeeeee0dddddd03330003000dddd0444004440ddd0aaaa0aa0aa00ddddd0b3333333330dddd0bbbb000b000dd00000000
00000000dd08888b8888b0dddd0ee0eeeeee0e0dddd033333333330dddd0404004040ddd0aaaa0aa0aaaa0ddddd0b33333330dddddd0bbbbbbbbbb0d00000000
00000000dd088b88888880ddd0eeee0eeee0ee0ddd03333333033330ddd0444004440ddd0aaaaa0aa0aaaa0dddd0b3b33b330dddddd0bbbbbbb000dd00000000
00000000dd0888888b8880ddd0eeeee0ee0eee0ddd0330333300000ddd020002200020dd0aaaaaa0aa0aa0dddddd0b333330dddddddd0bbbbb0ddddd00000000
00000000dd0b8888888880ddd0eeeeeeeeeeee0dd033330330330330dd020222222020ddd0aaaaa0aaa000dddddd0b333330dddddd0dd0bbbbb0dddd00000000
00000000ddd088b888880dddd0eeeeeeeeeeee0dd03330000d00000ddd022000000220ddd0aaaaaa000aa0ddddddd0b3330dddddd0b00bbb0bbb0ddd00000000
00000000ddd088888b880ddddd0eeeeeeeeee0ddd0330dddddddddddd02222022022220ddd0aaaaaaaaaa0ddddddd0b3330dddddd0b0bbb070bbb0dd00000000
00000000dddd08888880ddddddd0eee000ee0ddd0330dddddddddddddd022202202220ddddd0aaaaaaaa0ddddddddd0b30dddddddd00bbbb00000ddd00000000
00000000ddddd08b880dddddddd0eee0e0ee0dddd030ddddddddddddddd0200000020ddddddd0aaaaa00dddddddddd0b30dddddddddd0bbbb00bb0dd00000000
00000000dddddd0880dddddddddd0eee0ee0dddddd0ddddddddddddddddd0dddddd0ddddddddd00000ddddddddddddd0b0ddddddddddd0bbb0d0b0dd00000000
00000000ddddddd00dddddddddddd000000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0ddddddddddddd000ddd0ddd00000000
ddddddddd0dddddddddddd0000dddddddddddddddddddddddddddd0000ddddddddddddddddddd000000000ddddddddddddddddddddddd000000000dddddddddd
dddddddd0dddddddddddd033330dddddddddddddddddddddddddd0aaaa0dddddddddddddddd00fffffffff0dddddddddddddddddddd00fffffffff0ddddddddd
ddddddd0dddddddddddddd0330dddddddddddd0000dddddddddd0aaaaaa0ddddddddddddd00ffffffffffff0ddddddddddddddddd00ffffffffffff0dddddddd
ddddd000000dddddddddd000000ddddddddd0033b300ddddddd0aaaaa6aa0ddddddddddd0ffffffffffffff0dddddddddddddddd0ffffffffffffff0dddddddd
dddd0bb0bbb0dddddddd0a0aa0a0ddddddd0333b33330ddddd0aaaaaaaaaa0ddddddddd0ffff0000fffffff000ddddddddddddd0ffff0000fffffff000dddddd
dddd0bbbbbb0ddddddd0aaa00aaa0dddddd03b3b33b30ddddd0aa6aaaaaaa0dddddddd0ffff077770fffff07770ddddddddddd0ffff077770fffff07770ddddd
ddd0bbbbbbbb0ddddd0a0a0aa0a0a0dddd03b33b3b3330dddd0aaaaaaaaaa0ddddddd0ffff07777770fff0777770ddddddddd0ffff07777770fff0777770dddd
ddd0bbbbbbbb0ddddd0aa0aaaa0aa0dddd03b33b3b33b0dddd0aaaa6aaa6a0ddddddd0ffff07707770fff0777070ddddddddd0ffff07700770fff0770070dddd
dd0bbbbbbbbbb0ddd0aaaa0aa0aaaa0ddd03b33b3b33b0dddd0aaaaaaaaaa0dddddd0fffff07770770fff0770770dddddddd0fffff07700770fff0770070dddd
d0bbbbbbbbbbbb0dd00a00a00a00a00ddd03b33b3b3330dddd0a6aaaaaaaa0dddddd0fffff07777070fff0707770dddddddd0fffff07700770fff0770070dddd
0bbbbbbbbbbbbbb0d0a0aaa00aaa0a0ddd033b3b33b330dddd0aaaaaaaaaa0ddddd0ffffff07777770fff0777770ddddddd0ffffff07777770fff0777770dddd
0bbbbbbbbbbbbbb0d0aa0a0aa0a0aa0dddd0333b33330ddddd0aaaaaaa6aa0ddddd0fffffff077770fffff077700ddddddd0fffffff077770f00f0077700dddd
0bbbbbbbbbbbbbb0d0aaa0aaaa0aaa0dddd03333b3330dddddd0aaa6aaaa0dddddd0444444ff0000fffffff000f0ddddddd0444444ff0000f0fffff000f0dddd
d0bbbbbbbbbbbb0ddd0a0a0aa0a0a0dddddd00333300dddddddd0aaaaaa0dddddd044444444fffffffffffffffff0ddddd044444444fffffff0000ffffff0ddd
d0bbbbbbbbbbbb0dddd0aaa00aaa0ddddddddd0000ddddddddddd0aaaa0ddddddd044ffff044ffffff00000fffff0ddddd044ffff044ff0f00000000f0ff0ddd
dd000000000000dddddd00000000dddddddddddddddddddddddddd0000dddddddd04ffffff04fff0f0fffff0f0ff0ddddd04ffffff04f0ff00000000f0ff0ddd
ddddddddddddddddddddddddddddddddddd000000ddddddddddddddddddddddddd04ffffff044fff0fffffff0fff0ddddd04ffffff044ff0000000000fff0ddd
ddddddddddddddddddddddd0dddd0ddddd08888880ddddddddd000000ddddddddd04f0ffff044ff0fffffffff0ff0ddddd04f0ffff044ff0000000000f0f0ddd
ddd0dddddddd00dddddddd0e0000e0dddd0770088800dddddd08888880dddddddd04f0fff04444ffffffffffffff0ddddd04f0fff04440f0000000000f0f0ddd
dd0e0dd0dddd0e0ddddddd0eee0ee0ddddd0088888880ddddd0770088800dddddd04f0ff0f000444fffffffffff40ddddd04f0ff0f00040f00000000f0f40ddd
d0eee00e0000e00ddddd000ee00e00dddd0888880008000dddd0088888880ddddd044f0ff0fff04444444444444440dddd044f0ff0fff04f00000000f44440dd
0eeeee0eee0ee0ddddd0eee000a00dddd088888077707770dd0888880008000ddd044440fffff044444444444444400ddd044440fffff040ff0000ff0444400d
0eeeee0ee00e00ddddd0eeeeeeaaa0ddd000888070707070d088888077707770d044444400fff04444444444444440f0d044444400fff04400ffff00444440f0
d0eeeee000a00ddddd0eeeeeeaaaaa0d0888088077707770d000888070707070d04444444400044444444444444440f0d04444444400044444000044444440f0
d0eeeeeeeeaaa0dddd0eeeeee00000e0077880880008000d0888088077707770d0444444444444444444444444440ff0d0444440ffff04444444444444440ff0
dd0eeeeeeaaaaa0dd0eeeeeeee0d0e0d088888888888880d077880880008000dd0444440ffff0444444444444444000dd044440ffffff044444444444444000d
dd0eeeeee00000ddd0eeee0ee0ddd0dd0778808888800880088888888888880ddd04440ffffff044444444444440dddddd04440ffffff0444444444444400ddd
dd00eeeeee0ddddd0eeee0000ddddddd08880888880000800778808888888880ddd0440ffffff04444444444440f0dddddd04440ffff044444444444440ff0dd
d0a00eeee0ddddddd0ee0a0dddddddddd0008888880000800888088888800080dddd0040ffff04444444444000fff0dddddd040ffffff0444444444000ffff0d
0a00a0000ddddddddd00d0dddddddddddddd00000880080dd000888888088800dddddd0ffffff0000000000d0fffff0dddddd0ffffffff000000000d0fffff0d
d0dd0dddddddddddddddddddddddddddddddddddd08880dddddd0000088880ddddddd0ffffffff0ddddddddd0fffff0ddddddd00000000ddddddddddd000000d
dddddddddddddddddddddddddddddddddddddddddd000dddddddddddd0000ddddddddd00000000ddddddddddd000000ddddddddddddddddddddddddddddddddd
dddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddd00000000dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd00444444440ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0444444444440dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0444ff444ff440d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0444ff0444f0440d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
044fff0f4ff040dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
044fff0ffff0f0dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0444fffffffff0dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0444444444440dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd0444f00ff40ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddd044444440dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddd0ff4400ddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd00fffffff0dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0ffffffffff0ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0fff00ffffff0ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0fffff0fffff00dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ffff0fff0ff0f0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0000000000000dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
044444444444440d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
040004440000040d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00fff000d0fff0dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0ffff0ddd000ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dd00000ddddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d444444dddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4f0ff0f4ddd3bbb30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4f0ff0f4ddd33bb30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d444444ddddd33330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffdddd33330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dffffffdddddd33d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d444444ddddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddfddfdddddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222220000222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
222222222222222222220033b3002222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222220333b33330222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
222222222222222222203b3b33b30222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222203b33b3b333022222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222203b33b3b33b022222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222203b33b3b33b022222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222203b33b3b333022222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
222222222222222222033b3b33b33022222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222220333b33330222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
222222222222222222203333b3330222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222003333002222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222220000222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222064022222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222220664602222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222206664660222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222206664666022222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222220444444402222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222064666602222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222220404666022222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222204020660222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222220040222002222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222206602222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222206602222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222220022222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222002220222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200550005002222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222055006660550222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222220555550605555022
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222220555555055555022
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200020002222206055000505550022
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222033303330222206600555550506022
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222070707070002220055055555060502
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200030003330220550605555005502
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222203333333333005506660005055502
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222033330333333305066660550505502
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222200000333303300666660555060022
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222033033033033330600005050666022
22222222222222222222222222220000000022222222222222222222222222222222222222222222222222222222222222200000200003330055555506660222
22222222222222222222222222004444444402222222222222222222222222222222222222222222222222222222222222222222222220330200555506002222
22222222222222222222222220444444444440222222222222222222222222222222222222222222222222222222222222222222222222033022000000222222
22222222222222222222222220444ff444ff44022222222222222222222222222222222222222222222222222222222222222222222222030222222222222222
2222222222222222222222220444ff0444f044022222222222222222222222222222222222222222222222222222222222222222222222202222222222222222
222222222222222222222222044fff0f4ff040222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
222222222222222222222222044fff0ffff0f0222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222222222222222222222220444fffffffff0222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222220444444444440222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
222222222222222222222222220444f00ff402222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222204444444022222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222220ff4400222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222222222222222222222222200fffffff022222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222220ffffffffff02222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222222222222222222222220fff00ffffff02222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222222222222222222222220fffff0fffff00222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2222222222222222222222220ffff0fff0ff0f022222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222220000000000000222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222204444444444444022222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222204000444000004022222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222200fff00020fff0222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222220ffff02220002222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222000002222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22220000222200002222000022220000222200002222000022220000222200002222000022220000222200002222000022220000222200002222000022220000
00002222000022220000222200002222000022220000222200002222000022220000222200002222000022220000222200002222000022220000222200002222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee22222
eeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeee
22222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee2
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
2ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee222222ee22222
eeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22eeeeee22e
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006
60004444440000000000000000000007007007007007007007007007007007007007007007007007007007000000000000000000000000000000000000000006
6004f0ff0f4002220000000000000027027027027027027027027027027027027027027027027027027027000000000000022202220222022202220222000006
6004f0ff0f4000777000000000000027027027027027027027027027027027027027027027027027027027000000000000027772777077727770777277700006
60004444440002227000000000000027027027027027027027027027027027027027027027027027027027000000000000027272727222727272227272700006
600ffffffff002777000000000000027027027027027027027027027027027027027027027027027027027000000000000027272727277727272777272700006
6000ffffff0002720000000000000027027027027027027027027027027027027027027027027027027027000000000000027272727272027272720272700006
60004444440000777000000000000027027027027027027027027027027027027027027027027027027027000000000000007770777077707770777077700006
60000f00f00000000000000000000007007007007007007007007007007007007007007007007007007007000000000000000000000000000000000000000006
60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666

__gff__
0000000000010400000000000000000010000000000104000000000000000000000000000002080000010100000000000000101010040400000101000000000000000000000104000000000000000000000000000001040000000000000000000000000000010400000000000000000000001000000104000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000002505050505050526000000000000000032333333333333340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000253515151515151516260000000000000000000000000000000000000000000000000032333334000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000002505050505260000000000000025351515151515151515162600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101010101010101010000000
0000000000000000000000000000000000000000253515151515162600000000002535151515151515151515151626000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000020000000
0000000000000000000000000000000000000025351515151515151626000000253515151515151515151515151516260000000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010101010101010100000000010101010101000000020000000000000000020000000
050505050505050505050505050505050505053515151515151515151605050535151515151515151515151515151516050505050505050505050505050505050505052900000000000000002a050505200000000000000000000000000000202000000000200000000020000000002000000020000000000000000020000000
151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515153900000000000000003a151515200000000000000000000000000000202000000000200000000020000000002000000020000000000000000020000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002a050505050505050000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000250505292a05050505050505050505050505052900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003a151515151515150000000000000000000000000000000000000000000000000000000000000000
000000000000000000000025351515393a15151515151515151515151515153900000000000000000000000000000000000005050505290000000000000000000000000000000000000000000000000000000000000000003a151515151515150000000000000000000000000000000000000000000000000000000000000000
000000000000000000002535151515393a15151515151515151515151515153900000000000000000000000000000000000015151515390000000505050529000000000000000000000000000000000000000000000000003a151515151515150000000000000000000000000000000000000000000000000000000000000000
2a0505050505050505053515151515393a1515151515151515151515151515390505050505290000000005050505050500001515151539000000151515153900000000002a050505050505290000000005050505050505053a151515151515150000000000000000000000000000000000000000000000000000000000000000
3a1515151515151515151515151515393a1515151515151515151515151515391515151515390000000015151515151500001515151539000000151515153900000000003a151515151515390000000015151515151515153a151515151515150000000000000000000000000000000000000000000000000000000000000000
__sfx__
01080000270561f056220561805622056180561d05618056270561f05622056180560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
