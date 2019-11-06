<cfset loggedInUserName = Session.userFullName>
<cfset defaultThemeStruct = {}>
<cfset defaultThemeStruct = {fileLoc='css/statusPanelTheme.css', mediaType='screen'}>
<cfset cssLoadFiles = ArrayNew(1)>
<cfset cssLoadFiles[1] = defaultThemeStruct>
<cfset loadJavaScriptStruct = {}>
<cfset loadJavaScriptStruct = {fileloc='js/script.js'}>
<cfset jsLoadFiles = ArrayNew(1)>
<cfset jsLoadFiles[1] = loadJavaScriptStruct>
<cfset pageHeader = "NetOps Helpdesk Monitor">
<cfset pageTitle = "NetOps Helpdesk">
<cfset recentAppURL = Application.serviceURL & "applications.cfm">
<cfset testScoreURL = Application.serviceURL & "testScores.cfm">
<cfset CPRListenerURL = Application.serviceURL & "cprListener.cfm">
<cfset unsentMailURL = Application.serviceURL & "unsentMail.cfm">
<cfset sarSyncURL = Application.serviceURL & "sarSync.cfm">
<cfset publisherURL = Application.serviceURL & "publisher.cfm"> 
<cfset codesetURL = Application.serviceURL & "codesets.cfm">
<cfset gpmsLPURL = Application.serviceURL & "gpmsLP.cfm">
<cfinclude template="/includes/bootstrapheaderfooter/header.cfm">
<cfoutput>
<meta http-equiv="refresh" content="300">
<cfif isDefined("form.resetBtn") AND CSRFverifyToken(form.token)>  
	<cfoutput>
		<cfquery name="unsentMailUpdate" datasource="#Application.ds_information#">
			UPDATE statusPanelConfig
     		SET configValue = CONVERT( VARCHAR(255), GETDATE(), 120 )
   			WHERE configName IN ( 'SQLMailResetDateTime', 'CFMailResetDateTime' );
		</cfquery>
	</cfoutput>
</cfif>
<section class="content">
	<div class="container">
		<div class="row">
<!--- -----------------------------------------------Network Operations Status Portal Panel---------------------------------------------------------- --->
			<div class="col-md-4">
				<div class="panel panel-default" id="statusBanner">
					<div class="panel-heading">
						<h4 class="panel-title">Network Operations Status Portal</h4>
					</div>
					<table class="table">
						<tbody>
							<tr>
								<td class="noBreak">
									<b>Date/Time</b> 
									#EncodeForHTML( DateFormat( Now(), "mm-dd-yyyy" ) )#
									#EncodeForHTML( TimeFormat( Now(), "h:nn tt" ) )#	
								</td>
							</tr>
						</tbody>
					</table>
				</div>
<!--- -----------------------------------------------Applications Started in Past 24 Hours Panel---------------------------------------------------------- --->
				<div class="panel panel-default">
					<div class="panel-heading">
						<h4 class="panel-title">
							Applications Completed
							<p class="floRight">
								<a data-toggle="tooltip" data-placement="bottom" title="This panel shows the number of Graduate School applications started in the past 24 hours as well as the date/time of the most recently started Graduate School application."><i class="fas fa-info-circle"></i></a>
							</p>
						</h4>
					</div>  
					<table class="table table-bordered">
						<tbody>
							<cfhttp url="#recentAppURL#" method="GET" result="response">
            					<cfhttpparam type="header" name="Content-Type" value="application/x-www-form-urlencoded">
            					<cfhttpparam type="header" name="Accept" value="application/json">
        					</cfhttp>    
							<cfset appStats = DeserializeJSON( response.fileContent )>
							<tr>
								<th class="center" scope="col">In the Past 24 Hours</th>	
								<th class="center" scope="col">In the Past 3 Days</th>
								
							</tr>
							<tr>
								<td>   		
									<h3 class="center">#EncodeForHTML( appStats.data[1].APPSINPAST24Hours )#</h3> 
								</td>
								<td>
									<h3 class="center">#EncodeForHTML( appStats.data[1].APPSINPAST72Hours )#</h3>
								</td>	
							</tr>
							<tr> 
								<td colspan="2">
									<b>Most Recently Started</b>
									<div class="floRight">
										#EncodeForHTML( DateFormat( appStats.data[1].APPLASTSTARTEDDATETIME, "mm-dd-yyyy" ) )#
										#EncodeForHTML( TimeFormat( appStats.data[1].APPLASTSTARTEDDATETIME, "h:nn tt" ) )#
									</div>
								</td>
							</tr>
						</tbody>
					</table>
				</div>				
<!--- -----------------------------------------------Unsent Mail Panel---------------------------------------------------------- --->
				<div class="panel panel-default">
					<div class="panel-heading">
						<h4 class="panel-title">
							Unsent Mail
							<p class="floRight">
								<a data-toggle="tooltip" data-placement="bottom" title="This panel shows the count of unsent mail items in both the SQL Server and the ColdFusion Administrative web console.  Clicking the 'Reset Mail Counts' button will reset the count back to zero and should be clicked after any unsent mail is handled."><i class="fas fa-info-circle"></i></a>
							</p>
						</h3>
					</div>
					<table class="table">
						<tbody>
							<cfhttp url="#unsentMailURL#" method="GET" result="response">
            					<cfhttpparam type="header" name="Content-Type" value="application/x-www-form-urlencoded">
            					<cfhttpparam type="header" name="Accept" value="application/json">
        					</cfhttp>
							<cfset appStats = DeserializeJSON( response.fileContent )>
							<cfset unsentSQLMail = appStats.data[1].UNSENTSQLMAIL>
							<cfset unsentCFMail = appStats.data[1].UNSENTCFMAIL>
							<cfif #unsentSQLMail# GTE 5>
								<cfset classSet = "danger">
							<cfelseif #unsentSQLMail# GTE 2>
								<cfset classSet = "warning">
							<cfelse>
								<cfset classSet = "">
							</cfif>
							<tr class = #classSet#>
								<th>SQL Server</th>
								<td class="center">#EncodeForHTML( appStats.data[1].UNSENTSQLMAIL )#</td>
							</tr>		
							<cfif #unsentCFMail# GTE 5>
								<cfset classSet = "danger">
							<cfelseif #unsentCFMail# GTE 2>
								<cfset classSet = "warning">
							<cfelse>
								<cfset classSet = "">
							</cfif>
							<tr class = #classSet#>					 
								<th>ColdFusion</th>
								<td class="center">#EncodeForHTML( appStats.data[1].UNSENTCFMAIL )#</td>
							</tr>					
						</tbody>
					</table>		
					<cfform method="post" name="secureName">
						<input name="token" type="hidden" value="#CSRFGenerateToken()#" />
    					<button name="resetBtn" type="submit" class="btn btn-primary btn-block">
							Reset Mail Counts 
						</button>			
					</cfform>							
				</div>		
<!--- -----------------------------------------------GPMS/LP Interface---------------------------------------------------------- --->
				<div class="panel panel-default" id="statusBanner">
					<div class="panel-heading">
						<h4 class="panel-title">
							GPMS/LP Interface
							<p class="floRight">
								<a data-toggle="tooltip" data-placement="bottom" title="This panel shows the number of failed GPMS/LionPATH interface calls that have not been corrected as well as the date/time of the most recently successful GPMS/LionPATH service call."><i class="fas fa-info-circle"></i></a>
							</p>
						</h4>
					</div> 
					<table class="table">
						<tbody>
							<cfhttp url="#gpmsLPURL#" method="GET" result="response">
            					<cfhttpparam type="header" name="Content-Type" value="application/x-www-form-urlencoded">
            					<cfhttpparam type="header" name="Accept" value="application/json">
        					</cfhttp>
							<cfset appStats = DeserializeJSON( response.fileContent )>
							<cfset failCount = appStats.data[1].GPMSLPSERVICEFAILCOUNT>
							<cfif failCount GT 0>
								<cfset classSet = "danger">
							<cfelse>
								<cfset classSet = "">
							</cfif>
							<tr class = #classSet#>
								<th>Service Fail Count</th>
								<td class="center">#EncodeForHTML( appStats.data[1].GPMSLPSERVICEFAILCOUNT )#</td>
							</tr>
							<cfset recentDate = appStats.data[1].MOSTRECENTGPMSLPPROCESSED>
							<cfif DateDiff( "d", #recentDate#, Now() ) GTE 4>
								<cfset classSet="danger">
							<cfelseif DateDiff( "d", #recentDate#, Now() ) GTE 3>
								<cfset classSet="warning">
							</cfif>
							<tr class = #classSet#>
								<th>Most Recent Proccessed</th>
									<td class="noBreak">
										#EncodeForHTML( DateFormat( appStats.data[1].MOSTRECENTGPMSLPPROCESSED, "mm-dd-yyyy" ) )#
										#EncodeForHTML( TimeFormat( appStats.data[1].MOSTRECENTGPMSLPPROCESSED, "h:nn tt" ) )#	
									</td>
								</th>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
			<div class="col-md-4"> 
<!--- ----------------------------------------------- Recently Loaded Test Scores Panel---------------------------------------------------------- --->
				<div class="panel panel-default" id="statusBanner">
					<div class="panel-heading">
						<h4 class="panel-title">
							Recently Loaded Test Scores 
							<p class="floRight">
								<a data-toggle="tooltip" data-placement="bottom" title="This panel shows the most recent date that OFFICIAL test scores have been received for each test type."><i class="fas fa-info-circle"></i></a>
							</p>
						</h3>
					</div>
					<table class="table">
						<tbody>
							<cfhttp url="#testScoreURL#" method="GET" result="response">
            					<cfhttpparam type="header" name="Content-Type" value="application/x-www-form-urlencoded">
            					<cfhttpparam type="header" name="Accept" value="application/json">
        					</cfhttp>
							<cfset appStats = DeserializeJSON( response.fileContent )> 
							<cfloop index="i" from="0" to="4" >
								<cfswitch expression = #i#>
									<cfcase value = 0> 
										<cfset testScore=appStats.data[1].GMAT> 
										<cfset testTitle="GMAT"> 
										<cfset warningLimit = 6>
										<cfset dangerLimit = 7>
									</cfcase>
									<cfcase value = 1> 
										<cfset testScore=appStats.data[1].GRE> 
										<cfset testTitle="GRE"> 
										<cfset warningLimit = 6>
										<cfset dangerLimit = 7>
									</cfcase>
									<cfcase value = 2> 
										<cfset testScore=appStats.data[1].IELTS> 
										<cfset testTitle="IELTS"> 
										<cfset warningLimit = 14>
										<cfset dangerLimit = 21>
									</cfcase>
									<cfcase value = 3> 
										<cfset testScore=appStats.data[1].MAT> 
										<cfset testTitle="MAT"> 
										<cfset warningLimit = 6>
										<cfset dangerLimit = 7>
									</cfcase>
									<cfcase value = 4>  
										<cfset testScore=appStats.data[1].TOEFL> 
										<cfset testTitle="TOEFL"> 
										<cfset warningLimit = 6>
										<cfset dangerLimit = 7>
									</cfcase>
								</cfswitch>
								<cfif DateDiff( "d", #testScore#, Now() ) GTE #dangerLimit#>
									<cfset classSet="danger">
								<cfelseif DateDiff( "d", #testScore#, Now() ) EQ #warningLimit#>
									<cfset classSet="warning">
								<cfelse>
									<cfset classSet="">
								</cfif>	
								<tr class = #classSet#>
									<th>#testTitle#</th>
									<td class="noBreak">
										#EncodeForHTML( DateFormat(testScore, "mm-dd-yyyy" ) )#
									</td>
								</tr>
							</cfloop>
						</tbody>
					</table>
				</div>
<!--- ----------------------------------------------Pushes to Production--------------------------------------------------------- --->
				<div class="panel panel-default">
					<div class="panel-heading">
						<h4 class="panel-title">
							Pushes to Production 
							<p class="floRight">
								<a data-toggle="tooltip" data-placement="bottom" title="This panel shows the number of times that code has been pushed to production and logged by Network Operations staff.  It also displays the date/time of the most recent code push to production."><i class="fas fa-info-circle"></i></a>
							</p>
						</h4>
					</div>
					<table class="table">   
						<tbody>
							<cfhttp url="#publisherURL#" method="GET" result="response">
            					<cfhttpparam type="header" name="Content-Type" value="application/x-www-form-urlencoded">
            					<cfhttpparam type="header" name="Accept" value="application/json">
        					</cfhttp>
							<cfset appStats = DeserializeJSON( response.fileContent )> 
							<cfset publisherVarDate=appStats.data[1].LASTPUBLISHEDDATE>
							<cfif DateDiff( "ww", #publisherVarDate#, Now() ) GTE 1>
								<cfset classSet="danger">
							<cfelseif DateDiff( "d", #publisherVarDate#, Now() ) EQ 5>
								<cfset classSet="warning">
							<cfelse>
								<cfset classSet="">
							</cfif>	
							<tr>
								<th>Number of Publishes</th>
								<td class="center">#EncodeForHTML(appStats.data[1].PUBLISHERCOUNT)#</td>
							</tr>
							<tr class=#classSet#>
								<th>Most Recent Publish</th>
								<td>
									#EncodeForHTML( DateFormat( publisherVarDate, "mm-dd-yyyy" ) )#
									#EncodeForHTML( TimeFormat( publisherVarDate, "h:nn tt" ) )#
								</td> 
							</tr>		
						</tbody>
					</table>
				</div>
<!--- -----------------------------------------------CPR Listener Panel---------------------------------------------------------- --->
				<div class="panel panel-default" id="statusBanner">
					<div class="panel-heading">
						<h4 class="panel-title">
							CPR Listener 
							<p class="floRight">
								<a data-toggle="tooltip" data-placement="bottom" title="This panel shows information about notifications from the Central Person Repository (CPR).  The 'Most Recent Record' displays the date/time of the most recently received CPR notification picked up by the CPR Listener and the 'Last Processing Time' displays the date/time that the CPR Parser website was last loaded."><i class="fas fa-info-circle"></i></a>
							</p>
						</h4>
					</div>
					<table class="table">
						<tbody>
							<cfhttp url="#CPRListenerURL#" method="GET" result="response">
            					<cfhttpparam type="header" name="Content-Type" value="application/x-www-form-urlencoded">
            					<cfhttpparam type="header" name="Accept" value="application/json">
        					</cfhttp>
							<cfset appStats = DeserializeJSON( response.fileContent )> 
							<cfloop index="i" from="0" to="1" >
								<cfswitch expression = #i#>
									<cfcase value = 0> 
										<cfset cprVar = appStats.data[1].MOSTRECENTRECEIVED> 
										<cfset cprTitle="Most Recent Record"> 
										<cfset dangerLimit=1> 
										<cfset warningLimit=50> 
									</cfcase>
									<cfcase value = 1> 
										<cfset cprVar = appStats.data[1].MOSTRECENTPROCESSED>
										<cfset cprTitle = "Last Processing Time"> 
										<cfset dangerLimit=0.5> 
										<cfset warningLimit=20> 
									</cfcase>
								</cfswitch>				
								<cfif DateDiff( "h", #cprVar#, Now() ) GTE #dangerLimit#>
									<cfset classSet="danger">
								<cfelseif DateDiff( "n", #cprVar#, Now() ) GTE #warningLimit#>
									<cfset classSet="warning">
								<cfelse>
									<cfset classSet="">
								</cfif>									
								<tr class = #classSet#>
									<th>#cprTitle#</th>
									<td class="noBreak">
										#EncodeForHTML( DateFormat(cprVar, "mm-dd-yyyy" ) )#
										#EncodeForHTML( TimeFormat(cprVar, "h:nn tt" ) )#
									</td>
								</tr>				
							</cfloop>
							<cfset cprVar = appStats.data[1].UNPROCESSEDRECORDS>
							<cfif cprVar GTE 50>
								<cfset classSet="danger">
							<cfelseif cprVar GTE 25>
								<cfset classSet="warning">
							<cfelse>
								<cfset classSet="">
							</cfif>
							<tr class = #classSet#>
								<th>Unprocessed Records</th>
								<td class="center"> #EncodeForHTML( cprVar )#</td>
							</tr>
						</tbody>
					</table>
				</div>
<!--- ---------------------------------------------------------SAR Sync-------------------------------------------------------- --->
				<div class="panel panel-default">
					<div class="panel-heading">
						<h4 class="panel-title">
							SAR Sync 
							<p class="floRight">
								<a data-toggle="tooltip" data-placement="bottom" title="This panel shows the date/time that the hourly SAR Sync with LionPATH was last run."><i class="fas fa-info-circle"></i></a>
							</p>
						</h4>
					</div>
					<table class="table">
						<tbody>
							<cfhttp url="#sarSyncURL#" method="GET" result="response">
            					<cfhttpparam type="header" name="Content-Type" value="application/x-www-form-urlencoded">
            					<cfhttpparam type="header" name="Accept" value="application/json">
        					</cfhttp>    
							<cfset appStats = DeserializeJSON( response.fileContent )>
							<cfset sarVar = appStats.data[1].MOSTRECENTSYNC>
							<cfif DateDiff( "h", sarVar, Now() ) GTE 2>
								<cfset classSet="danger">
							<cfelseif DateDiff( "h", sarVar, Now() ) GTE 1>
								<cfset classSet="warning">
							<cfelse>
								<cfset classSet="">
							</cfif>
							<tr class=#classSet#>
								<th>Most Recent Sync</th>
								<td class="noBreak">   
									#EncodeForHTML( DateFormat(sarVar, "mm-dd-yyyy" ) )#
									#EncodeForHTML( TimeFormat(sarVar, "h:nn tt" ) )#
								</td>
							</tr>
						</tbody>
					</table>
				</div>
<!--- ---------------------------------------------------------Codeset Data-------------------------------------------------------- --->
				<div class="panel panel-default">
					<div class="panel-heading">
						<h4 class="panel-title">
							Codeset Data 
							<p class="floRight">
								<a data-toggle="tooltip" data-placement="bottom" title="This panel shows the most recent date that codesets were imported from LionPATH."><i class="fas fa-info-circle"></i></a>
							</p>			
						</h4>
					</div>
					<table class="table"> 
						<tbody>
					    	<cfhttp url="#codesetURL#" method="GET" result="response">
            					<cfhttpparam type="header" name="Content-Type" value="application/x-www-form-urlencoded">
            					<cfhttpparam type="header" name="Accept" value="application/json">
        					</cfhttp>    
							<cfset appStats = DeserializeJSON( response.fileContent )> 
							<cfset enrollmentDate = appStats.data[1].ENROLLMENTSUPDATED>
							<cfset importedDate = appStats.data[1].LASTCODESETIMPORT>
							<cfset consistencyCheck = appStats.data[1].CONSISTENCYCHECK>
							<cfif DateDiff( "d", enrollmentDate, Now() ) GTE 3> 
								<cfset classSet="danger">
							<cfelseif DateDiff( "d", enrollmentDate, Now() ) GTE 2>
								<cfset classSet="warning">
							<cfelse>
								<cfset classSet="">
							</cfif> 
							<tr class=#classSet#>
								<th>Most Recent Enrollment Data</th>
								<td class="noBreak">   
									#EncodeForHTML( DateFormat( enrollmentDate, "mm-dd-yyyy" ) )#
								</td>
							</tr> 
							<cfif DateDiff( "h", importedDate, Now() ) GTE 48> 
								<cfset classSet="danger">
							<cfelseif DateDiff( "h", importedDate, Now() ) GTE 24>
								<cfset classSet="warning">
							<cfelse>
								<cfset classSet="">
							</cfif>
							<tr class=#classSet#>
								<th>Last Codeset Import</th>
								<td class="noBreak"> 
									#EncodeForHTML( DateFormat( importedDate, "mm-dd-yyyy" ) )#
								</td>
							</tr> 
							<cfif consistencyCheck EQ "true">
								<cfset csStatus = "No Issues">
								<cfset errorMsg = "false">
								<cfset classSet = "">
							<cfelse>
								<cfset csStatus = "Failed">
								<cfset errorMsg = "true">
								<cfset classSet = "danger">
							</cfif>
							
							<tr class=#classSet#>
								<th>Codeset Consistency</th>
								<td>#csStatus#</td>
								<cfif errorMsg EQ "false">
									<tr>
										<th class="noBorderTop floRight">Error Message: </th>
										<td class="noBorderTop">
										<cfset counter = 1>
										<cfset consistencyError = appStats.data[1].CONSISTENCYERROR>
											<cfloop condition = "consistencyError neq null">
												<cfset consistencyError = appStats.data[counter].CONSISTENCYERROR>
												#consistencyError#
												<cfset counter = counter + 1>
											</cfloop>
										</td>
									</tr>
								</cfif>
							</tr>
						</tbody>
					</table>
				</div>
<!--- --------------------------------------------------------- Links -------------------------------------------------------- --->
				<div class="panel panel-default">
					<div class="panel-heading">
						<h4 class="panel-title">
							Links
							<p class="floRight">
								<a data-toggle="tooltip" data-placement="bottom" title="INSERT TOOLTIP HERE"><i class="fas fa-info-circle"></i></a>
							</p>
						</h4>
					</div>
					<table class="table">
						<tbody>
							<tr>
								<td class="center">
									<a href="https://wikispaces.psu.edu/display/gradschool/Network+Operations">NetOps Wiki</a>
								</td>
							</tr>
							<tr>
								<td class="center">
									<a href="https://pennstate.service-now.com/sp?id=services_status">PSU IT Alerts</a>
								</td>
							</tr>
							<tr>
								<td class="center">
									<a href="http://128.118.137.35:8088/fusionreactor/findex.htm?p=home">Fusion Reactor</a>
								</td>
							</tr>
							<tr>
								<td class="center">
									<a href="https://servicedesk.css.psu.edu/secure/Dashboard.jspa">Jira</a>
								</td>
							</tr>											
						</tbody>
					</table>									
				</div>
			</div>							
		</div>
	</div>
</section>
<cfinclude template="/includes/bootstrapheaderfooter/footer.cfm">
</cfoutput>
