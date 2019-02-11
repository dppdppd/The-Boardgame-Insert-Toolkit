
module Hex( radius = 1, t = 0.1 )
{
    difference()
    {
        circle(r = radius, $fn = 6 );  
        
        offset(r = -t)
        {
            circle( r = radius, $fn = 6 );  
        }
    }
}

module HexFast( radius = 1, t = 0.1 )
{
        circle(r = radius, $fn = 6 );  
        
        offset(r = -t)
        {
            circle( r = radius, $fn = 6 );  
        }
    
}


module HexOuter( radius = 1, t = 0.1 )
{
        circle(r = radius, $fn = 6 );  
}

module HexInner( radius = 1, t = 0.1, depth = 1 )
{
        linear_extrude( depth )
            offset(r = -t)
            {
                circle( r = radius, $fn = 6 );  
            }  
}

module FastHexGrid( x = 200, y = 200, r = 6, t = 1 )
{
    difference()
    {
        cube([ x, y, 1]);

         MakeGrid( x = 200, y = 200, r = 6, t = 1 )
            HexInner( r, t );           
    }
}

module MakeHexGrid( x = 200, y = 200, r = 6, t = 1 )
{
    o = cos(30) * r;

    x_count = x / ( o );
    y_count = y / ( o );

    translate( [-x/3, -y/4, 0])
    {
        for( j = [0:y_count] )
        {
            translate( [ ( j % 2 ) * (o - t/2), 0, 0 ] )
            {
                for( i = [ 0: x_count ] )
                {
                    translate( [ i * ( o * 2 - t ), j * ( r * 1.5 - t), 0 ] )
                    {
                        rotate( 30, [ 0, 0, 1 ] )
                        {
                            children();
                        }
                    }
                }
            }
        }
    }
}




            module HexGrid( x = 200, y = 200, r = 6, t = 1 )
            {
                o = cos(30) * r;

                x_count = x / ( o );
                y_count = y / ( o );
            
                translate( [-x/3, -y/4,0])
                {
                    for( j = [0:y_count] )
                    {
                        translate( [ ( j % 2 ) * (o - t/2), 0, 0 ] )
                        {
                            for( i = [ 0: x_count ] )
                            {
                                translate( [ i * ( o * 2 - t ), j * ( r * 1.5 - t), 0 ] )
                                {
                                    rotate( 30, [ 0, 0, 1 ] )
                                    {
                                        HexFast( r, t );
                                    }
                                }
                            }
                        }
                    }
                }
            }

            module HexGrid2( x = 200, y = 200, r = 3, t = 0.2 )
            {
                o = cos(30) * r;

                x_count = x / r;
                y_count = y / r;
            
                for( i = [0:9] )
                {
                    a = i * 60;

                    rotate( a, [0,0,1], [x/2,y/2,0])
                    for( j = [0:x_count] )
                    {
                        translate([-x/2, (r * j) - y/2, 0] )
                            cube( [x,  t, 1]);

                    }
                }


                
                          


            }


//FastHexGrid();

module Hexigonm( r = 1, t = 0.2, d = 1  )
{
    linear_extrude( d )
    {
        polygon([
            [ r * cos(0 * 2 * ( PI / 6)* 180 / PI), r * sin(0 * 2 * ( PI / 6) * 180 / PI) ],
            [ r * cos(1 * 2 * ( PI / 6)* 180 / PI), r * sin(1 * 2 * ( PI / 6) * 180 / PI) ],
            [ r * cos(2 * 2 * ( PI / 6)* 180 / PI), r * sin(2 * 2 * ( PI / 6) * 180 / PI) ],
            [ r * cos(3 * 2 * ( PI / 6)* 180 / PI), r * sin(3 * 2 * ( PI / 6) * 180 / PI) ],
            [ r * cos(4 * 2 * ( PI / 6)* 180 / PI), r * sin(4 * 2 * ( PI / 6) * 180 / PI) ],
            [ r * cos(5 * 2 * ( PI / 6)* 180 / PI), r * sin(5 * 2 * ( PI / 6) * 180 / PI) ],
            [ ( r - t ) * cos(0 * 2 * ( PI / 6)* 180 / PI), ( r - t ) * sin(0 * 2 * ( PI / 6) * 180 / PI) ],
            [ ( r - t ) * cos(1 * 2 * ( PI / 6)* 180 / PI), ( r - t ) * sin(1 * 2 * ( PI / 6) * 180 / PI) ],
            [ ( r - t ) * cos(2 * 2 * ( PI / 6)* 180 / PI), ( r - t ) * sin(2 * 2 * ( PI / 6) * 180 / PI) ],
            [ ( r - t ) * cos(3 * 2 * ( PI / 6)* 180 / PI), ( r - t ) * sin(3 * 2 * ( PI / 6) * 180 / PI) ],
            [ ( r - t ) * cos(4 * 2 * ( PI / 6)* 180 / PI), ( r - t ) * sin(4 * 2 * ( PI / 6) * 180 / PI) ],
            [ ( r - t ) * cos(5 * 2 * ( PI / 6)* 180 / PI), ( r - t ) * sin(5 * 2 * ( PI / 6) * 180 / PI) ]],
            
            [[0,1,2,3,4,5],[6,7,8,9,10,11]]
            );
    }
            
};

module FINAL( r = 1, t = 0.1 )
{
    MakeHexGrid( r = r, t = t, x = 100, y = 100 )
        Hexigonm( r, t);
}

FINAL();