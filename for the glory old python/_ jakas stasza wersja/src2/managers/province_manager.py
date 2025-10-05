# src/managers/province_manager.py
class ProvinceManager:
    """Handles province-related operations."""

    def __init__(self, game_state):
        
        from core.game_state import GameState
        self.gs : GameState = game_state

    #
    #   MANAGE OWNER PROVINCE
    #

    def change_province_owner(self, province, tag, change_occupant=False, visual = False):

        if isinstance(province, int):
            province = self.gs.provinces.get(province)

        if province is None:
            return

        province.change_province_owner(tag, change_occupant, visual)

        if visual:
            province.view_province()

            other_provs = self.get_neighbors_for_province(province)
            for other in other_provs:
                other.view_province()

    def change_province_occupant(self, province, tag, visual = False):

        if isinstance(province, int):
            province = self.gs.provinces.get(province)

        if province is None:
            return

        province.change_province_occupant(tag)
        if visual:
            province.view_province()

    #
    #   ROADS BETWEEN PROVS
    #

    def find_path_between_provinces( self, prov_from_id, prov_to_id):
        from utils import pathengine
        path, distance = pathengine.shortest_path(prov_from_id, prov_to_id)
        print(f"Shortest path from {prov_from_id} to {prov_to_id}: {path} with distance {distance}")

    def find_provs_in_range(self,  prov_id, range = 10):
        # Calculate all provinces within a certain range
        from utils import pathengine
        provinces_in_range = pathengine.provinces_in_range(prov_id, range)
        print(f"Provinces within {prov_id} distance from {range}: {provinces_in_range}")

    def highlight_path_between_provinces(self, prov_from_id, prov_to_id, hide_all_roads=False):

        # Hide all roads
        if hide_all_roads:
            for road in self.gs.roads_items.values():
                road.hide_road()

        # Calculate the path between the two provinces
        from utils import pathengine
        path, distance = pathengine.shortest_path(prov_from_id, prov_to_id, None, 'normal')

        # Show only the roads in the calculated path
        for i in range(len(path) - 1):
            road = self.gs.roads_items.get((path[i], path[i + 1]))
            if road:
                road.show_road()

    #
    #   PROVINCE DATA
    #

    def process_before_all(self):
        print("  Province manager before processing")

    #
    #   SHOW / HIDE PROVINCES
    #

    def get_neighbors_for_province( self, province):

        neighbors = []
        for neighbor_id in province.neighbors_distance.keys():
            neighbor_province = self.gs.provinces.get(neighbor_id)
            if neighbor_province:
                neighbors.append(neighbor_province)
        return neighbors

    #
    #   MANAGE VIEW AND EXPLORE
    #

    def explore_entire_map(self):
        for prov in self.gs.provinces.values():
            prov.explore_province()

    def unexplore_entire_map(self):
        for prov in self.gs.provinces.values():
            prov.unexplore_province()

    def view_entire_map(self):
        for prov in self.gs.provinces.values():
            prov.view_province()

    def unview_entire_mapp(self):
        for prov in self.gs.provinces.values():
            prov.unview_province()

    def explore_province_by_geography(self, country_tag='POL', prov_ids=None, names=None):

        country = self.gs.countries.get(country_tag)
        if country:
            for prov in self.gs.provinces.values():
                prov.unexplore_province()

            country.explored_provinces.clear()

            if prov_ids:
                for id, prov in self.gs.provinces.items():
                    if id in prov_ids:
                        prov.explore_province()
                        country.explored_provinces[id] = prov

            if names:
                for id, prov in self.gs.provinces.items():
                    if ((prov.continent and prov.continent.tag in names) or
                            (prov.region and prov.region.tag in names) or
                            (prov.area and prov.area.tag in names)):
                        prov.explore_province()
                        country.explored_provinces[id] = prov

    #
    #   CHANGE CURRENT PLAYER
    #

    def switch_current_country_tag(self, new_tag):

        self.gs.current_country_tag = new_tag
        print("Switched country to ", self.gs.current_country_tag)

        # hide all provinces
        for prov in self.gs.provinces.values():
            prov.unview_province()
            prov.unexplore_province()
            prov.province_item.set_core_pixmap(False)
            prov.province_item.set_province_large_frame(None)
            prov.province_item.set_city_pixmap()

        country = self.gs.countries.get( new_tag )
        if country:

            for prov in country.explored_provinces.values():
                prov.explore_province()

        # view only mine
        for prov in self.gs.provinces.values():

            # i do own
            if prov.country_owner_tag == new_tag:

                prov.view_province()
                others = self.get_neighbors_for_province(prov)
                for o in others:
                    o.explore_province()
                    o.view_province()

            # i do occupy
            if prov.country_occupant_tag == new_tag:
                prov.explore_province()
                prov.view_province()