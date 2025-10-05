'''

PROVINCE MANAGER

Class to manage all provinces in game, part of game logic

'''
from src.db import TDB

db = TDB()

import pathengine


class ProvinceManager:
    def __init__(self):
        from items.item_province import ProvinceItem
        self.provinces : dict[int, ProvinceItem] = {}


def find_path_between_provinces( prov_from_id, prov_to_id):
    path, distance = pathengine.shortest_path(prov_from_id, prov_to_id)
    print(f"Shortest path from {prov_from_id} to {prov_to_id}: {path} with distance {distance}")

def find_provs_in_range( prov_id, range = 10):
    # Calculate all provinces within a certain range
    provinces_in_range = pathengine.provinces_in_range(prov_id, range)
    print(f"Provinces within {prov_id} distance from {range}: {provinces_in_range}")


#
#   PROVINCE DATA
#

def process_before_all():
    print("  Province manager before processing")

#
#   SHOW / HIDE PROVINCES
#

def get_neighbors_for_province( province):

    neighbors = []
    for neighbor_id in province.neighbors_distance.keys():
        neighbor_province = db.provinces.get(neighbor_id)
        if neighbor_province:
            neighbors.append(neighbor_province)
    return neighbors

#
#   manage view and explore
#

def explore_entire_map():
    for prov in db.provinces.values():
        prov.explore_province()

def unexplore_entire_map():
    for prov in db.provinces.values():
        prov.unexplore_province()

def view_entire_map():
    for prov in db.provinces.values():
        prov.view_province()

def unview_entire_map():
    for prov in db.provinces.values():
        prov.unview_province()

#
#   MANAGE OWNER PROVINCE
#

def change_province_owner( province, tag, change_occupant = False):

    if isinstance(province, int):
        province = db.provinces.get( province)

    if province is None:
        return

    province.change_province_owner(tag, change_occupant)
    province.view_province()

    other_provs = get_neighbors_for_province(province)
    for other in other_provs:
        other.view_province()

def change_province_occupant(province, tag):

    if isinstance(province, int):
        province = db.provinces.get( province)

    if province is None:
        return

    province.change_province_occupant(tag)
    province.view_province()

#
#   CHANGE CURRENT PLAYER
#

def switch_current_country_tag( new_tag):

    db.current_country_tag = new_tag
    print("Switched country to ", db.current_country_tag)

    # hide all provinces
    for prov in db.provinces.values():
        prov.unview_province()
        prov.unexplore_province()
        prov.set_core_pixmap(False)
        prov.set_province_large_frame(None)
        prov.set_city_pixmap()

    country = db.countries.get( new_tag )
    if country:

        for prov in country.explored_provinces.values():
            prov.explore_province()

    # view only mine
    for prov in db.provinces.values():

        # i do own
        if prov.country_owner_tag == new_tag:

            prov.view_province()
            others = get_neighbors_for_province(prov)
            for o in others:
                o.explore_province()
                o.view_province()

        # i do occupy
        if prov.country_occupant_tag == new_tag:
            prov.explore_province()
            prov.view_province()

    # center on this capitol country view
    move_viewport_to_capital(new_tag)

def move_viewport_to_capital(country_tag):
    country = db.countries.get(country_tag)
    if country and country.capitol_province:
        db.game_scene.center_view_on_province(country.capitol_province.province_id)

def explore_province_by_geography( country_tag = 'POL', prov_ids = None, names = None):

    country = db.countries.get(country_tag)
    if country:
        for prov in db.provinces.values():
            prov.unexplore_province()

        country.explored_provinces.clear()

        if prov_ids:
            for id, prov in db.provinces.items():
                if id in prov_ids:
                    prov.explore_province()
                    country.explored_provinces[id] = prov

        if names:
            for id, prov in db.provinces.items():
                if ((prov.continent and prov.continent.tag in names) or
                        (prov.region and prov.region.tag in names) or
                        (prov.area and prov.area.tag in names)):
                    prov.explore_province()
                    country.explored_provinces[id] = prov

#
#   MANAGE ROADS
#

def highlight_path_between_provinces(prov_from_id, prov_to_id, hide_all_roads = False):

    # Hide all roads
    if hide_all_roads:
        for road in db.roads_items.values():
            road.hide_road()

    # Calculate the path between the two provinces
    path, distance = pathengine.shortest_path(prov_from_id, prov_to_id, None, 'normal')

    # Show only the roads in the calculated path
    for i in range(len(path) - 1):
        road = db.roads_items.get((path[i], path[i + 1]))
        if road:
            road.show_road()

#
#
#

def save_provinces_to_file():
    directory_path = str( db.path_mod / 'archive')
