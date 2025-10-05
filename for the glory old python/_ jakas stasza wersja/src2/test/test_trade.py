import random

from virtual import CenterOfTrade


def test_cot( new_merch_turn = 8, number_of_turns = 36):
    # Create a CenterOfTrade instance
    cot = CenterOfTrade( name = 'COT', color = 'black', power = 10)

    # Add random merchants to the CenterOfTrade
    cot.add_random_merchants(new_merch_turn)

    # Display initial merchants
    print("Initial Merchants:")
    for merchant in cot.merchants:
        print(f"  Owner: {merchant.owner}, Lifetime: {merchant.lifetime}, Effectiveness: {merchant.effectiveness}")

    # Repeat the process 20 times with a 1-second delay
    for turn in range(1, number_of_turns):
        print(f"\n{'=' * 10} Turn {turn} {'=' * 10}")

        new_merchants = random.randrange(1, 5)

        # Add random merchants to the CenterOfTrade
        cot.add_random_merchants(new_merchants)

        # Cycle merchants to simulate the passage of time
        removed_merchants = cot.cycle_merchants()

        # Display merchants after cycling
        print("\nMerchants after cycling:")
        for merchant in cot.merchants:
            print(f"  Owner: {merchant.owner}, Lifetime: {merchant.lifetime}, Effectiveness: {merchant.effectiveness}")

        # Calculate and display total income
        owner_income = dict(sorted(cot.calculate_total_income().items(), key=lambda item: item[1], reverse=True))

        print("\nOwner Income:")
        for owner, income in owner_income.items():
            num_merchants = sum(1 for merchant in cot.merchants if merchant.owner == owner)
            print(f"  Owner: {owner}, Income: {income}, Number of Merchants: {num_merchants}")

        # Display summary
        total_merchants = len(cot.merchants)
        total_value = cot.calculate_cot_value()
        total_income = round(sum(owner_income.values()), 1)
        total_unused = round(total_value - total_income, 1)

        print("\nSummary:")
        print(f"  Total Merchants: {total_merchants}")
        print(f"  Total Value of CoT: {total_value}")
        print(f"  Total Used Income: {total_income}")
        print(f"  Total Unused: {total_unused}")
        print(f"  New Merchants Added This Turn: {new_merchants}")
        print(f"  Merchants Removed This Turn: {removed_merchants}")


test_cot(8,36)