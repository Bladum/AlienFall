"""
funding.py

Defines the TFunding class, which manages XCOM's funding based on country scores and generates monthly reports. Operates from the country perspective and updates funding and relations.

Classes:
    TFunding: Funding and monthly report manager for XCOM.

Last standardized: 2025-06-30
"""

from typing import TYPE_CHECKING, List, Dict
if TYPE_CHECKING:
    from globe.country import TCountry

class TFunding:
    """
    TFunding manages XCOM's funding based on the score in each country and generates monthly reports.
    This class operates from the country perspective.

    Attributes:
        countries (List[TCountry]): List of TCountry instances.
        month_scores (Dict[str|int, int]): Mapping of country IDs to their monthly scores.
    """
    def __init__(self, countries: List['TCountry']) -> None:
        """
        Initialize a TFunding instance.

        Args:
            countries (List[TCountry]): List of TCountry instances.
        """
        self.countries: List['TCountry'] = countries
        self.month_scores: Dict[str|int, int] = {country.pid: 0 for country in countries}

    def add_tile_score(self, country_id: str | int, score: int) -> None:
        """
        Add a score to a country's monthly total.

        Args:
            country_id (str|int): The ID of the country.
            score (int): The score to add.
        """
        if country_id in self.month_scores:
            self.month_scores[country_id] += score

    def monthly_report(self) -> Dict[str, Dict[str, int | bool]]:
        """
        Update all countries' funding and relation based on their monthly score.

        Returns:
            Dict[str, Dict[str, int | bool]]: Summary report with relation, funding, active status, and score for each country.
        """
        report: Dict[str, Dict[str, int | bool]] = {}
        for country in self.countries:
            score = self.month_scores.get(country.pid, 0)
            country.monthly_update(score)
            report[country.name] = {
                'relation': country.relation,
                'funding': country.funding,
                'active': country.active,
                'score': score
            }
            self.month_scores[country.pid] = 0
        return report
