import pathengine
from cot import CenterOfTrade
from items.item_road import RoadItem
from src.db import TDB

db = TDB()


def create_center_of_trades(args):

    for key, val in args.items():
        cot = CenterOfTrade( val )
        db.center_of_trades[key] = cot


def calculate_range_of_cots():
    print("Processing COT Manager")

    # update COT provinces
    for _, cot in db.center_of_trades.items():
        cot.location_province = db.provinces.get(cot.location_province_id)

    # init variables

    province_costs = {}
    roads_cost = {}

    print("  Preparing provs")

    # precalculate for provs
    for prov_id, prov in db.provinces.items():
        c = pathengine.province_cost_merchant(prov, None)
        province_costs[prov_id] = c

    print("  Preparing roads")

    # precalculate for roads
    for road_id, road in db.roads_items.items():
        road: RoadItem
        from_id = road.province_from.province_id
        to_id = road.province_to.province_id
        c = pathengine.road_cost_merchant(from_id, to_id)
        roads_cost[ (from_id, to_id )] = c
        roads_cost[ (to_id, from_id )] = c

    province_cot_values = {province_id: {} for province_id in db.provinces}

    # find all provinces in range
    def calculate_province_range(cot, province, remaining_power, visited):

        if (remaining_power <= 0 or
                (province.province_id in visited
                and remaining_power <= province_cot_values[province.province_id].get(cot, 0))):
            return

        visited.add(province.province_id)

        if province.province_id not in province_cot_values:
            province_cot_values[province.province_id] = {}
        if cot not in province_cot_values[province.province_id] or remaining_power > \
                province_cot_values[province.province_id][cot]:
            province_cot_values[province.province_id][cot] = remaining_power

        # for each neighbour
        for neighbor_id, neighbor in province.neighbors.items():
            cost = province_costs.get(neighbor_id)
            cost *= roads_cost.get((province.province_id, neighbor_id), 999999)
            calculate_province_range(cot, neighbor, remaining_power - cost, visited)

    print("  Process COTs")

    for _, cot in db.center_of_trades.items():
        print("    COT name", cot.name)
        calculate_province_range(cot, cot.location_province, db.map_height // 3, set())

    # assign each province to its most popular COT

    for province_id, cot_values in province_cot_values.items():
        if cot_values:
            best_cot = max(cot_values, key=cot_values.get)
            db.provinces[province_id].center_of_trade = best_cot

def process_before_all():
    print("  Center of trade manager before processing")


