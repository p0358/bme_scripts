//=========================================================
//	_init
//  Called on newgame or transitions, AFTER entities have been created and initialized
//=========================================================
	printl( "Code Script: _init" )

	// prevent save/load code from running global scripts again
	Assert ( !("_initialized" in getroottable()) )
	_initialized <- true

	// allow script to do overrides before global scripts are run
	if ( "GlobalsWillLoad" in getroottable() )
		GlobalsWillLoad()

	// New global includes go here

	// End new global includes

	foreach( callback in _PostEntityLoadCallbacks )
	{
		thread callback()
	}

	if ( "GlobalsDidLoad" in getroottable() )
		GlobalsDidLoad()

	FlagSet( "EntitiesDidLoad" )

	if ( "EntitiesDidLoad" in getroottable() )
		thread EntitiesDidLoad()

	RunFunctionInAllFileScopes( "EntitiesDidLoad" )

	local exfilPanels = GetEntArrayByClass_Expensive( "prop_exfil_panel" )
	foreach ( panel in exfilPanels )
		panel.Destroy()

	// regexp unit tests
	Assert( regexp( "^foo.*bar$" ).match( "foobar" ) )
	Assert( !regexp( "^foo.+bar$" ).match( "foobar" ) )
	Assert( regexp( "^foo.*bar$" ).match( "fooxbar" ) )
	Assert( regexp( "^foo.+bar$" ).match( "fooxbar" ) )
	Assert( regexp( "^foo.*$" ).match( "foo" ) )
	Assert( !regexp( "^foo.+$" ).match( "foo" ) )
	Assert( regexp( "^foo.*$" ).match( "foon" ) )
	Assert( regexp( "^foo.+$" ).match( "foon" ) )