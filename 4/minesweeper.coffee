### (c) 2013 Maxim Litvinov ###

iw = 20
ih = 20
probability = 0.2
BOMB = 9
EMPTY = 0
COVER = 1
FLAG = 2
styles = [
	'#ffffff' #0
	'#f7e0e0'
	'#efc0c0'
	'#e7a0a0'
	'#df8080'
	'#d76060'
	'#cf4040'
	'#c72020'	
	'#bf0000' #8
	'#000000' #bomb
]
cover_styles = [
	'white' #---
	'lightgray' #covered
	'gold' #flaged
]

$ ->
	canvas = document.getElementById 'canvas'
	ctx = canvas.getContext '2d'
	ctx.translate 0.5,0.5


	w=h=l=x0=y0=state=cover=null
	playing = true
	won = false
	gameover = ->
		playing = false
		won = false
		console.log 'GAME OVER'
	win = ->
		playing = false
		won = true
		console.log 'YOU WIN!'

	reset = ->
		state = ((if Math.random()<=probability then BOMB else EMPTY) for x in [0...iw] for y in [0...ih])
		for row,y in state
			for cell,x in row when cell isnt BOMB
				bombs = 0
				for dy in [y-1..y+1] when 0<=dy<ih
					for dx in [x-1..x+1] when 0<=dx<iw and state[dy][dx] is BOMB
						bombs+=1
				state[y][x]=bombs
		cover = (COVER for x in [0...iw] for y in [0...ih])
		playing = true
		resize()

	draw = ->
		ctx.clearRect 0,0,w,h
		ctx.strokeStyle = 'black'
		ctx.lineWidth = 1
		ctx.strokeRect x0-1,y0-1,l*iw+2,l*ih+2 # frame
		if state?
			for row,y in state
				for cell,x in row
					if cover[y][x] is EMPTY
						ctx.lineWidth = 1
						ctx.strokeRect x0+x*l, y0+y*l, l, l
						if EMPTY<cell<BOMB
							ctx.textAlign = 'center'
							ctx.textBaseline = 'middle'
							ctx.font='bold '+(l/1.5)+'px sans-serif'
							ctx.fillStyle = styles[cell]
							ctx.lineWidth = 4
							ctx.strokeText cell, x0+x*l+l/2, y0+y*l+l/2
							ctx.fillText cell, x0+x*l+l/2, y0+y*l+l/2
						else if cell is BOMB
							ctx.beginPath()
							ctx.moveTo x0+x*l+0.8*l, y0+y*l+0.5*l
							ctx.arc x0+x*l+0.5*l, y0+y*l+0.5*l, 0.3*l, 0, 2*Math.PI
							ctx.fillStyle = styles[BOMB]
							ctx.fill()
					else
						ctx.beginPath()
						ctx.rect x0+x*l, y0+y*l, l, l
						ctx.fillStyle = cover_styles[cover[y][x]]
						ctx.fill()
						ctx.lineWidth = 1
						ctx.stroke()

		if not playing
			ctx.font = 'bold 300% sans-serif'
			ctx.lineWidth = 2
			ctx.textAlign = 'center'
			ctx.textBaseline = 'middle'
			if won
				ctx.strokeStyle = 'yellow'
				ctx.fillStyle = 'green'
				ctx.fillText 'YOU WIN!',w/2,h/2
				ctx.strokeText 'YOU WIN!',w/2,h/2
			else
				ctx.strokeStyle = 'darkred'
				ctx.fillStyle = 'red'
				ctx.fillText 'GAME OVER',w/2,h/2
				ctx.strokeText 'GAME OVER',w/2,h/2



	window.onresize = resize = ->
		w = canvas.width = canvas.offsetWidth
		h = canvas.height = canvas.offsetHeight
		l = Math.min(w/iw, h/ih)&~1
		x0 = (w-l*iw)/2|0
		y0 = (h-l*ih)/2|0
		draw()
	
	reset()



	uncover = (x,y)->
		if x in [0...iw] and y in [0...ih] and cover[y][x] is COVER
			cover[y][x] = EMPTY
			if state[y][x] is BOMB
				gameover()
			else if state[y][x] is EMPTY
				uncover dx,dy for dx in [x-1..x+1] for dy in [y-1..y+1]
		
	flag = (x,y,flag)->
		if x in [0...iw] and y in [0...ih] and cover[y][x] isnt EMPTY
			if flag?
				cover[y][x] = flag
			else
				cover[y][x] ^= COVER^FLAG

	countCoversNear = (x,y,flag)->
		count = 0
		for dy in [y-1..y+1] when dy in [0...ih]
			for dx in [x-1..x+1] when dx in [0...iw] and (cover[dy][dx]&flag) isnt EMPTY
				count += 1
		count

	countCoversTotal = (flag)->
		count = 0
		for dy in [0...ih]
			for dx in [0...iw] when (cover[dy][dx]&flag) isnt EMPTY
				count += 1
		console.log count,flag
		count

	countBombsTotal = ->
		count = 0
		for dy in [0...ih]
			for dx in [0...iw] when state[dy][dx] is BOMB
				count += 1
		console.log count
		count

	canvas.oncontextmenu = canvas.onclick = click = (e)->
		if not playing
			reset()
			return
		offset = $(canvas).offset()
		x = Math.floor (e.pageX - offset.left - x0)/l
		y = Math.floor (e.pageY - offset.top - y0)/l
		if x in [0...iw] and y in [0...ih]
			if cover[y][x] isnt EMPTY
				if e.button is 0
					uncover x,y
				else
					flag x,y
			else if cover[y][x] is EMPTY and state[y][x] isnt EMPTY #3x3
				if e.button is 0 #open 3x3
					if countCoversNear(x,y,FLAG) is state[y][x]
						uncover dx,dy for dx in [x-1..x+1] for dy in [y-1..y+1]
				else #flag 3x3
					if countCoversNear(x,y,COVER|FLAG) is state[y][x]
						flag dx,dy,FLAG for dx in [x-1..x+1] for dy in [y-1..y+1]

		if countCoversTotal(COVER) is 0 and countCoversTotal(FLAG) is countBombsTotal()
			win()
		draw()
		false


