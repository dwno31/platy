#App.push = App.cable.subscriptions.create {channel:"PushChannel",room:c_uuid},
##App.push = App.cable.subscriptions.create "PushChannel",
#  connected: ->
#    # Called when the subscription is ready for use on the server
#
#  disconnected: ->
#    # Called when the subscription has been terminated by the server
#
#  received: (data) ->
#    # Called when there's incoming data on the websocket for this channel
#    console.log("hello..?"); $("div[name=likeitem"+data["pid"]+"]").toggleClass("likebutton-item-clicked");
#
#  status: ->
#    @perform 'status'
