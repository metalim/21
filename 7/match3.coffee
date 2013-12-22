### (c) 2013 Maxim Litvinov ###

iw = 8
ih = 8
COLORS = 7
DEG = Math.PI/180

styles = [
	'blue'
	'magenta'
	'red'
	'orange'
	'yellow'
	'green'
	'white'
]

disabled = (e)->
	e.preventDefault()
trace = (e)->
	#console.log e.type,e

class Game
	constructor:->
		@canvas = document.getElementById 'canvas'
		@ctx = @canvas.getContext '2d'
		@ctx.translate 0.5,0.5
		@audio = {}
		(@audio[name] = new Audio 'audio/'+name+'.wav') for name in ['hit','coin','fill']
		@reset()
		@canvas.onmousemove = (e)=>@move e
		@canvas.onmousedown = (e)=>@mousedown e
		@canvas.onmouseup = (e)=>@mouseup e
		@canvas.onclick = trace

		window.onresize = (e)=>@resize e

		document.ontouchstart = disabled
		document.ontouchmove = disabled
		document.onmousewheel = disabled

	reset:->
		@playing = true
		@won = false
		@state = []
		@state = (Math.random()*COLORS|0 for y in [0...ih] for x in [0...iw])
		@resize()
		@tryRemove()

	resize:->
		# iOS7 bug: 100% = outerHeight, not innerHeight
		$('html').height window.innerHeight
		window.scrollTo 0,0
		w = $('div').get(0).offsetWidth
		h = $('div').get(0).offsetHeight
		console.log w,h
		#$(document.body).prepend h
		@u = Math.min(w/iw, h/ih)&~1
		@canvas.width = @w = (@u*iw)|0
		@canvas.height = @h = (@u*ih)|0
		@offset = $(@canvas).offset()
		console.log @w,@h,@u
		@draw()

	userActive:->
		if not musicPlaying
			musicPlaying = true
			audio = $("audio").get(0);
			if audio.duration is 0
				audio.load()
				audio.play()

	getPos: (e)->
		x: Math.floor((e.clientX - @offset.left)/@u)|0
		y: ih - Math.ceil((e.clientY - @offset.top)/@u)|0

	checkMoves:->
		state = (c for c in col for col in @state)
		#horz swap
		for x in [0...iw-1]
			for y in [0...ih]
				@swap state,x,y,x+1,y
				if @canRemove state
					return true
				@swap state,x,y,x+1,y
		#vert swap
		for x in [0...iw]
			for y in [0...ih-1]
				@swap state,x,y,x,y+1
				if @canRemove state
					return true
				@swap state,x,y,x,y+1

	canRemove:(state)->
		# horz
		for x in [0...iw-2]
			for y in [0...ih]
				c = state[x][y]
				same = 1
				for dx in [x+1...iw]
					if state[dx][y] is c
						same += 1
					else
						break
				if same>=3
					return true
		#vert
		for x in [0...iw]
			for y in [0...ih-2]
				c = state[x][y]
				same = 1
				for dy in [y+1...ih]
					if state[x][dy] is c
						same += 1
					else
						break
				if same>=3
					return true
		false

	tryRemove:->
		removing = {}
		# horz
		for x in [0...iw-2]
			for y in [0...ih]
				c = @state[x][y]
				same = 1
				for dx in [x+1...iw]
					if @state[dx][y] is c
						same += 1
					else
						break
				if same>=3
					console.log x,y,'horz',same
					for dx in [x...x+same]
						removing[dx+'x'+y] = {x:dx,y:y}
		#vert
		for x in [0...iw]
			for y in [0...ih-2]
				c = @state[x][y]
				same = 1
				for dy in [y+1...ih]
					if @state[x][dy] is c
						same += 1
					else
						break
				if same>=3
					console.log x,y,'vert',same
					for dy in [y...y+same]
						removing[x+'x'+dy] = {x:x,y:dy}
		removed = 0
		for i of removing
			c = removing[i]
			console.log 'deleting',c.x,c.y
			delete @state[c.x][c.y]
			removed += 1
		console.log removed
		if removed
			@audio.coin.play()
			if not @removing
				@removing = setTimeout =>
					@removing = null
					@fillNew()
				,500
		@draw()
		removed>0

	fillNew:->
		for x of @state
			@state[x] = (c for c in @state[x] when c?)
		for x of @state
			while @state[x].length<ih
				@state[x].push Math.random()*COLORS|0
		@audio.fill.play()
		@draw()
		if not @checkMoves()
			@gameover()
		setTimeout =>
			@tryRemove()
		,500


	swap:(state,x1,y1,x2,y2)->
		c = state[x1][y1]
		state[x1][y1] = state[x2][y2]
		state[x2][y2] = c

	trySwap:(x1,y1,x2,y2)->
		@swap @state,x1,y1,x2,y2
		if not @tryRemove()
			@audio.hit.play()
			@swap @state,x1,y1,x2,y2

	
	mousedown:(e)->
		@userActive()
		if @playing
			@start = @getPos e

	mouseup:(e)->
		if not @playing
			@reset()
			return
		end = @getPos e
		dx = end.x-@start.x
		dy = end.y-@start.y
		if dx is 0 and dy is 0
			return
		if Math.abs(dx)>Math.abs(dy)
			#horizontal
			@trySwap @start.x, @start.y, @start.x + (if dx>0 then 1 else -1), @start.y
		else
			#vertical
			@trySwap @start.x, @start.y, @start.x, @start.y + (if dy>0 then 1 else -1)

	move:(e)->
		if not @playing
			return
		p = @getPos e
		if p.x in [0...iw] and p.y in [0...ih]
			@selected = p
		else
			@selected = null
		@draw()

	gameover:->
		@playing=false
	win:->
		@playing=false
		@won=true
		

	draw:->
		@ctx.clearRect 0,0,@w,@h
		@ctx.strokeStyle = 'grey'
		@ctx.lineWidth = 1
		@ctx.strokeRect 0,0,iw*@u,ih*@u
		for col,x in @state
			for cell,y in col when cell?
				@ctx.fillStyle = styles[cell]
				@ctx.beginPath()
				@ctx.moveTo @u*(x+0.5),@u*(ih-y-0.95)
				for i in [1...cell+3]
					angle = Math.PI*2*i/(cell+3)
					dx = 0.45*Math.sin angle
					dy = -0.45*Math.cos angle
					@ctx.lineTo @u*(x+0.5+dx),@u*(ih-y-0.5+dy)
				@ctx.closePath()
				if @selected? and @selected.x is x and @selected.y is y
					@ctx.globalAlpha = 0.6
				else
					@ctx.globalAlpha = 0.8
				@ctx.fill()
				@ctx.globalAlpha = 1
				@ctx.strokeStyle = 'gray'
				@ctx.lineWidth = 1
				@ctx.stroke()
		if not @playing
			@ctx.font = 'bold '+(@u*ih*0.1)+'px sans-serif'
			@ctx.lineWidth = 2
			@ctx.textAlign = 'center'
			@ctx.textBaseline = 'middle'
			if @won
				@ctx.strokeStyle = 'yellow'
				@ctx.fillStyle = 'green'
				@ctx.fillText 'YOU WIN!',@w/2,@h/2
				@ctx.strokeText 'YOU WIN!',@w/2,@h/2
			else
				@ctx.strokeStyle = 'darkred'
				@ctx.fillStyle = 'red'
				@ctx.fillText 'GAME OVER',@w/2,@h/2
				@ctx.strokeText 'GAME OVER',@w/2,@h/2

$ ->
	new Game()


