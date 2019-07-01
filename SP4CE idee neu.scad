//!#OpenSCAD

// SPACE RINGS: a multi axe ring thing with custom center element
// 

// basic resolution. Set low for speed / high for quality
$fn = 48;
outer_diameter = 50;
height_main = 10; // [1:0.1:30]

ring_thickness = 2; //[.1:.1:10]
tolerance = 0.4; // [0:0.05:0.6]
midpart_height = 9; // 
midpart_width = 40; //
// on: multi axe system; off: no axes (what means that the rings move 'freely'. (hence, the hight should be big enough so that the rings wont slip out!)
multi_axe_konstruct = true;

// wenn hier ein pfad zu einem STL file gesetzt wird, wird dieses angezeigt. Wenn leer, wird String (s.u.) angezeigt.
// midpart_stl = "";

// enter path to a 2d object (e.g. svg). Or leave empty to ignore.
midpart_2d = "";

// enter string and font. Or leave empty to ignore
midpart_string = "SP4CE";
// enter correct font name without "" (OpenSCAD Help/Font list)
string_font = "Liberation Sans:style=Bold";
font_spacing = 0.70; //[0.1:0.01:2]
midpart_scale_x = 1.16; //[0.11:0.01:2]
midpart_scale_y = 1; //[0.11:0.01:2]
// x-position correction 
// off: assumes origin of midpart to be left bottom
midpart_is_centeraligned = true;
midpart_corr_x = -1.6; //[-10:0.1:10]
midpart_corr_y = 0; //[-10:0.1:10]
// adds an inter connecting bar behind letters
holding_bar = false;
holding_bar_xrange = 0.6;//[0.1:0.01:1.1]
holding_bar_height = 0.5;//[0:0.01:1]

// rotate_A = 0; // [0:360]
// fun options: look how rings turn
rotate_B = 0; // [0:360]
rotate_C = 0; // [0:360]
rotate_D = 0; // [0:360]

debugview = false;
///////////////////////////////////////

if (debugview == false)
    mainconstruct();
else difference() {
      mainconstruct();
     # translate([0,0,.5*height_main]) cube([outer_diameter, outer_diameter, height_main], center=true);
    };
 

////////////////////////////////////
////////////////////////////////////

module mainconstruct(){
    union() {
    // outer ring
    // rotate([rotate_A,0,0]) {
    // render() {       
    // !color("green", 1) {
        intersection() {
            difference() {
                sphere(d=outer_diameter);
                sphere(d=outer_diameter - ring_thickness*2); 
                nupsi(0, outer_diameter/2  - ring_thickness - tolerance,0,0,outer=false);
                nupsi(0, outer_diameter/-2 + ring_thickness + tolerance,0,180,outer=false);
            };
            cube([100, 100, height_main], center=true);
        };
    }

    // mid ring
    // render() {
    rotate([0,rotate_B,0]) {
        union()         
        intersection() {
            difference() {
                sphere(r=.5*outer_diameter - ring_thickness - tolerance);
                sphere(r=.5*outer_diameter - 2*ring_thickness - tolerance); 
                nupsi( 0.5*outer_diameter - 2*ring_thickness - 2*tolerance,0,0,-90,outer=false);
                nupsi(-0.5*outer_diameter + 2*ring_thickness + 2*tolerance,0,0, 90,outer=false);
            };
            cube([100, 100, height_main], center=true);
        };  
        nupsi(0,0.5*outer_diameter - ring_thickness - 2*tolerance,0,0,outer=true);
        nupsi(0,-0.5*outer_diameter + ring_thickness + 2*tolerance,0,180,outer=true);

    };

    // inner ring
    // render() {
    rotate([rotate_C,rotate_B,0]) {
        intersection() {
            union() {
                difference() {
                    sphere(r=.5*outer_diameter - 2*ring_thickness - 2*tolerance);
                    sphere(r=.5*outer_diameter - 3*ring_thickness - 2*tolerance);
                };
            midpart_holder();
           };
            cube([100, 100, height_main], center=true);
        };
        nupsi(0.5*outer_diameter - 2*ring_thickness - 3*tolerance,0,0,-90,outer=true);
        nupsi(-0.5*outer_diameter + 2*ring_thickness + 3*tolerance,0,0,90,outer=true);
    };

    // center part
    // render() {
    rotate([rotate_C,rotate_B+rotate_D,0])
    // rotate([0,rotate_D,0])
        intersection() {
            sphere(r=.5*outer_diameter - 3*ring_thickness - 3*tolerance);
            midpart();
            cube([100, 100, height_main], center=true);
        };
};


// 'nose' (axe connectors) = parameter driven zylinder
module nupsi(tx,ty,tz,rz,outer){

    // outer bool desides about applying outer or inner tolerances 
    tol=tolerance * (outer? -0.5:0.5);
    d1_= 4 + tol;
    d2_=d1_ - min(2*ring_thickness*cos(45),d1_);
    // echo(d1=d1_);
    // echo(d2=d2_);
    if (multi_axe_konstruct==true)  // if rings each other cover enough, no nupsis needed
          translate([tx,ty,tz]) rotate([-90,0,rz]) cylinder(d1=d1_, d2=d2_, h=ring_thickness, center=false);
}

module midpart_holder() {  
    // 2 holders for the axe
   // inner part variables
    
    l = outer_diameter - 3*ring_thickness - 2*tolerance; // length
    ofs = 5; // upper/lower axe holder x mid-offset
    brett_w = ring_thickness*2/3; //1.5; //brettdicke
    brettpos = [l/2 - ofs, midpart_height/2+tolerance, 0];


// !    color("brown", .4) {
    if (multi_axe_konstruct==true) { // if rings each other cover enough, no holder needed

        intersection() { // makes outer sphere limit
            sphere(r=.5*outer_diameter - 3*ring_thickness - 2*tolerance);

            union() { // inner holding system
                //oberes Brett mit 3d printable borders/angles
                translate(brettpos)    
                    rotate([-90,0,0])
                            hull() { 
                                translate([(l-ring_thickness- height_main )/-2,0,0]) 
                                3dp_hole(extr_l=brett_w, r=height_main/2, ovhang=45, center=false);
                                translate([(l-ring_thickness)/2,0,0])
                                3dp_hole(extr_l=brett_w, r=height_main/2, ovhang=45, center=false);
                              };
                        // };
                //unteres Brett mit chamfer (dirty)
                rotate([0,0,180])
                translate(brettpos) 
                    rotate([-90,0,0])
                            hull() { 
                                translate([(l-ring_thickness- height_main )/-2,0,0]) 
                                3dp_hole(extr_l=brett_w, r=height_main/2, ovhang=45, center=false);
                                translate([(l-ring_thickness)/2,0,0])
                                3dp_hole(extr_l=brett_w, r=height_main/2, ovhang=45, center=false);
                              } ;
                // Achse
                rotate([90,0,0]) cylinder(r=1.5, h=midpart_height+2*tolerance , center=true);
            };
        };
    };
    // }; color
}

// center message letters or stl-something, fitted into the rings
module midpart(){
    hbw = 0.6; // width of 'holding bar' in mm
    hbl = holding_bar_xrange; // multiplier für holding bar length 
    hbo = 0.5*holding_bar_height*midpart_height ; // holding_bar y offset (hbw/2 = mitte)
    midalign = midpart_is_centeraligned ? 0 : 1;

    // render(convexity = 10)
// !    color("dark gray", .4) {
  
        difference() { // middle axe cut out
 
            union() {
                // if (midpart_stl == "") { // extrude text with font
                if (midpart_string != "") { // extrude text with font
                   translate([midpart_corr_x,midpart_corr_y,0])
                    scale([midpart_scale_x, midpart_scale_y, 1]) 

                    render(convexity = 10)
                    linear_extrude(height=midpart_height*1.1, center=true, convexity=20)
                    translate([0,midpart_height/-50,0]) text(midpart_string, size=midpart_height, font=string_font, halign="center", valign="center", spacing=font_spacing);
                }
                else if (midpart_2d != "") { // extrude text with font
                   translate([midpart_corr_x,midpart_corr_y,0])
                    render(convexity = 10)
                        linear_extrude(height=midpart_height*1.1, center=true, convexity=20)
                        // translate([0,midpart_height/-50])
                            scale([midpart_scale_x, midpart_scale_y]) 
                            translate([0,midalign*midpart_height/-2])
                            resize([0,midpart_height,0], auto=true)
                            // center unknown width
                            translate([midalign*-20,0,0]) resize([40,0,0], auto=true)
                              import(midpart_2d);

                    // translate([midalign*midpart_width*-0.35 +midpart_corr_x,midalign*midpart_height/-2 +midpart_corr_y, 0]) resize([midpart_width*midpart_scale_x,midpart_height*midpart_scale_y])
                };
                

                // letter stabilizer 'holding bar'
                if (holding_bar == true) {
                    translate([midpart_width*hbl/-2,0,0])
                    union() {
                        translate([0, hbo , height_main/-2 ])
                            cube ([midpart_width*hbl, hbw, height_main*.6], center=false);
                        translate([0, -hbo-hbw, height_main/-2 ])
                            cube ([midpart_width*hbl, hbw, height_main*.6], center=false);
                    }
                };
            };
            // axe hole to be cutted out
    if (multi_axe_konstruct==true)  // if rings cover each other enough, no axe needed
            // rotate([90,0,0]) cylinder(r=1.5 + tolerance, h=midpart_height+11 , center=true)
            rotate([90,0,0]) 3dp_hole(extr_l=midpart_height+11, r=1.5 + tolerance, ovhang=45, center=true);
        }
    // } //color
}

// 2d cirle-ish object, enables 3d printable objects/holes
// 3dp_hole(extr_l=1, r=3, ovhang=45, center=true)
module 3dp_hole(extr_l=1, r=3, ovhang=35, center=true) {
    linear_extrude(height=extr_l, center=center, convexity=2) {
        hull() {
            circle(r=r);
            polygon(points=[[cos(ovhang)*r,sin(ovhang)*r],[0,sin(ovhang)*r*2],[cos(180-ovhang)*r,sin(180-ovhang)*r]]);
}}}