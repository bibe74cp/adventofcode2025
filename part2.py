filename = "day9.txt"

with open(filename, "r") as f:
    red_tiles = [
        tuple(int(coordinate) for coordinate in line.strip().split(","))
        for line in f.readlines()
    ]


def check_point_in_shape(shape, point):
    """
    A horizontal line is drawn from the point to the left edge of the grid.
    Odd numbers of intersections if the point is in the shape.
    This function is only for points whose coordinates are not integers.
    """
    number_of_intersections = len(
        [
            vertex
            for index, vertex in enumerate(shape)
            if (vertex[0] == shape[index - 1][0] < point[0])
            and (
                (vertex[1] < point[1] < shape[index - 1][1])
                or (vertex[1] > point[1] > shape[index - 1][1])
            )
        ]
    )
    if number_of_intersections % 2 == 0:
        return False
    else:
        return True


def check_segment_no_intersection(shape, point_a, point_b):
    if point_a[1] == point_b[1]:  # Horizontal segment
        for index, vertex in enumerate(shape):
            if (
                (vertex[0] == shape[index - 1][0])
                and (
                    min(point_a[0], point_b[0])
                    < vertex[0]
                    < max(point_a[0], point_b[0])
                )
                and (
                    min(vertex[1], shape[index - 1][1])
                    < point_a[1]
                    < max(vertex[1], shape[index - 1][1])
                )
            ):
                return False
    elif point_a[0] == point_b[0]:  # Vertical segment
        for index, vertex in enumerate(shape):
            if (
                (vertex[1] == shape[index - 1][1])
                and (
                    min(point_a[1], point_b[1])
                    < vertex[1]
                    < max(point_a[1], point_b[1])
                )
                and (
                    min(vertex[0], shape[index - 1][0])
                    < point_a[0]
                    < max(vertex[0], shape[index - 1][0])
                )
            ):
                return False
    return True


def get_sign(num):
    if num > 0:
        return 1
    elif num < 0:
        return -1
    else:
        return 0


largest_area = 0
for i, red_tile_a in enumerate(red_tiles):
    for red_tile_b in red_tiles[i + 1 :]:
        x_diff = red_tile_a[0] - red_tile_b[0]
        y_diff = red_tile_a[1] - red_tile_b[1]
        if x_diff * y_diff == 0:
            continue  # Assuming a single-line rectangle cannot be the largest
        area = (abs(x_diff) + 1) * (abs(y_diff) + 1)
        if area > largest_area:
            adjusted_a0 = red_tile_a[0] - 0.5 * get_sign(x_diff)
            adjusted_a1 = red_tile_a[1] - 0.5 * get_sign(y_diff)
            adjusted_b0 = red_tile_b[0] + 0.5 * get_sign(x_diff)
            adjusted_b1 = red_tile_b[1] + 0.5 * get_sign(y_diff)
            points = [
                (adjusted_a0, adjusted_a1),
                (adjusted_a0, adjusted_b1),
                (adjusted_b0, adjusted_b1),
                (adjusted_b0, adjusted_a1),
            ]
            points_check_passed = True
            for j, point in enumerate(points):
                if (not check_point_in_shape(red_tiles, point)) or (
                    not check_segment_no_intersection(red_tiles, point, points[j - 1])
                ):
                    points_check_passed = False
                    break
            if points_check_passed:
                largest_area = area

print(largest_area)
