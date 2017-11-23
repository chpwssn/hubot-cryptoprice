module.exports = () -> tokens

tokens = {
    ZRX: {
        default: 'USD',
        ETH: (robot, msg, cb) ->
            exchanges.POLO.fetchLastTokenPrice(robot, 'ZRX', 'ETH', (result) ->
                cb(result)
            )
        USD: (robot, msg, cb) ->
            exchanges.POLO.fetchLastTokenPrice(robot, 'ZRX', 'ETH', (zrxEth) ->
                exchanges.GDAX.fetchLastTokenPrice(robot, 'ETH', 'USD', (ethUsd) ->
                    cb(zrxEth * ethUsd)
                )
            )
    },
    ETH: {
        base: 'USD',
        USD: (robot, msg, cb) -> 
            exchanges.GDAX.fetchLastTokenPrice(robot, 'ETH', 'USD', cb)
    }
    BTC: {
        base: 'USD',
        USD: (robot, msg, cb) -> 
            exchanges.GDAX.fetchLastTokenPrice(robot, 'BTC', 'USD', cb)

    }
    # LTC: {
    #     base: 'USD',
    #     USD: (robot, msg, cb) -> 
    #         exchanges.GDAX.fetchLastTokenPrice(robot, 'LTC', 'USD', cb)
    # },
    wildcard: (robot, res, baseToken, quoteToken) ->
        found = false
        Object.keys(exchanges).forEach (x, i) ->
            exchanges[x].supportsPair(robot, baseToken, quoteToken, (supported) ->
                if found then return
                if supported
                    found = supported
                    exchanges[x].fetchLastTokenPrice(robot, baseToken, quoteToken, (response) ->
                        res.send("I've found that #{baseToken} was last traded for #{response} #{quoteToken} on #{x}")
                    )
            )
}

exchanges = {
    POLO: {
        fetchToken: (robot, baseToken, quoteToken, cb) ->
            baseToken = baseToken.toUpperCase()
            quoteToken = quoteToken.toUpperCase()
            robot.http('https://poloniex.com/public?command=returnTicker')
                .get() (err, res, body) ->
                    if err
                        cb(null)
                    cb(JSON.parse(body)["#{quoteToken}_#{baseToken}"])
        fetchLastTokenPrice: (robot, baseToken, quoteToken, cb) ->
            baseToken = baseToken.toLowerCase()
            quoteToken = quoteToken.toLowerCase()
            exchanges.POLO.fetchToken(robot, baseToken, quoteToken, (result) ->
                cb(parseFloat result.last)
            )
        supportsPair: (robot, baseToken, quoteToken, cb) ->
            baseToken = baseToken.toUpperCase()
            quoteToken = quoteToken.toUpperCase()
            robot.http('https://poloniex.com/public?command=returnTicker')
                .get() (err, res, body) ->
                    cb(JSON.parse(body).hasOwnProperty("#{quoteToken}_#{baseToken}"))
    },
    GDAX: {
        fetchToken: (robot, baseToken, quoteToken, cb) ->
            baseToken = baseToken.toLowerCase()
            quoteToken = quoteToken.toLowerCase()
            robot.http("https://api.gdax.com/products/#{baseToken}-#{quoteToken}/ticker")
                .get() (err, res, body) ->
                    if err
                        cb(null)
                    cb(JSON.parse(body))
        fetchLastTokenPrice: (robot, baseToken, quoteToken, cb) ->
            baseToken = baseToken.toLowerCase()
            quoteToken = quoteToken.toLowerCase()
            exchanges.GDAX.fetchToken(robot, baseToken, quoteToken, (result) ->
                cb(parseFloat result.price)
            )
        supportsPair: (robot, baseToken, quoteToken, cb) ->
            baseToken = baseToken.toUpperCase()
            quoteToken = quoteToken.toUpperCase()
            robot.http('https://api.gdax.com/products')
                .get() (err, res, body) ->
                    data = JSON.parse(body)
                    found = false
                    data.forEach (x, i) ->
                        if x.id == "#{baseToken}-#{quoteToken}"
                            cb(true)
                            found = true
                    if !found then cb(false)
    }
}