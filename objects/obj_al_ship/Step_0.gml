// Manages space combat, checks if ships are destroyed and does the targeting and pointing of the ship

var __b__;
var bull, ok, targe=0,rdir=0,dist=9999,xx=x,yy=y;
var front=0,right=0,left=0,rear=0;
var f=0,facing="",ammo=0,range=0,wep="",dam=0;
var o_dist=0, spid=0;
var gud=0;
var husk;
var explo;

__b__ = action_if_variable(owner, 6, 0);
if (!__b__){
    image_angle=direction;

    if (obj_fleet.start!=5) then exit;

    if (class="Daemon") and (image_alpha<1) then image_alpha+=0.006;

    o_dist=0;
    spid=0;

    if (shields>0) and (shields<maxshields) then shields+=0.02;

    // Need to every couple of seconds check this
    // with obj_en_ship if not big then disable, check nearest, and activate once more
    if (instance_exists(obj_en_ship)) then target=instance_nearest(x,y,obj_en_ship);
    if (!instance_exists(target)) then exit;
    // Check if ship is destroyed
    if (hp<=0){
        gud=0;
        for(var wh=1; wh<=5; wh++){if (obj_fleet.enemy[wh]==owner) then gud=wh;}
        
        if (class=="Gorbag's Revenge" or (class=="Dethdeala") or (class=="Kroolboy") or (class=="Desecrator")) or (class=="Custodian") then obj_fleet.en_capital_lost[gud]+=1;
        else if (class=="Battlekroozer") or (class=="Daemon") or (class=="Avenger Class Grand Cruiser") or (class=="Carnage") or (class=="Emissary") or (class=="Protector") then obj_fleet.en_frigate_lost[gud]+=1;
        else if (class=="Ravager") or (class=="Iconoclast") or (class=="Warden") or (class=="Castellan") then obj_fleet.en_escort_lost[gud]+=1;
        else if (class=="Leviathan") then obj_fleet.en_capital_lost[gud]+=1;
        else if (class=="Razorfiend") then obj_fleet.en_frigate_lost[gud]+=1;
        else if (class=="Stalker") or (class=="Prowler") or (class=="Sword Class Frigate") then obj_fleet.en_escort_lost[gud]+=1;
        
        image_alpha=0.5;
        
        if (owner != eFACTION.Tyranids){
            husk=instance_create(x,y,obj_en_husk);
            husk.sprite_index=sprite_index;
            husk.direction=direction;
            husk.image_angle=image_angle;
            husk.depth=depth;
            husk.image_speed=0;
            for(var i=0; i<choose(4,5,6); i++){
                explo=instance_create(x,y,obj_explosion);
                explo.image_xscale=0.5;
                explo.image_yscale=0.5;
                explo.x+=random_range(sprite_width*0.25,sprite_width*-0.25);
                explo.y+=random_range(sprite_width*0.25,sprite_width*-0.25);
            }
        }
        if (owner == eFACTION.Tyranids) then effect_create_above(ef_firework,x,y,1,c_purple);
        instance_destroy();
    }
    // While ship is alive, attack
    if (hp>0) and (instance_exists(obj_en_ship)){
        // TODO on another PR we need to redo how combat works, currently its just "attack" perhaps we can have more precise choise based AI with
        // simpler patterns?
        if (class=="Apocalypse Class Battleship"){
            o_dist=500;
            action="attack";
            spid=20;
        }
        if (class=="Nemesis Class Fleet Carrier"){
            o_dist=1000;
            action="attack";
            spid=20;
        }
        if (class=="Leviathan"){
            o_dist=160;
            action="attack";
            spid=20;
        }
        if (class=="Battle Barge") or (class=="Custodian"){
            o_dist=300;
            action="attack";
            spid=20;
        }
        if (class=="Desecrator"){
            o_dist=300;
            action="attack";
            spid=20;
        }
        if (class=="Razorfiend"){
            o_dist=100;
            action="attack";
            spid=25;
        }
        if (class=="Dethdeala") or (class=="Protector") or (class=="Emissary"){
            o_dist=200;
            action="attack";
            spid=20;
        }
        if (class=="Gorbag's Revenge"){
            o_dist=200;
            action="attack";
            spid=20;
        }
        if (class=="Kroolboy") or (class=="Slamblasta"){
            o_dist=200;
            action="attack";
            spid=25;
        }
        if (class=="Battlekroozer"){
            o_dist=200;
            action="attack";
            spid=30;
        }
        if (class=="Avenger") or (class=="Carnage") or (class=="Daemon"){
            o_dist=200;
            action="attack";
            spid=20;
        }        
        if (class=="Ravager") or (class=="Iconoclast") or (class=="Castellan") or (class=="Warden"){
            o_dist=300;
            action="attack";
            spid=35;
        }
        if (class=="Stalker") or (class=="Sword Class Frigate"){
            o_dist=100;
            action="attack";
            spid=20;
        }
        if (class=="Prowler"){
            o_dist=100;
            action="attack";
            spid=35;
        }
        if (class=="Avenger Class Grand Cruiser"){
            o_dist=48;
            action="broadside";
            spid=20;
        }
        // if (class!="big") then flank!!!!
        spid=spid*speed_bonus;
        
        dist=point_distance(x,y,target.x,target.y)-(max(sprite_get_width(sprite_index),sprite_get_height(sprite_index)));
        // For example here we could improve the options and how ships beheave...
        if (target!=0) and (action=="attack"){
            direction = turn_towards_point(direction, x, y, target.x, target.y, global.frame_timings.t01);
        }
        if (target!=0) and (action=="broadside") and (dist>o_dist){
            if (y>=target.y) then dist=point_distance(x,y,target.x+lengthdir_x(64,target.direction-180),target.y+lengthdir_y(128,target.direction-90))-(max(sprite_get_width(sprite_index),sprite_get_height(sprite_index)));
            if (y<target.y) then dist=point_distance(x,y,target.x+lengthdir_x(64,target.direction-180),target.y+lengthdir_y(128,target.direction+90))-(max(sprite_get_width(sprite_index),sprite_get_height(sprite_index)));
            if (y > target.y) && (dist>o_dist) { direction = turn_towards_point(direction, x + lengthdir_x(64, target.direction - 180), y, target.x, target.y + lengthdir_y(128, target.direction - 90), global.frame_timings.t02); }
            if (y < target.y) && (dist>o_dist) { direction = turn_towards_point(direction, x + lengthdir_x(64, target.direction - 180), y, target.x, target.y + lengthdir_y(128, target.direction + 90), global.frame_timings.t02); }
            if (turn_bonus > 1) {
                if (y < target.y) && (dist > o_dist) { direction = turn_towards_point(direction, x + lengthdir_x(64, target.direction - 180), y, target.x, target.y + lengthdir_y(128, target.direction + 90), global.frame_timings.t02); }
            }
        }
        /*if (target!=0) and (action="broadside") and (o_dist>=dist){
            direction=turn_towards_point(direction,x+lengthdir_x(128,target.direction-90),y,target.x,target.y+lengthdir_y(128,target.direction-90),.2)
        }*/
        /*if (target!=0) and (action="broadside") and (o_dist>=dist){
            var re_deh;re_deh=relative_direction(direction,target.direction);
            // if (re_deh<45) or (re_deh>315) or ((re_deh>135) and (re_deh<225)) then direction=turn_towards_point(direction,x+lengthdir_x(128,target.direction-90),y,target.x,target.y+lengthdir_y(128,target.direction-90),.2)
            var wok;
            wok=0;
            if (!instance_exists(target_l)) then wok=2;
            if (!instance_exists(target_r)) then wok=1;
            if (instance_exists(target_l)) and (instance_exists(target_r)){
                if (point_distance(x,y,target_l.x,target_l.y))<(point_distance(x,y,target_r.x,target_r.y)) then wok=1;
                else{wok=2;}
                
            }
            if (wok=1){
                direction=turn_towards_point(direction,x,y,x+lengthdir_x(256,90),y+lengthdir_y(256,90),.2)
            }
            if (wok=2){
                direction=turn_towards_point(direction,x,y,x+lengthdir_x(256,270),y+lengthdir_y(256,270),.2)
            }
            // direction=turn_towards_point(direction,x+lengthdir_x(128,target.direction-90),y,target.x,target.y+lengthdir_y(128,target.direction-90),.2)
        }*/
        // Controls speed based on action
        if (action="attack"){
            if (dist>o_dist) and (speed<((spid)/10)) then speed+=0.005;
            if (dist<o_dist) and (speed>0) then speed-=0.025;
        }
        if (action="broadside"){
            if (dist>o_dist) and (speed<((spid)/10)) then speed+=0.005;
            if (dist<o_dist) and (speed>0) then speed-=0.025;
        }
        if (speed<0) then speed=speed*0.9;
        // Weapon reloads
        if (cooldown[1]>0) then cooldown[1]-=1;
        if (cooldown[2]>0) then cooldown[2]-=1;
        if (cooldown[3]>0) then cooldown[3]-=1;
        if (cooldown[4]>0) then cooldown[4]-=1;
        if (cooldown[5]>0) then cooldown[5]-=1;
        if (turret_cool>0) then turret_cool-=1;
        
        targe=0;
        rdir=0;
        dist=9999;
        xx=x;
        yy=y;
        // Turret targetting
        if (turrets>0) and (instance_exists(obj_en_in)) and (turret_cool=0){
            targe=instance_nearest(x,y,obj_en_in);
            if (instance_exists(targe)) then dist=point_distance(x,y,targe.x,targe.y);
            if (dist>64) and (dist<300){
                bull=instance_create(x,y,obj_al_round);
                bull.direction=point_direction(x,y,targe.x,targe.y);
                if (owner == eFACTION.Tyranids) then bull.sprite_index=spr_glob;
                bull.speed=20;
                bull.dam=3;
                bull.image_xscale=0.5;
                bull.image_yscale=0.5;
                turret_cool=floor(60/turrets);
                bull.direction+=choose(random(10),1*-(random(10)));
            }
        }
        targe=0;
        dist=9999;
        xx=lengthdir_x(64,direction+90);
        yy=lengthdir_y(64,direction+90);
        
        // TODO we could implement facing with stronger shields or other stuff
        front=0;
        right=0;
        left=0;
        rear=0;
        
        targe=instance_nearest(xx,yy,obj_en_ship);
        rdir=point_direction(x,y,target.x,target.y);
        // if (rdir>45) and (rdir<=135) and (targe!=target){target_r=targe;right=1;}
        // if (rdir>225) and (rdir<=315) and (targe!=target) and (targe!=target_r){target_l=targe;left=1;}   
        target_l=instance_nearest(x+lengthdir_x(64,direction+90),y+lengthdir_y(64,direction+90),obj_en_ship);
        target_r=instance_nearest(x+lengthdir_x(64,direction+270),y+lengthdir_y(64,direction+270),obj_en_ship);
        
        if (collision_line(x,y,x+lengthdir_x(2000,direction),y+lengthdir_y(2000,direction),obj_en_ship,0,1)) then front=1;
        
        f=0;
        facing="";
        ammo=0;
        range=0;
        wep="";
        dam=0;
        
        for(var gg=1; gg<=weapons; gg++){
            // Resets
            ok=0;
            f+=1;
            facing="";
            ammo=0;
            range=0;
            wep="";
        
            if (cooldown[gg]<=0) and (weapon[gg]!="") and (weapon_ammo[gg]>0) then ok=1;
            if (ok==1){
                facing=weapon_facing[gg];
                ammo=weapon_ammo[gg];
                range=weapon_range[gg];
            }
        
            targe=target;
            if (facing=="front") and (front==1) then ok=2;
            if (facing=="most") then ok=2;
            /*
            if (facing="right") then targe=target_r;
            if (facing="left") then targe=target_l;    
            if ((facing="front") or (facing="most")) and (front=1) then ok=2;
            if (facing="right") or (facing="most") and (right=1) then ok=2;
            if (facing="left") or (facing="most") and (left=1) then ok=2;
            */
            if (facing=="special") then ok=2;
            if (!instance_exists(targe)) then exit;
            dist=point_distance(x,y,targe.x,targe.y);
            if (facing=="right") and (point_direction(x,y,target_r.x,target_r.y)<337) and (point_direction(x,y,target_r.x,target_r.y)>203) then ok=2;
            if (facing=="left") and (point_direction(x,y,target_r.x,target_r.y)>22) and (point_direction(x,y,target_r.x,target_r.y)<157) then ok=2;
            /*var re_deh;re_deh=relative_direction(direction,target.direction);
            if (re_deh<45) or (re_deh>315) or ((re_deh>135) and (re_deh<225)) then direction=turn_towards_point(direction,x+lengthdir_x(128,target.direction-90),y,target.x,target.y+lengthdir_y(128,target.direction-90),.2)
            */
            if (ok==2) and (dist<(range+(max(sprite_get_width(sprite_index),sprite_get_height(sprite_index))))){
                if (ammo>0) and (ammo<900) then ammo-=1;
                weapon_ammo[gg]=ammo;
                cooldown[gg]=weapon_cooldown[gg];
                wep=weapon[gg];
                dam=weapon_dam[gg];
                // if (f=3) and (ship_id=2) then show_message("ammo: "+string(ammo)+" | range: "+string(range));
                if (ammo<0) then ok=0;
                ok=3;
                // Weapons fire
                if (string_count("orpedo",wep)==0) and (string_count("Interceptor",wep)==0) and (string_count("ommerz",wep)==0) and (string_count("Claws",wep)==0) and (string_count("endrils",wep)==0) and (ok==3){
                    bull=instance_create(x+lengthdir_x(32,direction),y+lengthdir_y(32,direction),obj_al_round);
                    bull.speed=20;
                    bull.dam=dam;
                    if (targe==target) then bull.direction=point_direction(x+lengthdir_x(32,direction),y+lengthdir_y(32,direction),target.x,target.y);
                    if (facing!="front"){bull.direction=point_direction(x+lengthdir_x(32,direction),y+lengthdir_y(32,direction),target.x,target.y);}
                    if (string_count("ova",wep)==1){
                        bull.image_xscale=2;
                        bull.image_yscale=2;
                    }
                    if (string_count("eavy Gunz",wep)==1){
                        bull.image_xscale=1.5;
                        bull.image_yscale=1.5;
                    }
                    if (string_count("Lance",wep)==1){
                        bull.sprite_index=spr_ground_las;
                        bull.image_xscale=1.5;
                        bull.image_yscale=1.5;
                    }
                    if (string_count("Ion",wep)==1){
                        bull.sprite_index=spr_pulse;
                        bull.image_xscale=1.5;
                        bull.image_yscale=1.5;
                    }
                    if (string_count("Rail",wep)==1){
                        bull.sprite_index=spr_railgun;
                        bull.image_xscale=1.5;
                        bull.image_yscale=1.5;
                    }
                    if (string_count("Gravitic",wep)==1){
                        bull.image_xscale=2;
                        bull.image_yscale=2;
                    }
                    if (string_count("Plasma",wep)==1){
                        bull.sprite_index=spr_ground_plasma;
                        bull.image_xscale=2;
                        bullimage_yscale=2;
                        bull.speed=15;
                    }
                    if (string_count("Pyro-Acid",wep)==1){
                        bull.sprite_index=spr_glob;
                        bull.image_xscale=2;
                        bullimage_yscale=2;
                    }
                    if (string_count("Weapons",wep)==1) and (owner == eFACTION.Eldar){
                        bull.sprite_index=spr_ground_las;
                        bull.image_xscale=2;
                        bull.image_yscale=2;
                    }
                    if (string_count("Pulse",wep)==1) and (owner == eFACTION.Eldar){
                        bull.sprite_index=spr_pulse;
                        bull.image_xscale=1.5;
                        bull.image_yscale=1.5;
                    }
                }
                // Torpedo weapons
                if (string_count("orpedo",wep)==1) and (ok==3){
                    if (class!="Ravager"){
                        bull=instance_create(x,y+lengthdir_y(-30,direction+90),obj_al_round);
                        bull.speed=10;
                        bull.direction=direction;
                        bull.sprite_index=spr_torpedo;
                        bull.dam=dam;
                    }
                    bull=instance_create(x,y+lengthdir_y(-10,direction+90),obj_al_round);
                    bull.speed=10;
                    bull.direction=direction;
                    bull.sprite_index=spr_torpedo;
                    bull.dam=dam;
                    bull=instance_create(x,y+lengthdir_y(10,direction+90),obj_al_round);
                    bull.speed=10;
                    bull.direction=direction;
                    bull.sprite_index=spr_torpedo;
                    bull.dam=dam;
                    if (class!="Ravager"){
                        bull=instance_create(x,y+lengthdir_y(30,direction+90),obj_al_round);
                        bull.speed=10;
                        bull.direction=direction;
                        bull.sprite_index=spr_torpedo;
                        bull.dam=dam;
                    }
                }
                // Melee ship weapons (nids)
                if ((string_count("Claws",wep)==1) or (string_count("endrils",wep)==1)) and (ok==3){
                    if (target.shields<=0) then target.hp-=weapon_dam[wep];
                    if (target.shields>0) then target.shields-=weapon_dam[wep];
                }
                // Special weapons
                if ((string_count("Interceptor",wep)==1) or (string_count("ommerz",wep)==1) or (string_count("Manta",wep)==1) or (string_count("Glands",wep)==1) or (string_count("Eldar Launch",wep)==1)) and (ok==3){
                    bull=instance_create(x,y+lengthdir_y(-30,direction+90),obj_al_in);
                    bull.direction=self.direction;
                    bull.owner=self.owner;
                }
            }
        }
    }
}
// Checks if the enemy fleet is Eldar
__b__ = action_if_variable(owner, 6, 0);
if (__b__){
    image_angle=direction;

    if (obj_fleet.start!=5) then exit;

    o_dist=0;
    spid=0;

    if (shields>0) and (shields<maxshields) then shields+=0.03;
    // Need to every couple of seconds check this
    // with obj_en_ship if not big then disable, check nearest, and activate once more
    if (instance_exists(obj_en_ship)) then target=instance_nearest(x,y,obj_en_ship);

    if (hp<=0){
        gud=0;
        for(var wh=1; wh<=5; wh++){if (obj_fleet.enemy[wh]==owner) then gud=wh;}

        if (class=="Void Stalker") then obj_fleet.en_capital_lost[gud]+=1;
        if (class=="Shadow Class") then obj_fleet.en_frigate_lost[gud]+=1;
        if (class=="Hellebore") or (class=="Aconite") then obj_fleet.en_escort_lost[gud]+=1;
        
        image_alpha=0.5;
        
        husk=instance_create(x,y,obj_en_husk);
        husk.sprite_index=sprite_index;
        husk.direction=direction;
        husk.image_angle=image_angle;
        husk.depth=depth;
        husk.image_speed=0;

        for(var i=0; i<choose(4,5,6); i++){
            explo=instance_create(x,y,obj_explosion);
            explo.image_xscale=0.5;
            explo.image_yscale=0.5;
            explo.x+=random_range(sprite_width*0.25,sprite_width*-0.25);
            explo.y+=random_range(sprite_width*0.25,sprite_width*-0.25);
        }
        instance_destroy();
    }
    if (hp>0) and (instance_exists(obj_en_ship)){
        if (class=="Void Stalker"){
            o_dist=300;
            action="swoop";
            spid=60;
        }
        if (class=="Shadow Class"){
            o_dist=200;
            action="swoop";
            spid=80;
        }
        if (class=="Hellebore") or (class=="Aconite"){
            o_dist=200;
            action="swoop";
            spid=100;
        }
        
        dist=point_distance(x,y,target.x,target.y)-(max(sprite_get_width(target.sprite_index),sprite_get_height(sprite_index)));
        
        if (target!=0){
            if (speed<((spid)/10)) then speed+=0.02;
            if (instance_exists(target)){
                dist=point_distance(x,y,target.x,target.y);
                
                if (action == "swoop") { direction = turn_towards_point(direction, x, y, target.x, target.y, global.frame_timings.t5 - ship_size);}
                if (dist<=o_dist) and (collision_line(x,y,x+lengthdir_x(o_dist,direction),y+lengthdir_y(o_dist,direction),obj_en_ship,0,1)) then action="attack";
                if (dist<300) and (action=="attack") then action="bank";
                if (action == "bank") { direction = turn_towards_point(direction, x, y, room_width, room_height / 2, global.frame_timings.t5 - ship_size); }
                if (action=="bank") and (dist>700) then action="attack";
            }
        }
        
        if (y<-2000) or (y>room_height+2000) or (x<-2000) or (x>room_width+2000) then hp=-50;
        // Weapon and turret cooldown
        for (var i = 1; i < array_length(cooldown); i++) {
            if (cooldown[i]>0){
                cooldown[i]--;
            }
        }
        if (turret_cool>0) then turret_cool-=1;

        targe=0;
        dist=9999;
        xx=x;
        yy=y;
        
        if (turrets>0) and (instance_exists(obj_en_in)) and (turret_cool==0){
            targe=instance_nearest(x,y,obj_en_in);
            if (instance_exists(targe)) then dist=point_distance(x,y,targe.x,targe.y);
            
            if (dist>64) and (dist<300){
                bull=instance_create(x,y,obj_al_round);
                bull.direction=point_direction(x,y,targe.x,targe.y);
                if (owner = eFACTION.Tyranids) then bull.sprite_index=spr_glob;
                if (owner = eFACTION.Tau) or (owner = eFACTION.Eldar) then bull.sprite_index=spr_pulse;
                bull.speed=20;
                bull.dam=3;
                bull.image_xscale=0.5;
                bull.image_yscale=0.5;
                turret_cool=floor(60/turrets);
                bull.direction+=choose(random(10),1*-(random(10)));
            }
        }
        targe=0;
        rdir=0;
        dist=9999;
        
        xx=lengthdir_x(64,direction+90);
        yy=lengthdir_y(64,direction+90);
        
        front=0;
        right=0;
        left=0;
        rear=0;
        
        targe=instance_nearest(xx,yy,obj_en_ship);
        rdir=point_direction(x,y,target.x,target.y);
        // if (rdir>45) and (rdir<=135) and (targe!=target){target_r=targe;right=1;}
        // if (rdir>225) and (rdir<=315) and (targe!=target) and (targe!=target_r){target_l=targe;left=1;}   
        target_l=instance_nearest(x+lengthdir_x(64,direction+90),y+lengthdir_y(64,direction+90),obj_en_ship);
        target_r=instance_nearest(x+lengthdir_x(64,direction+270),y+lengthdir_y(64,direction+270),obj_en_ship);
        
        if (collision_line(x,y,x+lengthdir_x(2000,direction),y+lengthdir_y(2000,direction),obj_en_ship,0,1)) then front=1;
        
        
        f=0;
        facing="";
        ammo=0;
        range=0;
        wep="";
        dam=0;
        gg=0;
        
        for(var gg=1; gg<=weapons; gg++){
            ok=0;
            f+=1;
            facing="";
            ammo=0;
            range=0;
            wep="";
            
            if (cooldown[gg]<=0) and (weapon[gg]!="") and (weapon_ammo[gg]>0) then ok=1;
            if (ok==1){
                facing=weapon_facing[gg];
                ammo=weapon_ammo[gg];
                range=weapon_range[gg];
            }
        
            targe=target;
            if (facing=="front") and (front==1) then ok=2;
            if (facing=="most") then ok=2;
            /*
            if (facing="right") then targe=target_r;
            if (facing="left") then targe=target_l;    
            if ((facing="front") or (facing="most")) and (front=1) then ok=2;
            if (facing="right") or (facing="most") and (right=1) then ok=2;
            if (facing="left") or (facing="most") and (left=1) then ok=2;
            */
            if (facing=="special") then ok=2;
            if (!instance_exists(targe)) then exit;
            dist=point_distance(x,y,targe.x,targe.y);
        
            if (facing=="right") and (point_direction(x,y,target_r.x,target_r.y)<337) and (point_direction(x,y,target_r.x,target_r.y)>203) then ok=2;
            if (facing=="left") and (point_direction(x,y,target_r.x,target_r.y)>22) and (point_direction(x,y,target_r.x,target_r.y)<157) then ok=2;
            /*
            var re_deh;re_deh=relative_direction(direction,target.direction);
            if (re_deh < 45) || (re_deh > 315) || ((re_deh > 135) && (re_deh < 225)) { direction = turn_towards_point(direction, x + lengthdir_x(128, target.direction-90), y, target.x, target.y + lengthdir_y(128, target.direction - 90), global.frame_timings.t02) }
            */
            if (ok==2) and (dist<(range+(max(sprite_get_width(sprite_index),sprite_get_height(sprite_index))))){
                if (ammo>0) and (ammo<900) then ammo-=1;
                weapon_ammo[gg]=ammo;
                cooldown[gg]=weapon_cooldown[gg];
                wep=weapon[gg];
                dam=weapon_dam[gg];
                // if (f=3) and (ship_id=2) then show_message("ammo: "+string(ammo)+" | range: "+string(range));
                if (ammo<0) then ok=0;
                ok=3;
                // Weapon types
                if (string_count("orpedo",wep)==0) and (string_count("Interceptor",wep)==0) and (string_count("ommerz",wep)==0) and (string_count("Claws",wep)==0) and (string_count("endrils",wep)==0) and (ok==3){
                    bull=instance_create(x+lengthdir_x(32,direction),y+lengthdir_y(32,direction),obj_al_round);
                    bull.speed=20;
                    bull.dam=dam;
                    if (targe==target) then bull.direction=point_direction(x+lengthdir_x(32,direction),y+lengthdir_y(32,direction),target.x,target.y);
                    if (facing!="front"){bull.direction=point_direction(x+lengthdir_x(32,direction),y+lengthdir_y(32,direction),target.x,target.y);}
                    if (string_count("ova",wep)==1){
                        bull.image_xscale=2;
                        bull.image_yscale=2;
                    }
                    if (string_count("eavy Gunz",wep)==1){
                        bull.image_xscale=1.5;
                        bull.image_yscale=1.5;
                    }
                    if (string_count("Lance",wep)==1){
                        bull.sprite_index=spr_ground_las;
                        bull.image_xscale=1.5;
                        bull.image_yscale=1.5;
                    }
                    if (string_count("Ion",wep)==1){
                        bull.sprite_index=spr_pulse;
                        bull.image_xscale=1.5;
                        bull.image_yscale=1.5;
                    }
                    if (string_count("Rail",wep)==1){
                        bull.sprite_index=spr_railgun;
                        bull.image_xscale=1.5;
                        bull.image_yscale=1.5;
                    }
                    if (string_count("Gravitic",wep)==1){
                        bull.image_xscale=2;
                        bull.image_yscale=2;
                    }
                    if (string_count("Plasma",wep)==1){
                        bull.sprite_index=spr_ground_plasma;
                        bull.image_xscale=2;
                        bullimage_yscale=2;
                        bull.speed=15;
                    }
                    if (string_count("Pyro-Acid",wep)==1){
                        bull.sprite_index=spr_glob;
                        bull.image_xscale=2;
                        bullimage_yscale=2;
                    }
                    if (string_count("Weapons",wep)==1) and (owner = eFACTION.Eldar){
                        bull.sprite_index=spr_ground_las;
                        bull.image_xscale=2;
                        bull.image_yscale=2;
                    }
                    if (string_count("Pulse",wep)==1) and (owner = eFACTION.Eldar){
                        bull.sprite_index=spr_pulse;
                        bull.image_xscale=1.5;
                        bull.image_yscale=1.5;
                    }
                }
                if (string_count("orpedo",wep)==1) and (ok==3){
                    if (class!="Ravager"){
                        bull=instance_create(x,y+lengthdir_y(-30,direction+90),obj_al_round);
                        bull.speed=10;
                        bull.direction=direction;
                        bull.sprite_index=spr_torpedo;
                        bull.dam=dam;
                    }
                    bull=instance_create(x,y+lengthdir_y(-10,direction+90),obj_al_round);
                    bull.speed=10;
                    bull.direction=direction;
                    bull.sprite_index=spr_torpedo;
                    bull.dam=dam;
                    bull=instance_create(x,y+lengthdir_y(10,direction+90),obj_al_round);
                    bull.speed=10;
                    bull.direction=direction;
                    bull.sprite_index=spr_torpedo;
                    bull.dam=dam;
                    if (class!="Ravager"){
                        bull=instance_create(x,y+lengthdir_y(30,direction+90),obj_al_round);
                        bull.speed=10;
                        bull.direction=direction;
                        bull.sprite_index=spr_torpedo;
                        bull.dam=dam;
                    }
                }
                if ((string_count("Claws",wep)==1) or (string_count("endrils",wep)==1)) and (ok==3){
                    if (target.shields<=0) then target.hp-=weapon_dam[wep];
                    if (target.shields>0) then target.shields-=weapon_dam[wep];
                }
                if ((string_count("Interceptor",wep)==1) or (string_count("ommerz",wep)==1) or (string_count("Manta",wep)==1) or (string_count("Glands",wep)==1) or (string_count("Eldar Launch",wep)==1)) and (ok==3){
                    bull=instance_create(x,y+lengthdir_y(-30,direction+90),obj_al_in);
                    bull.direction=self.direction;
                    bull.owner=self.owner;
                }
            }
        }
    }
}
