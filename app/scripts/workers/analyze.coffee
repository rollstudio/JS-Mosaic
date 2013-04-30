importScripts '../utils.js'

analyzeImagePart = (part, images, L) ->
    positions = part.positions

    originX = positions[0]
    originY = positions[1]

    w = positions[2] - originX
    h = positions[3] - originY

    out = []

    for y in [0...h] by L
        for x in [0...w] by L
            squareData = getSquareDataFromImageData part.data, L, x, y

            square = new ImageWrapper squareData
            image = square.nearestNeighbor images

            out.push {
                data: image.imageData,
                x: originX + x,
                y: originY + y,
            }

    postMessage out

this.onmessage = (e) ->
    data = e.data

    analyzeImagePart data.part, data.images, data.L