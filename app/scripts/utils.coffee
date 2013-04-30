PROXY_URL = 'http://protected-earth-1043.herokuapp.com/tag/'

getSquareDataFromImageData = (imageData, L, x, y) ->
    out = []

    startX = x
    startY = y

    endX = x + L
    endY = y + L

    width = imageData.width
    data = imageData.data

    for y in [startY...endY]
        for x in [startX...endX]
            index = (y * width * 4) + (x * 4)

            if index >= data.length
                break

            for i in [0...4]
                out.push data[index + i]

                if data[index + i] != 0 and not data[index + i]
                    debugger

    return out

componentToHex = (c) ->
    hex = c.toString(16)

    if hex.length == 1
        hex = '0' + hex

    hex

rgbToHex = (r, g, b) ->
    r = Math.floor(r)
    g = Math.floor(g)
    b = Math.floor(b)

    componentToHex(r) + componentToHex(g) + componentToHex(b)


hexToRgb = (hex) ->
    if hex.length == 3
        r = hex[0] + hex[0]
        g = hex[1] + hex[1]
        b = hex[2] + hex[2]
    else
        r = hex[0] + hex[1]
        g = hex[2] + hex[3]
        b = hex[4] + hex[5]

    r = parseInt(r, 16)
    g = parseInt(g, 16)
    b = parseInt(b, 16)

    [r, g, b]


vectorError = (a, b) ->
    error = 0

    for i in [0...a.length]
        d = a[i] - b[i]

        error += Math.abs d

    error

hexDiff = (a, b) ->
    vectorError hexToRgb(a), hexToRgb(b)
    
averageColor = (image) ->
    if image.avg
        return image.avg

    data = image.imageData

    count = 0
    r = 0
    g = 0
    b = 0        

    for i in [0...data.length] by 4
        r += data[i]
        g += data[i + 1]
        b += data[i + 2]
    
        count++

    if (rgbToHex r / count, g / count, b / count).length > 6
        debugger

    image.avg = rgbToHex r / count, g / count, b / count

class ImageWrapper
    constructor: (@imageData, @src) ->

    getColors: ->
        if @colors? 
            return @colors

        @colors = {}
        data = @imageData

        r = g = b = a = 0;

        for i in [0...data.length] by 4
            r = data[i]
            g = data[i + 1]
            b = data[i + 2]
            a = data[i + 3]

            hex = rgbToHex r, g, b
        
            if @colors[hex]?
                @colors[hex]++
            else
                @colors[hex] = 1

            if hex.length > 6
                console.error 'hex length wrong'

        @colors

    maxColor: ->
        if @max?
            return @max

        colors = @getColors()
        count = 0

        for k, c of colors
            if c > count
                count = c
                @max = k

        @max

    averageColor: ->
        if @avg?
            return @avg

        data = @imageData

        count = 0
        r = 0
        g = 0
        b = 0        

        for i in [0...data.length] by 4
            r += data[i]
            g += data[i + 1]
            b += data[i + 2]
        
            count++

        if (rgbToHex r / count, g / count, b / count).length > 6
            debugger

        @avg = rgbToHex r / count, g / count, b / count

    nearestNeighbor: (images) ->
        min = Math.min()

        color = @maxColor()

        for image in images
            diff = hexDiff(color, averageColor(image))

            if diff < min
                minImage = image
                min = diff

        if !diff
            console.error 'no diff'
 
        return minImage

getImagesFromTag = (tag, callback) ->
    tag = tag.replace('#', '')

    return $.getJSON PROXY_URL + tag, callback


root = exports ? this
root.ImageWrapper = ImageWrapper
root.getSquareDataFromImageData = getSquareDataFromImageData
root.getImagesFromTag = getImagesFromTag