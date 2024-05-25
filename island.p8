pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- island adventure
-- palo banco games 2023
-- rocco panella ;)

-- todo
-- animation when enemies are beat
-- enemy balancing
--

-- no repeater
poke(0x5f5c,255)
-- use extended mem for map
poke(0x5f56,0x80)

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
	text_draws = {}
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
	update_hammerballs()
	fix_score()
	rotate_flag()
	-- pit
	if (p1.y > 128) energy = 0
	if energy <= 0 then
		die()
	end
end


flag_cands = {
9,105,11,97,130,196}
flag_index=1

function rotate_flag()
	--flag.x = 120
	flag.y = 24+10*sin(.5*t())
	if tf()%20==1 then 
		flag_index+=1
		if (flag_index>#flag_cands) flag_index=1
	end
	flag.ix = flag_cands[flag_index]
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

function fix_score()
	if score > 9999 then
		score10k += 1
		score %= 10000
	end
end

function score_str()
	local scorewidth=4
	local zeropad = scorewidth - #(""..score)
	local scorestr = ""
	for i=1,zeropad,1 do
		scorestr = scorestr.."0"
	end
	scorestr = scorestr..score
	if score10k > 9 then
		scorestr = ""..score10k..scorestr
	else
	 scorestr = "0"..score10k..scorestr
	end
	return scorestr
end

function check_fruits()
	for f in all(fruits) do
		if collide_p1(p1,f,12,16) then
			if f.name == "flag" then
				if f.ix==11 then
				 hammer_up()
				elseif f.ix==196 then
					life_up()
				else
					sfx(1)
					freeze(15)
				end
				del(fruits,f)
				level_end()
				--return
			elseif f.name=="hammer" then
				score += f.points
				hammer_up()
				del(fruits,f)
			else
				score += f.points
				energy += f.health
				energy = min(energy,100)
				del(fruits,f)
				make_text(f.points,f.x-2,f.y-12,7,6)
				sfx(1)
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
	freeze(6)
	p1.ground = false
	p1.dy = -2
	p1.dx = -4
	if hammer > 0 then
	 hammer_down()
	else
		hammerpoints = 0
	end
end

function die()
	p1.ud = true
	p1.sp = 198
	hammer = 0
	freeze(15)
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
	freeze(15)
	energy = flr(energy)
	while energy > 0 do
		eloss = 5
		score += eloss * 10
		energy -= eloss
		sfx(1)
		freeze(9)
	end
	freeze(10)
	sfx(0)
	level_ix += 1
	freeze(30)
	energy = 10
	if level_ix < 9 then
		start_map()
	else
		start_gamewin()
	end
end

function set_pal_game()
	pal()
	palt(0,false)
	palt(13,true)
end

function draw_gameplay()
	draw_bg()
	
	set_pal_game()

	update_cam(p1,lvl,cam)
	map2()
	
	if (draw_bg == draw_bg_beach) set_pal_black()
	draw_p1(p1)
	--local flicker = flr(t()*30)%2
	--pset(p1.x,p1.y,7*flicker)
	
	flag_colors = {6,7}
	for _n=0,3,1 do
		_c = flag_colors[(_n%2)+1]
		_r = (_n*5 + 30*t())%20
		circfill(flag.x,flag.y,_r,_c)
	end
	
	for f in all(fruits) do
		spr(f.ix,f.x-f.w\2,f.y-f.h\2,2,2)
	end
	for s in all(spawners) do
		if (s.visible) spr(s.ix,s.x-8,s.y-8,2,2)
	end
	for b in all(bads) do
		b:draw()
	end
	for b in all(balls) do
		spr(79,b.x-4,b.y-4)
	end
	for h in all(hammers) do
		draw_hammer(h)
	end
	draw_hammerballs()
	set_pal_game()
	draw_text()
	-- overlay
	camera()
	--draw_fg()
	draw_status()
	palt()
	oprint(hammerpoints,1,1,4,9)
	palt(0,false)
	palt(13,true)
	for i=1,hammer,1 do
		spr(48,6+i*3,0)
	end
	palt()
end

function kill_bad(b)
	del(bads,b)
	for i=1,flr(rnd(4)),1 do
		make_hammerball(b.x,b.y)
	end
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
	offprint(score_str(),100,120,7,2)
end

function start_gameplay()
	fade_out()
	init_level()
	hammers = {}
	hammerballs = {}
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
	make_cam()
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
	draw_bg_greens()
	ovalfill(14,30,109,87,3)
	oval(14,30,109,87,10)
	cprint("island",40,0,9,true)
	cprint("adventure",55,0,9,true)
	line(29,67,97,67,0)
	cprint("palo blanco games",70,0,9)
	cprint("2024",78,0,9)
	cprint("press x, c, or z",110,0,12)
end

function init_globals()
	lives = 3
	level_ix = 1
	status_height = 12
	score = 0
	score10k = 0
	denergy = 5/60
	hammer = 0
	hammerpoints = 0
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
		if (btn(4) or btn(5)) r+=6
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
		if (btn(4) or btn(5)) r-=6
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
	bgs[level_ix]()
	cprint("level "..level_ix,40,7,0,true)
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


function draw_text()
	for t in all(text_draws) do
		offprint(t.s,t.x,t.y,t.c,t.c0)
		t.t -= 1
		if (t.t < 1) del(text_draws,t)
	end
end

function make_text(s,x,y,c,c0,t)
	local text = {}
	text.s = s
	text.x = x
	text.y = y
	text.c = c
	text.c0 = c0
	text.t = t or 30	
	add(text_draws,text)
end

function hammer_up()
	make_text("hammer up",p1.x-12,p1.y-20,6,2,40)
	hammer=min(4,hammer+1)
	sfx(0)
	freeze(15)
end

function life_up()
	make_text("life up!!",p1.x-12,p1.y-20,6,2,40)
	lives+=1
	sfx(0)
	freeze(15)
end

function hammer_down()
	make_text("hammer down",p1.x-16,p1.y-20,8,2,40)
	
	if hammer == 1 then
		xx = p1.x+160 + rnd(80)
		yy = 60
		while mget2(xx\8,yy\8) > 0 do
			yy -= 8
		end
		add(fruits,make_fruit(11,xx,yy))
	end
	
	hammer=max(0,hammer-1)
	sfx(0)
	freeze(15)
end
-->8
-- player

function return_p1()
	local p1 = {}
	p1.x = 32
	p1.y = 64
	p1.dx = 0
	p1.dy = 0
	p1.jumpmax=11
	p1.jump=0
	p1.offset = 0
	p1.offtime_max = 10
	p1.offtime = 0
	p1.left = false
	p1.ud = false --upsidedown
	p1.run=false
	p1.move=false
	p1.ground=false
	p1.canjump=false
	p1.w = 16
	p1.h = 24
	p1.tosstimer=0
	p1.tossmax=10
	return p1
end

function update_p1(p1,lvl)
	p1.offtime = (p1.offtime+1)%p1.offtime_max
	if (p1.offtime == p1.offtime_max-1) p1.offset = 1-p1.offset
	p1.tosstimer = max(p1.tosstimer-1,0)
	
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
			make_hammer(-1,p1.x+4,p1.y-4,hammer>3)
		else
			make_hammer(1,p1.x-4,p1.y-4,hammer>3)
		end
		p1.tosstimer = p1.tossmax
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
	if btnp(5) and p1.canjump then
		p1.dy = -2.5
		p1.ground=false
		p1.canjump=false
		p1.jump = 1
	elseif p1.jump < p1.jumpmax and btn(5) and not p1.ground then
		p1.jump += 1
		p1.dy = -2.5
	elseif btn(5) then
		p1.dy+= 0.1
		p1.jump=p1.jumpmax
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
		p1.canjump=true
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
	if (p1.tosstimer>0) p1.sp=192
	if (p1.tosstimer>6) p1.sp=198
	spr(p1.sp,p1.drawx,p1.drawy,2,3,p1.left,p1.ud)
	if (hammer>0) spr(194+(hammer-1)*16,p1.drawx,p1.drawy-4-p1.offset,2,1,p1.left)
end

-- collision methods

function collide(a1,a2,r)
	if (a2.flashing) return false
	local r = r or 8
	return abs(a1.x-a2.x)<r and abs(a1.y-a2.y)<r
end

function collide_p1(p,a,rx,ry)
	if (a.flashing) return false
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
				if b.health <= 0 then
					_p = b.points
					if (hammer==4) _p*=2
				 score += _p
				 make_text(_p,b.x-2,b.y-12,7,6)
				end
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
	if (y < 0) return 0
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
	local z = map_pal[3] or 0
	pal(0,z)
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
	map_pal = {13,14}
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
	make_cat_spawners(0.03)
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
	map_pal = {0,0}--{9,15}
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
	map_pal = {1,2,8}
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

function cprint(str,y,c,co,big)
	big = big or false
	sl = #str
	if big then
		str = "\^t\^w"..str
		m = 4
	else
		m=2
	end
	local x = 64 - sl*m
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

function freeze(n)
	for i=1,n,1 do
		_draw()
		flip()
	end
end
-->8



-->8
-- items

fruit_kinds = {}
-- ix,      name,health,points
fruit_kinds[9]={"apple",20,20}
fruit_kinds[7]={"flag",0,1000}
fruit_kinds[11]={"hammer",0,0} 
fruit_kinds[196]={"burger",0,1000} 
fix = {9,73,105,97,128,130,132,134}
for f in all(fix) do
	fruit_kinds[f] = {"apple",20,20}
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
	y=2
	-- flag
	while mget2(x,y+2)==0 and y<14 do
		y += 1
	end
	y *= 8
	x *= 8
	y += 8
	x += 8
	flag = make_fruit(7,x,0)
	add(fruits,flag)
	--hammer
	x=96
	y=64
	add(fruits,make_fruit(11,x+rnd(100),y))
	return fruits
end

function make_hammerball(x,y)
	local hb = {}
	hb.x=x
	hb.y=y
	hb.dx = -.25+rnd(.5)
	hb.dy = -.1-rnd(.2)
	add(hammerballs,hb)
end

function draw_hammerballs()
	if (tf()%10<5) pal(2,10)
	for hb in all(hammerballs) do
		spr(241,hb.x-4,hb.y-4)
	end
	pal(2,2)
end

function update_hammerballs()
	for hb in all(hammerballs) do
		if collide_p1(p1,hb) then
			add_hammerball()
			del(hammerballs,hb)
		else
			hb.x+= hb.dx
			hb.dy += .005
			hb.y+= hb.dy
			if mget2(hb.x\8,hb.y\8)>0 then
				hb.dx = 0
				hb.dy = 0
			end
		end
	end
end

function add_hammerball()
	hammerpoints += 5
	_p = 5 * hammer
	if (hammer == 4) _p = 100
	if _p > 0 then
		score += _p
		make_text(_p,p1.x,p1.y-12,7,6)
	end
	if hammerpoints > 99 then
		if hammer < 4 then
			hammer_up()
			hammerpoints %= 100
		else
			score += 3000
			make_text(3000,p1.x-6,p1.y-12,7,6)
			hammerpoints = 0
			sfx(0)
		end
	end
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
	b.flashing=false
	if (b.dy<-1) b.flashing=true
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
		b.y -= .7
		b.y = flr(b.y)
		b.dy = 0
		floor = true
		b.dx = 1.6
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
	if b.timer == 0 then
		b.faceleft = b.x > p1.x
		b.dx = 1.7
		if (b.faceleft) b.dx = -1
	end
	b.ix = bulbird + 2*(flr(t()*15)%2)
	b.timer += 1
	if b.timer < 60 then
		b.flashing = true
		if b.faceleft then 
			b.x = cam.x+128
		else
			b.x = cam.x
		end
	else
		b.flashing = false
		b.x += b.dx
	end
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
		b.dy = -2
		b.timer = 180
	end
	b.timer += -1
	if b.timer == 130 then
		make_ball(b)
	end
	b.faceleft = p1.x < b.x
end

function draw_bad_default(b)
	-- flash
	if (b.flashing and tf()%4<2) return
	spr(b.ix,b.x-b.w\2,b.y-b.h\2,b.sw,b.sh,b.faceleft)
end	

function make_bad(ix,x,y,draw)
 local b = {}
	b.ix = ix
	b.name = bad_kinds[ix][1]
	b.health = bad_kinds[ix][2]
	b.damage = bad_kinds[ix][3]
	b.points = bad_kinds[ix][4]
	b.update = bad_kinds[ix][5]
	b.shield = bad_kinds[ix][6] or false
	b.faceleft=false
	b.flashing=false
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
	b.draw = draw or draw_bad_default
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
	b.draw = draw_bad_default
	return b 
end

chanceup = .0025

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
		for x=12,(level.rooms-1)*16,1 do
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
			chance += chanceup*.05
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
	local early = (s.x\8)%8 == 0
	update_empty(s) -- cat flower needs gravity
	if not early then
		if s.x - p1.x < -40 then
			local c = make_bad(cat,s.x,s.y-3)
			c.dy = -1
			c.faceleft = false
			add(bads, c)
			del(spawners, s)
		end
	else
		if s.x - p1.x < 38 then
			local c = make_bad(cat,s.x,s.y-3)
			c.dy = -1
			c.faceleft = true
			add(bads, c)
			del(spawners, s)
		end
	end
end

function s_bulbird_update(s)
	s.x = p1.x
	s.y = p1.y
	if flr(t()*60)%90==1 then
		local y = 20 + rnd(80)
		local b = make_bad(bulbird,s.x+rnd({100,-50}),y)
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

function draw_bg_greens()
	-- sky
	cls(12)
	fillp(░-.5,4*t())
	circfill(96,24,22,0xca)
	fillp(▒-.5,4*t())
	circfill(96,24,18,0xca)
	fillp()
	circfill(96,24,12,10)
	
	-- clouds
	mx = -cam.x \ 4 - t()
	fillp()
	sx = mx+20
	while sx< -40 do
		sx += 168
	end
	ovalfill(sx,11,sx+40,31,7)
	ovalfill(sx+84,11,sx+40+84,31,7)
	ovalfill(sx-84,11,sx+40-84,31,7)
	fillp()
	
	--water
	poke(0x5f54,0x60)	
	rectfill(0,88,128,128,1)
	palt(12,true)
	for yys=127,88,-1 do
		hh = 127-yys
		xh = 3*sqrt(yys-88)
		xhoff = xh*sin(t()/3+xh/3)/2
		sspr(xh+xhoff,hh,127-2*xh,1,0,yys,128,1)
		fillp(▒,xhoff)
		line(0,yys,127,yys,1)
	end
	palt(12,false)
	fillp()
	poke(0x5f54,0x00)
	pal(12,12)
		
end

function draw_bg_cave()
	cls(2)
	ys = 71 + 5*sin(.5*t())
	clip(0,0,127,ys)
	for _xx=20,140,60 do
		xx = _xx-(cam.x\4)
		while xx < -30 do
		 xx += 180
		end
		fillp(░-.5,2*sin(.5*t()))
		ovalfill(xx-5,-20,xx+30,148,0x21)
		ovalfill(xx-18,-20,xx+17,148,0x21)
		fillp(▒-.5,5*sin(.5*t()))
		ovalfill(xx-10,-20,xx+25,148,0x21)
		fillp()
		ovalfill(xx-15,-20,xx+20,148,1)
	end
	-- reflection
	clip()
	poke(0x5f54,0x60) -- screen as sheet
	pal(2,13)
	pal(1,5)
	for yy=ys,127,1 do
		local dif = yy-ys
		local ysrc=ys-1 - (dif)
		sspr(flr(2*(dif^.5)),ysrc,127-flr(4*(dif^.5)),1,0,yy,127,1)
	end
	poke(0x5f54,0x00) -- sheet as sheet
	set_pal_game()
end


function draw_bg_bridge()
	cls(8)
	local horizon=50
	clip(0,0,127,55)
	circfill(64,55,45,9)
	clip()
	rectfill(0,horizon,127,127,2)
	local r2 = 45^2
	for y=horizon,99,1 do
		local x = sqrt(r2 - (y-55)^2)
		local x0 = 64-10*sin(.5*t()+(500/(y-10)))
		fillp(▥,x0\8)
		line(x0-x,y,x0+x,y,9)
	end
	fillp()
end

function draw_bg_forest()
	cls(6)
	for _xx=20,140,40 do
		xx = _xx-(cam.x\4)
		while xx < -30 do
		 xx += 160
		end
		--fillp(▒-.5)
		--rectfill(xx-3,0,xx+12,127,0x65)
		fillp(▥-.5,cam.x\4)
		rectfill(xx-2,0,xx+13,127,0x65)
		fillp()
		rectfill(xx+3,0,xx+20,127,0x65)
	end
	for _xx=20,170,30 do
		xx = _xx-(cam.x\2)
		while xx < -30 do
		 xx += 180
		end
		circfill(xx,-5,20,3)
		circfill(xx+2,-8,20,15)
	end
end

function draw_bg_cliffs()
	cls(14)
	circfill(64,54,20,15)
	local yy = 74
	for xx=0,140,20 do
		local x = xx-4*t()
		while x < -20 do
			x += 160
		end
		circfill(x,yy,15,7)
		circfill(x,yy-60,15,7)
	end
		for xx=0,140,20 do
		local x = xx-4*t()
		while x < -20 do
			x += 160
		end
		circfill(x+(x-58)\32,yy+1,15,6)
		circfill(x+(x-58)\32,yy-61,15,6)
	end

	yy=94
	for xx=0,160,40 do
		local x = xx-8*t()
		while x < -20 do
			x += 200
		end
		circfill(x,yy,25,7)
		circfill(x,-5,25,7)
	end
	for xx=0,160,40 do
		local x = xx-8*t()
		while x < -20 do
			x += 200
		end
		circfill(x+(x-58)\32,yy+1,25,6)
		circfill(x+(x-58)\32,-6,25,6)
	end	
	yy=128 
	for xx=0,180,60 do
		local x = xx-16*t()
		while x < -20 do
			x += 240
		end
		circfill(x,yy,35,7)
	end	
	for xx=0,180,60 do
		local x = xx-16*t()
		while x < -20 do
			x += 240
		end
		circfill(x+(x-58)\32,yy+1,35,6)
	end
	
end

function draw_bg_swamps()
	-- {1,2,13}
	local horizon=50
	cls(13)
	rectfill(0,horizon,127,127,2)
	circfill(80,20,10,6)
	--cls(13)
	for xx in all({20,80,140}) do
		local x = xx-cam.x/4
		while x < -20 do
			x += 180
		end
		rectfill(x,0,x+20,55,1)

		clip(0,55,127,127)
		local xslope0 = (x-80)/(55-20)
		local x0 = 107*xslope0+80
		--line(80,20,x0,127,1)
		local xslope1 = (x-60)/(55-20)
		local x1 = 107*xslope1+80
		--line(80,20,x1,127,1)
		
		for yy=55,127,1 do
		 local delta = 2*sin(.5*t()+(500/(yy-18)))
			local x0 = (yy-20)*xslope0+80 + delta
			local x1 = (yy-20)*xslope1+80 + delta
			line(x0,yy,x1,yy,1)
		end
		clip()
	end
end

function draw_bg_beach()
	cls(14)
	rectfill(0,0,127,16,13)
	fillp(░-.5,0,t()/2)
	rectfill(0,17,127,28,0xde)
	fillp(▒-.5,0,t()/2)
	rectfill(0,29,127,37,0xde)
	fillp(░-.5,0,t()/2)
	rectfill(0,38,127,44,0xed)
	fillp()
	circfill(64,60,12,11)
	-- {9,15}
	y0 = 32 + 960*(1/(32+10))
	dy0 = 50*(1/(32+5))*sin(.5*t()+.1*32)
	rectfill(0,y0+dy0,127,127,13)
	--line(0,y0+dy0,127,y0+dy0,11)
	pat = {0.5,…,░,▒,█}
	fillp(▤)
	for zz=28,-2,-3 do
		local y = 32 + 960*(1/(zz+10))
		local h = sin(.5*t()+.05*zz)
		local dy = 100*(1/(zz+10))*h
		local ix = flr(1+(h+1)*.5*4.9)
		
		if y+dy > y0+dy0 then
			local h2 = (y+dy - (y0+dy0))/2
			local w = (y-y0)*3
			local xx = 100*(1/(zz+5)*sin(t()/2)) + (-500/(zz+5)) * cam.x/100
			xx %= w*2
			xx += -w*2
			local up = true
			while xx < 128+w*2 do
				--clip(xx,y0+dy0,xx+w,y0+dy0)
				clip(xx,y0+dy0,128,h2+1)
				oval(xx,y0+dy0,xx+w,y+dy,11)
				xx += w
				clip(xx,y0+dy0+h2,128,2*h2)
				oval(xx,y0+dy0,xx+w,y+dy,11)
				xx += w
				--oval(0,y0+dy0,(y-y0)*2,y+dy,11)
				clip()
			end
		end
		
		y0,dy0 = y,dy
	end
	fillp()
end

function set_pal_black()
	pal({0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})
end

vol_ix=1


function gauss(x)
	return flr(11.99*(1.5^(-((x-64)/16)^2)) + 1.5+ 1.5*cos(abs((x-64)/16)-t()/2))
end

function draw_bg_volcano()
	cls(1)
	local ol={8,9,10,9,8,2}
	if tf()%15==1 then
		vol_ix = ((vol_ix)%#ol)+1
		map_pal = {1,2,ol[vol_ix]}
	end
	local ol={0x00,0x01,0x11,0x12,0x22,
	0x25,0x55,0x58,0x88,0x89,0x99,
	0x9a,0xaa,0xa7,0x77}
	fillp(▒-.5)
	for yy=0,127,1 do
		line(0,yy,127,yy,ol[gauss(yy)+1])
	end
	fillp()
end

bgs = {
draw_bg_greens,
draw_bg_cave,
draw_bg_bridge,
draw_bg_forest,
draw_bg_cliffs,
draw_bg_swamps,
draw_bg_beach,
draw_bg_volcano
}
__gfx__
77000000dddddddddddddddddddd00000000dddd0000000000000000ddd0ddddddddddddddddddddddddddddddddddddddddddddddddd00ddd0ddddddddddddd
00000000dddd00000000dddddd00444444440ddd33333333bbb3bbb3dd070ddddddd0dddddddddddd0dddddddddddddd00ddddddddd0055000500ddddddddddd
00700700dd00444444440dddd0444444444440dd333300003bb33bb3ddd000ddddd070dddddddddd0dddddddddddddd0640ddddddd055006660550dddddddddd
00077000d0444444444440ddd0444ff444ff440d0000333333333333ddd07700dd0770dddddd000d0d00dddddddddd066460ddddd05555506055550ddddddddd
00077000d0444ff444ff440d0444ff0444f0440d3333333333333333ddd07777007770ddddd0888000880dddddddd06664660dddd05555550555550ddddddddd
007007000444ff0444f0440d044fff0f4ff040dd3bb33333d33dd33dddd07777777770dddd087888088780ddddddd066646660dd060550005055500ddddddddd
00000000044fff0f4ff040dd044fff0ffff0f0ddbbbbb33bddddddddddd07777777770ddd08788888888780ddddddd044444440d066005555505060ddddddddd
00000000044fff0ffff0f0dd0444fffffffff0ddbbbbbbbbddddddddddd07777777700ddd08888888888880dddddddd06466660dd005505555506050dddddddd
000000000444fffffffff0ddd0444444444440ddbbbbbbbbbbbbbb03ddd000777770ddddd08888888888880ddddddd04046660ddd055060555500550dddddddd
bbbbbbbbd0444444444440dddd0444f00ff40dddb33bbbbbb33bbbb0ddd0dd00770dddddd08888888888880dddddd040d0660ddd0550666000505550dddddddd
dd3333dddd0444f00ff40dddddd044444440dddd33333bb333333bb3ddd0dddd00ddddddd08888888888880dddd0040ddd00dddd0506666055050550dddddddd
33bbbb33ddd044444440dddddddd0ff4400ddddd3333333333333333ddd0dddddddddddddd088888888880dddd0660ddddddddddd06666605550600ddddddddd
3bbbbbb3dddd0ff4400ddddddd00fffffff0dddd3333333333333333ddd0ddddddddddddddd0888888880ddddd0660ddddddddddd06000050506660ddddddddd
3bbbbbb3dd00fffffff0ddddd0ffffffffff0ddd3bb333333bb33333ddd0dddddddddddddddd08800880ddddddd00ddddddddddddd055555506660dddddddddd
33bbbb33d0ffffffffff0ddd0fff00ffffff0dddbbbbb33bbbbbb33bddd0ddddddddddddddddd00dd00dddddddddddddddddddddddd0055550600ddddddddddd
dd3333dd0fff00ffffff0ddd0fffff0fffff00ddbbbbbbbbbbbbbbbbddd0ddddddddddddddddddddddddddddddddddddddddddddddddd000000ddddddddddddd
dd3333dd0fffff0fffff00dd0ffff0fff0ff0f0dddddddd00ddddddddddddddddddddddd0000000000000000dddddddddddddddddddddddddddddddddddddddd
d3bbbb3d0ffff0fff0ff0f0dd0000000000000dddddddd0330dddddddddd00000ddddddd3333333033333333ddd0ddddddd000dddddddddddddddddddddddddd
3bbbbbb3d0000000000000dd044444444444440dddddd030030dddddddd0777770dddddd3333000033330000dd060ddddd06660ddddddddd00d00ddddddddddd
3bbbbbb3044444444444440d040004440000040ddddd03033030dddddd077777770ddddd0000333000003333d06660dd0060060ddddddd00660660dddddddddd
3bbbbbb3040004440000040d00fff000d0fff0ddddd0303333030dddd07777007770dddd333333303333333306666600660660dddddd0060600600dddddddddd
3bbbbbb300fff000d0fff0dddd0000ddd0fff0dddd0303333bb030dd0777707707770ddd3bb333303bb3333306666660600600ddddd0666600a00ddddddddddd
d3bbbb3dd0ffff0ddd000dddddddddddd0ffff0dd030b33bbbbb030d0777077770770dddbbbbb3303bbbb33bd066666600a00dddddd0666666aaa0dddddddddd
dd3333dddd00000ddddddddddddddddddd00000d030bbbbbbbbbb0300777070770770dddbbbbbbb03bbbbbbbd066666666aaa0dddd0666666aaaaa0ddddddddd
ddd0ddddd444444dddd00000000000000000dddd30bbbbbb00000000077770770007000dbbbbbbb03bbbbbbbdd0666666aaaaa0ddd06666660000060dddddddd
dd060ddd4f0ff0f4ddd3bbb3bbb3bbb3bbb3dddd033bbbbb3333333307777770eee0eee0b33bbbb0333bbbbbdd066666600000ddd0666666660d060ddddddddd
d06460dd4f0ff0f4ddd33bb33bb33bb33bb3dddd33333bb333330000d07777707070707033333bb033333bb3ddd06666660dddddd066660660ddd0dddddddddd
dd06660dd444444ddddd3333333333333333dddd3333333300003333dd077700777077703333333033333333dddd060660dddddd066660000d00dddddddddddd
dd046460ffffffffdddd333333333333333ddddd3333333333333333ddd07077000e000d3333333033333333ddddd0000d00ddddd0660dd00d0a0ddddddddddd
d040060ddffffffdddddd33dd33dd33dd33ddddd3bb333333bb33333dddd00000eee0ddd3bb333303bb33333ddddddd00d0a0ddddd00ddd0a0d0dddddddddddd
060dd0ddd444444dddddddddddddddddddddddddbbbbb33bbbbbb33bddd0eeeeeeeee0ddbbbbb3303bbbb33bddddddd0a0d0dddddddddddd0ddddddddddddddd
d0ddddddddfddfddddddddddddddddddddddddddbbbbbbbbbbbbbbbbdd0000000000000dbbbbbbb03bbbbbbbdddddddd0ddddddddddddddddddddddddddddddd
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
dd0dd00000000ddddd00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd000000000000000000000000000000000000000000000000
d0400444444440ddd0ee0dddddddddddddddddddddddddddddddddddddddddddddddd00000dddddd000000000000000000000000000000000000000000000000
d04444444444440dd02ee0ddddddddddddd0000000000dddddddddddddddddddddd008888800dddd000000000000000000000000000000000000000000000000
dd044444444fff40dd02ee0ddddddddddd0ffffffff4f0dddddd00000000dddddd08888888880ddd000000000000000000000000000000000000000000000000
d04444444440ff40ddd02e0dddddddddd0fff4ffffffff0ddd00444444440dddd0888888888880dd000000000000000000000000000000000000000000000000
d044444444ff0f0dddd02e0ddddddddd0ffffffff4fff4f0d0444444444440dd088888888888880d000000000000000000000000000000000000000000000000
d044444444ffff0ddd222222222222dd0f4ffffffffffff0d0444ff444ff440d08888ff0ff808880000000000000000000000000000000000000000000000000
d044444444ffff0dddddd0ddddddddddd00000000000000d0444f0f444f0440d0888fff0fff0f880000000000000000000000000000000000000000000000000
dd0444444444440ddd00dd00dddddddd0444444444444440044fff0f4f0f40dd0888fff0fff0ff80000000000000000000000000000000000000000000000000
ddd0444444fff00dd0ee00ee0ddddddd0444444444444440044ffffffffff0dd0888fff0fff0ff80000000000000000000000000000000000000000000000000
dddd044444440ff0d02ee02ee0ddddddd00000000000000d0444fffffffff0dd0888fffffffff00d000000000000000000000000000000000000000000000000
ddddd0ff4400fff0dd02ee02ee0ddddd0ffffffffffff4f0d0004444444440ddd088ffffffff0ddd000000000000000000000000000000000000000000000000
dddd0ff000fffff0ddd02e002e0ddddd0ff4fffffffffff00fff04fffff40ddddd000fffff00dddd000000000000000000000000000000000000000000000000
ddd0ffffffffff0dddd02e002e0dddddd0ffffff4fffff0d0fff04444440ddddddddd0fff0dddddd000000000000000000000000000000000000000000000000
dd0fffffffff00dddd222222222222dddd000000000000dd0fff0ff4400ddddddddd0feeef0ddddd000000000000000000000000000000000000000000000000
d0ffffffff00f0ddddddd0ddd0dddddddddddddddddddddd0ff0fffffff0d0ddddd00eeeeee00ddd000000000000000000000000000000000000000000000000
d0ffffffffffff0ddd00dd00dd00dddd2200000000000000d0ffffffffff0f0ddd0ff0eeee0ff0dd000000000000000000000000000000000000000000000000
dd000000000000ddd0ee00ee00ee0ddd2200001100000000d0fffffff0ff0f0ddd0ff0eeee0ff0dd000000000000000000000000000000000000000000000000
d04444444444440dd02ee02ee02ee0dd8800002200000000d0000000000000ddddd0008880d00ddd000000000000000000000000000000000000000000000000
d00004440000040ddd02ee02ee02ee0d880000550000000004444440000440dddddd0eeeee0ddddd000000000000000000000000000000000000000000000000
0ffff000d0fff0ddddd02e002e002e0d99000088000000000400040ffff040dddddd0000000ddddd000000000000000000000000000000000000000000000000
0fff0dddd0ffff0dddd02e002e002e0d990000990000000000fff00ffff040dddddd0f0d0f0ddddd000000000000000000000000000000000000000000000000
0ff0dddddd0000dddd2222222222220daa0000aa00000000d0ffff0000000dddddd0880d0880dddd000000000000000000000000000000000000000000000000
d000ddddddddddddddddd0ddd0ddd0ddaa00007700000000dd00000ddddddddddddd000d000ddddd000000000000000000000000000000000000000000000000
d444444ddddddddddd00dd00dd00dddd000000000000000077777777777777777777777777777777000000000000000000000000000000000000000000000000
4f0ff0f4dd2222ddd099009900990ddd00000000000000004f0ff0f4ddd3bbb3bbb3bbb3bbb3dddd000000000000000000000000000000000000000000000000
4f0ff0f4d288882dd0899089908990dd00000000000000004f0ff0f4ddd33bb33bb33bb33bb3dddd000000000000000000000000000000000000000000000000
d444444dd289982ddd0899089908990d0000000000000000d444444ddddd3333333333333333dddd000000000000000000000000000000000000000000000000
ffffffffd289982dddd089008900890d0000000000000000ffffffffdddd333333333333333ddddd000000000000000000000000000000000000000000000000
dffffffdd288882dddd089008900890d0000000000000000dffffffdddddd33dd33dd33dd33ddddd000000000000000000000000000000000000000000000000
d444444ddd2222dddd8888888888880d0000000000000000d444444ddddddddddddddddddddddddd000000000000000000000000000000000000000000000000
ddfddfddddddddddddddd0ddd0ddd0dd0000000000000000ddfddfdddddddddddddddddddddddddd000000000000000000000000000000000000000000000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccacccacccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccacccacccacccacccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccacccacccacccacccacccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccacccacccacccacccacccacccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccacccacccacacacacacccacccacccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccacccaccacacacacacacaccccacccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccacccacacacacacacacacacacacccacccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaccacacacacacacacacacacaacccacccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccacccacacacacacacacacacacacacacccacccccccccccccc
ccccccccccccccccccccccccccccccccc7777777777777cccccccccccccccccccccccccccccccccacccaacacacacacacacacacacacacaccaccccc77777777777
ccccccccccccccccccccccccccccc777777777777777777777cccccccccccccccccccccccccccccccacacacacacacaaaaaaacacacacacaccc777777777777777
cccccccccccccccccccccccccc777777777777777777777777777ccccccccccccccccccccccccccaccacacacacaaaaaaaaaaaaacacacac777777777777777777
cccccccccccccccccccccccc7777777777777777777777777777777ccccccccccccccccccccccacccacacacacaaaaaaaaaaaaaaacaca77777777777777777777
ccccccccccccccccccccccc777777777777777777777777777777777cccccccccccccccccccccccaacacacacaaaaaaaaaaaaaaaaaca777777777777777777777
cccccccccccccccccccccc77777777777777777777777777777777777ccccccccccccccccccccacccacacacaaaaaaaaaaaaaaaaaaa7777777777777777777777
ccccccccccccccccccccc7777777777777777777777777777777777777cccccccccccccccccaccccacacacaaaaaaaaaaaaaaaaaaa77777777777777777777777
cccccccccccccccccccc777777777777777777777777777777777777777ccccccccccccccccccacacacacaaaaaaaaaaaaaaaaaaa777777777777777777777777
ccccccccccccccccccc77777777777777777777777777777777777777777cccccccccccccccaccccacacaaaaaaaaaaaaaaaaaaa7777777777777777777777777
ccccccccccccccccccc77777777777777777777777777777777777777777cccccccccccccccccacacacacaaaaaaaaaaaaaaaaaa7777777777777777777777777
ccccccccccccccccccc77777777777777777777777777777777777777777cccccccccccccccaccacacacaaaaaaaaaaaaaaaaaaa7777777777777777777777777
ccccccccccccccccccc77777777777777777777777777777777777777777cccccccccccccccccacacacaaaaaaaaaaaaaaaaaaaa7777777777777777777777777
ccccccccccccccccccc77777777777777777777777777777777777777777cccccccccccccccaccacacacaaaaaaaaaaaaaaaaaaa7777777777777777777777777
cccccccccccccccccccc777777777777777777777777777777777777777ccccccccccccccccccacacacaaaaaaaaaaaaaaaaaaaaa777777777777777777777777
ccccccccccccccccccccc7777777777777777777777777777777777777cccccccccccccccccaccacacacaaaaaaaaaaaaaaaaaaaaa77777777777777777777777
cccccccccccccccccccccc77777777777777777777777777777777777ccccccccccccccccccccacacacaaaaaaaaaaaaaaaaaaaaaaa7777777777777777777777
ccccccccccccccccccccccc777777777777777777777777777777777cccccccccccccccccccaccacacacaaaaaaaaaaaaaaaaaaaaaaa777777777777777777777
cccccccccccccccccccccccc7777777777777777777777777777777ccccccccccccccccccccccacacacacaaaaaaaaaaaaaaaaaaaaaaa77777777777777777777
cccccccccccccccccccccccccc777777777777777777777777777ccccccccccccccccccccccaccccacacaaaaaaaaaaaaaaaaaaaaaaaaac777777777777777777
ccccccccccccccccccccccccccccc777777777777777777777cccaaaaaaaaaaaaaaaaaaccccccacacacacaaaaaaaaaaaaaaaaaaaaaaacacac777777777777777
ccccccccccccccccccccccccccccccccc7777777777777aaaaaaa333333333333333333aaaaaaaccacacacaaaaaaaaaaaaaaaaaaaaacacacaccac77777777777
ccccccccccccccccccccccccccccccccccccccccccaaaa33333333333333333333333333333333aaaacacacaaaaaaaaaaaaaaaaaaacacacacacccccccccccccc
cccccccccccccccccccccccccccccccccccccccaaa3333333333333333333333333333333333333333aaacacaaaaaaaaaaaaaaaaacacacacaccacccccccccccc
ccccccccccccccccccccccccccccccccccccaaa3333333333333333333333333333333333333333333333aaacaaaaaaaaaaaaaaacacacacacacccccccccccccc
ccccccccccccccccccccccccccccccccccaa3333333333333333333333333333333333333333333333333333aaaaaaaaaaaaaaacacacacaacccacccccccccccc
cccccccccccccccccccccccccccccccaaa33333333333333333333333333333333333333333333333333333333aaaaaaaaaacacacacacacccacccccccccccccc
cccccccccccccccccccccccccccccaa33333333333333333333333333333333333333333333333333333333333333aacacacacacacacaccacccccccccccccccc
cccccccccccccccccccccccccccca333333333333333333333333333333333333333333333333333333333333333333acacacacacacacacccacccccccccccccc
ccccccccccccccccccccccccccaa33333333333999999993399999999993333999999999999993399999933333333333aaacacacacaacccacccccccccccccccc
ccccccccccccccccccccccccca333333333333390000009339000099009333390000009900009339000093333333333333aacacacacccacccccccccccccccccc
cccccccccccccccccccccccca33333333333333900000099990000990093333900000099000099990000999333333333333aacaccccacccccccccccccccccccc
ccccccccccccccccccccccaa3333333333333339990099990099999900933339009900990099009900990093333333333333aacccacccacccccccccccccccccc
ccccccccccccccccccccca33333333333333333339009339009999990093333900990099009900990099009333333333333333aacccacccccccccccccccccccc
cccccccccccccccccccca3333333333333333333390093390000009900933339000000990099009900990093333333333333333acacccccccccccccccccccccc
ccccccccccccccccccca333333333333333333333900933900000099009333390000009900990099009900933333333333333333accccccccccccccccccccccc
ccccccccccccccccccca333333333333333333333900933999990099009333390099009900990099009900933333333333333333accccccccccccccccccccccc
cccccccccccccccccca33333333333333333333999009999999900990099999900990099009900990099009333333333333333333acccccccccccccccccccccc
ccccccccccccccccca3333333333333333333339000000990000999900000099009900990099009900000093333333333333333333accccccccccccccccccccc
cccccccccccccccca333333333333333333333390000009900009339000000990099009900990099000000933333333333333333333acccccccccccccccccccc
cccccccccccccccca333333333333333333333399999999999999339999999999999999999999999999999933333333333333333333acccccccccccccccccccc
ccccccccccccccca33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333accccccccccccccccccc
ccccccccccccccca33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333accccccccccccccccccc
ccccccccccccccca33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333accccccccccccccccccc
cccccccccccccca3333333333339999999999999933999999999999999999999933999999999999999999999999999999993333333333acccccccccccccccccc
cccccccccccccca3333333333339000000990000933900990099000000990000933900000099009900990000009900000093333333333acccccccccccccccccc
cccccccccccccca3333333333339000000990000999900990099000000990000999900000099009900990000009900000093333333333acccccccccccccccccc
cccccccccccccca3333333333339009900990099009900990099009999990099009999009999009900990099009900999993333333333acccccccccccccccccc
cccccccccccccca3333333333339009900990099009900990099009993390099009339009339009900990099009900999333333333333acccccccccccccccccc
cccccccccccccca3333333333339000000990099009900990099000093390099009339009339009900990000999900009333333333333acccccccccccccccccc
cccccccccccccca3333333333339000000990099009900990099000093390099009339009339009900990000999900009333333333333acccccccccccccccccc
cccccccccccccca3333333333339009900990099009900000099009993390099009339009339009900990099009900999333333333333acccccccccccccccccc
cccccccccccccca3333333333339009900990099009900000099009999990099009339009339009900990099009900999993333333333acccccccccccccccccc
cccccccccccccca3333333333339009900990000009999009999000000990099009339009339990000990099009900000093333333333acccccccccccccccccc
ccccccccccccccca33333333333900990099000000933900933900000099009900933900933339000099009900990000009333333333accccccccccccccccccc
ccccccccccccccca33333333333999999999999999933999933999999999999999933999933339999999999999999999999333333333accccccccccccccccccc
ccccccccccccccca33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333accccccccccccccccccc
cccccccccccccccca333333333333000000000000000000000000000000000000000000000000000000000000000000000333333333acccccccccccccccccccc
cccccccccccccccca333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333acccccccccccccccccccc
ccccccccccccccccca3333333333399999999999339999333999999939999999939999999933339999999999999999999933333333accccccccccccccccccccc
cccccccccccccccccca33333333339000900090939900933390009093900090099900990093339900900090009000990093333333acccccccccccccccccccccc
ccccccccccccccccccca333333333909090909093909093339090909390909090909990909333909990909000909990999333333accccccccccccccccccccccc
ccccccccccccccccccca333333333900090009093909093339009909390009090909390909333909990009090900990009333333accccccccccccccccccccccc
cccccccccccccccccccca3333333390999090909990909333909090999090909090999090933390909090909090999990933333acccccccccccccccccccccccc
ccccccccccccccccccccca33333339093909090009009933390009000909090909900900993339000909090909000900993333accccccccccccccccccccccccc
ccccccccccccccccccccccaa3333399939999999999993333999999999999999999999999333399999999999999999999333aacccccccccccccccccccccccccc
cccccccccccccccccccccccca33333333333333333333333333333333333333333333333333333333333333333333333333acccccccccccccccccccccccccccc
ccccccccccccccccccccccccca333333333333333333333333333339999999999999999933333333333333333333333333accccccccccccccccccccccccccccc
ccccccccccccccccccccccccccaa33333333333333333333333333390009000900090909333333333333333333333333aacccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccca333333333333333333333333339990909099909090933333333333333333333333acccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccaa33333333333333333333333390009090900090009333333333333333333333aaccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccaaa33333333333333333333390999090909999909333333333333333333aaaccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccaa3333333333333333333900090009000939093333333333333333aacccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccaaa3333333333333333999999999999939993333333333333aaacccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccaaa3333333333333333333333333333333333333333aaaccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccaaaa33333333333333333333333333333333aaaacccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccaaaaaaa333333333333333333aaaaaaacccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a1a1a1a1a1a1a1a1a1a1a11111111111111111111
111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a1a1a1a1a1a1a111a111111111
111111111111111111111111111111111111111111111111111111111111111111111111111111111a11111a1a1a1a1a1111111111111a1a1a11111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a1a1a1a1a1a11111111111a111a1111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a1a1a11111a1a1a1a1a1a1a1a1111111a1111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111a111a1a1111111a1a1a1a1a1a1a1a111a1a1a1a1a1111
11111111111111111111111111111111111111111111111111111111111111111111111111111111a111a1a1a1a1a1a1a1a1a1a1a1a1a1111111a1a111111111
111111111111111111111111111111111111111111111111111111111111111111111111111111111a1a1a111a1a1a1a1a1a1a1a1a1a1a1a1a1a111111111111
11111111111111111111111111111717171717171711111111111111111111111111111111111a11111a1a1a111a1a1a1a1a1a1a1a1a1a1a1a1a1111111a1117
11111111111111111111111111117171717171717171717171717111111111111111111111111111111111111111a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a111
111111111111111111111111117171717171717171717171717171717111111111111111111111111111a11111a1a111a1a1a1a1a1a1a1a1a1a1a1a1a1a11171
1111111111111111111171717171717171717171717171717171717111111111111111111111111111111111a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a171717171
111111111111717171717171717171717171717171717171717111111111111111111111111111a11111a1a1a1a1a1a1a1a1a1a1a1a1a1a1a171717171717171
111111171717171717171717171717171717171717171717171111111111111111111111111a1a1a111a1a1a1a1a1a1a1a1a1a1a1a1a1a171717171717171717
11111111717171717171717171717171717171717171717171717111111111111111111111a111a1a1a111a1a1a1a1a1a1a1a1a1a1a1a1a17171717171717171
1111111111171717171717171717171717171717171717171717171717171111111111111111111111111a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a171717171717
1111111111111111717171717171717171717171717171717171717171717171711111111111111111111111a1111111a1a1a1a1a1a1a1a1a1a1a1a171717171
11111111111111111717171717171717171717171717171717171717171717171717111111111111111111111a1111111a1a1a1a1a1a1a1a1a1a1a1a1a171717
11111111111111717171717171717171717171717171717171717171717171717111111111111111111111111111a1a1a1a1a1a1a1a1a1a1a1a1a1a171717171
11111111171717171717171717171717171717171717171717171717171711111111111111111111111a11111a1a1a1a1a1a1a1a1a1a1a1a1a1a171717171717
111717171717171717171717171717171717171717171717171717111111111111111111111a11111a1a111a1a1a1a1a1a1a1a1a1a1a1a171717171717171717
7171717171717171717171717171717ccccccccccccccccccccc111ccccc11111111cccc11a1a111cccccccca1accccca1a1a1a1a1a1a1717171717171717171
1717171717171717171717171717171c000c000c000cc00cc00c111c0c0c1111111cc00c1111111cc00c000c1a1c000c1a1a1a1a1a1a1a171717171717171717
1111111171717171717171717171717c0c0c0c0c0ccc0ccc0ccc111c0c0c1111111c0ccc111111ac0c0c0c0c111ccc0ca1a1a1a1a1a1a1a1a1a1717171717171
1111111111111117171717171717171c000c00cc00cc000c000c171cc0ccccc1111c0c11ccc1111c0c0c00cc1a1cc0cc11111a1a1a1a1a1a1a1a1a1a1a111717
1111111111111111111171717171717c0ccc0c0c0ccccc0ccc0c717c0c0cc0c1111c0cccc0c1111c0c0c0c0c11ac0ccc11a1a11111a1a1a1a1a1a1a1a1a1a111
1111111111111111111111111717171c0c1c0c0c000c00cc00cc171c0c0c0cc1111cc00c0cc1111c00cc0c0c111c000c1111111a1a11111a1a1a1a1a1a1a1a1a
1111111111111111111111111111171ccc1cccccccccccccccc7171ccccccc111111cccccc11111ccccccccc111ccccc111a1a11111a1a11111a1a1a1a1a1a11
1111111111111111111111111111171717171717171717111111111111111111111111111111111111111111111a11111a11111a1a11111a1a11111a1a11111a
111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a11111a1a11111a1a111a1a11111a1a11111a1a11
111111111111111111111111111111111111111111111111111111111111111111111111111111111111a1111111a1a11111a1a11111a1a11111a11111111111
111111111111111111111111111111111111111111111111111111111111111111111111111111a11111a11111a1a11111a1a111a1a11111a111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111a111a111a1a11111a1a111111111a11111111111111
111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a11111a11111a1a1111111a11111a111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a11111a11111a111111111a11111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a11111a111111111a11111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a11111a111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111a11111a11
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111

__gff__
0000000000010400000000000000000010000000000104000000000000000000000000000002080000010100000000000000101010040400000101000000000000000000000104000000000000000000000000000001040000000000000000000000000000010400000000000000000000001000000104000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000101010000000000000
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
01020000180530f051050510f0501b0502b0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
