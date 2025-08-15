FundChain Smart Contract

 Overview
FundChain is a decentralized fundraising smart contract built on the [Stacks blockchain](https://stacks.co/) using the Clarity programming language.  
It allows anyone to create transparent fundraising campaigns, accept contributions in STX, and manage funds with built-in goal tracking and refund mechanisms.

---

 Features
-  **Campaign Creation** – Start a fundraising campaign with a goal amount and deadline.  
-  **Secure Contributions** – Contributors can send STX to support campaigns.  
-  **Goal Tracking** – Monitor total funds raised in real-time.  
-  **Automatic Refunds** – Contributors can withdraw funds if the campaign fails.  
-  **Owner Payouts** – Campaign creators can claim funds if the goal is reached before the deadline.

---

 Contract Functions

| Function | Description |
|----------|-------------|
| `create-campaign` | Creates a new campaign with goal and deadline. |
| `contribute` | Allows users to send STX to a campaign. |
| `withdraw-refund` | Refunds contributors if the goal is not met. |
| `withdraw-owner` | Transfers funds to the campaign creator if the goal is reached. |
| `get-campaign-details` | Fetches campaign metadata and status. |

---

 How It Works
1. **Create Campaign** – Specify your funding goal and deadline.  
2. **Accept Contributions** – Supporters send STX to your campaign address via the contract.  
3. **Campaign Ends** –  
   - If goal is reached : Owner withdraws funds.  
   - If goal is not reached : Contributors withdraw their STX.  

---

 Deployment
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/fundchain.git
   cd fundchain
