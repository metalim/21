### (c) 2013 Maxim Litvinov ###

iw = 20
ih = 20
COLORS = 3
degree = Math.PI/180

styles = [
	'red'
	'blue'
	'gold'
	'green'
]

musicPlaying = false
class Game
	constructor:->
		@canvas = document.getElementById 'canvas'
		@ctx = @canvas.getContext '2d'
		@ctx.translate 0.5,0.5
		@canvas.onmousemove = (e)=>@move e
		@canvas.onclick = (e)=>@click e
		window.onresize = (e)=>@resize e
		@audio = {}
		(@audio[name] = new Audio 'audio/'+name+'.wav') for name in ['hit']
		@reset()

	reset:->
		@playing = true
		@won = false
		@state = []
		until @canRemoveAny()
			@state = (Math.random()*COLORS|0 for y in [0...ih] for x in [0...iw])
		@resize()

	resize:->
		@w = @canvas.width = @canvas.offsetWidth
		@h = @canvas.height = @canvas.offsetHeight
		@u = Math.min(@w/iw, @h/ih)&~1
		@x0 = (@w-@u*iw)/2|0
		@y0 = (@h-@u*ih)/2|0
		console.log @w,@h,@u,@x0,@y0
		@draw()

	
	move:(e)->
		if not @playing
			return
		offset = $(@canvas).offset()
		x = Math.floor((e.pageX - offset.top - @x0)/@u)
		y = ih - Math.ceil((e.pageY - offset.top - @y0)/@u)
		if x in [0...iw] and y in [0...ih]
			@selected =
				x:x
				y:y
		else
			@selected = null
		@draw()

	click:(e)->
		if not musicPlaying
			musicPlaying = true
			audio = $("audio").get(0);
			if audio.duration is 0 or audio.paused 
				audio.load()
				audio.play()
		if not @playing
			@reset()
			return
		offset = $(@canvas).offset()
		x = Math.floor((e.pageX - offset.top - @x0)/@u)
		y = ih - Math.ceil((e.pageY - offset.top - @y0)/@u)
		if x in [0...@state.length] and y in [0...@state[x].length]
			if @tryRemove x,y
				@collapse()
				if not @canRemoveAny()
					@gameover()
				if not @state.length
					@win()
				@draw()
			else
				@audio.hit.play()


	gameover:->
		@playing=false
	win:->
		@playing=false
		@won=true

	tryRemove:(x,y)->
		bak = (c for c in col for col in @state)
		res = @remove x,y
		if res<3
			@state = bak
			false
		else
			true

	canRemoveAny:->
		for col,x in @state
			for c,y in col
				bak = (c for c in col for col in @state)
				res = @remove x,y
				@state = bak
				if res>=3
					return true
		false
		

	remove:(x,y,c=@state[x][y])->
		if x in [0...@state.length] and y in [0...ih] and @state[x][y] is c
			delete @state[x][y]
			1+@remove(x-1,y,c)+@remove(x+1,y,c)+@remove(x,y-1,c)+@remove(x,y+1,c)
		else
			0

	collapse:->
		for x of @state
			@state[x] = (c for c in @state[x] when c?)
		@state = (col for col in @state when col.length)

	draw:->
		@ctx.clearRect 0,0,@w,@h
		@ctx.strokeStyle = 'grey'
		@ctx.lineWidth = 1
		@ctx.strokeRect @x0,@y0,iw*@u,ih*@u
		for col,x in @state
			for cell,y in col when cell?
				@ctx.fillStyle = styles[cell]
				@ctx.beginPath()
				@ctx.rect @x0+@u*(x+0.05),@y0+@u*(ih-y-0.95),@u*0.9,@u*0.9
				@ctx.fill()
				if @selected? and @selected.x is x and @selected.y is y
					@ctx.lineWidth = 2
					@ctx.stroke()
				# then 'gold' else 'black'
				#@ctx.strokeStyle = 
				#
		if not @playing
			#@ctx.font = 'bold 300% sans-serif'
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


