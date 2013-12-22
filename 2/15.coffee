### (c) 2013 Maxim Litvinov ###

images = [
	'img/art-красивые-картинки-fantasy-море-947687.jpeg'
	'img/art-красивые-картинки-usavich-милиция-681232.jpeg'
	'img/art-красивые-картинки-черно-белое-бант-690725.jpeg'
	'img/fantasy-art-красивые-картинки-русалки-801550.jpeg'
]
round = 0

$ ->
	canvas = document.getElementById 'canvas'
	ctx = canvas.getContext '2d'

	divx=divy=div0=state=img=w=h=x0=y0=idx=idy=jdx=jdy=null

	shuffle = (a)->
		for i of a
			j = Math.random()*i |0
			t = a[i]
			a[i] = a[j]
			a[j] = t
		a

	getPos = (i)->
		x:i%divx
		y:i/divx|0
	
	newPuzzle = (w,h)->
		divx = w
		divy = h
		div0 = divx*divy-1
		state = shuffle [0...w*h]
		img = new Image()
		img.onload = draw
		img.src = images[round]
		round = (round+1)%images.length
		
		

	draw = ->
		if not img? or img.width is 0
			return
		ctx.clearRect 0,0,w,h
		aspect = img.width/img.height
		w2 = h*aspect
		x0 = (w-w2)/2
		y0 = 0
		idx = img.width/divx
		idy = img.height/divy
		jdx = w2/divx
		jdy = h/divy
		for i,j in state when i isnt div0
			ipos = getPos i
			jpos = getPos j
			ctx.drawImage img,
				idx*ipos.x, idy*ipos.y,
				idx, idy,
				x0+jdx*jpos.x, y0+jdy*jpos.y,
				jdx, jdy

	window.onresize = resize = ->
		w = canvas.width = canvas.offsetWidth
		h = canvas.height = canvas.offsetHeight
		draw()
	
	resize()

	
	
	isSolved = ->
		for i,j in state
			if i isnt j
				return false
		return true

	is0 = (x,y)->
		x in [0...divx] and y in [0...divy] and state[x+y*divx] is div0

	getj = (x,y)->
		x+y*divx if x in [0...divx] and y in [0...divy]

	swap = (i,j)->
		t = state[i]
		state[i]=state[j]
		state[j]=t

	canvas.onclick = click = (e)->
		if isSolved()
			newPuzzle(divx+1,divy+1)
			return

		offset = $(canvas).offset()
		x = Math.floor (e.pageX - offset.left - x0)/jdx
		y = Math.floor (e.pageY - offset.top - y0)/jdy
		if x in [0...divx] and y in [0...divy]
			j = x+y*divx
			console.log x, y, j, is0 x,y
			if is0 x-1,y
				swap j, getj x-1,y
			else if is0 x+1,y
				swap j, getj x+1,y
			else if is0 x,y-1
				swap j, getj x,y-1
			else if is0 x,y+1
				swap j, getj x,y+1
			draw()

	newPuzzle(3,3)

