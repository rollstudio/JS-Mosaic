lastRequest = null

setModalSizes = ->
    $modal = $ '#response'

    maxWidth = $(window).width() * 0.7
    maxHeight = $(window).height() * 0.7

    ratio = 0
    width = canvas.width
    height = canvas.height

    if width > maxWidth
        ratio = maxWidth / width

        $modal.css {
            width: Math.floor(maxWidth),
            height: Math.floor(height * ratio)
        }

        height = height * ratio
        width = width * ratio

    if height > maxHeight
        ratio = maxHeight / height

        $modal.css {
            width: Math.floor(width * ratio),
            height: Math.floor(maxHeight)
        }

        width = width * ratio


    $modal.css 'marginLeft', -width / 2


handleFile = (e) ->
    e.stopPropagation()
    e.preventDefault()

    dropZone.classList.remove 'dragover'

    file = e.dataTransfer.files[0]

    if not file.type.match('image.*')
        oldText = dropZone.innerText

        dropZone.innerText = 'File is not an image'

        window.setTimeout ->
            dropZone.innerText = oldText
        , 1000

        return

    img = new Image

    img.src = URL.createObjectURL file
    img.onload = ->
        canvas.width = img.width
        canvas.height = img.height

        $('#response').modal()

        $('#response').off('hide').on('hide', ->
            button = document.querySelector '#response button'

            button.disabled = true
            button.innerText = 'Generating...'

            document.getElementById('restart').classList.add('show')
        )

        setModalSizes()
        
        ctx.drawImage img, 0, 0

        doMosaic(lastRequest)


handleDragOver = (e) ->
    e.stopPropagation()
    e.preventDefault()
    e.dataTransfer.dropEffect = 'copy'

    dropZone.classList.add 'dragover'

goToStep1 = (e) ->
    e.stopPropagation()
    e.preventDefault()

    value = input.value = ''

    resetImages()

    document.getElementById('restart').classList.remove 'show'
    form.classList.remove 'step2'
    form.style.marginLeft = ''

goToStep2 = (e) ->
    e.stopPropagation()
    e.preventDefault()

    value = input.value.replace /^\s+|\s+$/g, ""

    if value != ''
        form.classList.add 'step2'

        $form = $ form
        w = $('#steps').width()

        $form.css {
            marginLeft: w - $form.width() - 120 - 40
        }

        lastRequest = getImagesFromTag value, (result) ->
            if result.images && result.images.length
                processImages result.images

            else
                console.error result


saveImage = (e) ->
    e.stopPropagation()
    e.preventDefault()

    canvas = document.getElementById 'square'

    canvas.toBlob (blob) ->
        saveAs blob, 'mosaic.png'

dropZone = document.getElementById 'drop'
canvas = document.getElementById 'source'
ctx = canvas.getContext '2d'

dropZone.addEventListener 'dragover', handleDragOver, false
dropZone.addEventListener 'drop', handleFile, false

form = document.querySelector '#steps .form'
next = document.querySelector '#hashtag button'
input = document.querySelector '#hashtag input'
next.addEventListener 'click', goToStep2, false

saveButton = document.querySelector '#response button'
saveButton.addEventListener 'click', saveImage, false

restart = document.querySelector '#restart a'
restart.addEventListener 'click', goToStep1, false


this.lastRequest = lastRequest