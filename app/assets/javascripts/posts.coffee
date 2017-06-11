$(document).on 'turbolinks:load', ->

  $grid = $('.grid')

  $grid.imagesLoaded ->
    $grid.masonry
      percentPosition: true
      itemSelector: '.grid-item'
      columnWidth: '.grid-sizer'
      gutter: '.gutter-sizer'
    return

  $grid.infinitescroll {
    navSelector: '.pagination'
    nextSelector: 'a.next_page'
    itemSelector: '.grid-item'
  }, (newElements) ->
    # hide new items while they are loading
    $newElems = $(newElements).css(opacity: 0)
    # ensure that images load before adding to masonry layout
    $newElems.imagesLoaded ->
      # show elems now they're ready
      $newElems.animate opacity: 1
      $grid.masonry 'appended', $newElems, true
      return
    return
  return
