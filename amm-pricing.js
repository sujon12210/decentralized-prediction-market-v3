/**
 * Simple Constant Product Pricing for Prediction Markets
 * price = reserve_collateral / reserve_outcome
 */
function calculateOutcomePrice(yesReserve, noReserve) {
    const total = BigInt(yesReserve) + BigInt(noReserve);
    if (total === 0n) return 0.5;

    const yesPrice = Number(noReserve) / Number(total);
    const noPrice = Number(yesReserve) / Number(total);

    return {
        yes: yesPrice,
        no: noPrice,
        impliedProbability: yesPrice * 100
    };
}

module.exports = { calculateOutcomePrice };
