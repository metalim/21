### (c) 2013 Maxim Litvinov ###

iw = 10
ih = 20
firstTimeout = 1000
speedIncrease = 1.05

shapes = [
	[
		[0,0]
		[0,0]
	]
	[
		[1,1,1,1]
	]
	[
		[null,2,2]
		[2,2,null]
	]
	[
		[null,null,3]
		[3,3,3]
	]
	[
		[4,4,null]
		[null,4,4]
	]
	[
		[5,null,null]
		[5,5,5]
	]
	[
		[null,6,null]
		[6,6,6]
	]
]

styles = [
	'black'
	'grey'
	'darkred'
	'red'
	'darkblue'
	'blue'
	'darkgreen'
	'green'
]

$ ->
	canvas = document.getElementById 'canvas'
	ctx = canvas.getContext '2d'


	w=h=l=x0=y0=state=part=ticker=timeout=null
	playing = true
	
	gameover = ->
		playing = false
		ctx.font = 'bold 200% sans-serif'
		ctx.strokeStyle = 'darkred'
		ctx.fillStyle = 'red'
		ctx.textAlign = 'center'
		ctx.fillText 'GAME OVER',w/2,h/2
		ctx.strokeText 'GAME OVER',w/2,h/2
		console.log 'GAME OVER'

	newPart = ->
		part =
			x:4,
			y:0,
			shape: shapes[Math.random()*shapes.length|0]
		draw()
		if haveSpace part.shape,part.x,part.y
			ticker = setTimeout tick,timeout
		else
			gameover()

	tick = ->
		clearTimeout ticker
		ticker = null
		if tryMove part.x, part.y+1
			ticker = setTimeout tick,timeout
		else
			drop()
			

	reset = ->
		state = (null for x in [0...iw] for y in [0...ih])
		playing = true
		timeout = firstTimeout
		resize()
		newPart()

	haveSpace = (shape,x,y)->
		if x<0 or x+shape[0].length>iw or y+shape.length>ih
			return false
		for row,dy in shape when y+dy>=0
			for cell,dx in row when cell?
				return false if state[y+dy][x+dx]?
		return true

	tryRotate = ->
		cx = part.shape[0].length/2|0
		cy = part.shape.length/2|0
		newShape = (part.shape[y][x] for y in [part.shape.length-1..0] for x of part.shape[0])
		r =
			x:part.x+cx-cy
			y:part.y+cy-cx
			shape:newShape
		if haveSpace r.shape,r.x,r.y
			part = r
			draw()

	tryMove = (x,y)->
		if haveSpace part.shape,x,y
			part.x=x
			part.y=y
			draw()

	drop = ->
		clearTimeout ticker
		ticker = null
		while tryMove(part.x, part.y+1) then
		for row,dy in part.shape when part.y+dy>=0
			for cell,dx in row when cell?
				state[part.y+dy][part.x+dx]=cell
		for row,y in state
			cells=0
			for cell,x in row when cell?
				cells+=1
			if cells is row.length
				state[y] = null
		newState = (row for row in state when row?)
		for row in state when not row?
			newState.unshift((null for x in [0...iw]))
			timeout /= speedIncrease
		state = newState
		newPart()



	drawShape = (x,y,shape)->
		ctx.strokeStyle = 'orange'
		for row,dy in shape
			for cell,dx in row when cell?
				ctx.beginPath()
				ctx.fillStyle = styles[cell]
				ctx.rect x0+(dx+x)*l, y0+(dy+y)*l, l, l
				ctx.fill()
				ctx.stroke()

	draw = ->
		ctx.clearRect 0,0,w,h
		ctx.strokeStyle = 'black'
		ctx.strokeRect x0-1,y0-1,l*iw+2,l*ih+2 # glass frame
		if state?
			for row,y in state
				for cell,x in row when cell?
					ctx.fillStyle = styles[cell]
					ctx.fillRect x0+x*l, y0+y*l, l, l
		if part?
			drawShape part.x, part.y, part.shape


	window.onresize = resize = ->
		w = canvas.width = canvas.offsetWidth
		h = canvas.height = canvas.offsetHeight
		l = Math.min w/iw, h/ih
		x0 = (w-l*iw)/2
		y0 = (h-l*ih)/2
		draw()
	
	reset()



	document.onkeydown = keydown = (e)->
		if not playing
			reset()
			return
		if e.keyCode is 37 #left
			tryMove part.x-1, part.y
		else if e.keyCode is 38 #up
			tryRotate()			
		else if e.keyCode is 39 #right
			tryMove part.x+1, part.y
		else if e.keyCode is 40 #down
			drop()

	#canvas.onclick = click = (e)->


