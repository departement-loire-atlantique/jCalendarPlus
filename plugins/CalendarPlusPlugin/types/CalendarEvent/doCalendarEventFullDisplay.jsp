<%@ page contentType="text/html; charset=UTF-8" %><%
%><%--
  @Summary: CalendarEvent display page
  @Category: Generated
  @Author: JCMS Type Processor
  @Customizable: True 
  @Requestable: True
--%><%
// IMPORTANT : this page VOLUNTARILY does not perform any CSRF checks because action can be done from external site (from outlook for example).
%><%@ include file='/jcore/doInitPage.jspf' %><%
%><%@page import="generated.*"%><%
%><%@page import="com.jalios.jcmsplugin.calendar.*"%><%
%><%@page import="com.jalios.jcmsplugin.calendar.external.ExternalCalendarEvent"%><%
%><%@page import="com.jalios.jcms.calendar.*"%><%
%><%@page import="com.jalios.util.Util"%><%
%><%@page import="com.jalios.jcmsplugin.calendar.CalendarConstants"%><%
%><%@page import="com.jalios.jcmsplugin.googlemaps.GoogleMapsManager"%><%
%><% CalendarEventInterface obj = (CalendarEventInterface)request.getAttribute(PortalManager.PORTAL_PUBLICATION);
long eventStartDateValue = getLongParameter("eventStartDate", 0); 
if(eventStartDateValue != 0 && CalendarUtil.isPeriodicEvent(obj)){
  Date eventStartDate = new Date(eventStartDateValue);
  eventStartDate = CalendarUtil.getDayStartDate(eventStartDate);
  Interval interval = new Interval(eventStartDate, CalendarUtil.roundDateToDayEnd(eventStartDate), null);
  if(!interval.overlapWith(new Interval(obj.getStartDate(), obj.getEndDate(), null ))){
    obj = CalendarUtil.getNextPeriodicalEvent(obj,eventStartDate );  
  }  
}
if(obj == null){
  obj = (CalendarEventInterface)request.getAttribute(PortalManager.PORTAL_PUBLICATION);
}
CalendarEventInterface parentCalendarEvent = obj;
if(((Data)obj).getId() == null){
  parentCalendarEvent = (CalendarEventInterface) ((Data)obj).getExtraInfo(CalendarUtil.PERIODIC_PARENT);
}

jcmsContext.addCSSHeader("plugins/CalendarPlugin/css/calendarEventFullDisplay.css");
jcmsContext.addJavaScript("plugins/CalendarPlugin/js/portletCalendar.js");

boolean isDataWriteEnabled = channel.isDataWriteEnabled();
boolean isExternalEvent = obj instanceof ExternalCalendarEvent || !(obj instanceof CalendarEvent);

boolean isDirectAttendee = (loggedMember ==null || obj.getAttendingMemberSet() == null) ?false : obj.getAttendingMemberSet().contains(loggedMember);

String action = CalendarUtil.getAcceptAction(request);
if(action != null && loggedMember == null){
  sendForbidden(request, response);
}
//manage participate action
CalendarUtil.manageAction(request, obj, loggedMember, isDirectAttendee, action);

obj.updateAllAttendingMembersSet();

Set<Member> attendeesSet = obj.getAllAttendingMembersSet();
boolean isAttendee = loggedMember !=null ? (Util.notEmpty(attendeesSet) && attendeesSet.contains(loggedMember)) :false;
//if action have add/remove logguedMember from attendees
if(isAttendee){
  isDirectAttendee = obj.getAttendingMemberSet().contains(loggedMember);
}
boolean canEdit = isLogged && loggedMember.canWorkOn((Publication)obj) && !isExternalEvent;
boolean isCategories = (obj instanceof CalendarEvent) &&  Util.notEmpty(((CalendarEvent)obj).getCategories());

Set<Member> acceptedSet = CalendarUtil.getAcceptedAttendees(parentCalendarEvent, false);
Set<Member> declinedSet = CalendarUtil.getDeclinedAttendees(parentCalendarEvent, false);
Set<Member> pendingSet = CalendarUtil.getPendingAttendees(parentCalendarEvent, false);
Set<Member> contactSet = CalendarUtil.getContactAttendees(parentCalendarEvent);
boolean isAcceptedOrDeclined = Util.notEmpty(acceptedSet) || Util.notEmpty(declinedSet);

DateFormat dayFormat = new SimpleDateFormat(glp("jcmsplugin.calendar.day-format"),userLocale);
DateFormat hourFormat = new SimpleDateFormat(glp("jcmsplugin.calendar.time-format"),userLocale);
Date startDate = obj.getStartDate();
Date endDate = obj.getEndDate();      
boolean isPeriodicalEvent = CalendarUtil.isPeriodicEvent(obj);
boolean oldEvent = (!isPeriodicalEvent) &&  startDate!= null && startDate.getTime() < System.currentTimeMillis();
oldEvent &= endDate!= null && endDate.getTime() < System.currentTimeMillis();

CalendarContext calendarContext = new CalendarContext(obj);
calendarContext.setExternalEvent(isExternalEvent);
calendarContext.setDirectAttendee(isDirectAttendee);
calendarContext.setAttendee(isAttendee);
calendarContext.setCanEdit(canEdit);
calendarContext.setCategories(isCategories);
calendarContext.setAcceptedOrDeclined(isAcceptedOrDeclined);
calendarContext.setPeriodicalEvent(isPeriodicalEvent);
calendarContext.setOldEvent(oldEvent);
calendarContext.setAcceptedAttendees(acceptedSet);
calendarContext.setDeclinedAttendees(declinedSet);
calendarContext.setPendingAttendees(pendingSet);
calendarContext.setContactAttendees(contactSet);
calendarContext.hideResources(Util.isEmpty(channel.getAllPublicationSet(EventResource.class, loggedMember)) || !CalendarUtil.isFieldDisplayed(obj.getClass(),"resources"));

calendarContext.hideMap(Util.isEmpty(obj.getLocation()) || channel.getBooleanProperty("jcmsplugin.calendar.hideDefaultMap", false));
// Keep the calendar context in the request
request.setAttribute(CalendarConstants.CALENDAR_CONTEXT, calendarContext);

String evtId = ((Data)obj).getId();
if(Util.isEmpty(evtId)){
  Data tmpParentCalendarEvent = (Data) ((Data)obj).getExtraInfo(CalendarUtil.PERIODIC_PARENT);
  evtId = tmpParentCalendarEvent == null ? null : tmpParentCalendarEvent.getId();
}

//Ajout DEP44 Indique si la publication à une position géolocalisée
boolean isPubGeo =  Util.notEmpty(GoogleMapsManager.getGeolocation((Data)obj));
%><%
%><%@ include file='/front/doFullDisplay.jspf' %> 

<jalios:include target="CALENDAREVENT_FULLDISPLAY_BEFORE" />

<div class=" ajax-refresh-div full-display CalendarEvent" data-jalios-calendar-id="<%= encodeForHTMLAttribute(evtId)%>" data-jalios-calendar-currentDate="<%=encodeForHTMLAttribute(Long.toString(eventStartDateValue))%>">
	<%-- HEADER --%>
  <jalios:include target="CALENDAREVENT_FULLDISPLAY_HEADER_BEFORE" />
  <% if(!calendarContext.isHiddenHeader()) { %>
  <%@ include file='/plugins/CalendarPlugin/jsp/fulldisplay/doCalendarEventFullDisplayHeader.jspf' %>
  <% } %>
  <jalios:include target="CALENDAREVENT_FULLDISPLAY_HEADER_AFTER" />
  
  <div class="row">
    <div class="col-md-8">
		  <%-- UPPER BLOCK --%>
		  <jalios:include target="CALENDAREVENT_FULLDISPLAY_DATE_BEFORE" />
			<% if(!calendarContext.isHiddenDate()) { %>
		  <%@ include file='/plugins/CalendarPlugin/jsp/fulldisplay/doCalendarEventFullDisplayUpper.jspf' %>
		  <% } %>
		  <jalios:include target="CALENDAREVENT_FULLDISPLAY_DATE_AFTER" />
		  
		  <%-- INFORMATION --%>
		  <%-- DEP 44 : affiche la description si elle n'est pas vide --%>  
		  <jalios:include target="CALENDAREVENT_FULLDISPLAY_INFOS_BEFORE" />
		  <% if(!calendarContext.isHiddenInfos() && Util.notEmpty(obj.getDescription(userLang))) { %>
		  <% //if(!calendarContext.isHiddenInfos()) { %>
			<%@ include file='/plugins/CalendarPlugin/jsp/fulldisplay/doCalendarEventFullDisplayInfos.jspf' %>
		  <% } %>
		  <jalios:include target="CALENDAREVENT_FULLDISPLAY_INFOS_AFTER" />
		  
		  <% if(!isExternalEvent) { %>
         <%-- ATTENDEES --%>
         <%-- DEP 44 : affiche le bloc "Participants" si le Set n'est pas vide  --%>
        <jalios:include target="CALENDAREVENT_FULLDISPLAY_ATTENDEES_BEFORE" />
        <% //if(!calendarContext.isHiddenAttendees()) { %>
        <% if(!calendarContext.isHiddenAttendees() && Util.getSize(obj.getAllAttendingMembersSet()) != 0) { %>
	        <%@ include file='/plugins/CalendarPlugin/jsp/fulldisplay/doCalendarEventFullDisplayAttendees.jspf' %>
	    <% } %>
        <jalios:include target="CALENDAREVENT_FULLDISPLAY_ATTENDEES_AFTER" />
      <%} %>  
    </div>
    <div class="col-md-4">
      <jalios:include target="CALENDAREVENT_FULLDISPLAY_RIGHT_BEFORE" />
      <% if(!calendarContext.isHiddenMap() && isPubGeo) { %>
      
        <jalios:include target="CALENDAREVENT_FULLDISPLAY_MAP_BEFORE" />
        		
			<%--Inclusion de la carte --%>
            <% request.setAttribute("gMapsType", "small"); %>
            <%@ include file="/plugins/GoogleMapsPlusPlugin/jsp/doGoogleMapsPublication.jspf" %>   						
			
		<jalios:include target="CALENDAREVENT_FULLDISPLAY_MAP_AFTER" />
        
        
      <% } %>
		  <% if(!isExternalEvent) { %>
		    <%-- RESOURCES & DOCS --%>
		    <% if(!calendarContext.isHiddenResourcesAndDocs()) { %>
		    
		    <%
		    // 0010818: [AGENDA] - Portlet Documents 
		    // Si il n'y a pas de documents, le portlet documents ne doit pas apparaître. (si pas de droits)
		    boolean canWorkOnEvent = loggedMember != null ? (loggedMember.canWorkOn((Publication)obj) && channel.isDataWriteEnabled()): false;
		    
		    Set<Data> documentEnventSet = new HashSet();
		    if(obj.getDocuments() != null){
		        documentEnventSet.addAll(Arrays.asList(obj.getDocuments()));
		        documentEnventSet = (Set<Data>) JcmsUtil.applyDataSelector(documentEnventSet, Publication.getAuthorizedSelector(loggedMember)); 
		    }		    
		    %>
		      <jalios:if predicate="<%= canWorkOnEvent || Util.notEmpty(documentEnventSet) %>">
		          <%@ include file='/plugins/CalendarPlugin/jsp/fulldisplay/doCalendarEventFullDisplayResourcesAndDocs.jspf' %>
		      </jalios:if>
		    <% } %>
		  <% } %>
      <jalios:include target="CALENDAREVENT_FULLDISPLAY_RIGHT_AFTER" />
    </div>
  </div>
</div>
<jalios:include target="CALENDAREVENT_FULLDISPLAY_AFTER" />


