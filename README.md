# Decentralized Prediction Market V3

This repository provides an expert-level implementation of a Prediction Market. It allows users to trade on the outcome of future events using a peer-to-pool model. The protocol ensures that every "Outcome Token" is fully collateralized by a stable asset.

### Core Architecture
* **Conditional Tokens:** Uses a simplified version of the Gnosis Conditional Token standard to split collateral into mutually exclusive outcome tokens (e.g., YES/NO).
* **Automated Market Maker (AMM):** A specialized Constant Product Market Maker (CPMM) that provides instant liquidity for event participants.
* **Oracle Resolution:** Integrates with decentralized oracles (Chainlink/Umai) to trustlessly settle markets based on real-world data.
* **Escrow Engine:** Securely locks collateral until the event is resolved and winners claim their payouts.

### Market Lifecycle
1. **Market Creation:** Define the question, categories, and resolution date.
2. **Trading Phase:** Users swap collateral for outcome tokens.
3. **Resolution:** The Oracle reports the final result.
4. **Redemption:** Holders of the winning outcome token redeem them 1:1 for the underlying collateral.
