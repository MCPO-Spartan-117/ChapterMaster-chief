if (last_turn_check == obj_controller.turn){
    exit;
}

if (id > other.id) {
    if (trade_goods != "" && other.trade_goods != "" && string_count("merge", trade_goods) > 0 && string_count("merge", other.trade_goods) > 0) {
        var _same_navy = navy == other.navy;
        if (other.owner == self.owner && _same_navy) {
            if (action_x == other.action_x && action_y == other.action_y) {
                if (!fleet_has_cargo("colonize") && !fleet_has_cargo("colonize", other)) {
                    if (!fleet_has_cargo("ork_warboss") && !fleet_has_cargo("ork_warboss", other)) { // ork_warboss would never match as it seems only imperium ships get the 'merge' directive
                        merge_fleets(other.id, self.id);
                    }
                }
            }
        }
    }
}
last_turn_check = obj_controller.turn;
