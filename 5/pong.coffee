### (c) 2013 Maxim Litvinov ###

BALL_SPEED = 0.03
BALL_ACCELERATION = 1.04
SHIFT_AMP = 0.01
BAT_SPEED = 0.07
BAT_CURVE = 0.01
canvas=ctx=w=h=u=x0=y0=null
playing = true
score =
	left:0
	right:0
iw = 80
ih = 50

class Entity
	constructor: (@x,@y,@w,@h)->
		if @w < 0
			@x += @w
			@w = -@w
		if @h < 0
			@y += @h
			@h = -@h
	move:(@x,@y)->
	draw:->
		ctx.strokeRect x0+@x*u,y0+@y*u,@w*u,@h*u
	getRect:->
		x:@x
		y:@y
		w:@w
		h:@h
	collides:(e)->
		e.x < @x+@w and e.y < @y+@h and @x < e.x+e.w and @y < e.y+e.h


class Ball extends Entity
	constructor: (@x,@y,dir=1)->
		super @x,@y,1,1
		@speed =
			dx:dir
			dy:0

class Bat extends Entity
	constructor: (@x,@y,dir=1)->
		super @x,@y,2*dir,10


bound = (val,min,max)->
	Math.min Math.max(val,min),max

class Game
	constructor:->
		@reset()
		document.onmousemove = (e)=>@move e
		@audio = {}
		(@audio[name] = new Audio 'audio/'+name+'.wav') for name in ['left','right','wall','hit']

	reset:->
		@score =
			left:0
			right:0
		delete @left
		delete @right
		delete @ball
		@left = new Bat 0, 0
		@right = new Bat iw, 0, -1
		@ball = new Ball iw/2, ih/2, -BALL_SPEED
		@time = null
		@random_shift = 0
		@animate()

	move:(e)->
		offset = $(canvas).offset()
		y = (e.pageY - offset.top - y0)/u
		@left.y = bound y, 0, ih-@left.h

	animate:(time)->
		dt = (time - @time) || 0
		@time = time
		next = new Ball @ball.x + @ball.speed.dx*dt, @ball.y + @ball.speed.dy*dt
		next.speed = @ball.speed

		@random_shift = bound @random_shift-SHIFT_AMP+Math.random()*2*SHIFT_AMP, 0, 1
		# adjust right
		if @ball.speed.dx>0
			@right.y += Math.max -BAT_SPEED*dt, Math.min BAT_SPEED*dt, next.y-@right.y+(next.h-@right.h)*@random_shift
			@right.y = bound @right.y, 0, ih-@left.h

		# knock back
		if next.collides @left
			@audio.left.play()
			@ball.speed.dx = -@ball.speed.dx * BALL_ACCELERATION
			@ball.speed.dy += (next.y - @left.y + (next.h - @left.h)/2)*BAT_CURVE
		if next.collides @right
			@audio.right.play()
			@ball.speed.dx = -@ball.speed.dx * BALL_ACCELERATION
			@ball.speed.dy += (next.y - @right.y + (next.h - @right.h)/2)*BAT_CURVE

		# wall hit
		if next.y<0 or next.y+next.h>ih
			@audio.wall.play()
			@ball.speed.dy = -@ball.speed.dy

		next = null

		@ball.x += @ball.speed.dx*dt
		@ball.y += @ball.speed.dy*dt
		@draw()

		if @ball.x<0
			@audio.hit.play()
			@score.right += 1
			delete @ball
			@ball = new Ball(iw/2,ih/2,-BALL_SPEED)
		if @ball.x+@ball.w>iw
			@audio.hit.play()
			@score.left += 1
			delete @ball
			@ball = new Ball(iw/2,ih/2,BALL_SPEED)
		window.requestAnimationFrame (t)=>@animate t

	draw:->
		ctx.clearRect 0,0,w,h
		ctx.strokeRect x0,y0,iw*u,ih*u
		ctx.beginPath()
		ctx.moveTo x0+iw*u/2,y0
		ctx.lineTo x0+iw*u/2,y0+ih*u
		ctx.setLineDash? [5]
		ctx.stroke()
		ctx.setLineDash? []
		ctx.font = 'bold '+(u*ih*0.2)+'px sans-serif'
		ctx.textAlign = 'center'
		ctx.textBaseline = 'middle'
		ctx.strokeText @score.left, x0+iw*u*0.4, y0+ih*u*0.5
		ctx.strokeText @score.right, x0+iw*u*0.6, y0+ih*u*0.5
		@left.draw()
		@right.draw()
		@ball.draw()

$ ->
	canvas = document.getElementById 'canvas'
	ctx = canvas.getContext '2d'
	ctx.translate 0.5,0.5

	window.onresize = resize = ->
		w = canvas.width = canvas.offsetWidth
		h = canvas.height = canvas.offsetHeight
		u = Math.min(w/iw, h/ih)&~1
		x0 = (w-u*iw)/2|0
		y0 = (h-u*ih)/2|0
		console.log w,h,u,x0,y0
	
	resize()
	new Game()


