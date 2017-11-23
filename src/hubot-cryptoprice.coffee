# Description
#   A script to fetch the price of crypto
#
# Commands:
#   .price <token> - fetch the price of the given token with USD quote
#   .price <baseToken> <quoteToken> - fetch the price of the given token in the given quote
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Chip Wasson <chip@wasson.io>

tokens = require('./cryptoprice-data')();

module.exports = (robot) ->
  defaultQuote = 'USD'
  robot.hear /^\.price (\S+)\s*(\S+)?/, (res) ->
    token = res.match[1].toUpperCase()
    quote = if res.match[2] != undefined then res.match[2].toUpperCase() else defaultQuote
    response = []
    if tokens.hasOwnProperty(token)
      tokenObj = tokens[token]
      # Check to see if the token has the quote token
      if tokenObj.hasOwnProperty(quote)
        tokens[token][quote](robot, res, (price) ->
          response.push("#{token} last traded for #{price} #{quote}")
          res.send(response.join('\n'))
        )
      else
        # response.push("I don't know how to get #{token} in terms of #{quote} so I'll have to use #{defaultQuote}")
        # quote = defaultQuote
        tokens.wildcard(robot, token, quote)
    else
      found = false
      res.send "Sorry I don't know how to fetch #{token}/#{quote}, I'll see if I can find somewhere it is traded..."
      tokens.wildcard(robot, res, token, quote)
    
