<cfscript>

	rollout = application.rollout;
	
	// If there are no defined features, let's just set them up. This way, we don't
	// have to worry about "key existence" in the rest of the demo.
	if ( ! arrayLen( rollout.getFeatureNames() ) ) {

		rollout.ensureFeature( "featureA" );
		rollout.ensureFeature( "featureB" );
		rollout.ensureFeature( "featureC" );

	}


	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //


	// Param our action variables.
	param name="url.action" type="string" default="";
	param name="url.featureName" type="string" default="";
	param name="url.percentage" type="numeric" default="0";
	param name="url.groupName" type="string" default="";
	param name="url.userIdentifier" type="string" default="";

	if ( url.action == "activateFeatureForPercentage" ) {

		rollout.activateFeatureForPercentage( url.featureName, url.percentage );

	} else if ( url.action == "activateFeatureForGroup" ) {

		rollout.activateFeatureForGroup( url.featureName, url.groupName );

	} else if ( url.action == "deactivateFeatureForGroup" ) {

		rollout.deactivateFeatureForGroup( url.featureName, url.groupName );

	} else if ( url.action == "activateFeatureForUser" ) {

		rollout.activateFeatureForUser( url.featureName, url.userIdentifier );

	} else if ( url.action == "deactivateFeatureForUser" ) {

		rollout.deactivateFeatureForUser( url.featureName, url.userIdentifier );

	}


	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //


	// Get the collection of feature names for our various loops.
	featureNames = rollout.getFeatureNames();

	arraySort( featureNames, "text", "asc" );

</cfscript>

<cfcontent type="text/html; charset=utf-8" />
<cfoutput>

	<!doctype html>
	<html>
	<head>
		<meta charset="utf-8" />

		<title>
			ColdFusion Rollout
		</title>

		<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Open+Sans:400,600,700" />
		<link rel="stylesheet" type="text/css" href="./demo.css" />
	</head>
	<body>

		<h1>
			ColdFusion Rollout
		</h1>

		<h2>
			Rollout Configuration
		</h2>

		<form>

			<cfset features = rollout.getFeatures() />

			<!---
				NOTE: We could have just looped over the "features" struct. But, I am 
				looping over the sorted keys for output consistency.
			--->
			<cfloop index="featureName" array="#featureNames#">

				<cfset feature = features[ featureName ] />
				
				<h3>
					#featureName#
				</h3>
				
				<ul>
					<li>
						<strong>Percentage</strong>:
						<a href="#cgi.script_name#?action=activateFeatureForPercentage&featureName=#featureName#&percentage=100">100%</a> -
						<a href="#cgi.script_name#?action=activateFeatureForPercentage&featureName=#featureName#&percentage=75">75%</a> -
						<a href="#cgi.script_name#?action=activateFeatureForPercentage&featureName=#featureName#&percentage=50">50%</a> -
						<a href="#cgi.script_name#?action=activateFeatureForPercentage&featureName=#featureName#&percentage=25">25%</a> -
						<a href="#cgi.script_name#?action=activateFeatureForPercentage&featureName=#featureName#&percentage=0">0%</a>
					</li>
					<li>
						<strong>Users</strong>: 

						[ 
							<cfloop index="userIdentifier" array="#feature.users#">
								
								<a href="#cgi.script_name#?action=deactivateFeatureForUser&featureName=#featureName#&userIdentifier=#userIdentifier#">#userIdentifier#</a>

							</cfloop>
						]
					</li>
					<li>
						<strong>Groups</strong>: 
						[ 
							<cfloop index="groupName" array="#feature.groups#">
								
								<a href="#cgi.script_name#?action=deactivateFeatureForGroup&featureName=#featureName#&groupName=#groupName#">#groupName#</a>

							</cfloop>
						]
						-
						<strong>Activate</strong>:
						<a href="#cgi.script_name#?action=activateFeatureForGroup&featureName=#featureName#&groupName=even">Even</a> -
						<a href="#cgi.script_name#?action=activateFeatureForGroup&featureName=#featureName#&groupName=odd">Odd</a> -
						<a href="#cgi.script_name#?action=activateFeatureForGroup&featureName=#featureName#&groupName=male">Male</a> -
						<a href="#cgi.script_name#?action=activateFeatureForGroup&featureName=#featureName#&groupName=female">Female</a>
					</li>
				</ul>

			</cfloop>

		</form>


		<h2>
			Users &amp; Their Feature States
		</h2>

		<table border="1" cellspacing="1" cellpadding="10">
		<thead>
			<tr>
				<th>
					ID
				</th>
				<th>
					Name
				</th>
				<th>
					Gender
				</th>
				<cfloop index="featureName" array="#featureNames#">

					<th>
						#featureName#
					</th>

				</cfloop>
			</tr>
		</thead>
		<tbody>
			<cfloop index="user" array="#application.users#">

				<!---
					Get the feature states for the given user. This returns a struct in 
					which the keys are feature names and the values are booleans that 
					indicate whether or not feature is available for that user. This is 
					the PRIMARY GESTURE for my version of rollout - the code is internally
					optimized for this bulk, up-front gathering of a single user's data.

					When you get the data for a user, you can OPTIONALLY provide a 
					collection of groups that the user is part of. The collection of groups
					can be an array (of group names) or a struct in which the keys are the
					group names and the values are boolean that indicate whether or not the
					user is a logical member of that group.
				--->
				<cfset features = rollout.getFeatureStatesForUser( 
					user.id,
					{
						even: ! ( user.id % 2 ),
						odd: ( user.id % 2 ),
						male: ( user.gender eq "M" ),
						female: ( user.gender eq "F" )
					}
				) />
				
				<tr>
					<td>
						#user.id#
					</td>
					<td>
						#user.name#
					</td>
					<td>
						#user.gender#
					</td>

					<cfloop index="featureName" array="#featureNames#">

						<td <cfif features[ featureName ]> class="active" </cfif> >
							<a href="#cgi.script_name#?action=activateFeatureForUser&featureName=#featureName#&userIdentifier=#user.id#">#featureName#</a>
						</td>
						
					</cfloop>
				</tr>

			</cfloop>
		</tbody>
		</table>

	</body>
	</html>

</cfoutput>
