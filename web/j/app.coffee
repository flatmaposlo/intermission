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

  findNextSlide = (current) ->
    next = current.next(".sponsor")
    if next.length then next else $("#slides .sponsor").first()
  cycleSlides = ->
    findNextSlide($(".current-slide").removeClass("current-slide")).addClass("current-slide")

  $("#slides .sponsor").first().addClass("current-slide")

  window.nextSlide = cycleSlides

  setInterval cycleSlides, 6000
