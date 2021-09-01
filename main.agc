
// Project: ledge runner 
// Created: 2021-07-04

// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle( "ledge runner" )
SetWindowSize( 1024, 768, 0 )
SetWindowAllowResize( 1 ) // allow the user to resize the window

// set display properties
SetVirtualResolution( 1024, 768 ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( 30, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ) // use the maximum available screen space, no black borders
UseNewDefaultFonts( 1 ) // since version 2.0.22 we can use nicer default fonts


//init imgs

global playerImg = 1
global grassImg = 3
global purpleImg = 2
global lavaImg = 4


LoadImage(playerImg,"runner.png")
LoadImage(grassImg,"grass.png")
LoadImage(purpleImg,"purple.png")
LoadImage(lavaImg,"lava.png")

//sprite vars

global playerSprite = 1

global sprite_counter = 2

global ledger as yledge[]

//game vars

global origenalGravity as float
global Gravity as float

origenalGravity = 1.6
Gravity = origenalGravity

global ledgeSpeed = 1

global points = 1

global gameOver = 0

//timers
global spawnTimerDuration as float
global spawnTimerDone as float

spawnTimerDuration = 5
spawnTimerDone = GetSeconds()+spawnTimerDuration

//game objects
global player as yplayer
player = newPlayer()

//test ledge
tstl as yledge
tstl = newYledge(0,300)

//buttons
global btnRight = 1
global btnLeft = 2

AddVirtualButton(btnRight,GetScreenBoundsRight()-50,300,50)
AddVirtualButton(btnLeft,GetScreenBoundsLeft()+50,300,50)

do
	print("points: "+str(points))
	
	if gameOver then print("game over")
	if gameOver = 0
		inc points
		playerUpdate()
		moveYledges()
		spawnYledges()
	endif
	
	
	
    Sync()
loop


////////////player////////////

type yplayer
	id
	speed as float
	speedx as float
	speedy as float
	vf as float
	hf as float
endtype

function newPlayer()
	p as yplayer
	
	p.id = playerSprite
	p.speed = 0.1
	p.speedx = 0
	p.speedy = 0
	p.vf = 0.5
	p.hf = 0.95//needs to be a smaller num
	
	//create player sprite
	CreateSprite(p.id,playerImg)
	//spritemap set
	SetSpriteAnimation(p.id,128,128,9)
	//make player size smaller
	SetSpriteScale(p.id,0.5,0.5)
	
endfunction p

function playerUpdate()
	playerMove()
	adjustPosX()
	adjustPosY()
	boundaries()
endfunction

function playerMove()
	
	//reset animation to idle
	if GetSpritePlaying(player.id) =0
		SetSpriteFrame(player.id,1)
	endif
	//click bts
	if GetVirtualButtonState(btnRight)
		inc player.speedx,player.speed //incrament horizontal volocity by speed
		//if sprite is not playing
		if GetSpritePlaying(player.id) =0
			PlaySprite(player.id,15,0,1,-1) //play sprite from start to finish
			SetSpriteFlip(player.id,0,0) //flip sprite left or right
		endif
	endif
	
	if GetVirtualButtonState(btnLeft)
		dec player.speedx,player.speed //deincrament horizontal volocity by speed
		if GetSpritePlaying(player.id) =0
			PlaySprite(player.id,15,0,1,-1)
			SetSpriteFlip(player.id,1,0)
		endif
		
	endif
	
	//gravity and hit ledge
	Ihit = hitYledgeId(0,2)
	if Ihit>0 //preduct 2 pixels above ledge
		player.speedy = 0
		px = GetSpriteX(player.id)
		ly = GetSpritey(Ihit)
		SetSpritePosition(player.id,px,ly-65)
	else
		inc player.speedy,gravity
	endif
	
	//applay friction
	player.speedx =  player.speedx  * player.hf
	player.speedy =  player.speedy  * player.vf
endfunction



function adjustPosX()
	//get movment dir
	xs = sign(player.speedx)
	
	//loop how much we need to move
	i = 0
	while i < abs(player.speedx)
		if hitYledge(xs,0) = 0 //if no collition
			//while not hit ledge from left or right
			px = GetSpriteX(player.id)
			py = GetSpriteY(player.id)
			SetSpritePosition(player.id,px+xs,py)
		else
			//stop player
			player.speedx = 0
			exit
		endif
		inc i
	endwhile
endfunction

function adjustPosY()
	//get movment dir
	ys = sign(player.speedy)
	
	//loop how much we need to move
	i = 0
	while i < abs(player.speedy)
		if hitYledge(0,ys) = 0 //if no collition
			//while not hit ledge from left or right
			px = GetSpriteX(player.id)
			py = GetSpriteY(player.id)
			SetSpritePosition(player.id,px,py+ys)
		else
			//stop player
			player.speedy = 0
			exit
		endif
		inc i
	endwhile
endfunction

function boundaries()
	px = GetSpriteX(player.id)
	py = GetSpriteY(player.id)
	
	if px<0 then setspritex(player.id,0)
	if px> GetScreenBoundsRight() then setspritex(player.id, GetScreenBoundsRight()-50)
	
	//loss conditioms
	if py <-90 or py>GetScreenBoundsBottom()+50 then gameOver = 1
endfunction


/////////////ledge///////////////
type yledge
	id
	speed
	yactive
endtype


function newYledge(x,y)
	l as yledge
	l.id = sprite_counter
	l.speed = ledgeSpeed
	l.yactive = 1
	img = ledgeSpeed+1
	if img > 4 then img = 4
	CreateSprite(l.id,img)
	SetSpritePosition(l.id,x,y)
	SetSpriteSize(l.id,random(100,500),40)
	inc sprite_counter
	ledger.insert(l)
endfunction l
function moveYledges()
	//loop all ledges
	for i = 0 to ledger.length
		
		if ledger[i].yactive = 0 then continue
		lid = ledger[i].id
		lx = getspritex(lid)
		ly = getspritey(lid)
		SetSpritePosition(lid,lx,ly-ledger[i].speed)
		if ly <-100
			ledger[i].yactive = 0
			DeleteSprite(lid)
		endif
	next i 
	
	if mod(points,1000)=0 and ledgeSpeed <4
		inc ledgeSpeed
		dec spawnTimerDuration
	endif
	
endfunction

function spawnYledges()
	//if timer is done
	if spawnTimerDone < timer()
		newYledge(random(0,400),GetScreenBoundsBottom()+20)
		//reset timer
		spawnTimerDone = spawnTimerDuration+GetSeconds()
		
	endif
endfunction

function hitYledge(x as float,y as float)
	ret = 0
	//loop all ledges
	for i = 0 to ledger.length
		if ledger[i].yactive = 0 then continue
		if yhitp(player.id,ledger[i].id,x,y) then ret = 1
	next i 
endfunction ret

function hitYledgeId(x as float,y as float)
	ret = 0
	//loop all ledges
	for i = 0 to ledger.length
		if ledger[i].yactive = 0 then continue
		if yhitp(player.id,ledger[i].id,x,y) then ret = ledger[i].id
	next i
endfunction ret

function yhitp(id1,id2,xp as float,yp as float)
	
	ret = 0
	sx2 as float
	sy2 as float
	w as float
	h as float
	
	sx2 = GetSpriteX(id2) - xp
	sy2 = GetSpriteY(id2) - yp
	w = sx2+GetSpriteWidth(id2)
	h = sy2+GetSpriteHeight(id2)
	
	if GetSpriteInBox(id1,sx2,sy2,w,h) then ret = 1
	
	
	
endfunction ret

function sign(n)
	ret = 0
	if n>0 then ret = 1
	if n<0 then ret = -1
endfunction ret
