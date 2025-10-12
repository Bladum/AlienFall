import os

import yaml

from battle.battle import LandArmy, NavalArmy
from manager import manager_province, manager_cot
from src.db import TDB

db = TDB()


class Scenario:

    def __init__(self, kwargs = {}):
        self.name = kwargs.get('name')

        # start / end date
        self.start_date = kwargs.get('start_date')
        self.end_date = kwargs.get('end_date')

        # list of available countries
        self.countries_available = kwargs.get('countries')

        # details per country
        self.countries_details : dict = {}
        self.leaders_details : dict = {}
        self.rulers_details : dict = {}
        self.events_details : dict = {}

        # global discoveries already done
        self.discoveries = kwargs.get('discoveries')

        # existing wars and alliance
        self.wars = kwargs.get('wars')
        self.alliances = kwargs.get('alliances')

        # defined center of trades
        self.cots = kwargs.get('cots')

        manager_cot.create_center_of_trades(self.cots)

        # all events already done
        self.events_done = kwargs.get('events')

        # modification of existing provinces
        self.provinces = kwargs.get('provinces')

    def process_additional_file(self, content):
        if content:
            if 'countries' in content:
                self.process_countries(content['countries'])
            if 'leaders' in content:
                self.process_leaders(content['leaders'])
            if 'rulers' in content:
                self.process_rulers(content['rulers'])
            if 'events' in content:
                self.process_events(content['events'])
            if 'cots' in content:
                self.process_cots( content['cots'])

    def process_cots(self, cots):
        manager_cot.create_center_of_trades(cots)

    def process_countries(self, countries):
        for key, val in countries.items():
            self.countries_details[key] = val

    def process_leaders(self, leaders):
        for key, val in leaders.items():
            self.leaders_details[key] = val

    def process_rulers(self, rulers):
        for key, val in rulers.items():
            self.rulers_details[key] = val

    def process_events(self, events):
        for key, val in events.items():
            self.events_details[key] = val

    def load_content(self):

        for country_tag, val in self.countries_details.items():

            country = db.countries.get(country_tag)

            # owned provinces
            owned_provinces = val.get('ownedprovinces', [])
            for prov_id in owned_provinces:
                manager_province.change_province_owner(prov_id, country_tag)

            # occupied provinces
            controlled_provinces = val.get('controlledprovinces', [])
            for prov_id in controlled_provinces:
                manager_province.change_province_occupant(prov_id, country_tag)

            # national provinces
            national__provinces = val.get('nationalprovinces', [])
            for prov_id in national__provinces:
                country.add_national_province( prov_id)

            # claimed provinces
            claimed_provinces = val.get('claimedprovinces', [])
            for prov_id in claimed_provinces:
                country.add_claim_province( prov_id)

            landunits = val.get('landunits', [])
            for army in landunits:
                army['owner'] = country_tag
                a = LandArmy( army )
                prov = db.provinces.get( a.province_id)
                if prov:
                    prov.armies.append(a)
                    country.armies.append(a)

            navalunits = val.get('navalunits', [])
            for navy in navalunits:
                navy['owner'] = country_tag
                a = NavalArmy(navy)
                prov = db.provinces.get( a.province_id)
                if prov:
                    prov.navies.append(a)
                    country.navies.append(a)

            religion = val.get('religion')
            if religion:
                country.change_religion(religion)

            cultures = val.get("cultures")
            if cultures:
                country.add_culture( cultures )

            # load cities
            cities = val.get('cities', {})
            for prov_id, city in cities.items():
                prov = db.provinces.get(prov_id)
                if prov:

                    # load population
                    prov.manpower_max = city.get('population', 0)

                    # set capital
                    if city.get('capital', False):
                        country.change_country_capital_province(prov)

            # load center of trades

            # known provinces & regions
            known_provs = val.get("knownprovinces")
            knwon_regions = val.get("knownregions")
            manager_province.explore_province_by_geography(country_tag,
                                                           names=knwon_regions,
                                                           prov_ids=known_provs)


class ScenarioLoader:

    def __init__(self, base_path):
        self.base_path = base_path
        self.scenarios : dict[str, Scenario] = {}

    def load_scenarios(self):
        print("Loading all scenarios")
        with open( str(self.base_path) , 'r') as f:
            content = yaml.safe_load(f)
            if 'scenarios' in content:
                for scenario_name, scenario_data in content['scenarios'].items():
                    scenario = Scenario( scenario_data )
                    self.scenarios[ str(scenario_name) ] = scenario

    def select_scenario(self, scenario_name):
        print("Loading scenario", scenario_name)
        scenario = self.scenarios.get(scenario_name)

        if scenario:
            dir_name = os.path.dirname(self.base_path)
            base_dir = os.path.join(dir_name, scenario_name)
            for root, _, files in os.walk( str(base_dir)):
                for file in files:
                    if file.endswith('.yml'):
                        file_path = os.path.join(root, file)
                        with open(file_path, 'r') as f:
                            content = yaml.safe_load(f)
                            scenario.process_additional_file(content)
                            pathka = str(file_path).replace( str(dir_name), "")

        return scenario
