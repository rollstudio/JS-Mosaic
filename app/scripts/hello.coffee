canvasSource = document.getElementById 'source'
ctxSource = canvasSource.getContext '2d'

canvasSquare = document.getElementById 'square'
ctxSquare = canvasSquare.getContext '2d'

canvasSquareTmp = document.getElementById 'square-temp'
ctxSquareTmp = canvasSquareTmp.getContext '2d'

L = 10

stash = []

createWorker = ->
    worker = new Worker 'scripts/workers/analyze.js'

    return worker

divideImage = (context, width, height) ->
    parts = []

    quarter = Math.ceil height / 4

    quarter = Math.ceil(quarter / L) * L

    partsPositions = [
        [0, 0, width, quarter],
        [0, quarter, width, quarter * 2],
        [0, quarter * 2, width, quarter * 3],
        [0, quarter * 3, width, height],
    ]

    for i in [0...partsPositions.length]
        p = partsPositions[i]
        data = context.getImageData p[0], p[1], p[2], p[3]

        parts.push {data: data, positions: p}        
    
    parts

createStash = (images) ->
    out = []

    ctxSquareTmp.height = L
    ctxSquareTmp.width = L

    for image in images
        ctxSquareTmp.drawImage image, 0, 0, L, L

        data = ctxSquareTmp.getImageData 0, 0, L, L

        out.push new ImageWrapper data.data, ''

    out

resetImages = () ->
    stash = []


processImages = (images) ->
    loadImages images, (results) ->
        stash = createStash results

createMosaic = (images) ->
    w = canvasSource.width
    h = canvasSource.height

    canvasSquare.width = w
    canvasSquare.height = h

    parts = divideImage ctxSource, w, h

    total = parts.length
    current = 0

    for part in parts
        worker = createWorker()

        worker.postMessage({
            part: part,
            images: images,
            L: L
        })

        worker.onmessage = (e) ->
            images = e.data

            for image in images
                data = ctxSquare.createImageData L, L
                data.data.set(image.data)

                ctxSquare.putImageData data, image.x, image.y

            current++

            if current == total
                button = document.querySelector '#response button'

                button.disabled = false
                $(button).text 'Save'


loadImage = (src, callback) ->
    $img = $ '<img/>', {
        src: src,
        load: -> 
            callback(this)
    }

    img = $img[0]

    $img.bind "readystatechange", ->
        if this.readyState == "complete"
            callback(this)

            $(this).unbind();

    if img.complete || img.readystate == "complete"
        callback(img)

        $img.unbind()


loadImages = (images, callback) ->
    count = images.length
    out = []

    _done = (img) ->
        out.push img

        if --count == 0
            callback(out)

    for image in images
        url = image

        loadImage url, _done

doMosaic = (request) ->
    if stash.length == 0

        return window.setTimeout doMosaic, 200
    createMosaic stash

doSpin = ->
    opts = {
        lines: 14,
        length: 5,
        width: 16,
        radius: 5,
        color: '#fff',
        speed: 1
        trail: 60
    }

    target = document.getElementById('spinner');
    spinner = new Spinner(opts).spin(target);

doSpin()

this.doMosaic = doMosaic
this.processImages = processImages
this.resetImages = resetImages
