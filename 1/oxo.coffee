### (c) 2013 Maxim Litvinov ###

$ ->
	canvas = document.getElementById 'canvas'
	ctx = canvas.getContext '2d'
	
	w=h=l=x0=y0=null
	
	state = init_state = [
		[null,null,null]
		[null,null,null]
		[null,null,null]
	]
	
	left = 9
	turn = 1
	
	checkWinner = ->
		# horizontal
		for row,y in state
			if row[0]? and row[0]==row[1] and row[1]==row[2]
				turn = null
				ctx.strokeStyle='red'
				ctx.beginPath()
				ctx.moveTo x0  ,y0+l/6+l/3*y
				ctx.lineTo x0+l,y0+l/6+l/3*y
				ctx.stroke()
		# vertical
		for x in [0..2]
			if state[0][x]? and state[0][x]==state[1][x] and state[1][x]==state[2][x]
				turn = null
				ctx.strokeStyle='red'
				ctx.beginPath()
				ctx.moveTo x0+l/6+l/3*x,y0
				ctx.lineTo x0+l/6+l/3*x,y0+l
				ctx.stroke()
		# diagonal
		if state[0][0]? and state[0][0]==state[1][1] and state[1][1]==state[2][2]
			turn = null
			ctx.strokeStyle='red'
			ctx.beginPath()
			ctx.moveTo x0,y0
			ctx.lineTo x0+l,y0+l
			ctx.stroke()
			
		if state[2][0]? and state[2][0]==state[1][1] and state[1][1]==state[0][2]
			turn = null
			ctx.strokeStyle='red'
			ctx.beginPath()
			ctx.moveTo x0+l,y0
			ctx.lineTo x0,y0+l
			ctx.stroke()
		
	draw = ->
		ctx.clearRect 0,0,w,h
		ctx.lineWidth = 10
		ctx.lineCap = 'round'
		ctx.strokeStyle = '#000'
		ctx.beginPath()
		
		#grid
		ctx.moveTo x0 + l/3,y0
		ctx.lineTo x0 + l/3,y0+l
		ctx.moveTo x0+2*l/3,y0
		ctx.lineTo x0+2*l/3,y0+l
		ctx.moveTo x0  , y0 + l/3
		ctx.lineTo x0+l, y0 + l/3
		ctx.moveTo x0  , y0+2*l/3
		ctx.lineTo x0+l, y0+2*l/3
		ctx.stroke()
	
		#cells
		for row,y in state
			for cell,x in row when cell?
				#console.log y,x,cell
				if cell is 0
					#ctx.moveTo x0+x*l/3+l/3,y0+y*l/3+l/6
					ctx.beginPath()
					ctx.arc x0+x*l/3+l/6, y0+y*l/3+l/6, l/9, 0, Math.PI*2, 0
					ctx.stroke()
				else if cell is 1
					ctx.beginPath()
					ctx.moveTo x0+x*l/3+l/20,y0+y*l/3+l/20
					ctx.lineTo x0+x*l/3+l/3-l/20,y0+y*l/3+l/3-l/20
					ctx.moveTo x0+x*l/3+l/20,y0+y*l/3+l/3-l/20
					ctx.lineTo x0+x*l/3+l/3-l/20,y0+y*l/3+l/20
					ctx.stroke()
		checkWinner()
	
	window.onresize = resize = ->
		w = canvas.width = canvas.offsetWidth
		h = canvas.height = canvas.offsetHeight
		l = if w<h then w-20 else h-20
		x0 = (w-l)/2
		y0 = (h-l)/2
		draw()
	
	resize()
	
	canvas.onclick = click = (e)->
		if turn? and left>0
			offset = $(canvas).offset()
			x = Math.floor (e.pageX - offset.left - x0)/l*3
			y = Math.floor (e.pageY - offset.top - y0)/l*3
			console.log x, y
			if x in [0..2] and y in [0..2] and not state[y][x]?
				state[y][x]=turn
				left -= 1
				turn = 1-turn
				draw()
		else
			state = [[null,null,null],[null,null,null],[null,null,null]]
			turn = 1
			left = 9
			draw()
			