
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

            module HexGrid( x = 200, y = 200, r = 6, thickness = 3 )
            {
                o = cos(30) * r;

                x_count = x / ( o );
                y_count = y / ( o );
            
                translate( [-x/3, -y/4,0])
                {
                    for( j = [0:y_count] )
                    {
                        translate( [ ( j % 2 ) * (o - thickness/2), 0, 0 ] )
                        {
                            for( i = [ 0: x_count ] )
                            {
                                translate( [ i * ( o * 2 - thickness ), j * ( r * 1.5 - thickness), 0 ] )
                                {
                                    rotate( 30, [ 0, 0, 1 ] )
                                    {
                                        Hex( r, thickness );
                                    }
                                }
                            }
                        }
                    }
                }
            }

            module HexGrid2( x = 200, y = 200, r = 3, thickness = 0.2 )
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
                            cube( [x,  thickness, 1]);

                    }
                }


                
                          


            }


HexGrid2();
