define ["jquery", "underscore", "backbone", "cs!twitter"
], ($, _, Backbone, Twitter) -> $ ->

  class Tweet extends Backbone.Model

  class Tweets extends Backbone.Collection
    model: Tweet
    comparator: (tweet) -> -tweet.id

  class TweetItem extends Backbone.View
    tagName: "li"
    template: _.template $("#tweet-item-template").html()
    retweetTemplate: _.template $("#tweet-retweet-template").html()

    initialize: =>
      @model.bind "change", @render
      @model.view = this

    render: =>
      tweet = @model.toJSON()
      if tweet.retweeted_status?
        @$el.html(@template(tweet.retweeted_status))
        @$el.append(@retweetTemplate(tweet))
      else
        @$el.html(@template(tweet))

  class TweetList extends Backbone.View
    initialize: =>
      @collection.bind "add", @addTweet
      @collection.bind "remove", @removeTweet

    addTweet: (tweet, collection, options) =>
      view = new TweetItem({ model: tweet })
      view.render()
      before = @$el.children()[options.index]
      if before
        $(before).before(view.el)
      else
        @$el.append(view.el)

    removeTweet: (tweet) =>
      tweet.view.remove()

  window.tweets = tweets = new Tweets()

  window.list = list = new TweetList
    collection: tweets
    el: $("#tweets")

  twitter = new Twitter
  twitter.on "tweet", (tweet) ->
    tweets.add(new Tweet(tweet))
  twitter.on "delete", (id) ->
    tweets.remove(tweets.get(id))


  # Sponsor slides

  findNextSponsor = (current) ->
    next = current.next(".sponsor")
    if next.length then next else $("#sponsors .sponsor").first()
  cycleSponsors = ->
    findNextSponsor($("#sponsors .current-slide").removeClass("current-slide")).addClass("current-slide")

  $("#sponsors .sponsor").first().addClass("current-slide")
  setInterval cycleSponsors, 6000


  # Regular slides

  cycleSlide = (dir) ->
    current = $("#slides .current-slide")
    next = current[dir](".slide")
    if next.length
      current.removeClass("current-slide")
      next.addClass("current-slide")
  nextSlide = -> cycleSlide("next")
  prevSlide = -> cycleSlide("prev")
  $("#slides .slide").first().addClass("current-slide")

  $(window).on "keydown", (e) ->
    console.log e
    if $("#slides").hasClass("active")
      if e.keyCode == 34 # PgUp
        nextSlide()
      else if e.keyCode == 33 # PgDn
        prevSlide()
      else if e.keyCode == 32 # Space
        $("#slides").removeClass("active")
        $("#sponsors").addClass("active")
        $("#tweets").addClass("active")
    else if $("#sponsors").hasClass("active")
      if e.keyCode == 32 # Space
        $("#sponsors").removeClass("active")
        $("#tweets").removeClass("active")
        $("#slides").addClass("active")


  $("#slides").addClass("active")
