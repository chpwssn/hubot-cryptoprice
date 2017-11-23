module.exports = () -> tokens

tokens = {
    ZRX: {
        default: 'USD',
        ETH: (robot, msg, cb) ->
            robot.http('https://poloniex.com/public?command=returnTicker')
                .get() (err, res, body) ->
                    if err
                        return null
                    cb(parseFloat JSON.parse(body).ETH_ZRX.last)
        USD: (robot, msg, cb) ->
            robot.http('https://poloniex.com/public?command=returnTicker')
                .get() (err, res, body) ->
                    if err
                        return null
                    ETH_ZRX = parseFloat JSON.parse(body).ETH_ZRX.last
                    tokens.ETH.USD(robot, msg, (ETH_USD) ->
                        cb(ETH_ZRX * ETH_USD)
                    )
    },
    ETH: {
        base: 'USD',
        USD: (robot, msg, cb) -> 
            robot.http('https://api.gdax.com/products/eth-usd/ticker')
                .get() (err, res, body) ->
                    if err
                        return null
                    cb(parseFloat JSON.parse(body).price)
    }
    BTC: {
        base: 'USD',
        USD: (robot, msg, cb) -> 
            robot.http('https://api.gdax.com/products/btc-usd/ticker')
                .get() (err, res, body) ->
                    if err
                        return null
                    cb(parseFloat JSON.parse(body).price)
    }
    LTC: {
        base: 'USD',
        USD: (robot, msg, cb) -> 
            robot.http('https://api.gdax.com/products/ltc-usd/ticker')
                .get() (err, res, body) ->
                    if err
                        return null
                    cb(parseFloat JSON.parse(body).price)
    }
}