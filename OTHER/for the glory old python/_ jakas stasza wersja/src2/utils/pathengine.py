import heapq

from core.game_state import GameState

gs = GameState()



def shortest_path(start_id, end_id, owner_tag=None, method='merchant', distances = {}, previous_nodes = {}):
    """
    Find the shortest path between two provinces using A* or Dijkstra's algorithm.

    :param start_id: The ID of the starting province.
    :param end_id: The ID of the ending province.
    :param owner_tag: The owner of the provinces.
    :param method: The method to calculate the move cost
    :return: A tuple containing the path and the total distance.
    """

    # Validate inputs
    if start_id not in gs.provinces:
        raise ValueError(f"Start ID {start_id} not found in provinces")
    if end_id not in gs.provinces:
        raise ValueError(f"End ID {end_id} not found in provinces")

    # this is calculated only for explored provinces, otherwise you don't know path
    distances = distances.copy()
    distances[start_id] = 0
    priority_queue = [(0, start_id)]
    previous_nodes = previous_nodes.copy()

    while priority_queue:
        current_distance, current_id = heapq.heappop(priority_queue)

        if current_id == end_id:
            break

        if current_distance > distances[current_id]:
            continue

        current_province = gs.provinces[current_id]
        for neighbor_id, distance in current_province.neighbors_distance.items():
            neighbor_prov = gs.provinces.get(neighbor_id)

            if method == 'merchant':
                move_cost = _merchant_cost(current_id, neighbor_prov, owner_tag)
            else:
                move_cost = 1

            new_distance = current_distance + move_cost

            if new_distance < distances[neighbor_id]:
                distances[neighbor_id] = new_distance
                previous_nodes[neighbor_id] = current_id
                heapq.heappush(priority_queue, (new_distance, neighbor_id))

    try:
        path = []
        current_id = end_id
        while current_id is not None:
            path.append(current_id)
            current_id = previous_nodes[current_id]
        path.reverse()
    except Exception as e:
        print(f"Error reconstructing path: {e}")
        return [], float('inf')

    if not path or path[0] != start_id:
        print(f"End ID {end_id} unreachable")
        return [], float('inf')

    return path, distances[end_id]

def road_cost_merchant(from_id, to_id):

    move_cost = gs.province_neighbours_distance.get((from_id, to_id), 999999)
    from items.item_road import RoadItem

    roadek: RoadItem = gs.roads_items.get((from_id, to_id))

    if roadek:
        if roadek.road_type == 'coastal':
            move_cost *= 3.0

    return move_cost

def province_cost_merchant(prov_id, owner_tag):
    if isinstance(prov_id, int):
        prov = gs.provinces.get(prov_id )
    else:
        prov = prov_id

    move_cost = 1

    if prov is None:
        return  move_cost

    if prov.terrain is None:
        return move_cost

    # terrain cost for merchant
    ter = prov.terrain.tag
    if ter == "sea":
        move_cost *= 0.5
    elif ter == 'mountain':
        move_cost *= 1.75
    elif ter == 'forest':
        move_cost *= 1.25
    elif ter == 'desert':
        move_cost *= 1.5
    elif ter == 'marsh':
        move_cost *= 2

    # moving on own terrain is cheaper
    if owner_tag:
        if prov.country_owner_tag == owner_tag:
            move_cost *= 0.75

    # moving on hard climate is more expensive
    if prov.climate:
        clim = prov.climate.tag
        if clim == 'desertic':
            move_cost *= 1.25
        if clim == 'tropical':
            move_cost *= 1.5

    # if on land then if there is road its cheaper
    if prov.is_land:
        for build in prov.buildings:
            move_cost *= build.modifiers.mod_merchant_cost

    # TODO province country tariffs level, low, med, high is 0.5 / 1.0 / 2.0
    # TODO if there is war in country its 2.0
    # TODO if there is battle in province its 3.0
    # TODO if there is bad weather like SNOW / STORM its 1.5 / 2.
    # TODO if countries have trade embargo / trade agreement its 4.0 or 0.5
    # TODO if countries have good / bad relations its 0.5 to 2.0 from -200 to 200

    return move_cost


def _merchant_cost(current_id, neighbor_prov, owner_tag):
    neighbor_id = neighbor_prov.province_id
    from items.item_road import RoadItem

    move_cost = gs.province_neighbours_distance.get((current_id, neighbor_id), float('inf'))

    # terrain cost for merchant
    ter = neighbor_prov.terrain.tag
    if ter == "sea":
        move_cost *= 0.5
    elif ter == 'mountain':
        move_cost *= 1.75
    elif ter == 'forest':
        move_cost *= 1.25
    elif ter == 'desert':
        move_cost *= 1.5
    elif ter == 'marsh':
        move_cost *= 2

    # changing from ship to wagon is expensive
    roadek: RoadItem = gs.roads_items.get((current_id, neighbor_id))
    if roadek:
        if roadek.road_type == 'coastal':
            move_cost *= 5

            # TODO unless there is a shipyard in province

    # moving on own terrain is cheaper
    if neighbor_prov.country_owner_tag == owner_tag:
        move_cost *= 0.75

    # moving on hard climate is more expensive
    if neighbor_prov.climate:
        clim = neighbor_prov.climate.tag
        if clim == 'desertic':
            move_cost *= 1.25
        if clim == 'tropical':
            move_cost *= 1.5

    # if on land then if there is road its cheaper
    if neighbor_prov.is_land:
        for build in neighbor_prov.buildings:
            move_cost *= build.modifiers.mod_merchant_cost

    # TODO province country tariffs level, low, med, high is 0.5 / 1.0 / 2.0
    # TODO if there is war in country its 2.0
    # TODO if there is battle in province its 3.0
    # TODO if there is bad weather like SNOW / STORM its 1.5 / 2.
    # TODO if countries have trade embargo / trade agreement its 4.0 or 0.5
    # TODO if countries have good / bad relations its 0.5 to 2.0 from -200 to 200

    return move_cost

def _army_move_cost(self, current_id, neighbor_id, army_owner_tag):

    move_cost = gs.province_neighbours_distance.get((current_id, neighbor_id), float('inf'))

    base_cost = 8
    speed_mod = 1.0

    # move mod from terrain
    terrain = gs.db_terrains.get(self.terrain_tag)
    if terrain:
        base_cost = terrain.get('army_movement', 8)

    # move mod from weather
    if self.has_snow_or_ice:
        speed_mod *= 1.5
    if self.has_storm_or_hurricane:
        speed_mod *= 2

    # move mod from province building
    mod = 1
    for build in self.buildings:
        mod *= build.modifiers.mod_army_movement
    speed_mod *= mod

    # move mod from owner technology
    owner = gs.countries.get(army_owner_tag)
    if owner:
        tech_level = owner.technology.modifiers.mod_army_movement
        speed_mod *= tech_level

        # move bonus form policies

    # moving on own terrain is faster
    if army_owner_tag == self.country_owner_tag:
        speed_mod *= 0.8
    else:
        speed_mod *= 1

    return round(base_cost * speed_mod, 0)

def provinces_in_range(self, province_id):
    # TODO complete this method
    return 1

