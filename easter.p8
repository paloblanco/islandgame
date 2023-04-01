pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- happy easter
-- love lydia, bea, jeanna, 
-- and rocco
-- april 2023


function _init()
	bunx = 20
	buny = 128 - 32
	bundx = 1
	bunleft = true
	xstart = 128
end

function _update60()
	--if btn(0) then
	if bunx < 20 then
		bundx = 1
		bunleft = true
	end
	--if btn(1) then
	if bunx > 108 then
		bundx -= 1
		bunleft = false
	end
	bunx += bundx
	buny = 128 - 32 - flr(t()*10)%2
end

function _draw()
	cls(13)
	palt(0,false)
	palt(13,true)
	map()
	spr(168,bunx,buny,2,2,bunleft)
	draw_easter()
	draw_cousins()
	draw_girls()
end

function draw_cousins()
	names = {
	"nico",
	"noelle",
	"aunt alison",
	"uncle tony",
	}
	text = ""
	for n in all(names) do
		text = text.."   "..n
	end
	lentext = #text
	--text = "nico and noelle"
	xstart += -0.5
	if xstart < -lentext*4 then
		xstart = 128
	end
	yamp = 1.9
	colors = {8,9,10,11,12,2}
	clen = #colors
	for ix=1,#text,1 do
		wave = -sin(t()/2+ix/10)
		cix = flr(t()*2+ix/10)%clen + 1
		oprints(text[ix],xstart+ix*4,84+yamp*wave,colors[cix],0)
	end
end

function draw_easter()
	text = "happy easter"
	local xstart = 8
	yamp = 4
	colors = {8,9,10,11,12,2}
	clen = #colors
	for ix=1,#text,1 do
		wave = sin(t()/2+ix/10)
		cix = flr(t()*2+ix/10)%clen + 1
		oprint(text[ix],xstart+ix*8,64+yamp*wave,colors[cix],0)
	end
end

function draw_girls()
	text = "from lydia and bea"
	local xstart = 28
	yamp = 1.9
	colors = {8,9,10,11,12,2}
	clen = #colors
	for ix=1,#text,1 do
		wave = sin(t()/2+ix/10)
		cix = flr(t()*2+ix/10)%clen + 1
		oprints(text[ix],xstart+ix*4,118+yamp*wave,colors[cix],0)
	end
end


function oprint(text,x,y,c,co)
	pre = "\^w\^t"
	local t = pre..text
	for xx=x-1,x+1,1 do
	for yy=y-1,y+1,1 do
		print(t,xx,yy,co)
	end
	end
	print(t,x,y,c)
end

function oprints(text,x,y,c,co)
	pre = ""
	local t = pre..text
	for xx=x-1,x+1,1 do
	for yy=y-1,y+1,1 do
		print(t,xx,yy,co)
	end
	end
	print(t,x,y,c)
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
00000000d0444444444440dddd0444f00ff40dddb33bbbbbb33bbbb0ddd0dd00770dddddd08888888888880dddddd040d0660ddd055066600050555000000000
00000000dd0444f00ff40dddddd044444440dddd33333bb333333bb3ddd0dddd00ddddddd08888888888880dddd0040ddd00dddd050666605505055000000000
00000000ddd044444440dddddddd0ff4400ddddd3333333333333333ddd0dddddddddddddd088888888880dddd0660ddddddddddd06666605550600d00000000
00000000dddd0ff4400ddddddd00fffffff0dddd3333333333333333ddd0ddddddddddddddd0888888880ddddd0660ddddddddddd06000050506660d00000000
00000000dd00fffffff0ddddd0ffffffffff0ddd3bb333333bb33333ddd0dddddddddddddddd08800880ddddddd00ddddddddddddd055555506660dd00000000
00000000d0ffffffffff0ddd0fff00ffffff0dddbbbbb33bbbbbb33bddd0ddddddddddddddddd00dd00dddddddddddddddddddddddd0055550600ddd00000000
000000000fff00ffffff0ddd0fffff0fffff00ddbbbbbbbbbbbbbbbbddd0ddddddddddddddddddddddddddddddddddddddddddddddddd000000ddddd00000000
000000000fffff0fffff00dd0ffff0fff0ff0f0dddddddd00ddddddddddddddddddddddd0000000000000000dddddddddddddddddddddddddddddddd00000000
000000000ffff0fff0ff0f0dd0000000000000dddddddd0330dddddddddd00000ddddddd3333333033333333ddd0ddddddd000dddddddddddddddddd00000000
00000000d0000000000000dd044444444444440dddddd030030dddddddd0777770dddddd3333000033330000dd060ddddd06660ddddddddd00d00ddd00000000
00000000044444444444440d040004440000040ddddd03033030dddddd077777770ddddd0000333000003333d06660dd0060060ddddddd00660660dd00000000
00000000040004440000040d00fff000d0fff0ddddd0303333030dddd07777007770dddd333333303333333306666600660660dddddd0060600600dd00000000
0000000000fff000d0fff0dddd0000ddd0fff0dddd0303333bb030dd0777707707770ddd3bb333303bb3333306666660600600ddddd0666600a00ddd00000000
00000000d0ffff0ddd000dddddddddddd0ffff0dd030b33bbbbb030d0777077770770dddbbbbb3303bbbb33bd066666600a00dddddd0666666aaa0dd00000000
00000000dd00000ddddddddddddddddddd00000d030bbbbbbbbbb0300777070770770dddbbbbbbb03bbbbbbbd066666666aaa0dddd0666666aaaaa0d00000000
00000000d444444dddd00000000000000000dddd30bbbbbb00000000077770770007000dbbbbbbb03bbbbbbbdd0666666aaaaa0ddd0666666000006000000000
000000004f0ff0f4ddd3bbb3bbb3bbb3bbb3dddd033bbbbb3333333307777770eee0eee0b33bbbb0333bbbbbdd066666600000ddd0666666660d060d00000000
000000004f0ff0f4ddd33bb33bb33bb33bb3dddd33333bb333330000d07777707070707033333bb033333bb3ddd06666660dddddd066660660ddd0dd00000000
00000000d444444ddddd3333333333333333dddd3333333300003333dd077700777077703333333033333333dddd060660dddddd066660000d00dddd00000000
00000000ffffffffdddd333333333333333ddddd3333333333333333ddd07077000e000d3333333033333333ddddd0000d00ddddd0660dd00d0a0ddd00000000
00000000dffffffdddddd33dd33dd33dd33ddddd3bb333333bb33333dddd00000eee0ddd3bb333303bb33333ddddddd00d0a0ddddd00ddd0a0d0dddd00000000
00000000d444444dddddddddddddddddddddddddbbbbb33bbbbbb33bddd0eeeeeeeee0ddbbbbb3303bbbb33bddddddd0a0d0dddddddddddd0ddddddd00000000
00000000ddfddfddddddddddddddddddddddddddbbbbbbbbbbbbbbbbdd0000000000000dbbbbbbb03bbbbbbbdddddddd0ddddddddddddddddddddddd00000000
00000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0ddddddddddddddddddddddd0000dd
00000000ddddddddddddddddddddddddddddddddddddddddddddddddddddd0dddd0dddddddddd000000dddddddddddddd0f0dddddddddd000dd00dddd0bbbb0d
00000000ddddddddddddddddddd0ddddddddd0ddddddddddddddddddd0dd020dd020dd0dddd0099999900dddddddddd00ff0dddddddd00bbb00bb0dd0bbbbbb0
00000000dddddddddddddddddd0e0dd0000d0e0ddddddddddddddddd020d020dd020d020dd099999959990ddddddd00fffff0dddddd0bbb000b000dd0bbbbbb0
00000000dddddddddddddddddd0ee00eeee0ee0ddddddddddddddddd0220222002220220dd099999555990dddddd0ffff0000ddddd0bbb070707070d0bbbbbb0
00000000ddddddd0dddddddddd0eeeeeeeee0e0dddddddd000d000dd0222000220002220d09995999599990ddddd0f000ffff0dddd0bbb070707070d0bbbbbb0
00000000ddddddd0d000dddddd0eeeeeeeeee0dddddddd033303330d0220444004440220d09999999999990ddddd00ffffff0ddddd0bbbb000b000ddd0bbbb0d
00000000ddddddd00bb0dddddd0ee0eeeeee0e0dddd000070707070d0220404004040220d09999999959990dddd0fffff000f0ddddd0bbbbbbbb00dddd0000dd
00000000ddddddd0bb0dddddd0eeee0eeee0ee0ddd033330003000ddd02044400444020dd09999599999990dddd0ff000fffff0dddd0bbbbbbbbbb0ddddddddd
00000000ddd000000000ddddd0eeeee0ee0eee0ddd033333333330ddd02200022000220dd09599999999590dddd000ffffff00dddddd0bbbbb0000dddddddddd
00000000ddd088808880ddddd0e00eeeeeeeee0dd03333333033330dd02222222222220dd09999999999990ddd0ffffff000ff0ddd0dd0bbbbbbbb0ddddddddd
00000000ddd088808880dddddd0eeeeeeeeee0dd03330333330000dddd022000000220dddd099999999990dddd0fff000fffff0dd0b00bbb000000dddddddddd
00000000ddd000000000ddddd0eeeeee00eeee0dd03330303333330dddd0220220220ddddd099959959990dddd0000fffff0000dd0b0bbb077770ddddddddddd
00000000dddddddddddddddd0eee0000dd0eeee003330000030000dddddd02222220ddddddd0099999900dddd0fffffff0055550dd00bbbb00700ddddddddddd
00000000dddddddddddddddd0ee0ee0dddd0000dd03330ddd030ddddddddd000000dddddddddd000000dddddd0ffffff05555550dddd0bbbbb0bb0dddddddddd
00000000ddddddddddddddddd00d00dddddddddddd00000dd000dddddddddddddddddddddddddddddddddddddd0000000000000dddddd00000d00ddddddddddd
00000000ddddddddddddddddddddddddddddddddddddddddddddddddddddd0dddd0ddddddd000ddddddddddd0000000000000000dddddd000dd00ddd00000000
00000000ddddddddddddddddddd0ddddddddd0dddddddddddddddddddddd020dd020dddddd000000dddddddd0b333333333333b0dddd00bbb00bb0dd00000000
00000000dddddddddddddddddd0e0dd0000d0e0ddddddddd000d000ddddd020dd020dddddd00a0aa0dddddddd0b33b3333b3330dddd0bbb000b000dd00000000
00000000dddddddddddddddddd0ee00eeee0ee0dddddddd033303330ddd0222002220dddd0aa0a0aa0ddddddd0b3b333333b330ddd0bbb070707070d00000000
00000000dddddddddddddddddd0eeeeeeeee0e0dddddd00070707070dd020002200020ddd0aa0aa0aa0ddddddd0b3333333330dddd0bbb070707070d00000000
00000000dddddddddddddddddd0eeeeeeeeee0dddddd03330003000dddd0444004440ddd0aaaa0aa0aa00ddddd0b3333333330dddd0bbbb000b000dd00000000
00000000dddddddddddddddddd0ee0eeeeee0e0dddd033333333330dddd0404004040ddd0aaaa0aa0aaaa0ddddd0b33333330dddddd0bbbbbbbbbb0d00000000
00000000dddddd040000ddddd0eeee0eeee0ee0ddd03333333033330ddd0444004440ddd0aaaaa0aa0aaaa0dddd0b3b33b330dddddd0bbbbbbb000dd00000000
00000000ddddd009d0800dddd0eeeee0ee0eee0ddd0330333300000ddd020002200020dd0aaaaaa0aa0aa0dddddd0b333330dddddddd0bbbbb0ddddd00000000
00000000dddd009999090dddd0eeeeeeeeeeee0dd033330330330330dd020222222020ddd0aaaaa0aaa000dddddd0b333330dddddd0dd0bbbbb0dddd00000000
00000000ddddd0d99d0a0dddd0eeeeeeeeeeee0dd03330000d00000ddd022000000220ddd0aaaaaa000aa0ddddddd0b3330dddddd0b00bbb0bbb0ddd00000000
00000000ddddd09999000ddddd0eeeeeeeeee0ddd0330dddddddddddd02222022022220ddd0aaaaaaaaaa0ddddddd0b3330dddddd0b0bbb070bbb0dd00000000
00000000ddddd0000000ddddddd0eee000ee0ddd0330dddddddddddddd022202202220ddddd0aaaaaaaa0ddddddddd0b30dddddddd00bbbb00000ddd00000000
00000000ddddddddddddddddddd0eee0e0ee0dddd030ddddddddddddddd0200000020ddddddd0aaaaa00dddddddddd0b30dddddddddd0bbbb00bb0dd00000000
00000000dddddddddddddddddddd0eee0ee0dddddd0ddddddddddddddddd0dddddd0ddddddddd00000ddddddddddddd0b0ddddddddddd0bbb0d0b0dd00000000
00000000ddddddddddddddddddddd000000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0ddddddddddddd000ddd0ddd00000000
00000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd4444444444444444
00000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd4444444444444444
00000000000000000000000000000000ddddddddddddddddddddddddddddddddddddddddddddddbbddddddddeeddddddaddddaddadaddaddd4dddddd44dd4ddd
00000000000000000000888800000000dddddddddddddddddddddddddddddddddddddddddddddbbbdddddddeeeedddddddddddddddddddddddddddd44dddd4dd
00000000000000000088899888888000dddddddccddddddddddddddddddddddddddddddddddddbbbddd99ddeeeeddddddddddddddddddddddddddd44dddddd4d
000000000000000000899aa999998880dddddcccccddddddddd5444444445ddddddddddddddddbbbdd999eeeeeeedddddddddaaaaaaddddddddddd4ddddddddd
00000000000000000889abbaaaaa9988dddddccc0cddddddddd4dddddddd4dddddddddeeedddddbbdd99eeeeaeeeccddddddaaaaaaaaddaddddddddddddddddd
00000000000000008999abcbbbbbaa98dddddccccc9dddddddd488c99baa4ddddddddeee2eddddd4d999eeeeeeeccccddaddaaaaaaaadddddddddddddddddddd
00000000000000000000bccccccbbb00dddddcccccddddddddd4888999aa4dddddddde2eeeddddd4999a9eeeeccccccdddddaaaaaaaadddddddddddddddddddd
000000000000000000000222222cccc0ddd66666666666ddddd4888999aa4ddddddddeee2eddddd4999999eeccccccccddddaaaaaaaadddddddddddddddddddd
00000000000000000aa0000000022200ddd66666666666ddd45445445445445dddddde2eeeddddd4d9999dbdccccacccddddaaaaaaaaddaddddddddddddddddd
0000000000000000a0000000000aaa004444666666666644dd544544544544dddddddeeeeeddddd4d9999bbddcccccccdaddaaaaaaaadddddddddddddddddddd
0000000000000000aa00a000000a0aa04444466666664444ddd5555555555ddddddddeee2eddddd4dd99bbddddbccccdddddaaaaaaaadddddddddddddddddddd
000000000000000000a000a0000aaaa06664466666644444ddd4454454454dddddddddeeedddddd4ddddbbddddbccccddddddaaaaaadddaddddddddddddddddd
0000000000000000aa00a0aaaa0a00006666444444444444ddd4454454454dddbbbbbbbbbbbbbbbbddddbbdddbbdccdddadddddddddddddddddddddddddddddd
00000000000000000000a0a00a0aaaa06666444444444444ddd5555555555dddbbbbbbbbbbbbbbbbddbbbbdddbbbbddddddddddddddddddddddddddddddddddd
0000000000000000ddddddd777777777dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd4444444444444444
0000000000000000ddddddd777777777ddddddddddddddddddddddddddddddddddd4dddd4ddddddddddddddddddddddddddddddddddddddd4444444444404444
0000000000000000ddddddd777777777ddddddddddddddddddddddddddddddddddd4dddd4ddddddddddddddddddddddddddddddddddddddd4404444444404444
0000000000000000ddddddddd889abc2ddddddddddddddddddddddddddddddddddd4dddd4ddddddddddddddddddddddddddddddddddddddd4404444444404444
0000000000000000dddddd888889abc2dddddddddddddddddddd0000000dddddddd404404dddddddddcdccdddddddddddddddddddddddddd4404444444404444
0000000000000000dddd88899999abc2ddddddddddddddddddd000000000ddddddd44e444dddddddddccccccdddddddddddd1111dddddddd4404444444404444
0000000000000000dd88899aaaaabbc2ddddddddddddddddddd000000000ddddddd404044ddddddddddc0ccccdddddddddd11111dddddddd4404444044444444
0000000000000000dd899aaabbbbbcc2ddddddddddddddddddd444444444ddddddd444444dddddd6d99ccccccdddddddddd111011ddddddd4404444044444444
0000000000000000d889abbbcccccc2ddd88ddddddddddddddd4444444444dddddd444444444444ddd9cccccccddddccdd91111111dddddd4404444044444444
0000000000000000d89aabccc222222dd8888dddddddddddddd444444448ddddddd444444464644dd99ccccccccdddccddd111111111111d4404444044444444
0000000000000000d777777777ddddddd9999dddddddddddddd466644448ddddddd644644444444ddddccc0000ccccccddd1111111111ddd4404444044444444
0000000000000000d777777777dddddddaaaadddddddddddddd466644440ddddddd444444444444ddddccc000cccccccddd111000011dddd4444444044444404
0000000000000000d777777777dddddddbbbbdddddddddddddd466644448ddddddd444444644644ddddccccccccccdddddd111001111dddd4444444044444404
0000000000000000d777777777dddddddccccdddddddddddddd444444448ddddddd446444444444dddddcccccccccddddddd11100011dddd4444444044444404
0000000000000000d777777777ddddddd2222dddddddddddddd4444444444ddddddd44444444dddddddddd9dd9ddddddddddd9d9dddddddd4444444444444404
0000000000000000dddddddddddddddddd22ddddddddddddddd4444444444dddddddd6ddddd6ddddddddd99d99ddddddddddd9d9dddddddd4444444444444404
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
0000000000010400000000000000000000000000000104000000000000000000000000000002080000010100000000000000101010040400000101000000000000000000000104000000000000000000000000000001040000000000000000000000000000010400000000000000000000001000000104000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000a2a300008e8faeaf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
008c8d0000b2b3aaab8485bebf8e8f0000000000000000000000000000000000000000002505050505050526000000000000000032333333333333340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009c9d00000000babb9495aeaf9e9f0000000000000000000000000000000000000000253515151515151516260000000000000000000000000000000000000000000000000032333334000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000008e8f8e8fbebf00000000000000002505050505260000000000000025351515151515151515162600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a2a300000000009e9f9e9faeaf00acad00000000253515151515162600000000002535151515151515151515151626000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b2b300b2a2a300acad0000bebf00bcbd00000025351515151515151626000000253515151515151515151515151516260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b20000bcbd0000aeaf8e8f8e0005053515151515151515151605050535151515151515151515151515151516050505050505050505050505050505050505052900000000000000002a050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000008e8f8e8fbebf9e9f9e0015151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515153900000000000000003a151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000009e9f9e9faeaf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000a800000000bebf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000aeaf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000a8bebf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8a8b0086878a8b88898a8baeafa48a8b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9a9b0096979a9b98999a9bbebfb49a9b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2a05050505050505050505050505052900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3a15151515151515151515151515153900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01080000270561f056220561805622056180561d05618056270561f05622056180560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
