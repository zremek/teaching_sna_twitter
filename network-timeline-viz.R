library(xml2)
library(tidyverse)
library(igraph)
library(ggraph)

doc <- read_xml("cocomment_search427_nodes427_2026_11_06-14_27_44.gexf")
xml_ns_strip(doc)

# attribute id -> title lookup
att <- xml_find_all(doc, "//attributes[@class='node']/attribute")
att_map <- setNames(xml_attr(att, "title"), xml_attr(att, "id"))

# nodes
nodes <- xml_find_all(doc, "//nodes/node") |>
  map_dfr(function(n) {
    vals <- xml_find_all(n, ".//attvalue")
    row <- setNames(xml_attr(vals, "value"), att_map[xml_attr(vals, "for")])
    as_tibble(as.list(row)) |>
      mutate(name = xml_attr(n, "id"), label = xml_attr(n, "label"))
  }) |>
  mutate(
    date      = as.POSIXct(as.numeric(publishedAtUnix), origin = "1970-01-01", tz = "UTC"),
    viewCount = as.numeric(viewCount)
  ) |>
  relocate(name)

# edges
edges <- xml_find_all(doc, "//edges/edge") |>
  map_dfr(~ tibble(from = xml_attr(.x, "source"),
                   to = xml_attr(.x, "target"),
                   weight = as.numeric(xml_attr(.x, "weight"))))

g <- graph_from_data_frame(edges, directed = FALSE, vertices = nodes)

# --- 1. greedy lane packing: x fixed, y chosen to avoid collisions ---
pack_lanes <- function(x, min_dx, max_lanes = 300) {
  lane_order <- c(0, as.vector(rbind(1:max_lanes, -(1:max_lanes))))  # 0, 1, -1, 2, -2, ...
  last <- rep(-Inf, length(lane_order))   # last x placed in each lane
  lane <- numeric(length(x))
  for (i in order(x)) {
    k <- which(x[i] - last >= min_dx)[1]  # first lane that is free at this x
    last[k] <- x[i]
    lane[i] <- lane_order[k]
  }
  lane
}

min_dx <- 4 * 86400   # minimum gap in seconds between nodes sharing a lane (4 days). Tune this.

lay_df <- tibble(
  name = V(g)$name,
  x    = as.numeric(V(g)$date),
  cat  = V(g)$videoCategoryLabel
) |>
  group_by(cat) |>
  mutate(lane = pack_lanes(x, min_dx)) |>
  ungroup()

# --- 2. stack the category bands so they don't overlap each other ---
bands <- lay_df |>
  group_by(cat) |>
  summarise(lo = min(lane), hi = max(lane), .groups = "drop") |>
  mutate(h = hi - lo + 3,                       # +3 = gap between bands
         start = cumsum(lag(h, default = 0)),
         mid = start + (hi - lo) / 2 + 1)

lay_df <- lay_df |>
  left_join(bands, by = "cat") |>
  mutate(y = start + (lane - lo) + 1)

lay <- lay_df[match(V(g)$name, lay_df$name), ]   # keep the same order as the graph

p <- ggraph(g, layout = "manual", x = lay$x, y = lay$y) +
  geom_edge_link(aes(edge_alpha = weight, edge_width = weight), edge_colour = "grey30") +
  geom_node_point(aes(colour = videoCategoryLabel, size = viewCount), alpha = 0.85) +
  scale_size(range = c(0.8, 6), trans = "sqrt", guide = "none") +
  scale_edge_width(range = c(0.1, 1), guide = "none") +
  scale_edge_alpha(range = c(0.05, 0.5), guide = "none") +
  scale_y_continuous(breaks = bands$mid, labels = bands$cat) +
  scale_x_continuous(
    breaks = as.numeric(seq(as.POSIXct("2021-01-01", tz = "UTC"),
                            as.POSIXct("2026-12-01", tz = "UTC"), by = "6 months")),
    labels = function(x) format(as.POSIXct(x, origin = "1970-01-01", tz = "UTC"), "%b %Y")
  ) +
  theme_minimal() +
  theme(panel.grid.minor = element_blank(), axis.title = element_blank(),
        legend.position = "bottom")

p
