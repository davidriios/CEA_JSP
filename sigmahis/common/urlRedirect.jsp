<%@ page import="java.util.Enumeration" %>
<%@ page import="issi.admin.IBIZEscapeChars"%>
<jsp:useBean id="_urlInfo" scope="session" class="java.util.Hashtable" />
<%
String fromPage = request.getParameter("fromPage");
String toPage = request.getParameter("toPage");
String forwardPage = request.getParameter("forwardPage");
request.setCharacterEncoding("UTF-8");
if (forwardPage != null) { %>
<jsp:forward page="<%=forwardPage%>" />
<% }
if (fromPage == null || toPage == null) throw new Exception("Origen o Destino no válido. Por favor intente nuevamente!");

Enumeration param = request.getParameterNames();
String url = toPage;
String urlParam = ""+Math.random();

while (param.hasMoreElements())
{
	String paramValue = (String) param.nextElement();
	if (!paramValue.equals("fromPage") && !paramValue.equals("toPage"))
	{
		if (!urlParam.equals("")) urlParam += "&";
		urlParam += paramValue+"="+IBIZEscapeChars.forURL(request.getParameter(paramValue));

	}
}

if (!urlParam.equals("")) url += "?"+urlParam;

_urlInfo.put(toPage, url);
//System.out.println("***************** session URL INFO ["+toPage+"] = "+((Hashtable) session.getAttribute("_urlInfo")).get(toPage));
response.sendRedirect(url);
%>
