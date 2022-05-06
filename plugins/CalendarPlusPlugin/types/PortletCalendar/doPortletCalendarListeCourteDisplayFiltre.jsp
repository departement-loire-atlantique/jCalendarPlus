<%@ include file='/jcore/doInitPage.jspf' %>
<%@ page import="com.jalios.jcms.calendar.*" %>
<%@ page import="com.jalios.jcmsplugin.calendar.*" %>
<%@ include file='/jcore/portal/doPortletParams.jspf' %>

<%@page import="com.jalios.util.Util"%>
<%@page import="org.owasp.esapi.tags.EncodeForHTMLAttributeTag"%>
<%@page import="com.jalios.jcmsplugin.calendar.external.ExternalCalendarEvent"%>
<%@page import="com.jalios.jcms.TypeEntry"%><%
%><%@page import="generated.CalendarEvent"%><%
%><%@page import="com.jalios.util.DateUtil"%><%
%><%@ page import="com.jalios.jcms.calendar.*" %><%
%><%@ page import="com.jalios.jcmsplugin.calendar.*" %>

<% String calendarView = "Diary"; 
  String displayFilter = getUntrustedStringParameter(CalendarUtil.DISPLAY_FILTER_ATTRIBUTE, null); 
  String includeMySchedule = getAlphaNumParameter(CalendarUtil.DISPLAY_FILTER_ADD_SCHEDULE, null);
  String displayTextFilter = getUntrustedStringParameter(CalendarUtil.DISPLAY_FILTER_TEXT, null);%>
<%@ include file='/types/PortletCalendar/doPortletCalendarCommon.jspf' %>
<% 
Date startDateSearch = new Date();
Date endDateSearch = new Date(startDateSearch.getTime() + 3 * JaliosConstants.MILLIS_IN_ONE_YEAR);
Set<CalendarEventInterface> tmpEventSet = CalendarUtil.getCalendarEventSet(loggedMember, loggedMember,startDateSearch, endDateSearch );
TreeSet<CalendarEventInterface> eventSet = new TreeSet<CalendarEventInterface>(CalendarUtil.getStartDateComparator());
if(Util.notEmpty(tmpEventSet)){
	eventSet.addAll(tmpEventSet);     
	CalendarUtil.manageDummyPeriodicalEvent(startDateSearch, endDateSearch,eventSet, userLocale);
}
PortalElement fullDisplayPortletCalendar = box.getFullDisplayCalendar();
if( fullDisplayPortletCalendar == null){
  fullDisplayPortletCalendar = box;
}
%>





<%
int dayNbr = 0;
boolean canEdit = loggedMember != null && channel.isDataWriteEnabled();

Set<Class<?>> classesSet = CalendarUtil.getAbstractCalendarClasses((PortletCalendar) portlet, canEdit, loggedMember, workspace);
canEdit &= !classesSet.isEmpty();
boolean isMultipleCalendarEventType = (!Util.isEmpty(classesSet)) && classesSet.size() > 1;
boolean isOtherCalendarEventType = !classesSet.contains(CalendarEvent.class);
boolean isCalendarEventType = classesSet.contains(CalendarEvent.class);

// Get the Ctx Menu Unique ID, if not exists default is 1
int ctxMenuUniqueId = Util.toInt(request.getAttribute("ctxMenuUniqueId"), new Random().nextInt());
String ctxMenuClassID = "AddCtxDiaryMenu" + ctxMenuUniqueId;
// Store the ctx menu ID to use in doMultipleCalendarCtxMenu.jspf
request.setAttribute("ctxMenuId", ctxMenuClassID);
%>
<input type='hidden' class='portletId' value='<%= box.getId()%>'/>
<div class="diary-court">
  <% if (Util.isEmpty(eventSet)) { %>
    <p class="no-event"><%= glp("jcmsplugin.calendar.no-event") %></p>
  <% } else {
       Date currDate = null; 
       boolean isOneEvent = false;
%>

<jalios:foreach collection="<%= eventSet %>"  name="event"  type="CalendarEventInterface" max="5">
        <%       
          CalendarEventInterface parentCalendarEvent = event;
          if(((Data)event).getId() == null){
            parentCalendarEvent = (CalendarEventInterface) ((Data)event).getExtraInfo(CalendarUtil.PERIODIC_PARENT);
          }
          Set<Member> declinedMbrSet = CalendarUtil.getDeclinedAttendees(event);
          if(!(loggedMember != null && Util.notEmpty(declinedMbrSet) && declinedMbrSet.contains(loggedMember))){
              isOneEvent = true;
              request.setAttribute(CalendarUtil.EVENT_ATTRIBUTE, parentCalendarEvent);
              
              boolean isPeriodical = CalendarUtil.isPeriodicEvent((CalendarEventInterface)event);
              isPeriodical &= Util.isEmpty(((Data)event).getId()); 
              Date startDate = event.getStartDate(); 
              Date dayStartDate = CalendarUtil.getDayStartDate(startDate);
              String eventsClass = "Events Events__"+dayStartDate.getTime(); 
              String style ="";  
          
                  
              %>
   
                                   
             <div class="<%=eventsClass %>">
                <div class="day">
                  
                   <jalios:select>
	                   <jalios:if predicate="<%= startDate.after(new Date()) %>">   
		                  <div class="jour">
		                     <jalios:date date='<%= startDate %>' format="dd" />
		                  </div>
		                 
		                  <div class="mois">
		                     <jalios:date date='<%= startDate %>' format="MMM" />    
		                  </div>
	                   </jalios:if>
		                  
		               
		               <jalios:default>
		                  <div class="jour">
		                     <jalios:date date='<%= new Date() %>' format="dd" />
		                  </div>
		                  
		                  <div class="mois">
		                     <jalios:date date='<%= new Date() %>' format="MMM" />    
		                  </div>
		               </jalios:default>
                   </jalios:select>
                  
                  
                </div>
                
                
                <div class="item-box-event">             
	                <div class="event-container" style="<%=style%>">	                 
		                <span class="event">
		                  <%		                    
		                    String[] paramNames = {"eventStartDate"};
		                    String[] paramRemove = {"portlet"};
		                    String startLong = Long.toString(startDate.getTime());
		                    String[] paramValues = { startLong };		                    
		                  %> 
		                  <jalios:link data="<%= (Data)parentCalendarEvent %>" paramNames="<%=paramNames%>" paramValues="<%=paramValues%>" paramRemove="<%=paramRemove %>"  />
		                </span>          		                 
	                </div>                    
                </div>
                
            </div>
           <%
     }
%></jalios:foreach>


<%
  ServletUtil.restoreAttribute(pageContext, CalendarUtil.EVENT_ATTRIBUTE);   
    }
%>

</div>

<%-- Add a contextual menu if there are multiple calendar event types --%>
<%@ include file='/types/PortletCalendar/doMultipleCalendarCtxMenu.jspf' %>

<%-- Increment the Ctx Menu Unique ID, if not exists default is 1 --%>
<% request.setAttribute("ctxMenuUniqueId", ctxMenuUniqueId + 1); %>

