<%@ include file='/jcore/doInitPage.jspf' %><%--  
--%><%@page import="com.jalios.jcmsplugin.calendar.CalendarUtil"%><%--
--%><%@page import="com.jalios.jcms.portlet.PortalManager"%><%--
--%><%@ page import="com.jalios.jcms.calendar.*" %><%--  
--%><%@ page import="com.jalios.jcmsplugin.calendar.*" %><%--  
--%><%@page import="com.jalios.jcmsplugin.calendar.PortletCalendarHandler"%><%--  
--%><%
  if (!isLogged) {
    return;
  }

  Portlet portlet = channel.getData(Portlet.class, InitPluginChannelListener.SIDEBAR_PORTLET_VIRTUAL_ID);
  if (portlet == null){
    return;
  }
  
  Calendar startCalendar = Calendar.getInstance();
  startCalendar.setTime(DateUtil.getDayStartDate(new Date(), userLocale));
  startCalendar.set(Calendar.HOUR_OF_DAY, ((PortletCalendar) portlet).getDayStartHour());
  // start on first work day 
  startCalendar.getTime(); //in order to compute correctly internals fields
  if(CalendarUtil.isWeekEndDay(startCalendar.getTime(), userLocale)){
    // if current date if in week-end,go to first work day after that
    while(CalendarUtil.isWeekEndDay(startCalendar.getTime(), userLocale)){
      startCalendar.add(Calendar.DATE, 1);
    }  
  }else{
    // if currentdate is not in a week-end, go to first wrok day after to previous week-end
	  while(!(CalendarUtil.isWeekEndDay(startCalendar.getTime(), userLocale))){
	    startCalendar.add(Calendar.DATE, -1);
	  }
    startCalendar.add(Calendar.DATE, 1);
  }
  String[] names= {"portlet",PortalManager.getActionParam(portlet, PortletCalendarHandler.CAL_DATE), PortalManager.getActionParam(portlet, PortletCalendarHandler.CAL_MODE), PortalManager.getActionParam(portlet, PortletCalendarHandler.CAL_DAY_NUMBER), CalendarUtil.DISPLAY_FILTER_ATTRIBUTE, CalendarUtil.DISPLAY_FILTER_ADD_SCHEDULE, "portal"};
  String[] values = {portlet.getId(), Long.toString(startCalendar.getTimeInMillis()) ,PortletCalendarHandler.WORK_WEEK_MODE_STR, "5", CalendarUtil.DISPLAY_MY_EVENTS, "on", PortalManager.getDefaultPortal().getId()};
  String fullDisplayPath = ServletUtil.getUrlWithUpdatedParams(ServletUtil.getBaseUrl(request), ServletUtil.getOrderedParameterMap(request) , names, values, new String[] {"jsp"}, false);
%>
<a class="sidebar-menu-item list-group-item" href="<%=encodeForHTMLAttribute(fullDisplayPath)%>">
<jalios:icon src="calendar" /> <%= glp("jcmsplugin.calendar.my-agenda") %>
</a>
