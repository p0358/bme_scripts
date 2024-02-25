
function DefineRumble( rumbleName, heavyMotor, lightMotor, leftTrigger, rightTrigger )
{
	Rumble_CreateGraph( rumbleName, heavyMotor, lightMotor, leftTrigger, rightTrigger )
	Rumble_CreatePlayParams( rumbleName, { name = rumbleName } )
}

function pt( time, power )
{
	return Vector( time, power )
}


function DefineRumbles()
{
	// A rumble has a name, and four graphs:
	// "name"
	//   HEAVY motor    (graph)
	//   LIGHT motor
	//   TRIGGER_LEFT motor
	//   TRIGGER_RIGHT motor

	// Graphs are arrays of points, like:
	//  [  point1, point2, point3 ]

	// To define a point on a graph:
	//   pt( TIME, POWER )


	////////////////////////////
	// Weapon Generic:

	DefineRumble( "reload_pilot_small",
					[],
					[	pt( 0, 0.75 ),	pt( 0.20, 0.0 )	],
					[],
					[] )

	DefineRumble( "reload_pilot_large",
					[	pt( 0, 0.4 ),	pt( 0.1, 0.5 ),	pt( 0.15, 0 )	],
					[	pt( 0, 1.0 ),	pt( 0.15, 0.0 )	],
					[],
					[] )

	DefineRumble( "reload_titan_small",
					[],
					[	pt( 0, 0.75 ),	pt( 0.20, 0.0 )	],
					[],
					[] )

	DefineRumble( "reload_titan_large",
					[	pt( 0, 0.4 ),	pt( 0.1, 0.5 ),	pt( 0.15, 0 )],
					[	pt( 0, 1.0 ),	pt( 0.15, 0.0 )	],
					[],
					[] )

	DefineRumble( "grenade_pin_pull",
					[	pt( 0, 0.4 ),	pt( 0.1, 0.5 ),	pt( 0.15, 0 )],
					[	pt( 0, 1.0 ),	pt( 0.15, 0.0 )	],
					[],
					[] )


	////////////////////////////
	// Weapon Specific:
	if ( Durango_IsDurango() )
	{
		DefineRumble( "pilot_singleshot_weak_fire",
						[	pt( 0, 5.0 ),	pt( 0.1, 5.2 ),	pt( 0.2, 0 )	],
						[	pt( 0, 1.8 ),	pt( 0.2, 0.0 )	],
						[],
						[] )


		DefineRumble( "pilot_singleshot_mid_fire",
						[	pt( 0, 1.8 ),	pt( 0.12, 2.9 ),	pt( 0.25, 0 )	],
						[	pt( 0, 3.0 ),	pt( 0.25, 0.0 )	],
						[],
						[] )


		DefineRumble( "pilot_singleshot_strong_fire",
						[	pt( 0, 17.0 ),	pt( 0.14, 19.0 ),	pt( 0.27, 0 )	],
						[	pt( 0, 19.0 ),	pt( 0.27, 0.0 )	],
						[],
						[] )


		DefineRumble( "pilot_singleshot_verystrong_fire",
						[	pt( 0, 70.0 ),	pt( 0.15, 90.5 ),	pt( 0.5, 0 )	],
						[	pt( 0, 70.0 ),	pt( 0.5, 0.0 )	],
						[],
						[] )


		DefineRumble( "pilot_autoshot_weak_fire",
						[	pt( 0, 0.9 ),	pt( 0.11, 0.0 )	],
						[	pt( 0, 1.5 ),	pt( 0.11, 0.0 )	],
						[],
						[] )


		DefineRumble( "pilot_autoshot_mid_fire",
						[	pt( 0, 2.0 ),	pt( 0.13, 0.0 )	],
						[	pt( 0, 3.2 ),	pt( 0.13, 0.0 )	],
						[],
						[] )


		DefineRumble( "pilot_autoshot_strong_fire",
						[	pt( 0, 26.4 ),	pt( 0.35, 0.0 )	],
						[	pt( 0, 28.0 ),	pt( 0.35, 0.0 )	],
						[],
						[] )


		DefineRumble( "pilot_autoshot_verystrong_fire",
						[	pt( 0, 18.4 ),	pt( 0.2, 0.0 )	],
						[	pt( 0, 20.0 ),	pt( 0.2, 0.0 )	],
						[],
						[] )






		DefineRumble( "titan_40mm",
						[	pt( 0, 17.9 ),	pt( 0.2, 18.4 ),	pt( 0.48, 0 ) ],
						[	pt( 0, 18.5 ),	pt( 0.52, 0.0 ) ],
						[],
						[] )


		DefineRumble( "titan_arc_cannon",
						[	pt( 0, 4.8 ),	pt( 0.25, 14.5 ),	pt( 0.65, 0 ) ],
						[	pt( 0, 10.0 ),	pt( 0.65, 0.0 ) ],
						[],
						[] )


		DefineRumble( "titan_rocket_launcher",
						[	pt( 0, 118.4 ),	pt( 0.15, 140.7 ),	pt( 0.5, 0.0 ) ],
						[	pt( 0, 134.0 ),	pt( 0.5, 0.0 ) ],
						[],
						[] )


		DefineRumble( "titan_sniper",
						[	pt( 0, 14.5 ),	pt( 0.2, 18.5 ),	pt( 0.5, 0.0 ) ],
						[	pt( 0, 16.9 ),	pt( 0.5, 0.0 ) ],
						[],
						[] )


		DefineRumble( "titan_triple_threat",
						[	pt( 0, 20.4 ),	pt( 0.2, 30.7 ),	pt( 0.45, 0.0 ) ],
						[	pt( 0, 26.0 ),	pt( 0.45, 0.0 ) ],
						[],
						[] )


		DefineRumble( "titan_xo16",
						[	pt( 0, 10.4 ),	pt( 0.14, 0.0 ) ],
						[	pt( 0, 12.0 ),	pt( 0.14, 0.0 ) ],
						[],
						[] )
	}
	else
	{
		DefineRumble( "pilot_singleshot_weak_fire",
						[	pt( 0, 0.5 ),	pt( 0.05, 0.6 ),	pt( 0.1, 0 )	],
						[	pt( 0, 0.9 ),	pt( 0.1, 0.0 )	],
						[],
						[] )


		DefineRumble( "pilot_singleshot_mid_fire",
						[	pt( 0, 0.9 ),	pt( 0.06, 1.45 ),	pt( 0.125, 0 )	],
						[	pt( 0, 1.5 ),	pt( 0.125, 0.0 )	],
						[],
						[] )


		DefineRumble( "pilot_singleshot_strong_fire",
						[	pt( 0, 8.9 ),	pt( 0.07, 9.4 ),	pt( 0.135, 0 )	],
						[	pt( 0, 9.5 ),	pt( 0.135, 0.0 )	],
						[],
						[] )


		DefineRumble( "pilot_singleshot_verystrong_fire",
						[	pt( 0, 30.4 ),	pt( 0.075, 35.5 ),	pt( 0.35, 0 )	],
						[	pt( 0, 30.0 ),	pt( 0.35, 0.0 )	],
						[],
						[] )


		DefineRumble( "pilot_autoshot_weak_fire",
						[	pt( 0, 0.45 ),	pt( 0.055, 0.0 )	],
						[	pt( 0, 0.75 ),	pt( 0.055, 0.0 )	],
						[],
						[] )


		DefineRumble( "pilot_autoshot_mid_fire",
						[	pt( 0, 1.0 ),	pt( 0.065, 0.0 )	],
						[	pt( 0, 1.6 ),	pt( 0.065, 0.0 )	],
						[],
						[] )


		DefineRumble( "pilot_autoshot_strong_fire",
						[	pt( 0, 8.4 ),	pt( 0.25, 0.0 )	],
						[	pt( 0, 9.0 ),	pt( 0.25, 0.0 )	],
						[],
						[] )


		DefineRumble( "pilot_autoshot_verystrong_fire",
						[	pt( 0, 9.4 ),	pt( 0.1, 0.0 )	],
						[	pt( 0, 10.0 ),	pt( 0.1, 0.0 )	],
						[],
						[] )






		DefineRumble( "titan_40mm",
						[	pt( 0, 8.9 ),	pt( 0.1, 9.4 ),	pt( 0.26, 0 ) ],
						[	pt( 0, 9.5 ),	pt( 0.26, 0.0 ) ],
						[],
						[] )


		DefineRumble( "titan_arc_cannon",
						[	pt( 0, 2.4 ),	pt( 0.25, 38.5 ),	pt( 0.4, 0 ) ],
						[	pt( 0, 5.0 ),	pt( 0.4, 0.0 ) ],
						[],
						[] )


		DefineRumble( "titan_rocket_launcher",
						[	pt( 0, 59.4 ),	pt( 0.2, 69.7 ),	pt( 0.45, 0.0 ) ],
						[	pt( 0, 67.0 ),	pt( 0.45, 0.0 ) ],
						[],
						[] )


		DefineRumble( "titan_sniper",
						[	pt( 0, 7.5 ),	pt( 0.1, 9.5 ),	pt( 0.25, 0.0 ) ],
						[	pt( 0, 8.9 ),	pt( 0.25, 0.0 ) ],
						[],
						[] )


		DefineRumble( "titan_triple_threat",
						[	pt( 0, 10.4 ),	pt( 0.15, 15.7 ),	pt( 0.3, 0.0 ) ],
						[	pt( 0, 13.0 ),	pt( 0.3, 0.0 ) ],
						[],
						[] )


		DefineRumble( "titan_xo16",
						[	pt( 0, 5.4 ),	pt( 0.07, 0.0 ) ],
						[	pt( 0, 6.0 ),	pt( 0.07, 0.0 ) ],
						[],
						[] )

	}






	DefineRumble( "titansniper_charge_beat",
					[],
					[	pt( 0, 0.4 ),	pt( 0.25, 0.0 )	],
					[],
					[] )


	DefineRumble( "triplethreat_spin_beat",
					[],
					[	pt( 0, 0.4 ),	pt( 0.25, 0.0 )	],
					[],
					[] )






	DefineRumble( "titan_damaged_front",
					[	pt( 0.0, 1.0 ),	pt( 0.15, 1.0 ),	pt( 0.2, 0.0 )	],
					[	pt( 0.0, 1.0 ),	pt( 0.15, 1.0 ),	pt( 0.2, 0.0 )	],
					[],
					[] )

	DefineRumble( "titan_damaged_back",
					[	pt( 0.0, 0.5 ),	pt( 0.15, 0.5 ),	pt( 0.2, 0.0 )	],
					[	pt( 0.0, 0.5 ),	pt( 0.15, 0.5 ),	pt( 0.2, 0.0 )	],
					[],
					[] )

	DefineRumble( "titan_damaged_left",
					[	pt( 0.0, 0.8 ),	pt( 0.15, 0.8 ),	pt( 0.2, 0.0 )	],
					[	pt( 0.0, 0.6 ),	pt( 0.15, 0.6 ),	pt( 0.2, 0.0 )	],
					[],
					[] )

	DefineRumble( "titan_damaged_right",
					[	pt( 0.0, 0.6 ),	pt( 0.15, 0.6 ),	pt( 0.2, 0.0 )	],
					[	pt( 0.0, 1.0 ),	pt( 0.15, 1.0 ),	pt( 0.2, 0.0 )	],
					[],
					[] )




	DefineRumble( "titan_damaged_front_short",
					[	pt( 0.0, 1.0 ),	pt( 0.075, 1.0 ),	pt( 0.1, 0.0 )	],
					[	pt( 0.0, 1.0 ),	pt( 0.075, 1.0 ),	pt( 0.1, 0.0 )	],
					[],
					[] )

	DefineRumble( "titan_damaged_back_short",
					[	pt( 0.0, 0.5 ),	pt( 0.075, 0.5 ),	pt( 0.1, 0.0 )	],
					[	pt( 0.0, 0.5 ),	pt( 0.075, 0.5 ),	pt( 0.1, 0.0 )	],
					[],
					[] )

	DefineRumble( "titan_damaged_left_short",
					[	pt( 0.0, 0.8 ),	pt( 0.075, 0.8 ),	pt( 0.1, 0.0 )	],
					[	pt( 0.0, 0.6 ),	pt( 0.075, 0.6 ),	pt( 0.1, 0.0 )	],
					[],
					[] )

	DefineRumble( "titan_damaged_right_short",
					[	pt( 0.0, 0.6 ),	pt( 0.075, 0.6 ),	pt( 0.1, 0.0 )	],
					[	pt( 0.0, 1.0 ),	pt( 0.075, 1.0 ),	pt( 0.1, 0.0 )	],
					[],
					[] )




	DefineRumble( "titan_damaged_front_long",
					[	pt( 0.0, 1.0 ),	pt( 0.25, 1.0 ),	pt( 0.3, 0.0 )	],
					[	pt( 0.0, 1.0 ),	pt( 0.25, 1.0 ),	pt( 0.3, 0.0 )	],
					[],
					[] )

	DefineRumble( "titan_damaged_back_long",
					[	pt( 0.0, 0.5 ),	pt( 0.25, 0.5 ),	pt( 0.3, 0.0 )	],
					[	pt( 0.0, 0.5 ),	pt( 0.25, 0.5 ),	pt( 0.3, 0.0 )	],
					[],
					[] )

	DefineRumble( "titan_damaged_left_long",
					[	pt( 0.0, 0.8 ),	pt( 0.25, 0.8 ),	pt( 0.3, 0.0 )	],
					[	pt( 0.0, 0.6 ),	pt( 0.25, 0.6 ),	pt( 0.3, 0.0 )	],
					[],
					[] )

	DefineRumble( "titan_damaged_right_long",
					[	pt( 0.0, 0.6 ),	pt( 0.25, 0.6 ),	pt( 0.3, 0.0 )	],
					[	pt( 0.0, 1.0 ),	pt( 0.25, 1.0 ),	pt( 0.3, 0.0 )	],
					[],
					[] )


}

// Run the function defined above:
DefineRumbles()







