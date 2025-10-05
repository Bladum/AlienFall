# Debt

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Minimum Payment and Overdraft Systems](#minimum-payment-and-overdraft-systems)
  - [Repayment and Recovery Frameworks](#repayment-and-recovery-frameworks)
  - [Short-Term Liquidity Instruments](#short-term-liquidity-instruments)
  - [Lender and Underwriting Architecture](#lender-and-underwriting-architecture)
  - [Interest, Fees, and Penalty Structures](#interest,-fees,-and-penalty-structures)
  - [Bankruptcy and Resolution Frameworks](#bankruptcy-and-resolution-frameworks)
  - [Operational Rules and Integration](#operational-rules-and-integration)
- [Examples](#examples)
  - [Minimum Payment Scenarios](#minimum-payment-scenarios)
  - [Repayment and Recovery Cases](#repayment-and-recovery-cases)
  - [Short-Term Liquidity Examples](#short-term-liquidity-examples)
  - [Lender and Underwriting Scenarios](#lender-and-underwriting-scenarios)
  - [Interest and Fee Structures](#interest-and-fee-structures)
  - [Bankruptcy Resolution Examples](#bankruptcy-resolution-examples)
  - [Operational Integration Cases](#operational-integration-cases)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Debt Management System establishes comprehensive financial risk frameworks for Alien Fall's economic gameplay, implementing loan mechanics, repayment structures, and recovery options while maintaining deterministic outcomes and strategic consequences. The system creates meaningful financial decision-making through credit rating systems, collateral requirements, and bankruptcy mechanics while providing players structured paths to manage cash shortfalls without immediate game termination. The framework balances economic pressure with recovery opportunities, enabling strategic debt utilization and long-term financial planning.

Debt provides structured financial levers for players to manage cash shortfalls without forcing immediate game over, creating strategic choices between punitive credit with long tails, emergency liquidity, or operational shrinkage.

## Mechanics

### Minimum Payment and Overdraft Systems

Daily financial monitoring prevents uncontrolled borrowing:
- Payment Enforcement: Daily negative balance monitoring with MinimumPayment = max(floor(abs(Balance) × min_payment_pct), fixed_minimum)
- Overdraft Conversion: Automatic loan creation from sustained negative balances with Principal = abs(balance)
- Penalty Structures: Late payment fees, credit rating deterioration, and interest rate increases
- Threshold Management: Minimum payment percentage and fixed minimum requirements
- Balance Monitoring: Continuous financial position assessment and alert systems
- Conversion Triggers: Automatic loan generation criteria and timing mechanisms

### Repayment and Recovery Frameworks

Structured repayment with flexible recovery options:
- Amortization Schedules: Fixed payment structures using Principal, interest_rate_daily, and term_days
- Early Repayment Options: Prepayment penalties and fee structures for early payoff
- Automatic Recovery Actions: Asset liquidation, project suspension, and emergency contract activation
- Deferment Mechanisms: Payment postponement and restructuring options with approval probabilities
- Negotiation Systems: Terms modification and approval probability frameworks
- Strategic Recovery: Long-term financial rehabilitation and stability restoration

### Short-Term Liquidity Instruments

Flexible borrowing options for immediate cash needs:
- Revolving Credit Lines: Flexible borrowing limits with daily interest accumulation and repayment flexibility
- Emergency Advances: High-interest immediate funding with reputation consequences and explicit terms
- Supplier Credit: Trade credit extensions and invoice financing based on relationship levels
- Bridge Financing: Temporary funding solutions for cash flow gaps and construction projects
- Contingency Funding: Crisis response financial instruments and emergency availability
- Liquidity Management: Short-term cash position stabilization and optimization

### Lender and Underwriting Architecture

Diverse lending sources with risk-based approval:
- Lender Categorization: Commercial banks, supplier credit lines, private investors, and black market financiers
- Approval Criteria: Credit rating, reputation, and relationship requirement systems
- Underwriting Rules: Risk assessment and loan approval probability frameworks
- Collateral Systems: Asset-based security and lien management structures
- Covenant Enforcement: Loan condition monitoring and operational restriction implementation
- Exposure Limits: Maximum borrowing capacity and diversification requirements

### Interest, Fees, and Penalty Structures

Comprehensive cost structures with transparent pricing:
- Interest Calculation: Daily and periodic rate application with compounding options
- Fee Assessment: Origination, servicing, transaction, and penalty cost frameworks
- Penalty Systems: Late payment, default, and covenant violation consequences
- Rate Determination: Risk-based pricing and credit rating influence on terms
- Cost Transparency: Fee disclosure and total borrowing cost calculation
- Economic Incentives: Penalty avoidance and timely payment reward systems

### Bankruptcy and Resolution Frameworks

Structured insolvency handling with recovery options:
- Default Procedures: Loan default handling and asset seizure mechanisms
- Bankruptcy Processes: Formal insolvency resolution with multiple restructuring options
- Asset Liquidation: Collateral seizure and forced sale procedures
- Recovery Planning: Post-bankruptcy rehabilitation and credit restoration
- Consequence Integration: Reputation damage and operational restriction systems
- Strategic Continuity: Campaign continuation options and difficulty adjustment

### Operational Rules and Integration

Comprehensive system integration and modding support:
- Financial State Tracking: Comprehensive debt portfolio and obligation monitoring
- UI Integration: Debt management interface and visualization systems
- Event Integration: Campaign event influence on financial conditions
- Modding Support: Configurable debt mechanics and custom lender creation
- Balance Tuning: Difficulty adjustment through debt parameter modification
- Performance Monitoring: Debt management efficiency and strategic effectiveness tracking

## Examples

### Minimum Payment Scenarios
- Standard Overdraft: Balance -$100K, Minimum payment $5K (5%), Late fee $1K if missed, Credit penalty -5 points
- Severe Overdraft: Balance -$500K, Minimum payment $25K (5%), Conversion to loan triggered, Emergency measures activated
- Critical Situation: Balance -$1M, Minimum payment $50K (5%), Multiple penalties applied, Bankruptcy risk high
- Recovery Phase: Balance -$50K, Minimum payment $2.5K, Consistent payments made, Credit rating stabilizing
- Stabilization: Balance -$10K, Minimum payment $1K, Controlled reduction, Normal operations resumed

### Repayment and Recovery Cases
- Standard Amortization: Principal $200K, Rate 8%, Term 24 months, Monthly payment $9,200, Total cost $220,800
- Early Repayment: Principal $150K paid in 12 months, Prepayment fee $3K, Interest saved $5K, Net benefit $2K
- Automatic Recovery: Asset sales triggered ($50K generated), Projects suspended (savings $20K/month), Emergency contracts activated
- Deferment Request: Payment postponed 30 days, Approval rate 70%, Extension fee $2K, Interest accrual continued
- Restructuring: Terms modified (rate reduced to 6%, term extended to 36 months), Negotiation success 60%, Monthly payment reduced

### Short-Term Liquidity Examples
- Revolving Credit: Limit $500K available, Current draw $200K, Daily interest 0.05%, Monthly cost $3K, Repayment flexibility
- Emergency Advance: Immediate funding $100K, Interest rate 15%, Term 6 months, Reputation penalty -10 karma, Total cost $107.5K
- Supplier Credit: Invoice financing $250K, Interest rate 5%, Term 30 days, Relationship bonus applied, Cost $3K
- Bridge Loan: Temporary funding $1M, Rate 10%, Term 90 days, Construction project enabled, Total interest $25K
- Contingency Funding: Crisis response $300K, Rate 12%, Term 60 days, Base defense maintained, Emergency operations funded

### Lender and Underwriting Scenarios
- Commercial Bank: Credit rating requirement 60+, Approval rate 80%, Rate 7%, Term up to 36 months, Collateral required
- Supplier Credit: Relationship level 70+, Approval rate 90%, Rate 4%, Term 30 days, Purchase history bonus
- Private Investor: Credit rating 50+, Approval rate 60%, Rate 10%, Term flexible, Personal guarantee required
- Black Market: No credit requirement, Approval rate 100%, Rate 20%, Term 12 months, Reputation penalty included
- Government Loan: Political favor required, Approval rate 50%, Rate 3%, Term 60 months, Diplomatic benefits

### Interest and Fee Structures
- Standard Loan: Principal $100K, Daily rate 0.02%, Monthly interest $600, Origination fee $2K, Servicing fee $500/year
- High-Risk Loan: Principal $50K, Daily rate 0.05%, Monthly interest $750, Origination fee $1K, Penalty fees $2K
- Late Payment: Minimum payment missed, Late fee $500, Credit penalty -10 points, Interest rate increase 2%
- Prepayment: Early repayment approved, Prepayment fee 2% of remaining balance, Interest savings calculated
- Default Penalty: Payment defaulted, Penalty fee $5K, Interest rate increase 5%, Collection actions initiated

### Bankruptcy Resolution Examples
- Asset Liquidation: Debt $500K, Assets seized $300K value, Deficiency $200K, Credit rating reset to 0
- Reorganization: Debt restructured $750K to $500K, Terms extended 5 years, Operations continued, Recovery plan implemented
- Formal Bankruptcy: Campaign paused, Assets auctioned, New campaign started, Reputation damage permanent
- Recovery Process: Post-bankruptcy period 2 years, Credit rebuilding, Limited borrowing capacity, Gradual restoration
- Strategic Continuity: Partial asset retention, Reduced operations, Focused recovery, Long-term rebuilding plan

### Operational Integration Cases
- Portfolio Management: Total debt $2M across 5 loans, Payment schedule coordinated, Interest optimization achieved
- UI Visualization: Debt dashboard active, Payment calendar displayed, Alert system monitoring, Planning tools available
- Event Influence: Economic crisis occurs, Interest rates increase 2%, Emergency borrowing required, Strategic adjustment
- Modding Capability: Custom lender created, Unique terms defined, Special conditions applied, Community content integrated
- Balance Adjustment: Difficulty increased, Interest rates raised 3%, Borrowing limits reduced, Strategic challenge enhanced
- Performance Tracking: Debt management efficiency 85%, Payment consistency 95%, Credit rating improvement +15 points

## Related Wiki Pages

- [Finance.md](Finance.md) - Financial systems and debt management
- [Income sources.md](Income%20sources.md) - Debt repayment and liquidity
- [Funding.md](Funding.md) - Government loans and credit
- [Suppliers.md](../economy/Suppliers.md) - Supplier credit and financing
- [Monthly reports.md](Monthly%20reports.md) - Debt tracking and analytics
- [Economy.md](../economy/Economy.md) - Economic impact of debt
- [Bankruptcy.md](../finance/Bankruptcy.md) - Bankruptcy resolution systems
- [Credit rating.md](../finance/Credit%20rating.md) - Borrowing capacity and terms

## References to Existing Games and Mechanics

- **Civilization Series**: Diplomatic debt and tribute systems
- **Crusader Kings Series**: Feudal loans and vassal obligations
- **Europa Universalis Series**: Bank loans and interest mechanics
- **Victoria Series**: Industrial loans and economic debt
- **Hearts of Iron Series**: War loans and national debt
- **Stellaris**: Empire debt and economic management
- **XCOM Series**: Emergency funding and resource shortages
- **Total War Series**: Mercenary contracts and campaign debt
- **Fire Emblem Series**: Mercenary payments and army funding
- **Final Fantasy Series**: Guild debts and organizational financing

